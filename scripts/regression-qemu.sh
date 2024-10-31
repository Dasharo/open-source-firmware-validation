#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/lib/robot.sh"

export RTE_IP=127.0.0.1
export CONFIG="qemu"
export SNIPEIT_NO="no"

compatibility_tests=(
  "dasharo-compatibility/custom-boot-menu-key.robot"
  "dasharo-compatibility/uefi-shell.robot"
  "dasharo-compatibility/network-boot.robot"
  "dasharo-compatibility/dmidecode.robot"
  # FIXME: unsafe to enable https://github.com/Dasharo/dasharo-issues/issues/887
  #"dasharo-compatibility/reset-to-defaults.robot"
)

security_tests=(
  "dasharo-security/network-stack.robot"
  "dasharo-security/secure-boot.robot"
  "dasharo-security/measured-boot.robot"
  "dasharo-security/uefi-password.robot"
)

# Compatibility tests
for test in "${compatibility_tests[@]}"; do
    execute_robot "$test"
done

# Security tests
for test in "${security_tests[@]}"; do
    execute_robot "$test"
done
