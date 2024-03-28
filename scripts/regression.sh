#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/lib/robot.sh"

FW_FILE=read-test.rom
# DEVICE_IP=192.168.10.166
RTE_IP=192.168.10.110
CONFIG=protectli-vp6670
SNIPEIT=no

# FW_FILE and DEVICE_IP are required for full regression
check_env_variable "FW_FILE"
# check_env_variable "DEVICE_IP"

execute_robot "dasharo-compatibility/flash-test-stub.robot"
