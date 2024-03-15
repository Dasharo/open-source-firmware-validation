#!/usr/bin/env bash

INIT_DIR="$(pwd)"

# Optionally, accept DIR as environmental variable. If not given, use current directory.
DIR="${DIR:-$PWD}"

# Check if the directory exists
if [ ! -d "$DIR" ]; then
    echo "The provided directory does not exist."
    exit 1
fi

if ! command -v swtpm &> /dev/null
then
    echo "swtpm could not be found"
    echo "Please install swtpm package first"
    exit 1
fi

HDD_PATH="qemu-data/hdd.qcow2"
INSTALLER_PATH="qemu-data/ubuntu.iso"

TPM_DIR="/tmp/osfv/tpm"
TPM_SOCK="${TPM_DIR}/sock"
TPM_PID_FILE="${TPM_DIR}/pid"
TPM_LOG_FILE="${TPM_DIR}/log"
# We need 2.0 only right now, but swtpm supports 1.2 only which may be useful in
# some cases.
# TPM_VERSION="2.0"

usage() {
cat <<EOF
Usage: ./$(basename ${0}) QEMU_MODE ACTION

This is the QEMU wrapper script for the Dasharo Open Source Firmware Validation.

  Available MODES:
    nographic    no graphic output is started, only serial over telnet is available
    vnc          graphic output is available via VNC
    graphic      graphic output is available in QEMU process window

  Available ACTIONS:
    firmware     a machine with lower resources assigned will be spawned and no disk
                 will be connected; suitable for firmware validation, but not for OS
                 booting
    os           a machine with more resources assigned will be spawned and HDD from
                 $HDD_PATH will be connected; suitable for firmware and OS validation,
                 if some OS is already installed on the disk image, it can be booted
    os_install   similar to "os" mode, but the CDROM with OS installer
                 from: $INSTALLER_PATH will be also attached

  Environmental variables:
    DIR         working directory, defaults to current working directory
    DRIVE_PATH  path to file which will be added as a virtual hard drive. The file
                should match formats described in chapter Disk Images of QEMU
                documentation

Example usage:
    ./$(basename $0) vnc firmware
    ./$(basename $0) graphic os_install
    DIR=/my/work/dir ./$(basename $0) graphic os
    DRIVE_PATH=/path/to/image ./$(basename $0) graphic os

EOF
  exit 0
}

check_disks() {
  UBUNTU_VERSION="22.04.3"

  if [ ! -f "${HDD_PATH}" ]; then
    echo "Disk at ${HDD_PATH} not found. You can create one with:"
    echo "qemu-img create -f qcow2 qemu-data/hdd.qcow2 20G"
    exit 1
  fi

  if [ ! -f "${INSTALLER_PATH}" ]; then
    echo "OS installer at ${INSTALLER_PATH} not found. Please provide OS installer, to continue."
    echo "Example: https://ubuntu.task.gda.pl/ubuntu-releases/${UBUNTU_VERSION}/ubuntu-${UBUNTU_VERSION}-desktop-amd64.iso"
    exit 1
  fi
}

tpm_start() {
  echo "Starting swtpm..."
  mkdir -p "${TPM_DIR}"
  touch "${TPM_PID_FILE}" "${TPM_LOG_FILE}"

  swtpm socket --tpm2 \
    --tpmstate dir=${TPM_DIR} \
    --ctrl type=unixio,path=${TPM_SOCK} \
    --pid file="${TPM_PID_FILE}" \
    --log level=5 &> "${TPM_LOG_FILE}" &

  sleep 1

  echo "swtpm started with PID: $(cat ${TPM_PID_FILE})"
}

tpm_stop() {
  if [ -f "${TPM_PID_FILE}" ]; then
    local _tpm_pid=0
    _tpm_pid="$(cat ${TPM_PID_FILE})"
    echo "stpoping swtpm with PID: ${_tpm_pid}"
    kill "${_tpm_pid}"
    echo "stopped swtpm"
  else
    echo "swtpm process not found"
  fi
  rm -f "${TPM_SOCK}" "${TPM_PID_FILE}"
}

cleanup() {
  echo "Cleaning up..."
  tpm_stop
  exit 1
}

trap cleanup INT

if [ $# -ne 2 ]; then
  usage
fi

QEMU_PARAMS_BASE="-machine q35,smm=on \
  -global driver=cfi.pflash01,property=secure,value=on \
  -drive if=pflash,format=raw,unit=0,file=./OVMF_CODE.fd,readonly=on \
  -drive if=pflash,format=raw,unit=1,file=/tmp/OVMF_VARS.fd \
  -debugcon file:debug.log -global isa-debugcon.iobase=0x402 \
  -global ICH9-LPC.disable_s3=1 \
  -qmp unix:/tmp/qmp-socket,server,nowait \
  -serial telnet:localhost:1234,server,nowait \
  -device virtio-scsi-pci,id=scsi \
  -device qemu-xhci,id=usb \
  -chardev socket,id=chrtpm,path=${TPM_SOCK} \
  -tpmdev emulator,id=tpm0,chardev=chrtpm \
  -device tpm-tis,tpmdev=tpm0"

QEMU_PARAMS_OS="-smp 2 \
  -enable-kvm \
  -mem-prealloc \
  -device ich9-intel-hda \
  -device hda-duplex,audiodev=hda \
  -audiodev pa,id=hda,server=unix:/run/user/1000/pulse/native,out.frequency=44100 \
  -object rng-random,id=rng0,filename=/dev/urandom \
  -device virtio-rng-pci,max-bytes=1024,period=1000 \
  -device virtio-net,netdev=vmnic \
  -netdev user,id=vmnic,hostfwd=tcp::5222-:22 \
  -smbios type=0,vendor=0vendor,version=0version,date=0date,release=0.0,uefi=on \
  -drive file=${HDD_PATH},if=virtio"

QEMU_PARAMS_INSTALLER="-cdrom ${INSTALLER_PATH}"

cd "$DIR" || exit

MODE="$1"

case "${MODE}" in
  nographic)
    QEMU_PARAMS="${QEMU_PARAMS_BASE} -nographic"
		;;
  vnc)
    QEMU_PARAMS="${QEMU_PARAMS_BASE} -nographic -vnc :0"
    ;;
  graphic)
    QEMU_PARAMS="${QEMU_PARAMS_BASE} -display gtk,window-close=off -vga virtio"
    ;;
  *)
    echo "Mode: ${MODE} not supported"
    exit 1
		;;
esac

ACTION="$2"

case "${ACTION}" in
  firmware)
    MEMORY="1G"
		;;
  os)
    MEMORY="4G"
    QEMU_PARAMS="${QEMU_PARAMS_BASE} ${QEMU_PARAMS_OS}"
    check_disks
    ;;
  os_install)
    MEMORY="4G"
    QEMU_PARAMS="${QEMU_PARAMS_BASE} ${QEMU_PARAMS_OS} ${QEMU_PARAMS_INSTALLER}"
    check_disks
    ;;
  *)
    echo "Action: ${ACTION} not supported"
    exit 1
		;;
esac

# Add disk
if [[ -v DRIVE_PATH ]]; then
  QEMU_PARAMS="$QEMU_PARAMS -hda $DRIVE_PATH"
fi

# Check for the existence of OVMF_CODE.fd and OVMF_VARS.fs files
if [ ! -f "OVMF_CODE.fd" ] || [ ! -f "OVMF_VARS.fd" ]; then
    echo "The required files OVMF_CODE.fd and OVMF_VARS.fs are missing."
    echo "Downloading files from the server..."
    wget -O ./OVMF_CODE.fd https://github.com/Dasharo/edk2/releases/latest/download/OVMF_CODE_RELEASE.fd
    wget -O ./OVMF_VARS.fd https://github.com/Dasharo/edk2/releases/latest/download/OVMF_VARS_RELEASE.fd
else
    echo "OVMF_CODE.fd and OVMF_VARS.fs files exist in the directory."
    echo "To make sure you are using the latest version from: https://github.com/Dasharo/edk2/releases"
    echo "simply remove them and let the script download the latest release."
fi

echo "Copy OVMF_VARS.fd to /tmp/OVMF_VARS.fd"
echo "On each run on this script, the firmware settings would be restored to default."
cp ./OVMF_VARS.fd /tmp/OVMF_VARS.fd

echo "Running QEMU Q35 with Dasharo (UEFI) firmware ... (Ctrl+C to terminate)"

tpm_start
qemu-system-x86_64 -m ${MEMORY} ${QEMU_PARAMS} || cleanup

cd $INIT_DIR || exit
