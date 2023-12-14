#!/usr/bin/env bash

# RTE_IP alone should be enough for running the regression.
# If for some reason, Sonoff/PiKVM IPs are not correct, they
# should be changed in the variables.robot file
RTE_IP=${RTE_IP:=192.168.10.188}

# Uncomment one of these
CONFIG=${CONFIG:=msi-pro-z690-a-ddr5}

FW_FILE=${FW_FILE:=msi_ms7d25_v1.1.3_ddr5_serial_enabled.rom}

DEVICE_IP="192.168.10.93"

if [ ! -f "${FW_FILE}" ]; then
    echo "${FW_FILE} not found. Please provide correct FW_FILE value"
    exit 1
fi

# Function to execute the robot command
execute_robot() {
    local _category=$1
    local _log_file="${_category}_log.html"
    local _report_file="${_category}_report.html"
    local _output_file="${_category}.xml"

    robot -L TRACE \
          -l ${CONFIG}/${_log_file} \
          -r ${CONFIG}/${_report_file} \
          -o ${CONFIG}/${_output_file} \
          -v device_ip:${DEVICE_IP} \
          -v rte_ip:${RTE_IP} \
          -v config:${CONFIG} \
          -v fw_file:${FW_FILE} \
          dasharo-${_category}
}
# Function to handle Ctrl+C
handle_ctrl_c() {
    echo "Ctrl+C pressed. Exiting."
    # You can add cleanup tasks here if needed
    exit 1
}

# Trap SIGINT (Ctrl+C)
trap 'handle_ctrl_c' SIGINT

execute_robot "compatibility"
execute_robot "security"
execute_robot "performance"
