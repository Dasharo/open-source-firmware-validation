#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

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

NO_AUDIO_EMULATION=""
HDD_PATH=${HDD_PATH:-qemu-data/hdd.qcow2}
PULSE_SERVER=${PULSE_SERVER:-unix:/run/user/$(id -u)/pulse/native}
INSTALLER_PATH="qemu-data/installer.iso"

TPM_DIR="/tmp/osfv/tpm"
TPM_SOCK="${TPM_DIR}/sock"
TPM_PID_FILE="${TPM_DIR}/pid"
TPM_LOG_FILE="${TPM_DIR}/log"
# We need 2.0 only right now, but swtpm supports 1.2 only which may be useful in
# some cases.
# TPM_VERSION="2.0"

QEMU_FW_FILE=${QEMU_FW_FILE:-./qemu_q35.rom}

usage() {
cat <<EOF
Usage: ./$(basename ${0}) [OPTIONS]... QEMU_MODE ACTION

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
    HDD2_PATH   optional path of the second hard drive to connect to the machine if
                ACTION "os" is used. Relative to DIR
    BRIDGE      if set, connects the machine to the local network via `br0` bridge
                instead of doing address translation.

  Additional OPTIONS:
    --no-audio-emulation   do not add an audio device to QEMU. Is only usable with
                           "os" ACTION.
    --help                 print this message.

Example usage:
    ./$(basename $0) vnc firmware
    ./$(basename $0) graphic os_install
    DIR=/my/work/dir HDD2_PATH=qemu-data/hdd2.qcow ./$(basename $0) graphic os

EOF
}

esc() {
    printf %q "$@"
}

check_disks() {
  UBUNTU_VERSION="22.04.4"

  if [ ! -f "${HDD_PATH}" ]; then
    echo "Disk at ${HDD_PATH} not found. You can create one with:"
    echo "qemu-img create -f qcow2 $(esc "${HDD_PATH}") 20G"
    exit 1
  fi

  if [[ "$1" == "os_install" && ! -f "${INSTALLER_PATH}" ]]; then
    echo "OS installer at ${INSTALLER_PATH} not found. Please provide OS installer, to continue."
    echo "Example:"
    echo "wget -O $(esc "$INSTALLER_PATH") $(esc "http://cdn.releases.ubuntu.com/jammy/ubuntu-${UBUNTU_VERSION}-desktop-amd64.iso")"
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
    echo "stopping swtpm with PID: ${_tpm_pid}"
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

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --no-audio-emulation)
        NO_AUDIO_EMULATION="true"
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      -*)
        usage
        echo "Unknown option $1"
        exit 1
        ;;
      *)
        POSITIONAL_ARGS+=( "$1" )
        shift
        ;;
    esac
  done
}

parse_args "$@"
set -- "${POSITIONAL_ARGS[@]}"

if [ $# -ne 2 ]; then
  usage
  exit 1
fi

QEMU_PARAMS_BASE="-machine q35,smm=on -cpu Skylake-Client \
  -global driver=cfi.pflash01,property=secure,value=off \
  -drive if=pflash,format=raw,unit=0,file=${QEMU_FW_FILE} \
  -global ICH9-LPC.disable_s3=1 \
  -qmp unix:/tmp/qmp-socket,server,nowait \
  -pidfile /tmp/qemu-pid \
  -serial telnet:localhost:1234,server,nowait \
  -device virtio-scsi-pci,id=scsi \
  -device qemu-xhci,id=usb \
  -chardev socket,id=chrtpm,path=${TPM_SOCK} \
  -tpmdev emulator,id=tpm0,chardev=chrtpm \
  -device tpm-tis,tpmdev=tpm0 \
  -smp 2 \
  -enable-kvm \
  -mem-prealloc"

QEMU_PARAMS_OS="-object rng-random,id=rng0,filename=/dev/urandom \
  -device virtio-rng-pci,max-bytes=1024,period=1000 \
  -device virtio-net,netdev=vmnic \
  -drive file=${HDD_PATH},if=ide"

QEMU_PARAMS_OS_AUDIO="-device ich9-intel-hda \
  -device hda-duplex,audiodev=hda \
  -audiodev pa,id=hda,server=${PULSE_SERVER},out.frequency=44100"

# Setting up a bridge interface for QEMU
# ip link add name br0 type bridge
# ip link set <interface> master br0
# ip addr flush dev <interface>
# ip link set br0 up
# ip addr add <interface_local_ip>/<mask> dev br0
# ip route add default via <gateway_ip>
if [[ -z ${BRIDGE} ]]; then
  QEMU_PARAMS_OS+=" -netdev user,id=vmnic,hostfwd=tcp::5222-:22"
else
  echo "Using bridged network $BRIDGE"
  QEMU_PARAMS_OS+=" -netdev bridge,id=vmnic,br=$BRIDGE"
fi

if [[ -f ${HDD2_PATH} ]]; then
  QEMU_PARAMS_OS+=" \
  -drive file=${HDD2_PATH},if=ide"

  echo "Using ${HDD2_PATH} as the second drive"
fi

QEMU_PARAMS_INSTALLER="-cdrom ${INSTALLER_PATH}"

cd "$DIR" || exit

MODE="$1"
ACTION="$2"

case "${MODE}" in
  nographic)
    QEMU_PARAMS="${QEMU_PARAMS_BASE} -nographic"
		;;
  vnc)
    QEMU_PARAMS="${QEMU_PARAMS_BASE} -nographic -vnc :0"
    ;;
  graphic)
    QEMU_PARAMS="${QEMU_PARAMS_BASE} -display gtk,window-close=off"
    ;;
  *)
    echo -e "Mode: ${MODE} not supported\n"
    usage
    exit 1
		;;
esac

case "${ACTION}" in
  firmware)
    MEMORY="1G"
		;;
  os)
    MEMORY="4G"
    QEMU_PARAMS="${QEMU_PARAMS} ${QEMU_PARAMS_OS}"

    if [[ "$NO_AUDIO_EMULATION" != "true" ]]; then
      QEMU_PARAMS="${QEMU_PARAMS} ${QEMU_PARAMS_OS_AUDIO}"
    fi

    check_disks ${ACTION}
    ;;
  os_install)
    MEMORY="4G"
    QEMU_PARAMS="${QEMU_PARAMS} ${QEMU_PARAMS_OS} ${QEMU_PARAMS_INSTALLER}"
    check_disks ${ACTION}
    ;;
  *)
    echo -e "Action: ${ACTION} not supported\n"
    usage
    exit 1
		;;
esac

# Check for the existence of QEMU firmware file
if [ ! -f "${QEMU_FW_FILE}" ]; then
    echo "The required file ${QEMU_FW_FILE} is missing."
    echo "Downloading from the server..."
    wget -O ${QEMU_FW_FILE} https://github.com/Dasharo/coreboot/releases/latest/download/qemu_q35_all_menus.rom
else
    echo "${QEMU_FW_FILE} file exists in the directory."
    echo "To make sure you are using the latest version from: https://github.com/Dasharo/coreboot/releases"
    echo "simply remove it and let the script download the latest release."
fi

echo "Clear UEFI variables"
echo "On each run on this script, the firmware settings would be restored to default."
dd if=/dev/zero of=${QEMU_FW_FILE} bs=256 count=1 conv=notrunc 2> /dev/null

echo "Running QEMU Q35 with Dasharo (coreboot+UEFI) firmware ... (Ctrl+C to terminate)"

tpm_start
# Detect if running in CI environment
if [[ "${CI:-false}" == "true" || "${GITHUB_ACTIONS:-false}" == "true" ]]; then
    echo "Running in CI mode - using nohup for process isolation"
    nohup qemu-system-x86_64 -m ${MEMORY} ${QEMU_PARAMS} </dev/null >/dev/null 2>&1 &
    QEMU_PID=$!
    echo "QEMU started with PID: $QEMU_PID"
    wait $QEMU_PID || cleanup
else
    echo "Running in local mode - normal execution"
    qemu-system-x86_64 -m ${MEMORY} ${QEMU_PARAMS} || cleanup
fi

cd $INIT_DIR || exit
