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

  return $_rc
}

setup_test_data() {
  git submodule update --init --checkout --recursive

  # osfv-test-data keeps its payloads in git-annex. The QEMU self-tests only
  # need the submodule to be checked out, so a missing annex remote must not
  # fail the whole job.
  (
    cd osfv-test-data || exit 0
    git config --local user.email "ci@3mdeb.com"
    git config --local user.name "osfv-ci"
    git annex pull || true
    ./setup.sh || true
  ) || true
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

trap cleanup EXIT

setup_test_data

./scripts/ci/qemu-run.sh nographic firmware &
wait_for_qemu

<<<<<<< HEAD
./scripts/ci/qemu-self-test.sh
=======
uv run ./scripts/ci/qemu-self-test.sh
>>>>>>> 00b6db2ffa24 (.ci: Add develop pr regression)
