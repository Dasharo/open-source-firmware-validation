#!/usr/bin/env bash

execute_robot() {
    local _category=$1
    local _test_name=$2
    local _log_file="${_test_name}_log.html"
    local _report_file="${_test_name}_report.html"
    local _output_file="${_test_name}.xml"

    robot -L TRACE \
          -l logs/${CONFIG}/${_log_file} \
          -r logs/${CONFIG}/${_report_file} \
          -o logs/${CONFIG}/${_output_file} \
          -v device_ip:${DEVICE_IP} \
          -v rte_ip:${RTE_IP} \
          -v config:${CONFIG} \
          -v fw_file:${FW_FILE} \
          dasharo-${_category}/${_test_name}.robot
}

handle_ctrl_c() {
    echo "Ctrl+C pressed. Exiting."
    # You can add cleanup tasks here if needed
    exit 1
}

# Trap SIGINT (Ctrl+C)
trap 'handle_ctrl_c' SIGINT

compatibility_tests=(
  "custom-boot-menu-key" # very basic test environment
  "nvme-support" # booting into Linux OS and executing shell commands
)

security_tests=(
  "usb-stack"
)

# Compatibility tests

CONFIG=msi-pro-z690-a-ddr5
RTE_IP=192.168.10.188

for test in "${compatibility_tests[@]}"; do
    execute_robot "compatibility" "$test"
done

for test in "${security_tests[@]}"; do
    execute_robot "security" "$test"
done

CONFIG=protectli-vp4630
RTE_IP=192.168.10.244

for test in "${compatibility_tests[@]}"; do
    execute_robot "compatibility" "$test"
done
