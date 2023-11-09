#!/usr/bin/env bash

INIT_DIR="$(pwd)"

# Check if a directory was provided as the first parameter
if [ -n "$1" ]; then
    DIR="$1"
else
    DIR="$(pwd)"
fi

# Check if the directory exists
if [ ! -d "$DIR" ]; then
    echo "The provided directory does not exist."
    exit 1
fi

# Change to the specified directory
cd "$DIR" || exit

# Check for the existence of OVMF_CODE.fd and OVMF_VARS.fs files
if [ ! -f "OVMF_CODE.fd" ] || [ ! -f "OVMF_VARS.fd" ]; then
    echo "The required files OVMF_CODE.fd and OVMF_VARS.fs are missing."
    echo "Downloading files from the server..."
    wget -O ./OVMF_CODE.fd https://github.com/Dasharo/edk2/releases/download/dasharo_qemu_v0.0.1-test3/OVMF_CODE_RELEASE.fd
    wget -O ./OVMF_VARS.fd https://github.com/Dasharo/edk2/releases/download/dasharo_qemu_v0.0.1-test3/OVMF_VARS_RELEASE.fd
else
    echo "Both OVMF_CODE.fd and OVMF_VARS.fs files exist in the directory."
fi

echo "Copy OVMF_VARS.fd to /tmp/OVMF_VARS.fd"
cp ./OVMF_VARS.fd /tmp/OVMF_VARS.fd

if [ ! -f "ubuntu-disk.img" ]; then
  qemu-img create -f qcow2 ubuntu-disk.img 10G
fi

q35_params="-machine q35,smm=on \
    -m 2G \
    -device nec-usb-xhci,id=xhci \
    -device usb-storage,drive=usbstick,bus=xhci.0 \
    -drive id=usbstick,file=ubuntu-disk.img,if=none \
    -global driver=cfi.pflash01,property=secure,value=on \
    -drive if=pflash,format=raw,unit=0,file=./OVMF_CODE.fd,readonly=on \
    -drive if=pflash,format=raw,unit=1,file=/tmp/OVMF_VARS.fd \
    -debugcon file:debug.log -global isa-debugcon.iobase=0x402 \
    -global ICH9-LPC.disable_s3=1 \
    -qmp unix:/tmp/qmp-socket,server,nowait \
    -serial telnet:localhost:1234,server,nowait"

echo "Run QEMU Q35 with Dasharo (UEFI) firmware ... (Ctrl+C to terminate)"
case "$2" in
	nographic)
		qemu-system-x86_64 $q35_params -nographic
		;;
	vnc)
		qemu-system-x86_64 $q35_params -nographic -vnc :0
		;;
	*)
    qemu-system-x86_64 $q35_params
		;;
esac

cd $INIT_DIR || exit
