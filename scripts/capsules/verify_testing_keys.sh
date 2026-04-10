#!/bin/bash

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0
CAPSULE="$1"
GEN_CAPSULE="dl-cache/edk2/BaseTools/BinWrappers/PosixLike/GenerateCapsule"
EDK2_CERTS="dl-cache/edk2/BaseTools/Source/Python/Pkcs7Sign"

# --decode always verifies the signatures
# continues to decode even if verification fails
out=$($GEN_CAPSULE --decode "$CAPSULE" \
    --signer-private-cert "$EDK2_CERTS/TestCert.pem" \
    --other-public-cert   "$EDK2_CERTS/TestSub.pub.pem" \
    --trusted-public-cert "$EDK2_CERTS/TestRoot.pub.pem" \
    --output /tmp/cap_verify 2>&1); rc=$?

if [ $rc -eq 0 ] && ! echo "$out" | grep -q "error:"; then
    # If decode succeeded and no errors in output then its verified correctly
    exit 0
elif echo "$out" | grep -q "unable to get local issuer certificate"; then
    # Couldn't build the trust chain, verification has failed
    exit 1
elif echo "$out" | grep -q "certificate has expired"; then
    # The trust chain could be established, but the certs are expired
    # That's the case for the testing keys in EDK2
    # as of 4328cc962c63 (Sep 28 2025)
    exit 0
else
    # Unknown issue
    echo "$out"
    exit 2
fi
