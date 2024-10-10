#!/bin/bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: MIT

here=$(realpath "$(dirname "$0")")

capsule=$(realpath "$1")
capsule_name=$(basename "$capsule")
capsule_name="${capsule_name%.*}"

cd dl-cache || exit
if [ ! -d "./edk2" ]; then
    git clone --depth 1 --branch osfv-capsule-tests https://github.com/Dasharo/edk2.git
fi

cd edk2 || exit

# Decoding the capsule
BaseTools/BinWrappers/PosixLike/GenerateCapsule \
    --decode "$capsule" \
    --output decoded

# Extracting data
json_file="decoded.json"

dependencies=$(jq -r '.Payloads[0].Dependencies' "$json_file")
fw_version=$(jq -r '.Payloads[0].FwVersion' "$json_file")
guid=$(jq -r '.Payloads[0].Guid' "$json_file")
hardware_instance=$(jq -r '.Payloads[0].HardwareInstance' "$json_file")
lowest_supported_version=$(jq -r '.Payloads[0].LowestSupportedVersion' "$json_file")
monotonic_count=$(jq -r '.Payloads[0].MonotonicCount' "$json_file")
payload=$(jq -r '.Payloads[0].Payload' "$json_file")
update_image_index=$(jq -r '.Payloads[0].UpdateImageIndex' "$json_file")

echo
echo "\"Dependencies\": \"$dependencies\""
echo "\"FwVersion\": \"$fw_version\""
echo "\"Guid\": \"$guid\""
echo "\"HardwareInstance\": \"$hardware_instance\""
echo "\"LowestSupportedVersion\": \"$lowest_supported_version\""
echo "\"MonotonicCount\": \"$monotonic_count\""
echo "\"Payload\": \"$payload\""
echo "\"UpdateImageIndex\": \"$update_image_index\""
echo

# Create json config files with capsule configs
echo "--- CREATING CAPSULE WITH MAX POSSIBLE VERSION NUMBER ---"

file_descriptor="_max_fw_ver"
output_file="$capsule_name$file_descriptor.json"

if [ -f $output_file ]; then
    rm $output_file
fi

# There might be an issue if more than one driver is present
content=$(cat <<EOF
{
  "EmbeddedDrivers": [
    {
      "Driver": "decoded.EmbeddedDriver.1.efi"
    }
  ],
  "Payloads": [
    {
      "Payload": "$payload",
      "Guid": "$guid",
      "FwVersion": "0x99999999",
      "LowestSupportedVersion": "$lowest_supported_version",
      "OpenSslSignerPrivateCertFile": "BaseTools/Source/Python/Pkcs7Sign/TestCert.pem",
      "OpenSslOtherPublicCertFile": "BaseTools/Source/Python/Pkcs7Sign/TestSub.pub.pem",
      "OpenSslTrustedPublicCertFile": "BaseTools/Source/Python/Pkcs7Sign/TestRoot.pub.pem"
    }
  ]
}
EOF
)

echo "$content" > "$output_file"

echo "Json file: $output_file"
echo "Output file: $capsule_name$file_descriptor.cap"

BaseTools/BinWrappers/PosixLike/GenerateCapsule --encode \
                                                --capflag PersistAcrossReset \
                                                --json-file $output_file \
                                                --output $capsule_name$file_descriptor.cap


echo "--- CREATING CAPSULE WITH WRONG CERTIFICATES ---"

file_descriptor="_wrong_cert"

output_file="$capsule_name$file_descriptor.json"

if [ -f $output_file ]; then
    rm $output_file
fi

invalid_cert_file="$here/sign.p12"
invalid_sub_file="$here/sub.pub.pem"
invalid_root_file="$here/root.pub.pem"

if [ ! -f $invalid_cert_file ]; then
    echo "!!!WARNING!!! Cert file not found!"
    fi
if [ ! -f $invalid_sub_file ]; then
    echo "!!!WARNING!!! Sub file not found!"
fi
if [ ! -f $invalid_root_file ]; then
    echo "!!!WARNING!!! Root file not found!"
fi

# There might be an issue if more than one driver is present
content=$(cat <<EOF
{
  "EmbeddedDrivers": [
    {
      "Driver": "decoded.EmbeddedDriver.1.efi"
    }
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
)

echo "$content" > "$output_file"

echo "Json file: $output_file"
echo "Output file: $capsule_name$file_descriptor.cap"

BaseTools/BinWrappers/PosixLike/GenerateCapsule --encode \
                                                --capflag PersistAcrossReset \
                                                --json-file $output_file \
                                                --output $capsule_name$file_descriptor.cap

echo "--- CREATING CAPSULE WITH WRONG GUID ---"

file_descriptor="_invalid_guid"
output_file="$capsule_name$file_descriptor.json"

if [ -f $output_file ]; then
    rm $output_file
fi

# There might be an issue if more than one driver is present
content=$(cat <<EOF
{
  "EmbeddedDrivers": [
    {
      "Driver": "decoded.EmbeddedDriver.1.efi"
    }
  ],
  "Payloads": [
    {
      "Payload": "$payload",
      "Guid": "11111111-2222-3333-4444-abcdefabcdef",
      "FwVersion": "$fw_version",
      "LowestSupportedVersion": "$lowest_supported_version",
      "OpenSslSignerPrivateCertFile": "BaseTools/Source/Python/Pkcs7Sign/TestCert.pem",
      "OpenSslOtherPublicCertFile": "BaseTools/Source/Python/Pkcs7Sign/TestSub.pub.pem",
      "OpenSslTrustedPublicCertFile": "BaseTools/Source/Python/Pkcs7Sign/TestRoot.pub.pem"
    }
  ]
}
EOF
)

echo "$content" > "$output_file"

echo "Json file: $output_file"
echo "Output file: $capsule_name$file_descriptor.cap"

BaseTools/BinWrappers/PosixLike/GenerateCapsule --encode \
                                                --capflag PersistAcrossReset \
                                                --json-file $output_file \
                                                --output $capsule_name$file_descriptor.cap
