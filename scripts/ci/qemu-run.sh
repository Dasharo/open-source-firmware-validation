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

# FW_TYPE=dasharo (default): Dasharo (coreboot+UEFI) for QEMU Q35.
# FW_TYPE=heads: Heads for the qemu-coreboot-* boards, booting from a
# writable 16 MiB flash image which Heads can reflash (settings, GPG keys).
FW_TYPE=${FW_TYPE:-dasharo}
if [[ "${FW_TYPE}" == "heads" ]]; then
  QEMU_FW_FILE=${QEMU_FW_FILE:-qemu-data/heads.rom}
else
  QEMU_FW_FILE=${QEMU_FW_FILE:-./qemu_q35.rom}
fi
# Heads only: USB security dongle, one of: nk3 (default; forward a Nitrokey 3,
# e.g. the emulated one from Heads' bin/qemu-nk3-usbip.sh, attached to the host
# before QEMU starts), canokey (QEMU's virtual OpenPGP card, state kept in
# $CANOKEY_FILE, needs a QEMU built with canokey), none
HEADS_USB_TOKEN=${HEADS_USB_TOKEN:-nk3}
CANOKEY_FILE=${CANOKEY_FILE:-qemu-data/canokey-file}
# TPM version presented to the guest: 2 (default) or 1.2 (Heads tpm1 boards)
TPM_VERSION=${TPM_VERSION:-2}

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
    FW_TYPE     dasharo (default) or heads
    QEMU_FW_FILE  firmware image, defaults to ./qemu_q35.rom, or
                qemu-data/heads.rom with FW_TYPE=heads (a 16 MiB Heads ROM
                for the qemu-coreboot-* boards; Heads writes to it)
    HEADS_USB_TOKEN  nk3 (default), canokey or none, with FW_TYPE=heads
    CANOKEY_FILE  canokey state, defaults to qemu-data/canokey-file
    TPM_VERSION 2 (default) or 1.2
    SERIAL_LOG  also write the serial console output to this file
    SERIAL_WAIT if set, start the VM only once a client connected to the
                serial console, so no early output is lost
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

  local _tpm_ver=""
  [[ "${TPM_VERSION}" == "2" ]] && _tpm_ver="--tpm2"
  swtpm socket ${_tpm_ver} \
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

# Serial console on telnet localhost:1234; with SERIAL_LOG also logged to a
# file, with SERIAL_WAIT the VM starts only once a telnet client connected
# (QEMU drops serial output while no client is connected)
SERIAL_PARAMS="-chardev socket,id=ser0,host=localhost,port=1234,telnet=on,server=on"
if [[ -n "${SERIAL_WAIT}" ]]; then
  SERIAL_PARAMS+=",wait=on"
else
  SERIAL_PARAMS+=",wait=off"
fi
if [[ -n "${SERIAL_LOG}" ]]; then
  SERIAL_PARAMS+=",logfile=${SERIAL_LOG},logappend=on"
fi
SERIAL_PARAMS+=" -serial chardev:ser0"

QEMU_CPU="Skylake-Client-noTSX-IBRS"
QEMU_ACCEL=""
if [[ -c /dev/kvm ]]; then
  # KVM maps guest physical addresses only within the host CPU's address width.
  # Report that width to the guest, so firmware places 64-bit PCI BARs within it.
  QEMU_CPU+=",host-phys-bits=on"
  QEMU_ACCEL="-enable-kvm"
fi

QEMU_PARAMS_BASE="-machine q35,smm=on -cpu ${QEMU_CPU} ${QEMU_ACCEL} \
  -global driver=cfi.pflash01,property=secure,value=off \
  -drive if=pflash,format=raw,unit=0,file=${QEMU_FW_FILE} \
  -global ICH9-LPC.disable_s3=1 \
  -qmp unix:/tmp/qmp-socket,server,nowait \
  -pidfile /tmp/qemu-pid \
  ${SERIAL_PARAMS} \
  -device virtio-scsi-pci,id=scsi \
  -device qemu-xhci,id=usb \
  -chardev socket,id=chrtpm,path=${TPM_SOCK} \
  -tpmdev emulator,id=tpm0,chardev=chrtpm \
  -device tpm-tis,tpmdev=tpm0 \
  -smp 2 \
  -mem-prealloc"

if [[ "${FW_TYPE}" == "heads" ]]; then
  # The Heads ROM fills a 16 MiB flash; QEMU allows 8 MiB by default.
  QEMU_PARAMS_BASE="${QEMU_PARAMS_BASE/-machine q35,smm=on/-machine q35,smm=on,max-fw-size=16M}"
  # TOTP needs the guest clock in UTC.  Heads powers off instead of
  # rebooting on QEMU; -no-shutdown keeps QEMU (and QMP) alive, so
  # 'Power On' can reset the machine.
  QEMU_PARAMS_BASE+=" -rtc base=utc -no-shutdown"
  case "${HEADS_USB_TOKEN}" in
    canokey)
      QEMU_PARAMS_BASE+=" -device canokey,bus=usb.0,file=${CANOKEY_FILE}"
      ;;
    nk3)
      # QEMU only warns when it cannot open the device and boots without
      # it, so check that it is attached and accessible first.
      nk3_dev=""
      for dev in /sys/bus/usb/devices/*; do
        [[ "$(cat "$dev/idVendor" 2>/dev/null)" == "20a0" ]] || continue
        [[ "$(cat "$dev/idProduct" 2>/dev/null)" == "42b2" ]] || continue
        nk3_dev=$(printf "/dev/bus/usb/%03d/%03d" \
          "$(cat "$dev/busnum")" "$(cat "$dev/devnum")")
        break
      done
      if [[ -z "$nk3_dev" ]]; then
        echo "No Nitrokey 3 (20a0:42b2) attached; start one with Heads'"
        echo "bin/qemu-nk3-usbip.sh, or use HEADS_USB_TOKEN=none"
        exit 1
      fi
      if [[ ! -r "$nk3_dev" || ! -w "$nk3_dev" ]]; then
        echo "No access to the Nitrokey 3 at $nk3_dev, e.g.:"
        echo "  sudo chown $(id -un) $nk3_dev"
        exit 1
      fi
      QEMU_PARAMS_BASE+=" -device usb-host,bus=usb.0,vendorid=0x20a0,productid=0x42b2"
      ;;
    none)
      ;;
    *)
      echo "Unknown HEADS_USB_TOKEN: ${HEADS_USB_TOKEN}"
      exit 1
      ;;
  esac
fi

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

if [[ "${FW_TYPE}" == "heads" ]]; then
  if [ ! -f "${QEMU_FW_FILE}" ]; then
    echo "Heads ROM ${QEMU_FW_FILE} not found. Copy a 16 MiB Heads ROM for a"
    echo "qemu-coreboot-* board there, e.g. from Heads' build/x86/<board>/."
    exit 1
  fi
  echo "Running QEMU Q35 with Heads from ${QEMU_FW_FILE} ... (Ctrl+C to terminate)"
# Check for the existence of QEMU firmware file
elif [ ! -f "${QEMU_FW_FILE}" ]; then
    echo "The required file ${QEMU_FW_FILE} is missing."
    echo "Downloading from the server..."
    wget -O ${QEMU_FW_FILE} https://github.com/Dasharo/coreboot/releases/latest/download/qemu_q35_all_menus.rom
else
    echo "${QEMU_FW_FILE} file exists in the directory."
    echo "To make sure you are using the latest version from: https://github.com/Dasharo/coreboot/releases"
    echo "simply remove it and let the script download the latest release."
fi

if [[ "${FW_TYPE}" != "heads" ]]; then
  echo "Clear UEFI variables"
  echo "On each run on this script, the firmware settings would be restored to default."
  dd if=/dev/zero of=${QEMU_FW_FILE} bs=256 count=1 conv=notrunc 2> /dev/null

  echo "Running QEMU Q35 with Dasharo (coreboot+UEFI) firmware ... (Ctrl+C to terminate)"
fi

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
