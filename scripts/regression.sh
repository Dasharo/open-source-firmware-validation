#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/robot.sh"

# DEVICE_IP is required; firmware can be provided via FW_FILE or FW_URI
check_env_variable "DEVICE_IP"
resolve_fw_file

_REGRESSION_RUN="True"
export _REGRESSION_RUN

check_test_station_variables

if [ -z "$NO_SETUP" ]; then
    execute_robot "util/basic-platform-setup.robot" "${@}"
fi

execute_robot "dasharo-compatibility" "${@}"
execute_robot "dasharo-security" "${@}"
execute_robot "dasharo-stability" "${@}"
execute_robot "dasharo-performance" "${@}"
