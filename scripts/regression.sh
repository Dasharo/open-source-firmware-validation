#!/usr/bin/env bash

FW_FILE=dasharo-protectli-vp46xx-.rom
DEVICE_IP=192.168.10.21
RTE_IP=192.168.10.203
CONFIG=protectli-vp4650


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/lib/robot.sh"

# FW_FILE and DEVICE_IP are required for full regression
check_env_variable "FW_FILE"
check_env_variable "DEVICE_IP"

execute_robot "dasharo-compatibility"
execute_robot "dasharo-security"
execute_robot "dasharo-performance"
