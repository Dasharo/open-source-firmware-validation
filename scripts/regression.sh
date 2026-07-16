#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/robot.sh"

run_qemu_regression() {
    export RTE_IP="${RTE_IP:-127.0.0.1}"
    export SNIPEIT_NO="${SNIPEIT_NO:-1}"

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

    for test in "${compatibility_tests[@]}"; do
        execute_robot "$test" "${@}"
    done

    for test in "${security_tests[@]}"; do
        execute_robot "$test" "${@}"
    done
}

if [ "$CONFIG" != "qemu" ]; then
    # FW_FILE and DEVICE_IP are required for full regression
    check_env_variable "FW_FILE"
    check_env_variable "DEVICE_IP"

    if [ ! -f "$FW_FILE" ]; then
        echo "Error: Environment variable FW_FILE doesn't point to a file."
        exit 1
    fi
fi

_REGRESSION_RUN="True"
export _REGRESSION_RUN

check_test_station_variables

if [ "$CONFIG" = "qemu" ]; then
    run_qemu_regression "${@}"
    exit $?
fi

if [ -z "$NO_SETUP" ]; then
    execute_robot "util/basic-platform-setup.robot" "${@}"
fi

execute_robot "dasharo-compatibility" "${@}"
execute_robot "dasharo-security" "${@}"
execute_robot "dasharo-stability" "${@}"
execute_robot "dasharo-performance" "${@}"
