#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
<<<<<<< HEAD
# SPDX-License-Identifier: MIT
=======
# SPDX-License-Identifier: Apache-2.0
>>>>>>> 1d6dc6fb9413 (Add license headers for compliance with reuse tool)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/robot.sh"

# FW_FILE and DEVICE_IP are required for full regression
check_env_variable "FW_FILE"
check_env_variable "DEVICE_IP"

check_test_station_variables

execute_robot "dasharo-compatibility" "${@}"
execute_robot "dasharo-security" "${@}"
execute_robot "dasharo-performance" "${@}"
