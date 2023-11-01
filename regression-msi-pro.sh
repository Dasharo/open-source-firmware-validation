#!/usr/bin/env bash

# RTE_IP alone should be enough for running the regression.
# If for some reason, Sonoff/PiKVM IPs are not correct, they
# should be changed in the variables.robot file
RTE_IP=192.168.10.199

# This one must be retrieved manually from the DUT before starting regression
DEVICE_IP=192.168.10.152

# Uncomment one of these
CONFIG="msi-pro-z690-a-wifi-ddr4"
# CONFIG="msi-pro-z690-a-ddr5"
# CONFIG="msi-pro-z790-p"

FW_FILE="msi_ms7d25_ddr4_v1.1.2_serial.rom"

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
  "logo-customization-functionality"
  "custom-boot-menu-key"
  "wifi-bluetooth-support"
  "audio-subsystem"
  "nvme-support"
  "network-boot"
  "uefi-shell"
  "cpu-status"
  "reset-to-defaults"
  "platform-suspend-and-resume"
  "memory-profile"
)

security_tests=(
  "tpm-support"
  "measured-boot"
  "verified-boot"
  "network-stack"
  "me-neuter"
  "uefi-password"
  "early-boot-dma-protection"
  "tcg-opal-disk-password"
  "usb-stack"
  "bios-lock"
  "smm-bios-write-protection"
)

performance_tests=(
  "cpu-temperature"
  "cpu-frequency"
)

### Firmware + Ubuntu tests ###
# Flags to be set in config:
# ${initial_dut_connection_method}                    pikvm
# ${tests_in_firmware_support}                        ${True}
# ${tests_in_ubuntu_support}                          ${True}

OS=ubuntu

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

# TODO: We could set RF flags within this script, to avoid manual edition of configs
# ### Firmware + Windows tests (?) ###
# OS=windows
#
# for test in "${compatibility_tests[@]}"; do
#     execute_robot "compatibility" "$test"
# done
#
# # Security tests
# for test in "${security_tests[@]}"; do
#     execute_robot "security" "$test"
# done
#
# # Performance tests
# for test in "${performance_tests[@]}"; do
#     execute_robot "performance" "$test"
# done
