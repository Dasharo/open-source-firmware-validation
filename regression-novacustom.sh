#!/usr/bin/env bash

# Uncomment one of these
CONFIG="novacustom-ns50mu"
# CONFIG="novacustom-nv41pz"
# CONFIG="novacustom-nv41mz"
# CONFIG="novacustom-nv41mb"
# CONFIG="novacustom-ns70mu"
# CONFIG="novacustom-ns70pu"

RTE_IP=192.168.4.180

DEVICE_IP=192.168.4.188

FW_FILE="novacustom_ns5x_tgl_v1.5.2_full.rom"

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
  # "efi"
  # "custom-boot-menu-key"
  # "uefi-shell"
  # "network-boot"
  # # "reset-to-defaults"
  # "display-ports-and-lcd-support"
  # "usb-hid-and-msc-support"
  # "dmidecode"
  # "wifi-bluetooth-support"
  # "audio-subsystem"
  # "nvme-support"
  # "usb-camera"
  # "sd-card-reader"
  # # "usb-type-c-semiauto"
  # "usb-type-c"
  # "cpu-status"
  # "ec-and-super-IO"
  # "platform-suspend-and-resume"
  # "firmware-bulding-locally"
  # "logo-customization-functionality"
  # "nvidia"
)

security_tests=(
  # "secure-boot"
  # "usb-stack"
  # "uefi-password"
  # "tpm-support"
  # "measured-boot"
  # # "verified-boot"
  "network-stack"
  "me-neuter"
  "early-boot-dma-protection"
  "bios-lock"
  "smm-bios-write-protection"
  "wifi-bluetooth-switch"
  "camera-switch"
)

stability_tests=(
  "m2-wifi"
  "network-interface-after-suspend"
  "nvme-detection"
  "tpm-detect"
  "usb-type-a-devices-detection"
)

performance_tests=(
  "platform-stability"
  "boot-time-measure"
  "custom-fan-curve"
  "cpu-temperature"
  "cpu-frequency"
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

# Stability tests
for test in "${stability_tests[@]}"; do
    execute_robot "stability" "$test"
done

# Performance tests
for test in "${performance_tests[@]}"; do
    execute_robot "performance" "$test"
done
