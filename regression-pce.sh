#!/usr/bin/env bash

# RTE_IP alone should be enough for running the regression.
# If for some reason, Sonoff/PiKVM IPs are not correct, they
# should be changed in the variables.robot file
RTE_IP=192.168.10.176

# This one must be retrieved manually from the DUT before starting regression
DEVICE_IP=192.168.10.86

# Uncomment one of these
CONFIG="pcengines-apu6"

FW_FILE="pcengines_apu6_v0.9.0.rom"

if [ ! -f "${FW_FILE}" ]; then
    echo "${FW_FILE} not found. Please provide correct FW_FILE value"
    exit 1
fi

# Function to execute the robot command
execute_robot() {
    local _category=$1
    local _test_name=$2
    local _log_file="${_test_name}_log.html"

    robot -L TRACE \
          -l ${CONFIG}-${OS}/${_log_file} \
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
  "apu-configuration-menu"
  "auto-boot-time-out"
  "cpu-status"
  "custom-boot-menu-key"
  "custom-network-boot-entries"
  "dasharo-tools-suite"
  "dmidecode"
  "efi"
  "esp-scanning"
  "firmware-building-locally"
  "network-boot"
  "reset-to-defaults"
  "uefi-shell"
  "usb-boot"
  "usb-detect"
  "usb-hid-and-msc-support"
  "wifi-bluetooth-support"
)

security_tests=(
  "tpm-support"
  "measured-boot"
  "verified-boot"
  "bios-lock"
  "secure-boot"
  "usb-stack"
  "network-stack"
  "uefi-password"
  "tpm2-commands"
)

performance_tests=(
  "cpu-temperature"
  "cpu-frequency"
  "platform-stability"
  "ubuntu-server-booting-performance-test"
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

Performance tests
for test in "${performance_tests[@]}"; do
    execute_robot "security" "$test"
done
