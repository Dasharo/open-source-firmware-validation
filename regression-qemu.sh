#!/usr/bin/env bash

RTE_IP=127.0.0.1
CONFIG="qemu"

# Function to execute the robot command
execute_robot() {
    local _category=$1
    local _test_name=$2
    local _log_file="${_test_name}_log.html"
    local _report_file="${_test_name}_report.html"
    local _output_file="${_test_name}.xml"

    robot -L TRACE \
          -l ${CONFIG}-${OS}/${_log_file} \
          -r ${CONFIG}-${OS}/${_report_file} \
          -o ${CONFIG}-${OS}/${_output_file} \
          -v device_ip:${DEVICE_IP} \
          -v rte_ip:${RTE_IP} \
          -v config:${CONFIG} \
          -v snipeit:no \
          -v fw_file:${FW_FILE} \
          dasharo-${_category}/${_test_name}.robot
}

# Function to handle Ctrl+C
handle_ctrl_c() {
    echo "Ctrl+C pressed. Exiting."
    # You can add cleanup tasks here if needed
    exit 1
}

# Trap SIGINT (Ctrl+C)
trap 'handle_ctrl_c' SIGINT

compatibility_tests=(
  "custom-boot-menu-key"
  "uefi-shell"
  "network-boot"
)

security_tests=(
  "network-stack"
  "secure-boot"
)

OS=ubuntu

# Compatibility tests
for test in "${compatibility_tests[@]}"; do
    execute_robot "compatibility" "$test"
done

# Security tests
for test in "${security_tests[@]}"; do
    execute_robot "security" "$test"
done
