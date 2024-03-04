#!/usr/bin/env bash

# RTE_IP alone should be enough for running the regression.
# If for some reason, Sonoff/PiKVM IPs are not correct, they
# should be changed in the variables.robot file
RTE_IP=192.168.10.55

# This one must be retrieved manually from the DUT before starting regression
DEVICE_IP=192.168.10.39

# Uncomment one of these
CONFIG="protectli-v1210"
# CONFIG="protectli-v1410"
# CONFIG="protectli-v1610"

FW_FILE="protectli_v1210_v0.9.2.rom"

OS=ubuntu
# OS=windows

if [ ! -f "${FW_FILE}" ]; then
    echo "${FW_FILE} not found. Please provide correct FW_FILE value"
    exit 1
fi

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
  "efi"
  "display-ports-and-lcd-support"
  "usb-hid-and-msc-support"
  "uefi-shell"
  "dmidecode"
  "custom-boot-menu-key"
  "wifi-bluetooth-support"
  # "audio-subsystem"
  "nvme-support"
  "reset-to-defaults"
  "network-boot-utilities"
  "eMMC-support"
  "usb-boot"
  "usb-detect"
  "custom-network-boot-entries"
  "miniPCIe-slot-verification"
)

security_tests=(
  "tpm-support"
  "measured-boot"
  # "verified-boot"
  # "bios-lock"
  "secure-boot"
  "usb-stack"
  "smm-bios-write-protection"
  # "me-neuter"
)

performance_tests=(
  "boot-time-measure"
  "cpu-temperature"
  "cpu-frequency"
  "platform-stability"
  # "free-bsd-booting-performance-test"
  # "opnsense-serial-booting-performance-test"
  # "opnsense-vga-booting-performance-test"
  # "pfsense-serial-booting-performance-test"
  # "pfsense-vga-booting-performance-test"
  # "proxmox-booting-performance-test"
  # "ubuntu-booting-performance-test"
  # "ubuntu-server-booting-performance-test"
  # "windows-booting-performance-test"
)


# Compatibility tests
for test in "${compatibility_tests[@]}"; do
    execute_robot "compatibility" "$test"
done

# Security tests
for test in "${security_tests[@]}"; do
    execute_robot "security" "$test"
done

# Performance tests
for test in "${performance_tests[@]}"; do
    execute_robot "performance" "$test"
done
