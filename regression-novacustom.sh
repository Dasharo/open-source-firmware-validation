#!/usr/bin/env bash

DEVICE_IP=192.168.4.240

# Uncomment one of these
CONFIG="novacustom-nv41mz"
# CONFIG="novacustom-nv41pz"
# CONFIG="novacustom-ns70mu"
# CONFIG="novacustom-ns70pu"

FW_FILE="coreboot.rom"

if [ ! -f "${FW_FILE}" ]; then
    echo "${FW_FILE} not found. Please provide correct FW_FILE value"
    exit 1
fi

# Function to execute the robot command
execute_robot() {
    local _category=$1
    local _test_name=$2
    local _log_file="${_test_name}_log.html"
    # local _report_file="${_test_name}_report.html"
    # local _output_file="${_test_name}.xml"

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
  "efi"
  "display-ports-and-lcd-support"
  "usb-hid-and-msc-support"
  # "uefi-shell"
  "dmidecode"
  # "custom-boot-menu-key"
  "wifi-bluetooth-support"
  "audio-subsystem"
  "nvme-support"
  # "network-boot"
  "cpu-status"
  # "reset-to-defaults"
  "platform-suspend-and-resume"
  "ec-and-super-IO"
  "sd-card-reader"
  "usb-camera"
  "cpu-status"
  # "boot-blocking"
  "docking-station-detect"
  "docking-station-usb-c-charging"
  "docking-station-usb-devices"
  "docking-station-net-interface"
  "docking-station-display-ports"
  "docking-station-audio"
  "docking-station-sd-card-reader"
#   "thunderbolt-docking-station"
#   "thunderbolt-docking-station-usb-devices"
#   "thunderbolt-docking-station-net-interface"
#   "thunderbolt-docking-station-display-ports"
#   "thunderbolt-docking-station-audio"
)

security_tests=(
  "tpm-support"
  "measured-boot"
  # "verified-boot"
  # "network-stack"
  # "me-neuter"
  # "uefi-password"
  # "early-boot-dma-protection"
  # "usb-stack"
  # "bios-lock"
  # "smm-bios-write-protection"
)

# performance_tests=(
#   "cpu-temperature"
#   "cpu-frequency"
# )

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
# for test in "${performance_tests[@]}"; do
#     execute_robot "security" "$test"
# done
