#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/robot.sh"

# FW_FILE and DEVICE_IP are required for full regression
check_env_variable "FW_FILE"
check_env_variable "DEVICE_IP"

check_test_station_variables

execute_robot "dasharo-compatibility" "${@}"
execute_robot "dasharo-security" "${@}"
execute_robot "dasharo-performance" "${@}"
