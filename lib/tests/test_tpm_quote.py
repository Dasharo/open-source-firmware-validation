# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Tests lib/tpm_quote.py on synthetic quotes, marshalled as
tpm2_quote writes them and signed with a P-256 key standing in for the AK.
Each tampering must fail the check.

Run with: python -m pytest lib/tests
"""

import hashlib
import os
import struct
import sys

import pytest
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.asymmetric import utils as ec_utils

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import tpm_quote as tq  # noqa: E402

NONCE = bytes(range(32))
PCRS = {
    17: hashlib.sha384(b"pcr 17").hexdigest(),
    18: hashlib.sha384(b"pcr 18").hexdigest(),
}
SHA256, SHA384 = 0x000B, 0x000C


def tpm2b(data):
    return struct.pack(">H", len(data)) + data


def attest(
    nonce=NONCE,
    pcrs=PCRS,
    bank=SHA384,
    magic=tq.TPM_GENERATED_VALUE,
    kind=tq.TPM_ST_ATTEST_QUOTE,
):
    mask = bytearray(3)
    for index in pcrs:
        mask[index // 8] |= 1 << (index % 8)
    digest = hashlib.sha256(
        b"".join(bytes.fromhex(pcrs[i]) for i in sorted(pcrs))
    ).digest()
    return (
        struct.pack(">IH", magic, kind)
        + tpm2b(b"\x00\x0b" + bytes(32))
        + tpm2b(nonce)
        + struct.pack(">QIIB", 123456, 3, 0, 1)
        + struct.pack(">Q", 0x2001_0000)
        + struct.pack(">I", 1)
        + struct.pack(">HB", bank, 3)
        + bytes(mask)
        + tpm2b(digest)
    )


def sign(key, message):
    r, s = ec_utils.decode_dss_signature(key.sign(message, ec.ECDSA(hashes.SHA256())))
    return (
        struct.pack(">HH", tq.TPM_ALG_ECDSA, SHA256)
        + tpm2b(r.to_bytes(32, "big"))
        + tpm2b(s.to_bytes(32, "big"))
    )


def pem(key):
    return key.public_key().public_bytes(
        serialization.Encoding.PEM, serialization.PublicFormat.SubjectPublicKeyInfo
    )


@pytest.fixture
def ak():
    return ec.generate_private_key(ec.SECP256R1())


def check(ak, message, signature=None, key=None, nonce=NONCE, pcrs=PCRS, bank="sha384"):
    signature = sign(ak, message) if signature is None else signature
    return tq.quote_should_verify_with_ak(
        message.hex(),
        signature.hex(),
        pem(key or ak).hex(),
        nonce.hex(),
        bank,
        {str(i): v for i, v in pcrs.items()},
    )


def test_quote_verifies(ak):
    assert "ECDSA-sha256 quote over sha384:17,18" in check(ak, attest())


def test_other_key_fails(ak):
    with pytest.raises(AssertionError, match="does not verify"):
        check(ak, attest(), key=ec.generate_private_key(ec.SECP256R1()))


def test_tampered_quote_fails(ak):
    message = attest()
    signature = sign(ak, message)
    tampered = message[:-1] + bytes([message[-1] ^ 1])
    with pytest.raises(AssertionError, match="does not verify"):
        check(ak, tampered, signature=signature)


def test_old_nonce_fails(ak):
    with pytest.raises(AssertionError, match="not fresh"):
        check(ak, attest(nonce=bytes(32)))


def test_other_pcr_values_fail(ak):
    other = {**PCRS, 18: hashlib.sha384(b"other").hexdigest()}
    with pytest.raises(AssertionError, match="covers other values"):
        check(ak, attest(), pcrs=other)


def test_other_bank_fails(ak):
    with pytest.raises(AssertionError, match="selects sha256:17,18"):
        check(ak, attest(bank=SHA256))


def test_other_pcr_selection_fails(ak):
    with pytest.raises(AssertionError, match="selects sha384:17, expected"):
        check(ak, attest(pcrs={17: PCRS[17]}))


def test_not_tpm_generated_fails(ak):
    with pytest.raises(AssertionError, match="not TPM_GENERATED_VALUE"):
        check(ak, attest(magic=0))


def test_not_a_quote_fails(ak):
    with pytest.raises(AssertionError, match="not TPM_ST_ATTEST_QUOTE"):
        check(ak, attest(kind=0x8017))


def test_truncated_quote_fails(ak):
    with pytest.raises(AssertionError, match="more needed"):
        check(ak, attest()[:-4])
