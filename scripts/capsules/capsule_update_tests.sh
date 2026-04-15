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



decode_capsule() {
    local filename="$1"
    local output_prefix="$2"
    local -n _result="$3"

    rm -f "${output_prefix}"*
    $GEN_CAPSULE --decode "$filename" --output "$output_prefix"

    local json_file="${output_prefix}.json"
    _result["json"]="$json_file"
    _result["dependencies"]=$(jq -r '.Payloads[0].Dependencies' "$json_file")
    _result["fw_version"]=$(jq -r '.Payloads[0].FwVersion' "$json_file")
    _result["guid"]=$(jq -r '.Payloads[0].Guid' "$json_file")
    _result["hardware_instance"]=$(jq -r '.Payloads[0].HardwareInstance' "$json_file")
    _result["lowest_supported_version"]=$(jq -r '.Payloads[0].LowestSupportedVersion' "$json_file")
    _result["monotonic_count"]=$(jq -r '.Payloads[0].MonotonicCount' "$json_file")
    _result["payload"]=$(jq -r '.Payloads[0].Payload' "$json_file")
    _result["update_image_index"]=$(jq -r '.Payloads[0].UpdateImageIndex' "$json_file")

    # Note: works for up to 9 drivers; alphabetical ordering may mix order beyond that
    local drivers
    drivers=$(for f in "${output_prefix}".EmbeddedDriver*; do
        [ -f "$f" ] || continue
        printf '        {\n            "Driver": "%s"\n        },\n' "$f"
    done | sed '$s/,$//')
    _result["drivers"]="$drivers"
}

is_capsule() {
    local cap="$1"
    local tmp="/tmp/check_is_capsule"

    if $GEN_CAPSULE --decode "$cap" --output "$tmp" &>/dev/null; then
        rm -f "${tmp}"*
        echo true
    else
        rm -f "${tmp}"*
        echo false
    fi
}

build_capsule() {
    local json_out="$1"
    local cap_out="$2"
    local -n json_data="$3"

    cat > "$json_out" <<EOF
{
  "EmbeddedDrivers": [
${json_data["drivers"]}
  ],
  "Payloads": [
    {
      "Payload": "${json_data["payload"]}",
      "Guid": "${json_data["guid"]}",
      "FwVersion": "${json_data["fw_version"]}",
      "LowestSupportedVersion": "${json_data["lowest_supported_version"]}",
      "OpenSslSignerPrivateCertFile": "${json_data["sign_cert"]}",
      "OpenSslOtherPublicCertFile": "${json_data["sub_cert"]}",
      "OpenSslTrustedPublicCertFile": "${json_data["root_cert"]}"
    }
  ]
}
EOF

    $GEN_CAPSULE --encode \
        --capflag PersistAcrossReset \
        --json-file "$json_out" \
        --output "$cap_out"
}

assemble_capsule() {
    local inner_cap="$1"
    local final_cap="$2"

    if [ "$is_v2" -eq 1 ]; then
        outer["payload"]="$inner_cap"
        outer["sign_cert"]="$TESTING_SIGN_CERT"
        outer["sub_cert"]="$TESTING_SUB_CERT"
        outer["root_cert"]="$TESTING_ROOT_CERT"
        build_capsule "${final_cap%.cap}_outer.json" "$final_cap" outer
    else
        mv "$inner_cap" "$final_cap"
    fi
}



rm -rf decoded* "${capsule_name}"*.json "${capsule_name}"*.cap

echo "--- DECODING CAPSULE ---"
declare -A outer
decode_capsule "$capsule" "decoded" outer

echo "FwVersion: ${outer["fw_version"]}"
echo "Guid:      ${outer["guid"]}"

is_v2=0
declare -A inner

if [ "$(is_capsule "${outer["payload"]}")" = "true" ]; then
    echo "Capsule V2 mode (nested capsules)"
    is_v2=1

    echo "--- DECODING INNER CAPSULE ---"
    decode_capsule "${outer["payload"]}" "decoded_inner" inner

    echo "--- INNER CAPSULE DATA ---"
    echo "FwVersion: ${inner["fw_version"]}"
    echo "Guid:      ${inner["guid"]}"
else
    echo "Legacy capsule mode"
    # For V1 capsules the outer IS the inner
    for key in "${!outer[@]}"; do
        inner["$key"]="${outer[$key]}"
    done
fi



echo "--- CREATING CAPSULE WITH WRONG CERTIFICATES ---"

inner["sign_cert"]="$here/sign.p12"
inner["sub_cert"]="$here/sub.pub.pem"
inner["root_cert"]="$here/root.pub.pem"

inner_wrong_cert="${capsule_name}_wrong_cert_inner.cap"
output_wrong_cert="${capsule_name}_wrong_cert.cap"

build_capsule "${capsule_name}_wrong_cert.json" "$inner_wrong_cert" inner
assemble_capsule "$inner_wrong_cert" "$output_wrong_cert"
echo "Output file: $output_wrong_cert"

echo "--- CREATING CAPSULE WITH WRONG GUID ---"

inner["guid"]="11111111-2222-3333-4444-abcdefabcdef"
inner["sign_cert"]="$TESTING_SIGN_CERT"
inner["sub_cert"]="$TESTING_SUB_CERT"
inner["root_cert"]="$TESTING_ROOT_CERT"

inner_invalid_guid="${capsule_name}_invalid_guid_inner.cap"
output_invalid_guid="${capsule_name}_invalid_guid.cap"

build_capsule "${capsule_name}_invalid_guid.json" "$inner_invalid_guid" inner
assemble_capsule "$inner_invalid_guid" "$output_invalid_guid"
echo "Output file: $output_invalid_guid"
