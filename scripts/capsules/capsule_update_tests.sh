#!/bin/bash

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

here=$(realpath "$(dirname "$0")")

if [ $# -ne 1 ]; then
    echo "Usage: $0 <capsule>"
    exit 1
fi

capsule=$(realpath "$1")
capsule_name=$(basename "$capsule")
capsule_name="${capsule_name%.*}"

mkdir -p dl-cache
cd dl-cache

if [ ! -d "./edk2" ]; then
    git clone --depth 1 --branch capsules-v2 https://github.com/Dasharo/edk2.git
fi

cd edk2

GEN_CAPSULE="BaseTools/BinWrappers/PosixLike/GenerateCapsule"
TESTING_ROOT_CERT="BaseTools/Source/Python/Pkcs7Sign/TestRoot.pub.pem"
TESTING_SUB_CERT="BaseTools/Source/Python/Pkcs7Sign/TestSub.pub.pem"
TESTING_SIGN_CERT="BaseTools/Source/Python/Pkcs7Sign/TestCert.pem"

# Cleanup
rm -rf decoded* "${capsule_name}"*.json "${capsule_name}"*.cap

echo "--- DECODING CAPSULE ---"

# Decode outer
$GEN_CAPSULE --decode "$capsule" --output decoded

nested=0
out_prefix="decoded"
json_file="decoded.json"

# Detect V2 capsule via env or structure
if [[ -n "${CAPSULE_UPDATE_V2:-}" ]]; then
    echo "Capsule V2 mode (nested capsules)"
    nested=1

    outer_json="$json_file"

    #outer_dependencies=$(jq -r '.Payloads[0].Dependencies' "$outer_json")
    outer_fw_version=$(jq -r '.Payloads[0].FwVersion' "$outer_json")
    outer_guid=$(jq -r '.Payloads[0].Guid' "$outer_json")
    #outer_hardware_instance=$(jq -r '.Payloads[0].HardwareInstance' "$outer_json")
    outer_lowest_supported_version=$(jq -r '.Payloads[0].LowestSupportedVersion' "$outer_json")
    #outer_monotonic_count=$(jq -r '.Payloads[0].MonotonicCount' "$outer_json")
    outer_payload=$(jq -r '.Payloads[0].Payload' "$outer_json")
    #outer_update_image_index=$(jq -r '.Payloads[0].UpdateImageIndex' "$outer_json")

    # Collect outer drivers
    outer_drivers=$(for f in decoded.EmbeddedDriver*; do
        [ -f "$f" ] || continue
        printf '        {\n            "Driver": "%s"\n        },\n' "$f"
    done | sed '$s/,$//')

    echo "--- DECODING INNER CAPSULE ---"
    $GEN_CAPSULE --decode "$outer_payload" --output decoded_inner

    out_prefix="decoded_inner"
    json_file="decoded_inner.json"
else
    echo "Legacy capsule mode"
fi

# Extract inner (or single) capsule data
#dependencies=$(jq -r '.Payloads[0].Dependencies' "$json_file")
fw_version=$(jq -r '.Payloads[0].FwVersion' "$json_file")
guid=$(jq -r '.Payloads[0].Guid' "$json_file")
#hardware_instance=$(jq -r '.Payloads[0].HardwareInstance' "$json_file")
lowest_supported_version=$(jq -r '.Payloads[0].LowestSupportedVersion' "$json_file")
#monotonic_count=$(jq -r '.Payloads[0].MonotonicCount' "$json_file")
payload=$(jq -r '.Payloads[0].Payload' "$json_file")
#update_image_index=$(jq -r '.Payloads[0].UpdateImageIndex' "$json_file")

echo "--- INNER CAPSULE DATA ---"
echo "Guid: $guid"
echo "FwVersion: $fw_version"
echo

# Collect drivers
drivers=$(for f in "${out_prefix}".EmbeddedDriver*; do
    [ -f "$f" ] || continue
    printf '        {\n            "Driver": "%s"\n        },\n' "$f"
done | sed '$s/,$//')

wrap_outer_if_needed() {
    local inner_cap=$1
    local final_cap=$2

    if [ "$nested" -eq 1 ]; then
        outer_json_file="${final_cap%.cap}_outer.json"

        cat > "$outer_json_file" <<EOF
{
  "EmbeddedDrivers": [
$outer_drivers
  ],
  "Payloads": [
    {
      "Payload": "$inner_cap",
      "Guid": "$outer_guid",
      "FwVersion": "$outer_fw_version",
      "LowestSupportedVersion": "$outer_lowest_supported_version",
      "OpenSslSignerPrivateCertFile": "$TESTING_SIGN_CERT",
      "OpenSslOtherPublicCertFile": "$TESTING_SUB_CERT",
      "OpenSslTrustedPublicCertFile": "$TESTING_ROOT_CERT"
    }
  ]
}
EOF

        $GEN_CAPSULE --encode \
            --capflag PersistAcrossReset \
            --json-file "$outer_json_file" \
            --output "$final_cap"
    else
        mv "$inner_cap" "$final_cap"
    fi
}

echo "--- CREATING CAPSULE WITH WRONG CERTIFICATES ---"

output_json="${capsule_name}_wrong_cert.json"
output_cap="${capsule_name}_wrong_cert.cap"

invalid_cert_file="$here/sign.p12"
invalid_sub_file="$here/sub.pub.pem"
invalid_root_file="$here/root.pub.pem"

# Inner capsule rebuilt with WRONG certs
cat > "$output_json" <<EOF
{
  "EmbeddedDrivers": [
$drivers
  ],
  "Payloads": [
    {
      "Payload": "$payload",
      "Guid": "$guid",
      "FwVersion": "$fw_version",
      "LowestSupportedVersion": "$lowest_supported_version",
      "OpenSslSignerPrivateCertFile": "$invalid_cert_file",
      "OpenSslOtherPublicCertFile": "$invalid_sub_file",
      "OpenSslTrustedPublicCertFile": "$invalid_root_file"
    }
  ]
}
EOF

inner_wrong_cap="${capsule_name}_wrong_cert_inner.cap"

$GEN_CAPSULE --encode \
    --capflag PersistAcrossReset \
    --json-file "$output_json" \
    --output "$inner_wrong_cap"

wrap_outer_if_needed "$inner_wrong_cap" "$output_cap"

echo "Output file: $output_cap"

echo "--- CREATING CAPSULE WITH WRONG GUID ---"

inner_json="${capsule_name}_invalid_guid_inner.json"
inner_cap="${capsule_name}_invalid_guid_inner.cap"
final_cap="${capsule_name}_invalid_guid.cap"

cat > "$inner_json" <<EOF
{
  "EmbeddedDrivers": [
$drivers
  ],
  "Payloads": [
    {
      "Payload": "$payload",
      "Guid": "11111111-2222-3333-4444-abcdefabcdef",
      "FwVersion": "$fw_version",
      "LowestSupportedVersion": "$lowest_supported_version",
      "OpenSslSignerPrivateCertFile": "$TESTING_SIGN_CERT",
      "OpenSslOtherPublicCertFile": "$TESTING_SUB_CERT",
      "OpenSslTrustedPublicCertFile": "$TESTING_ROOT_CERT"
    }
  ]
}
EOF

$GEN_CAPSULE --encode \
    --capflag PersistAcrossReset \
    --json-file "$inner_json" \
    --output "$inner_cap"

wrap_outer_if_needed "$inner_cap" "$final_cap"

echo "Output file: $final_cap"
