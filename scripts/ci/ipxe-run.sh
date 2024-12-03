#!/usr/bin/env bash

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <dts-base-image-path> <bzImage-path>"
    exit 1
fi

DTS_IMAGE_PATH=$1
DTS_IMAGE_FILENAME=$( basename $DTS_IMAGE_PATH)
BZ_IMAGE_PATH=$2
IPXE_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)/../../ipxe

echo $IPXE_PATH
mkdir $IPXE_PATH
cp $DTS_IMAGE_PATH $IPXE_PATH
cp $BZ_IMAGE_PATH $IPXE_PATH

echo -e "\n
#!ipxe\n
imgfetch --name file_kernel bzImage\n
imgfetch --name file_initrd $DTS_IMAGE_FILENAME\n
kernel file_kernel root=/dev/nfs initrd=file_initrd\n
boot" > $IPXE_PATH/dts.ipxe
cd $IPXE_PATH && python3 -m http.server 4321
