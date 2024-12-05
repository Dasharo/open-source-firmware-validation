#!/usr/bin/env bash

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <dts-base-image-path> <bzImage-path>"
    exit 1
fi

DTS_IMAGE_PATH=$1
DTS_IMAGE_FILENAME=$( basename "$DTS_IMAGE_PATH" )
BZ_IMAGE_PATH=$2
BZ_IMAGE_FILENAME=$( basename "$BZ_IMAGE_PATH" )
IPXE_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)/../../ipxe

mkdir -p "$IPXE_PATH"
ln -srf "$DTS_IMAGE_PATH" "$IPXE_PATH"/"$DTS_IMAGE_FILENAME"
ln -srf "$BZ_IMAGE_PATH" "$IPXE_PATH"/"$BZ_IMAGE_FILENAME"

cat <<EOF > "$IPXE_PATH/dts.ipxe"
#!ipxe
imgfetch --name file_kernel $BZ_IMAGE_FILENAME
imgfetch --name file_initrd $DTS_IMAGE_FILENAME
kernel file_kernel root=/dev/nfs initrd=file_initrd
boot
EOF

cd "$IPXE_PATH" && python3 -m http.server 4321
