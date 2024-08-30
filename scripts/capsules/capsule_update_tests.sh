#!/bin/bash

capsule=$1
capsule_name=$(basename "$capsule")
capsule_name="${capsule_name%.*}"

cd ..
if [ ! -d "./edk2" ]; then
    git clone https://github.com/Dasharo/edk2.git
    chmod 777 edk2
    cd edk2 || return
    git checkout 1370be0e5fbbf72600642b4bd31f4f9626e343f2
else
    cd edk2 || exit
fi

# Decoding the capsule
echo "---DECODING PAYLOAD---"


cleaned_capsule_path=$(echo "$capsule" | cut -c 3-) # Removes ./ from file path

BaseTools/BinWrappers/PosixLike/GenerateCapsule \
    --decode ../open-source-firmware-validation/$cleaned_capsule_path \
    --output decoded \

# Create json config files with capsule configs
echo "---CREATING CAPSULE WITH MAX POSSIBLE VERSION NUMBER---"

file_descriptor="_max_fw_ver"
output_file="$capsule_name$file_descriptor.json"

if [ -f $output_file ]; then
    rm $output_file
fi

echo "---CREATING JSON FILE---"
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
      "Payload": "decoded.Payload.1.bin",
      "Guid": "00112233-4455-6677-8899-aabbccddeeff",
      "FwVersion": "0x99999999",
      "LowestSupportedVersion": "0x00080000",
      "OpenSslSignerPrivateCertFile": "BaseTools/Source/Python/Pkcs7Sign/TestCert.pem",
      "OpenSslOtherPublicCertFile": "BaseTools/Source/Python/Pkcs7Sign/TestSub.pub.pem",
      "OpenSslTrustedPublicCertFile": "BaseTools/Source/Python/Pkcs7Sign/TestRoot.pub.pem"
    }
  ]
}
EOF
)

echo "---FILLING JSON WITH DATA---"
echo "$content" > "$output_file"

echo "Json file: $output_file"
echo "Output file: $capsule_name$file_descriptor.cap"

BaseTools/BinWrappers/PosixLike/GenerateCapsule --encode \
                                                --capflag PersistAcrossReset \
                                                --capflag InitiateReset \
                                                --json-file $output_file \
                                                --output $capsule_name$file_descriptor.cap


echo "---CREATING CAPSULE WITH WRONG CERTIFICATES---"

file_descriptor="_wrong_cert"

output_file="$capsule_name$file_descriptor.json"

if [ -f $output_file ]; then
    rm $output_file
fi

invalid_cert_file="../open-source-firmware-validation/scripts/capsules/InvalidTestCert.pem"
invalid_sub_file="../open-source-firmware-validation/scripts/capsules/InvalidTestSub.pub.pem"
invalid_root_file="../open-source-firmware-validation/scripts/capsules/InvalidTestRoot.pub.pem"

if [ ! -f $invalid_cert_file ]; then
    echo "!!!WARNING!!! Cert file not found!"
fi
if [ ! -f $invalid_sub_file ]; then
    echo "!!!WARNING!!! Sub file not found!"
fi
if [ ! -f $invalid_root_file ]; then
    echo "!!!WARNING!!! Root file not found!"
fi

echo "---CREATING JSON FILE---"
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
      "Payload": "decoded.Payload.1.bin",
      "Guid": "00112233-4455-6677-8899-aabbccddeeff",
      "FwVersion": "0x99999999",
      "LowestSupportedVersion": "0x00080000",
      "OpenSslSignerPrivateCertFile": "$invalid_cert_file",
      "OpenSslOtherPublicCertFile": "$invalid_sub_file",
      "OpenSslTrustedPublicCertFile": "$invalid_root_file"
    }
  ]
}
EOF
)

echo "---FILLING JSON WITH DATA---"
echo "$content" > "$output_file"

BaseTools/BinWrappers/PosixLike/GenerateCapsule --encode \
                                                --capflag PersistAcrossReset \
                                                --capflag InitiateReset \
                                                --json-file $output_file \
                                                --output $capsule_name$file_descriptor.cap

echo "---CREATING CAPSULE WITH WRONG GUID---"

file_descriptor="_invalid_guid"
output_file="$capsule_name$file_descriptor.json"

if [ -f $output_file ]; then
    rm $output_file
fi

echo "---CREATING JSON FILE---"
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
      "Payload": "decoded.Payload.1.bin",
      "Guid": "11111111-2222-3333-4444-abcdefabcdef",
      "FwVersion": "0x99999999",
      "LowestSupportedVersion": "0x00080000",
      "OpenSslSignerPrivateCertFile": "BaseTools/Source/Python/Pkcs7Sign/TestCert.pem",
      "OpenSslOtherPublicCertFile": "BaseTools/Source/Python/Pkcs7Sign/TestSub.pub.pem",
      "OpenSslTrustedPublicCertFile": "BaseTools/Source/Python/Pkcs7Sign/TestRoot.pub.pem"
    }
  ]
}
EOF
)

echo "---FILLING JSON WITH DATA---"
echo "$content" > "$output_file"

echo "Json file: $output_file"
echo "Output file: $capsule_name$file_descriptor.cap"

BaseTools/BinWrappers/PosixLike/GenerateCapsule --encode \
                                                --capflag PersistAcrossReset \
                                                --capflag InitiateReset \
                                                --json-file $output_file \
                                                --output $capsule_name$file_descriptor.cap
