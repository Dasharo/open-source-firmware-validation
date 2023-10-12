#!/usr/bin/env bash

if [ ! -f "./OVMF_CODE.fd" ]; then
    wget -O ./OVMF_CODE.fd https://cloud.3mdeb.com/index.php/s/iXmyJxKLBB2Eb94/download
fi

if [ ! -f "./OVMF_VARS.fd" ]; then
    wget -O ./OVMF_VARS.fd https://cloud.3mdeb.com/index.php/s/Mn2n92DZLnZQZ8N/download
fi

cp ./OVMF_VARS.fd /tmp/OVMF_VARS.fd

q35_params="-machine q35,smm=on \
    -global driver=cfi.pflash01,property=secure,value=on \
    -drive if=pflash,format=raw,unit=0,file=./OVMF_CODE.fd,readonly=on \
    -drive if=pflash,format=raw,unit=1,file=/tmp/OVMF_VARS.fd \
    -debugcon file:debug.log -global isa-debugcon.iobase=0x402 \
    -global ICH9-LPC.disable_s3=1 \
    -qmp unix:/tmp/qmp-socket,server,nowait \
    -net none \
    -serial telnet:localhost:1234,server,nowait"

if [ "$1" == "nographic" ]; then
    qemu-system-x86_64 $q35_params -nographic
else
    qemu-system-x86_64 $q35_params
fi
