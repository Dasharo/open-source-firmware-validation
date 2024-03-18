*** Settings ***
Resource    default.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=                   Telnet
${DUT_CONNECTION_METHOD}=                           ${INITIAL_DUT_CONNECTION_METHOD}
${PAYLOAD}=                                         tianocore
${RTE_S2_N_PORT}=                                   13541
${FLASH_SIZE}=                                      ${8*1024*1024}
${FLASH_LENGTH}=                                    ${EMPTY}
${TIANOCORE_STRING}=                                ENTER
${BOOT_MENU_KEY}=                                   ${F11}
${SETUP_MENU_KEY}=                                  ${DELETE}
${BOOT_MENU_STRING}=                                Please select boot device:
${SETUP_MENU_STRING}=                               Select Entry
${IPXE_BOOT_ENTRY}=                                 iPXE Network Boot
${EDK2_IPXE_CHECKPOINT}=                            iPXE Shell
${MANUFACTURER}=                                    PC Engines
${CPU}=                                             AMD GX-412TC SOC
${INITIAL_CPU_FREQUENCY}=                           1000
${DEF_CORES}=                                       4
${DEF_THREADS}=                                     1
${DEF_CPU}=                                         4
${DEF_ONLINE_CPU}=                                  0-3
${DEF_SOCKETS}=                                     1
${POWER_CTRL}=                                      RteCtrl
${FLASH_VERIFY_METHOD}=                             tianocore-shell
${FLASH_VERIFY_OPTION}=                             UEFI Shell
# TODO
${MAX_CPU_TEMP}=                                    ${EMPTY}

${DMIDECODE_MANUFACTURER}=                          PC Engines
${DMIDECODE_VENDOR}=                                3mdeb
${DMIDECODE_FAMILY}=                                N/A
# TODO
${DMIDECODE_TYPE}=                                  Desktop

${DEVICE_AUDIO1}=                                   ${EMPTY}
${DEVICE_AUDIO2}=                                   ${EMPTY}
${WIFI_CARD_UBUNTU}=                                ${EMPTY}
${USB_MODEL}=                                       ${EMPTY}
${USB_DEVICE}=                                      ${EMPTY}
${SD_CARD_VENDOR}=                                  ${EMPTY}
${SD_CARD_MODEL}=                                   ${EMPTY}

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=                       ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                         ${FALSE}
${TESTS_IN_DEBIAN_SUPPORT}=                         ${FALSE}
${TESTS_IN_WINDOWS_SUPPORT}=                        ${FALSE}

# Regression test flags
${DASHARO_SECURITY_MENU_SUPPORT}=                   ${FALSE}
${DASHARO_USB_MENU_SUPPORT}=                        ${FALSE}
${DASHARO_NETWORKING_MENU_SUPPORT}=                 ${FALSE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=                   ${FALSE}
${DASHARO_CHIPSET_MENU_SUPPORT}=                    ${FALSE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=                 ${FALSE}
${DASHARO_PCI_PCIE_MENU_SUPPORT}=                   ${FALSE}
${DASHARO_PCIE_REBAR_SUPPORT}=                      ${FALSE}
${DASHARO_MEMORY_MENU_SUPPORT}=                     ${FALSE}
# Test module: dasharo-compatibility
${BASE_PORT_ALLOCATOR_V4_SUPPORT}=                  ${FALSE}
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
${UEFI_SHELL_SUPPORT}=                              ${TRUE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=               ${TRUE}
${IPXE_BOOT_SUPPORT}=                               ${FALSE}
${NVME_DISK_SUPPORT}=                               ${FALSE}
${SD_CARD_READER_SUPPORT}=                          ${FALSE}
${WIRELESS_CARD_SUPPORT}=                           ${FALSE}
${WIRELESS_CARD_WIFI_SUPPORT}=                      ${FALSE}
${WIRELESS_CARD_BLUETOOTH_SUPPORT}=                 ${FALSE}
${NVIDIA_GRAPHICS_CARD_SUPPORT}=                    ${FALSE}
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
${EMMC_SUPPORT}=                                    ${FALSE}
${DTS_SUPPORT}=                                     ${FALSE}
${FIRMWARE_BUILDING_SUPPORT}=                       ${FALSE}
${DOCKING_STATION_NET_INTERFACE}=                   ${FALSE}
${DOCKING_STATION_HDMI}=                            ${FALSE}
${DOCKING_STATION_DISPLAY_PORT}=                    ${FALSE}
${UPLOAD_ON_USB_SUPPORT}=                           ${FALSE}
${DOCKING_STATION_SD_CARD_READER_SUPPORT}=          ${FALSE}
${CPU_TESTS_SUPPORT}=                               ${FALSE}
${RESET_TO_DEFAULTS_SUPPORT}=                       ${FALSE}
${L3_CACHE_SUPPORT}=                                ${FALSE}
${L4_CACHE_SUPPORT}=                                ${FALSE}
${MEMORY_PROFILE_SUPPORT}=                          ${FALSE}
${DEFAULT_POWER_STATE_AFTER_FAIL}=                  Powered Off
${ESP_SCANNING_SUPPORT}=                            ${FALSE}
${DTS_FIRMWARE_FLASHING_SUPPORT}=                   ${FALSE}
${DTS_EC_FLASHING_SUPPORT}=                         ${FALSE}
${BASE_PORT_BOOTBLOCK_SUPPORT}=                     ${FALSE}
${BASE_PORT_ROMSTAGE_SUPPORT}=                      ${FALSE}
${BASE_PORT_POSTCAR_SUPPORT}=                       ${FALSE}
${BASE_PORT_RAMSTAGE_SUPPORT}=                      ${FALSE}
${BOOT_BLOCKING_SUPPORT}=                           ${FALSE}
${FAN_SPEED_MEASURE_SUPPORT}=                       ${FALSE}
${DOCKING_STATION_AUDIO_SUPPORT}=                   ${FALSE}
${DOCKING_STATION_DETECT_SUPPORT}=                  ${FALSE}
${HEADS_PAYLOAD_SUPPORT}=                           ${FALSE}
${DEVICE_TREE_SUPPORT}=                             ${FALSE}
${MINI_PC_IE_SLOT_SUPPORT}=                         ${FALSE}
${NETBOOT_UTILITIES_SUPPORT}=                       ${FALSE}
${PETITBOOT_PAYLOAD_SUPPORT}=                       ${FALSE}
${HIBERNATION_AND_RESUME_SUPPORT}=                  ${FALSE}

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
${CPU_TEMPERATURE_MEASURE}=                         ${FALSE}
${CPU_FREQUENCY_MEASURE}=                           ${FALSE}
${PLATFORM_STABILITY_CHECKING}=                     ${FALSE}
${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}=            ${FALSE}
${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}=       ${FALSE}

# Test module: dasharo-stab
${M2_WIFI_SUPPORT}=                                 ${FALSE}
${TPM_DETECT_SUPPORT}=                              ${FALSE}
${NVME_DETECTION_SUPPORT}=                          ${FALSE}
${USB_TYPE-A_DEVICES_DETECTION_SUPPORT}=            ${FALSE}
${NETWORK_INTERFACE_AFTER_SUSPEND_SUPPORT}=         ${FALSE}

# Test cases iterations number
# Booting OS from USB stick test cases
${BOOT_FROM_USB_ITERATIONS_NUMBER}=                 0
# Sticks detection test cases
${USB_DETECTION_ITERATIONS_NUMBER}=                 0

# Other platform flags and counters
# Cooling procedure iterations
${COOLING_PROCEDURE_ITERATIONS}=                    0
# Stability tests duration in minutes
${STABILITY_TEST_DURATION}=                         15
# Interval between the following readings in stability tests
${STABILITY_TEST_MEASURE_INTERVAL}=                 5
# Frequency measure test duration
${FREQUENCY_TEST_DURATION}=                         60
# Interval between the following readings in frequency measure tests
${FREQUENCY_TEST_MEASURE_INTERVAL}=                 1
# Temperature measure test duration
${TEMPERATURE_TEST_DURATION}=                       60
# Interval between the following readings in temperature measure tests
${TEMPERATURE_TEST_MEASURE_INTERVAL}=               1
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
# Maximum fails during performing docking station detect tests
${ALLOWED_DOCKING_STATION_DETECT_FAILS}=            0
# Number of iterations in stability detection tests
${STABILITY_DETECTION_COLDBOOT_ITERATIONS}=         2
${STABILITY_DETECTION_WARMBOOT_ITERATIONS}=         2
${STABILITY_DETECTION_REBOOT_ITERATIONS}=           5
${STABILITY_DETECTION_SUSPEND_ITERATIONS}=          5

*** Keywords ***
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    Sleep    2s
    RteCtrl Power Off
    Sleep    10s
    Telnet.Read
    RteCtrl Power On
