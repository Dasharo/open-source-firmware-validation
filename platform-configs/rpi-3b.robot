*** Variables ***
${DUT_CONNECTION_METHOD}=                           Telnet
${PAYLOAD}=                                         ${EMPTY}
${RTE_S2_N_PORT}=                                   13541
${FLASH_SIZE}=                                      ${EMPTY}
${FLASH_LENGTH}=                                    ${EMPTY}
${TIANOCORE_STRING}=                                ${EMPTY}
${BOOT_MENU_KEY}=                                   ${EMPTY}
${SETUP_MENU_KEY}=                                  ${EMPTY}
${BOOT_MENU_STRING}=                                ${EMPTY}
${SETUP_MENU_STRING}=                               ${EMPTY}
${PAYLOAD_STRING}=                                  ${EMPTY}
${EDK2_IPXE_STRING}=                                ${EMPTY}
${EDK2_IPXE_CHECKPOINT}=                            ${EMPTY}
${EDK2_IPXE_START_POS}=                             ${EMPTY}
${IPXE_BOOT_ENTRY}=                                 ${EMPTY}
${IPXE_STRING}=                                     ${EMPTY}
${IPXE_STRING2}=                                    ${EMPTY}
${IPXE_KEY}=                                        ${EMPTY}
${NET_BOOT_KEY}=                                    ${EMPTY}
${SOL_STRING}=                                      ${EMPTY}
${SN_PATTERN}=                                      ${EMPTY}
${MANUFACTURER}=                                    ${EMPTY}
${CPU}=                                             ${EMPTY}
${POWER_CTRL}=                                      sonoff
${FLASH_VERIFY_METHOD}=                             none
${INCORRECT_SIGNATURES_FIRMWARE}=                   ${EMPTY}
${WIFI_CARD}=                                       ${EMPTY}
${WIFI_CARD_UBUNTU}=                                ${EMPTY}
${LTE_CARD}=                                        ${EMPTY}
# ${ecc_string}    Single-bit ECC
# ${IOMMU_string}    (XEN) AMD-Vi: IOMMU 0 Enable
# ${dram_size}    ${4096}
# ${def_cores}    4
# ${def_threads}    1
# ${def_cpu}    4
# ${def_online_cpu}    0-3
# ${def_sockets}    1
# ${wol_interface}    enp3s0
# ${SD_DEV_LINUX}    /dev/mmcblk0
# ${nic_number}    ${4}
${DEVICE_USB_KEYBOARD}=                             ${EMPTY}
${DEVICE_NVME_DISK}=                                ${EMPTY}
${DEVICE_AUDIO1}=                                   ${EMPTY}
${DEVICE_AUDIO2}=                                   ${EMPTY}
${DEVICE_AUDIO1_WIN}=                               ${EMPTY}
${INITIAL_CPU_FREQUENCY}=                           ${EMPTY}
${WIN_USB_STICK}=                                   ${EMPTY}
${USB_SHORT_NAME}=                                  ${EMPTY}
${INITIAL_FAN_RPM}=                                 ${EMPTY}
${ACCEPTED_%_NEAR_INITIAL_RPM}=                     ${EMPTY}

# eMMC driver support
${E_MMC_NAME}=                                      ${EMPTY}
${E_MMC_PARTITION_TABLE}=                           ${EMPTY}

# Platform flashing flags
${FLASHING_BASIC_METHOD}=                           ${EMPTY}

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=                       ${FALSE}
${TESTS_IN_UBUNTU_SUPPORT}=                         ${FALSE}
${TESTS_IN_DEBIAN_SUPPORT}=                         ${FALSE}
${TESTS_IN_WINDOWS_SUPPORT}=                        ${FALSE}
${TESTS_IN_UBUNTU_SERVER_SUPPORT}=                  ${FALSE}
${TESTS_IN_PROXMOX_VE_SUPPORT}=                     ${FALSE}
${TESTS_IN_PFSENSE_SERIAL_SUPPORT}=                 ${FALSE}
${TESTS_IN_PFSENSE_VGA_SUPPORT}=                    ${FALSE}
${TESTS_IN_OPNSENSE_SERIAL_SUPPORT}=                ${FALSE}
${TESTS_IN_OPNSENSE_VGA_SUPPORT}=                   ${FALSE}
${TESTS_IN_FREEBSD_SUPPORT}=                        ${FALSE}

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
${USB_C_CHARGING_SUPPORT}=                          ${FALSE}
${THUNDERBOLT_CHARGING_SUPPORT}=                    ${FALSE}
${USB_C_DISPLAY_SUPPORT}=                           ${FALSE}
${AUDIO_SUBSYSTEM_SUPPORT}=                         ${FALSE}
${SUSPEND_AND_RESUME_SUPPORT}=                      ${FALSE}
${SERIAL_NUMBER_VERIFICATION}=                      ${FALSE}
${SERIAL_FROM_MAC}=                                 ${FALSE}
${FIRMWARE_NUMBER_VERIFICATION}=                    ${FALSE}
${FIRMWARE_FROM_BINARY}=                            ${FALSE}
${PRODUCT_NAME_VERIFICATION}=                       ${FALSE}
${RELEASE_DATE_VERIFICATION}=                       ${FALSE}
${RELEASE_DATE_FROM_SOL}=                           ${FALSE}
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
${DOCKING_STATION_UPLOAD_SUPPORT}=                  ${FALSE}
${THUNDERBOLT_DOCKING_STATION_SUPPORT}=             ${FALSE}
${THUNDERBOLT_DOCKING_STATION_USB_SUPPORT}=         ${FALSE}
${THUNDERBOLT_DOCKING_STATION_KEYBOARD_SUPPORT}=    ${FALSE}
${THUNDERBOLT_DOCKING_STATION_UPLOAD_SUPPORT}=      ${FALSE}
${THUNDERBOLT_DOCKING_STATION_NET_INTERFACE}=       ${FALSE}
${THUNDERBOLT_DOCKING_STATION_HDMI}=                ${FALSE}
${THUNDERBOLT_DOCKING_STATION_DISPLAY_PORT}=        ${FALSE}
${THUNDERBOLT_DOCKING_STATION_AUDIO_SUPPORT}=       ${FALSE}
${DOCKING_STATION_SD_CARD_READER_SUPPORT}=          ${FALSE}
${RESET_TO_DEFAULTS_SUPPORT}=                       ${FALSE}

# Test module: dasharo-security
${TPM_SUPPORT}=                                     ${FALSE}
${VBOOT_KEYS_GENERATING_SUPPORT}=                   ${FALSE}
${VERIFIED_BOOT_SUPPORT}=                           ${FALSE}
${VERIFIED_BOOT_POPUP_SUPPORT}=                     ${FALSE}
${MEASURED_BOOT_SUPPORT}=                           ${FALSE}
${SECURE_BOOT_SUPPORT}=                             ${FALSE}
${ME_NEUTER_SUPPORT}=                               ${FALSE}
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
${DEVICE_BOOT_MEASURE_SUPPORT}=                     ${FALSE}
${CPU_FREQUENCY_MEASURE}=                           ${FALSE}
${CPU_TEMPERATURE_MEASURE}=                         ${FALSE}
${PLATFORM_STABILITY_CHECKING}=                     ${FALSE}
${TEST_FAN_SPEED}=                                  ${FALSE}
${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}=            ${FALSE}
${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}=       ${FALSE}
${UBUNTU_BOOTING}=                                  ${FALSE}
${DEBIAN_BOOTING}=                                  ${FALSE}
${UBUNTU_SERVER_BOOTING}=                           ${FALSE}
${PROXMOX_VE_BOOTING}=                              ${FALSE}
${PFSENSE_SERIAL_BOOTING}=                          ${FALSE}
${PFSENSE_VGA_BOOTING}=                             ${FALSE}
${OPNSENSE_SERIAL_BOOTING}=                         ${FALSE}
${OPNSENSE_VGA_BOOTING}=                            ${FALSE}
${FREEBSD_BOOTING}=                                 ${FALSE}
${WINDOWS_BOOTING}=                                 ${FALSE}

# Test module: dasharo-stability
${M2_WIFI_SUPPORT}=                                 ${FALSE}
${NVME_DETECTION_SUPPORT}=                          ${FALSE}
${USB_TYPE-A_DEVICES_DETECTION_SUPPORT}=            ${FALSE}
${TPM_DETECT_SUPPORT}=                              ${FALSE}

# Supported OS installation variants
${INSTALL_DEBIAN_USB_SUPPORT}=                      ${FALSE}
${INSTALL_UBUNTU_USB_SUPPORT}=                      ${FALSE}

# Test cases iterations number
# Booting OS from USB stick test cases
${BOOT_FROM_USB_ITERATIONS_NUMBER}=                 5
# Sticks detection test cases
${USB_DETECTION_ITERATIONS_NUMBER}=                 5
# Platform boot measure test cases
${DEVICE_BOOT_MEASURE_ITTERATIONS}=                 3

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
${TEMPERATURE_TEST_DURATION}=                       60
# Interval between the following readings in temperature measure tests
${TEMPERATURE_TEST_MEASURE_INTERVAL}=               1
# Fan control measure tests duration in minutes
${FAN_CONTROL_TEST_DURATION}=                       30
# Interval between the following readings in fan control tests
${FAN_CONTROL_MEASURE_INTERVAL}=                    3
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
${UBUNTU_BOOTING_ITERATIONS}=                       5
# Number of Debian booting iterations
${DEBIAN_BOOTING_ITERATIONS}=                       5
# Number of Ubuntu Server booting iterations
${UBUNTU_SERVER_BOOTING_ITERATIONS}=                5
# Number of Proxmox VE booting iterations
${PROXMOX_VE_BOOTING_ITERATIONS}=                   5
# Number of pfSense (serial output) booting iterations
${PFSENSE_SERIAL_BOOTING_ITERATIONS}=               5
# Number of pfSense (VGA output) booting iterations
${PFSENSE_VGA_BOOTING_ITERATIONS}=                  5
# Number of OPNsense (serial output) booting iterations
${OPNSENSE_SERIAL_BOOTING_ITERATIONS}=              5
# Number of OPNsense (VGA output) booting iterations
${OPNSENSE_VGA_BOOTING_ITERATIONS}=                 5
# Number of FreeBSD booting iterations
${FREEBSD_BOOTING_ITERATIONS}=                      5
# Number of Windows booting iterations
${WINDOWS_BOOTING_ITERATIONS}=                      5
# Maximum fails during performing booting OS tests
${ALLOWED_BOOTING_FAILS}=                           0
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
