#!/bin/bash

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

# Re-pack an EC capsule with a different `76EC_VERSION=` string in its payload.
# Only that string is changed (in place, padded with NULs). Header fields
# (FwVersion, LowestSupportedVersion, GUID, ...) and embedded drivers are
# taken from the input capsule. The EC FMP driver doesn't compare the string
# with the header, so the capsule gets installed and the new string can be
# read back from the EC to confirm the update.
#
# NOTE: the capsule is re-signed with the EDK2 *testing* keys, so the result
# is only accepted by firmware built with testing keys.

set -euo pipefail

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: $0 <ec_capsule> <new_76ec_version> [output]"
    echo "  e.g. $0 ec.cap 2099-12-31_deadbee"
    exit 1
fi

capsule=$(realpath "$1")
ec_version=$2
output=$(realpath -m "ec_ver.cap")

if ! [[ "$ec_version" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}_ ]]; then
    echo "WARNING: '$ec_version' isn't YYYY-MM-DD_<hash>; coreboot won't" \
         "publish EC firmware info (ESRT entry) after the update" >&2
fi

mkdir -p dl-cache
cd dl-cache
if [ ! -d "./edk2" ]; then
    git clone --depth 1 --branch capsules-v2 https://github.com/Dasharo/edk2.git
fi
cd edk2

GEN_CAPSULE="BaseTools/BinWrappers/PosixLike/GenerateCapsule"
SIGN_CERT="BaseTools/Source/Python/Pkcs7Sign/TestCert.pem"
SUB_CERT="BaseTools/Source/Python/Pkcs7Sign/TestSub.pub.pem"
ROOT_CERT="BaseTools/Source/Python/Pkcs7Sign/TestRoot.pub.pem"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

is_capsule() {
    $GEN_CAPSULE --decode "$1" --output "$work/probe" &>/dev/null
}

# Replace the first `76EC_VERSION=<value>\0` in the file, in place. The new
# value can't be longer than the old one and is padded with NULs, so the ROM
# size and layout don't change.
patch_ec_version() {
    python3 - "$1" "$ec_version" <<'EOF'
import sys
path, new = sys.argv[1], sys.argv[2].encode()
key = b"76EC_VERSION="
data = bytearray(open(path, "rb").read())
start = data.find(key)
if start < 0:
    sys.exit(f"'{key.decode()}' not found in payload, is this an EC capsule?")
if data.count(key) > 1:
    print("WARNING: multiple 76EC_VERSION strings, patching the first one",
          file=sys.stderr)
start += len(key)
end = data.index(0, start)
old = bytes(data[start:end])
if len(new) > len(old):
    sys.exit(f"New version '{new.decode()}' is longer than the old one "
             f"'{old.decode()}' ({len(new)} > {len(old)} bytes)")
data[start:end] = new + b"\0" * (len(old) - len(new))
open(path, "wb").write(data)
print(f"76EC_VERSION: {old.decode()} -> {new.decode()}")
EOF
}

# Take the JSON produced by --decode, add signing certificates and encode it.
re_encode() {
    local decoded_json="$1"
    local out_cap="$2"
    local json="${decoded_json%.json}_new.json"

    jq --arg s "$SIGN_CERT" --arg o "$SUB_CERT" --arg r "$ROOT_CERT" '
        .Payloads[0] += {
            OpenSslSignerPrivateCertFile: $s,
            OpenSslOtherPublicCertFile:   $o,
            OpenSslTrustedPublicCertFile: $r
        }' "$decoded_json" > "$json"

    $GEN_CAPSULE --encode --capflag PersistAcrossReset \
        --json-file "$json" --output "$out_cap"
}

echo "--- DECODING CAPSULE ---"
$GEN_CAPSULE --decode "$capsule" --output "$work/outer"
outer_payload=$(jq -r '.Payloads[0].Payload' "$work/outer.json")

if is_capsule "$outer_payload"; then
    echo "Capsule V2 mode (nested capsules)"
    $GEN_CAPSULE --decode "$outer_payload" --output "$work/inner"
    patch_ec_version "$(jq -r '.Payloads[0].Payload' "$work/inner.json")"
    re_encode "$work/inner.json" "$work/inner_new.cap"

    # Point the outer capsule at the rebuilt inner one
    jq --arg p "$work/inner_new.cap" '.Payloads[0].Payload = $p' \
        "$work/outer.json" > "$work/outer_patched.json"
    re_encode "$work/outer_patched.json" "$output"
else
    echo "Legacy capsule mode"
    patch_ec_version "$outer_payload"
    re_encode "$work/outer.json" "$output"
fi

echo "Output file: $output"
