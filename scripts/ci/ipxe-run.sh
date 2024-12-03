#!/usr/bin/env bash

mkdir ipxe
cp build/tmp/deploy/images/genericx86-64/dts-base-image-genericx86-64.cpio.gz ipxe
cp build/tmp/deploy/images/genericx86-64/bzImage ipxe

echo -e "\n
#!ipxe\n
imgfetch --name file_kernel bzImage\n
imgfetch --name file_initrd dts-base-image-genericx86-64.cpio.gz\n
kernel file_kernel root=/dev/nfs initrd=file_initrd\n
boot" > ipxe/dts.ipxe
cd ipxe && python3 -m http.server 4321 &
