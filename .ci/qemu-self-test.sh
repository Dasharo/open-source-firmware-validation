#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# The tests run against a throwaway QEMU machine spawned from this very
# checkout, so there is nothing to keep reproducible by a clean tree.
export ALLOW_DIRTY=1

QMP_SOCKET="/tmp/qmp-socket"
QEMU_PID_FILE="/tmp/qemu-pid"
TPM_PID_FILE="/tmp/osfv/tpm/pid"
# Port the QEMU serial console is exposed on, see scripts/ci/qemu-run.sh
SERIAL_PORT=1234
STARTUP_TIMEOUT=120

# toggle self-test / stress test
STRESS=${STRESS:-}

cleanup() {
  set +e
  local _rc=$?
  local _pid_file
  local _pid

  for _pid_file in "$QEMU_PID_FILE" "$TPM_PID_FILE"; do
    [ -f "$_pid_file" ] || continue
    _pid="$(cat "$_pid_file")"
    [ -n "$_pid" ] && kill "$_pid" 2> /dev/null || true
  done

  rm -f "${QEMU_FW_COPY:-}"
  rm -f "${QEMU_HDD_COPY:-}"

  return $_rc
}

# The suites talk to QEMU over both the serial telnet port and the QMP socket,
# and lib/QemuMonitor.py refuses to even load when the latter is missing, so
# robot must not be started before QEMU has set up the two of them.
wait_for_qemu() {
  local _waited=0

  while [ "$_waited" -lt "$STARTUP_TIMEOUT" ]; do
    if [ -S "$QMP_SOCKET" ] &&
      (exec 3<> "/dev/tcp/127.0.0.1/${SERIAL_PORT}") 2> /dev/null; then
      return 0
    fi
    sleep 1
    _waited=$((_waited + 1))
  done

  echo "QEMU did not come up within ${STARTUP_TIMEOUT}s"
  return 1
}

init() {
  local _mode=firmware
  local _noaudio=""
  if [ -n "${QEMU_HDD_BASE:-}" ]; then
    QEMU_HDD_COPY=$(mktemp osfv-hdd.XXXXXX.qcow2)
    qemu-img create -q -f qcow2 -b "$QEMU_HDD_BASE" -F qcow2 "$QEMU_HDD_COPY"
    export HDD_PATH="$QEMU_HDD_COPY"
    _mode=os
    _noaudio="--no-audio-emulation"
  fi

  QEMU_FW_FILE="${QEMU_FW_FILE:-${OSFV_ROMS_DIR:?}/coreboot.rom}"
  if [ ! -f "$QEMU_FW_FILE" ]; then
    echo "$QEMU_FW_FILE does not exist" >&2;
    return 1;
  fi

  QEMU_FW_COPY=$(mktemp qemu-fw.XXXXXX)
  cp "$QEMU_FW_FILE" "$QEMU_FW_COPY"
  QEMU_FW_FILE="$QEMU_FW_COPY" ./scripts/ci/qemu-run.sh "$_noaudio" nographic $_mode &
  wait_for_qemu
}

run() {
  if [ -n "$STRESS" ]; then
  echo "Running ./scripts/ci/qemu-stress-tests.sh"
    ./scripts/ci/qemu-stress-tests.sh
  else
    echo "Running ./scripts/ci/qemu-self-test.sh"
    ./scripts/ci/qemu-self-test.sh
  fi
}

ARG="${1:-}"

case "$ARG" in
  init)
    init
    ;;
  cleanup)
    cleanup
    ;;
  run)
    run
    ;;
  "")
    trap cleanup EXIT
    init
    run
    ;;
  *)
    trap cleanup EXIT
    init
    "$@"
    ;;
esac
