#!/bin/bash

capsule=$1
capsule_name=$(basename "$capsule")
capsule_name="${capsule_name%.*}"

cd ..
if [ ! -d "./edk2" ]; then
    git clone https://github.com/Dasharo/edk2.git
    chmod 777 edk2
    cd edk2
    git checkout 1370be0e5fbbf72600642b4bd31f4f9626e343f2
else
    cd edk2
fi

# Decoding the capsule

cleaned_capsule_path=$(echo "$capsule" | cut -c 3-) # Removes ./ from file path

BaseTools/BinWrappers/PosixLike/GenerateCapsule \
    --decode ../open-source-firmware-validation/$cleaned_capsule_path \
    --output decoded \
    --signer-private-cert BaseTools/Source/Python/Pkcs7Sign/TestCert.pem \
    --other-public-cert BaseTools/Source/Python/Pkcs7Sign/TestSub.pub.pem \
    --trusted-public-cert BaseTools/Source/Python/Pkcs7Sign/TestRoot.pub.pem

# Create json config files with capsule configs

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
EOF
)

echo "$content" > "$output_file"
tail -n +2 "decoded.json" >> "$output_file"

sed -i 's/"FwVersion": "[^"]*"/"FwVersion": "99999999"/' "$output_file" # changing version to max possible value
sed -i '/"Dependencies": "None",/d' "$output_file" # this line doesnt exist in tutorial, and it makes building fail
sed -i '/"MonotonicCount": "0",/d' "$output_file" # this line doesnt exist in tutorial, and it makes building fail
sed -i '/"HardwareInstance": "0",/d' "$output_file" # this line doesnt exist in tutorial, and it makes building fail
sed -i '/"UpdateImageIndex": "1"/d' "$output_file" # this line doesnt exist in tutorial, and it makes building fail

BaseTools/BinWrappers/PosixLike/GenerateCapsule --encode \
                                                --capflag PersistAcrossReset \
                                                --capflag InitiateReset \
                                                --json-file $output_file \
                                                --output capsule_name$file_descriptor.cap
