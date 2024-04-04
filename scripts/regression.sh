#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/lib/robot.sh"

# FW_FILE and DEVICE_IP are required for full regression
check_env_variable "FW_FILE"
# check_env_variable "DEVICE_IP"

execute_robot "dasharo-compatibility"
