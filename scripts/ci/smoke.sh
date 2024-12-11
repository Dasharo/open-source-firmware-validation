#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPT_DIR}/../lib/robot.sh"

# export CONFIG=msi-pro-z690-a-ddr5
# export RTE_IP=192.168.10.188
#
# execute_robot "dasharo-compatibility/custom-boot-menu-key.robot"
# execute_robot "dasharo-compatibility/nvme-support.robot"
# execute_robot "dasharo-security/usb-stack.robot"

export CONFIG=protectli-vp4670
export RTE_IP=192.168.10.14

execute_robot "dasharo-compatibility/custom-boot-menu-key.robot"
execute_robot "dasharo-compatibility/nvme-support.robot"
execute_robot "dasharo-security/usb-stack.robot"
