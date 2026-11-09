# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Checks a TPM 2.0 quote off the device, for WTD011.001 of trenchboot/.

tpm2_quote writes the TPMS_ATTEST the TPM signed (-m) and its TPMT_SIGNATURE
(-s, the default tss format), and tpm2_createak the AK's public key as PEM
(-f pem). The suite reads them with xxd -p and hands the hex here, with the
nonce the runner chose and the PCR values the OS reads from sysfs. The quote
verifies when the AK's signature covers the TPMS_ATTEST, the TPMS_ATTEST is a
quote that answers the nonce, and its PCR digest is the hash of those PCR
values. TPM 2.0 Library Part 2, 10.12 (TPMS_ATTEST), 11.3 (TPMT_SIGNATURE).
"""

import hashlib
import struct

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec, padding, rsa
from cryptography.hazmat.primitives.asymmetric import utils as ec_utils

TPM_GENERATED_VALUE = 0xFF544347
TPM_ST_ATTEST_QUOTE = 0x8018
TPM_ALG_RSASSA = 0x0014
TPM_ALG_ECDSA = 0x0018

# TPM_ALG_ID of each hash, its hashlib and cryptography names.
HASH_ALGS = {
    0x0004: ("sha1", hashes.SHA1),
    0x000B: ("sha256", hashes.SHA256),
    0x000C: ("sha384", hashes.SHA384),
    0x000D: ("sha512", hashes.SHA512),
}
HASH_IDS = {name: alg for alg, (name, _) in HASH_ALGS.items()}


class _Reader:
    """Reads the big-endian TPM marshalling of a byte string."""

    def __init__(self, data, what):
        self.data = data
        self.offset = 0
        self.what = what

    def take(self, size):
        if self.offset + size > len(self.data):
            raise AssertionError(
                f"The {self.what} ends at byte {len(self.data)}, {size} more needed at {self.offset}"
            )
        part = self.data[self.offset : self.offset + size]
        self.offset += size
        return part

    def uint(self, size):
        return int.from_bytes(self.take(size), "big")

    def tpm2b(self):
        return self.take(self.uint(2))

    def done(self):
        if self.offset != len(self.data):
            raise AssertionError(
                f"The {self.what} has {len(self.data) - self.offset} B after its end"
            )


def _bytes(hex_dump, what):
    text = "".join(hex_dump.split())
    try:
        return bytes.fromhex(text)
    except ValueError:
        raise AssertionError(
            f"The {what} is not a hex dump: {hex_dump[:80]!r}"
        ) from None


def parse_attest(attest):
    """Returns the fields of a TPMS_ATTEST holding a TPMS_QUOTE_INFO."""
    r = _Reader(attest, "TPMS_ATTEST")
    magic = r.uint(4)
    if magic != TPM_GENERATED_VALUE:
        raise AssertionError(
            f"The TPMS_ATTEST magic is {magic:#010x}, not TPM_GENERATED_VALUE: the TPM did not make it"
        )
    kind = r.uint(2)
    if kind != TPM_ST_ATTEST_QUOTE:
        raise AssertionError(
            f"The TPMS_ATTEST type is {kind:#06x}, not TPM_ST_ATTEST_QUOTE"
        )
    quote = {"signer": r.tpm2b(), "extra": r.tpm2b()}
    quote["clock"], quote["reset_count"], quote["restart_count"], quote["safe"] = (
        struct.unpack(">QIIB", r.take(17))
    )
    quote["firmware"] = r.uint(8)
    selections = []
    for _ in range(r.uint(4)):
        alg = r.uint(2)
        mask = r.take(r.uint(1))
        pcrs = [
            byte * 8 + bit
            for byte, bits in enumerate(mask)
            for bit in range(8)
            if bits & (1 << bit)
        ]
        selections.append((alg, pcrs))
    quote["selections"] = selections
    quote["pcr_digest"] = r.tpm2b()
    r.done()
    return quote


def parse_signature(signature):
    """Returns (signature algorithm, hash algorithm, signature fields) of a
    TPMT_SIGNATURE."""
    r = _Reader(signature, "TPMT_SIGNATURE")
    sig_alg, hash_alg = r.uint(2), r.uint(2)
    if sig_alg == TPM_ALG_ECDSA:
        fields = (r.tpm2b(), r.tpm2b())
    elif sig_alg == TPM_ALG_RSASSA:
        fields = (r.tpm2b(),)
    else:
        raise AssertionError(
            f"The quote's signature scheme is {sig_alg:#06x}, not ECDSA or RSASSA"
        )
    r.done()
    if hash_alg not in HASH_ALGS:
        raise AssertionError(
            f"The quote's signature hash is {hash_alg:#06x}, not a SHA hash"
        )
    return sig_alg, hash_alg, fields


def _verify(key, sig_alg, hash_alg, fields, attest):
    hash_type = HASH_ALGS[hash_alg][1]
    try:
        if sig_alg == TPM_ALG_ECDSA:
            if not isinstance(key, ec.EllipticCurvePublicKey):
                raise AssertionError(
                    "The quote has an ECDSA signature, the AK is not an EC key"
                )
            der = ec_utils.encode_dss_signature(
                int.from_bytes(fields[0], "big"), int.from_bytes(fields[1], "big")
            )
            key.verify(der, attest, ec.ECDSA(hash_type()))
        else:
            if not isinstance(key, rsa.RSAPublicKey):
                raise AssertionError(
                    "The quote has an RSASSA signature, the AK is not an RSA key"
                )
            key.verify(fields[0], attest, padding.PKCS1v15(), hash_type())
    except InvalidSignature:
        raise AssertionError(
            "The quote's signature does not verify with the AK"
        ) from None


def quote_should_verify_with_ak(
    attest_hex, signature_hex, ak_pem_hex, nonce_hex, bank, pcr_values
):
    """Fails when the quote does not verify with the AK, does not answer the
    nonce, selects other PCRs than ${pcr_values} in ${bank}, or its PCR digest
    is not the hash of their values. ${pcr_values} maps each PCR index to its
    hex value, as the OS reads it. Returns a summary."""
    attest = _bytes(attest_hex, "TPMS_ATTEST")
    signature = _bytes(signature_hex, "TPMT_SIGNATURE")
    nonce = _bytes(nonce_hex, "nonce")
    try:
        key = serialization.load_pem_public_key(_bytes(ak_pem_hex, "AK PEM"))
    except ValueError as error:
        raise AssertionError(f"The AK is not a PEM public key: {error}") from None
    sig_alg, hash_alg, fields = parse_signature(signature)
    _verify(key, sig_alg, hash_alg, fields, attest)

    quote = parse_attest(attest)
    if quote["extra"] != nonce:
        raise AssertionError(
            f"The quote's qualifying data is {quote['extra'].hex()}, the nonce was {nonce.hex()}: the quote is not fresh"
        )
    if bank not in HASH_IDS:
        raise AssertionError(f"Unknown PCR bank {bank}")
    pcrs = sorted(int(index) for index in pcr_values)
    wanted = [(HASH_IDS[bank], pcrs)]
    got = [(alg, sorted(selected)) for alg, selected in quote["selections"] if selected]
    if got != wanted:
        shown = (
            ", ".join(
                f"{HASH_ALGS.get(a, (hex(a),))[0]}:{','.join(map(str, p))}"
                for a, p in got
            )
            or "none"
        )
        raise AssertionError(
            f"The quote selects {shown}, expected {bank}:{','.join(map(str, pcrs))}"
        )
    values = {
        int(index): _bytes(value, f"PCR {index} value")
        for index, value in pcr_values.items()
    }
    expected = hashlib.new(
        HASH_ALGS[hash_alg][0], b"".join(values[i] for i in pcrs)
    ).digest()
    if quote["pcr_digest"] != expected:
        raise AssertionError(
            f"The quote's PCR digest is {quote['pcr_digest'].hex()}, the PCR values the OS reads give "
            f"{expected.hex()}: the quote covers other values"
        )
    return (
        f"{'ECDSA' if sig_alg == TPM_ALG_ECDSA else 'RSASSA'}-{HASH_ALGS[hash_alg][0]} quote over "
        f"{bank}:{','.join(map(str, pcrs))}, resetCount {quote['reset_count']}, "
        f"restartCount {quote['restart_count']}, clock {quote['clock']} ms"
    )
