*** Variables ***
${DUT_CONNECTION_METHOD}=                           Telnet
${PAYLOAD}=                                         ${TBD}
${RTE_S2_N_PORT}=                                   13541
${FLASH_SIZE}=                                      ${TBD}
${FLASH_LENGTH}=                                    ${TBD}
${TIANOCORE_STRING}=                                ${TBD}
${BOOT_MENU_KEY}=                                   ${TBD}
${SETUP_MENU_KEY}=                                  ${TBD}
${BOOT_MENU_STRING}=                                ${TBD}
${SETUP_MENU_STRING}=                               ${TBD}
${IPXE_BOOT_ENTRY}=                                 ${TBD}
${EDK2_IPXE_CHECKPOINT}=                            ${TBD}
${MANUFACTURER}=                                    ${TBD}
${CPU}=                                             ${TBD}
${POWER_CTRL}=                                      sonoff
${FLASH_VERIFY_METHOD}=                             none
${WIFI_CARD}=                                       ${TBD}
${WIFI_CARD_UBUNTU}=                                ${TBD}
${LTE_CARD}=                                        ${TBD}
# ${ecc_string}    Single-bit ECC
# ${IOMMU_string}    (XEN) AMD-Vi: IOMMU 0 Enable
# ${dram_size}    ${4096}
# ${DEF_CORES_PER_SOCKET}    4
# ${DEF_THREADS_PER_CORE}    1
# ${DEF_THREADS_TOTAL}    4
# ${def_online_cpu}    0-3
# ${def_sockets}    1
# ${wol_interface}    enp3s0
# ${SD_DEV_LINUX}    /dev/mmcblk0
# ${nic_number}    ${4}
${LAPTOP_EC_SERIAL_WORKAROUND}=                     ${FALSE}

${DEVICE_USB_KEYBOARD}=                             ${TBD}
${DEVICE_NVME_DISK}=                                ${TBD}
${DEVICE_AUDIO1}=                                   ${TBD}
${DEVICE_AUDIO2}=                                   ${TBD}
${DEVICE_AUDIO1_WIN}=                               ${TBD}
${INITIAL_CPU_FREQUENCY}=                           ${TBD}

# SD Wire config
${SD_WIRES_CONNECTED}=                              ${1}
${SD_WIRE_SERIAL1}=                                 sd-wire_01-80

# eMMC driver support
${E_MMC_NAME}=                                      ${TBD}

# Platform flashing flags

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=                       ${FALSE}
${TESTS_IN_UBUNTU_SUPPORT}=                         ${FALSE}
${TESTS_IN_DEBIAN_SUPPORT}=                         ${FALSE}
${TESTS_IN_WINDOWS_SUPPORT}=                        ${FALSE}

# Regression test flags
# Test module: dasharo-compatibility
${BASE_PORT_BOOTBLOCK_SUPPORT}=                     ${FALSE}
${BASE_PORT_ROMSTAGE_SUPPORT}=                      ${FALSE}
${BASE_PORT_POSTCAR_SUPPORT}=                       ${FALSE}
${BASE_PORT_RAMSTAGE_SUPPORT}=                      ${FALSE}
${BASE_PORT_ALLOCATOR_V4_SUPPORT}=                  ${FALSE}
${PETITBOOT_PAYLOAD_SUPPORT}=                       ${FALSE}
${HEADS_PAYLOAD_SUPPORT}=                           ${FALSE}
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=                    ${FALSE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=                   ${FALSE}
${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}=             ${FALSE}
${COREBOOT_FAN_CONTROL_SUPPORT}=                    ${FALSE}
${INTERNAL_LCD_DISPLAY_SUPPORT}=                    ${FALSE}
${EXTERNAL_HDMI_DISPLAY_SUPPORT}=                   ${FALSE}
${EXTERNAL_DISPLAY_PORT_SUPPORT}=                   ${FALSE}
${EC_AND_SUPER_IO_SUPPORT}=                         ${FALSE}
${CUSTOM_LOGO_SUPPORT}=                             ${FALSE}
${USB_DISKS_DETECTION_SUPPORT}=                     ${FALSE}
${USB_KEYBOARD_DETECTION_SUPPORT}=                  ${FALSE}
${USB_CAMERA_DETECTION_SUPPORT}=                    ${FALSE}
${USB_TYPE_C_DISPLAY_SUPPORT}=                      ${FALSE}
${UEFI_SHELL_SUPPORT}=                              ${FALSE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=               ${FALSE}
${IPXE_BOOT_SUPPORT}=                               ${FALSE}
${NETBOOT_UTILITIES_SUPPORT}=                       ${FALSE}
${NVME_DISK_SUPPORT}=                               ${FALSE}
${SD_CARD_READER_SUPPORT}=                          ${FALSE}
${WIRELESS_CARD_SUPPORT}=                           ${FALSE}
${WIRELESS_CARD_WIFI_SUPPORT}=                      ${FALSE}
${WIRELESS_CARD_BLUETOOTH_SUPPORT}=                 ${FALSE}
${MINI_PC_IE_SLOT_SUPPORT}=                         ${FALSE}
${NVIDIA_GRAPHICS_CARD_SUPPORT}=                    ${FALSE}
${AUDIO_SUBSYSTEM_SUPPORT}=                         ${FALSE}
${SUSPEND_AND_RESUME_SUPPORT}=                      ${FALSE}
${SERIAL_NUMBER_VERIFICATION}=                      ${FALSE}
${SERIAL_FROM_MAC}=                                 ${FALSE}
${FIRMWARE_NUMBER_VERIFICATION}=                    ${FALSE}
${FIRMWARE_FROM_BINARY}=                            ${FALSE}
${PRODUCT_NAME_VERIFICATION}=                       ${FALSE}
${RELEASE_DATE_VERIFICATION}=                       ${FALSE}
${MANUFACTURER_VERIFICATION}=                       ${FALSE}
${VENDOR_VERIFICATION}=                             ${FALSE}
${FAMILY_VERIFICATION}=                             ${FALSE}
${TYPE_VERIFICATION}=                               ${FALSE}
${HARDWARE_WP_SUPPORT}=                             ${FALSE}
${DOCKING_STATION_USB_SUPPORT}=                     ${FALSE}
${DOCKING_STATION_KEYBOARD_SUPPORT}=                ${FALSE}
${DOCKING_STATION_USB_C_CHARGING_SUPPORT}=          ${FALSE}
${DOCKING_STATION_DETECT_SUPPORT}=                  ${FALSE}
${DOCKING_STATION_AUDIO_SUPPORT}=                   ${FALSE}
${EMMC_SUPPORT}=                                    ${FALSE}
${DTS_SUPPORT}=                                     ${FALSE}
${FIRMWARE_BUILDING_SUPPORT}=                       ${FALSE}
${CPU_TESTS_SUPPORT}=                               ${FALSE}
${DOCKING_STATION_NET_INTERFACE}=                   ${FALSE}
${DOCKING_STATION_HDMI}=                            ${FALSE}
${DOCKING_STATION_DISPLAY_PORT}=                    ${FALSE}
${UPLOAD_ON_USB_SUPPORT}=                           ${FALSE}
${DOCKING_STATION_SD_CARD_READER_SUPPORT}=          ${FALSE}
${RESET_TO_DEFAULTS_SUPPORT}=                       ${FALSE}
${DEFAULT_POWER_STATE_AFTER_FAIL}=                  Powered Off
${ESP_SCANNING_SUPPORT}=                            ${FALSE}

# Test module: dasharo-security
${TPM_SUPPORT}=                                     ${FALSE}
${VERIFIED_BOOT_SUPPORT}=                           ${FALSE}
${VERIFIED_BOOT_POPUP_SUPPORT}=                     ${FALSE}
${MEASURED_BOOT_SUPPORT}=                           ${FALSE}
${SECURE_BOOT_SUPPORT}=                             ${FALSE}
${SECURE_BOOT_DEFAULT_STATE}=                       Disabled
${USB_STACK_SUPPORT}=                               ${FALSE}
${USB_MASS_STORAGE_SUPPORT}=                        ${FALSE}
${TCG_OPAL_DISK_PASSWORD_SUPPORT}=                  ${FALSE}
${BIOS_LOCK_SUPPORT}=                               ${FALSE}
${SMM_WRITE_PROTECTION_SUPPORT}=                    ${FALSE}
${WIFI_BLUETOOTH_CARD_SWITCH_SUPPORT}=              ${FALSE}
${CAMERA_SWITCH_SUPPORT}=                           ${FALSE}
${EARLY_BOOT_DMA_SUPPORT}=                          ${FALSE}
${UEFI_PASSWORD_SUPPORT}=                           ${FALSE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                             ${FALSE}
${CPU_FREQUENCY_MEASURE}=                           ${FALSE}
${CPU_TEMPERATURE_MEASURE}=                         ${FALSE}
${PLATFORM_STABILITY_CHECKING}=                     ${FALSE}
${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}=            ${FALSE}
${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}=       ${FALSE}

# Test module: dasharo-stability
${M2_WIFI_SUPPORT}=                                 ${FALSE}
${NVME_DETECTION_SUPPORT}=                          ${FALSE}
${USB_TYPE-A_DEVICES_DETECTION_SUPPORT}=            ${FALSE}
${TPM_DETECT_SUPPORT}=                              ${FALSE}

# Supported OS installation variants

# Test cases iterations number
# Booting OS from USB stick test cases
${BOOT_FROM_USB_ITERATIONS_NUMBER}=                 5
# Sticks detection test cases
${USB_DETECTION_ITERATIONS_NUMBER}=                 5
# Platform boot measure test cases

# Other platform flags and counters
# Cooling procedure iterations
${COOLING_PROCEDURE_ITERATIONS}=                    0
# Stability tests duration in minutes
${STABILITY_TEST_DURATION}=                         300
# Interval between the following readings in stability tests
${STABILITY_TEST_MEASURE_INTERVAL}=                 10
# Frequency measure test duration
${FREQUENCY_TEST_DURATION}=                         60
# Interval between the following readings in frequency measure tests
${FREQUENCY_TEST_MEASURE_INTERVAL}=                 1
# Temperature measure test duration
${TEMPERATURE_TEST_DURATION}=                       3600
# Interval between the following readings in temperature measure tests
${TEMPERATURE_TEST_MEASURE_INTERVAL}=               1
# Fan control measure tests duration in minutes
# Interval between the following readings in fan control tests
# Custom fan curve tests duration in minutes
${CUSTOM_FAN_CURVE_TEST_DURATION}=                  30
# Interval between the following readings in custom fan curve tests
${CUSTOM_FAN_CURVE_MEASURE_INTERVAL}=               1
# Maximum fails during during performing test suite usb-boot.robot
${ALLOWED_FAILS_USB_BOOT}=                          0
# Maximum fails during during performing test suite usb-detect.robot
${ALLOWED_FAILS_USB_DETECT}=                        0
# Number of suspend and resume cycles performed during suspend test
${SUSPEND_ITERATIONS_NUMBER}=                       15
# Maximum number of fails during performing suspend and resume cycles
${SUSPEND_ALLOWED_FAILS}=                           0
# Number of Ubuntu booting iterations
# Number of Debian booting iterations
# Number of Ubuntu Server booting iterations
# Number of Proxmox VE booting iterations
# Number of pfSense (serial output) booting iterations
# Number of pfSense (VGA output) booting iterations
# Number of OPNsense (serial output) booting iterations
# Number of OPNsense (VGA output) booting iterations
# Number of FreeBSD booting iterations
# Number of Windows booting iterations
# Maximum fails during performing booting OS tests
# Maximum fails during performing docking station detect tests
${ALLOWED_DOCKING_STATION_DETECT_FAILS}=            0
# Number of iterations in stability detection tests
${STABILITY_DETECTION_COLDBOOT_ITERATIONS}=         2
${STABILITY_DETECTION_WARMBOOT_ITERATIONS}=         2
${STABILITY_DETECTION_REBOOT_ITERATIONS}=           5
${STABILITY_DETECTION_SUSPEND_ITERATIONS}=          5

# *** Keywords ***
#
# Note: for now we do not need to override the external flashing keywords (SD
# Wire)
