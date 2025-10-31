*** Settings ***
Resource        ../../lib/options/${OPTIONS_LIB}.robot
Variables       ../../os-config/environment-test-ids.py


*** Variables ***
${TBD}=
...                                                 TBD_variable_not_set_and_should_be_defined_in_platform_config_if_needed
${INITIAL_DUT_CONNECTION_METHOD}=                   ${TBD}
${DUT_CONNECTION_METHOD}=                           ${TBD}
${TELNET_FUZZY_MAX_SUBSTITUTIONS}=                  0
${TELNET_FUZZY_MAX_INSERTIONS}=                     0
${TELNET_FUZZY_MAX_DELETIONS}=                      0
${PAYLOAD}=                                         tianocore
${RTE_S2_N_PORT}=                                   13541
${FLASH_SIZE}=                                      ${TBD}
${FLASH_LENGTH}=                                    ${TBD}
${TIANOCORE_STRING}=                                to boot directly
${BOOT_MENU_KEY}=                                   ${F11}
${SETUP_MENU_KEY}=                                  ${DELETE}
${BOOT_MENU_STRING}=                                Please select boot device:
${SETUP_MENU_STRING}=                               Select Entry
${IPXE_BOOT_ENTRY}=                                 iPXE Network Boot
${EDK2_IPXE_CHECKPOINT}=                            iPXE Shell
${MANUFACTURER}=                                    ${TBD}
${CPU}=                                             ${TBD}
${POWER_CTRL}=                                      ${TBD}
${FLASH_VERIFY_METHOD}=                             ${TBD}
${WIFI_CARD}=                                       ${TBD}
${MAX_CPU_TEMP}=                                    ${TBD}
${INTERNAL_PROGRAMMER_CHIPNAME}=                    Opaque flash chip
${FLASHING_METHOD}=                                 external
${SNIPEIT}=                                         yes
${SEABIOS_BOOT_DEVICE}=                             ${EMPTY}
${CHECK_POWER_LED_SUPPORT}=                         ${TRUE}
${DUT_HAS_RESET_BUTTON}=                            ${TRUE}
${DUT_HAS_POWER_BUTTON}=                            ${TRUE}
${DUT_HAS_CMOS_RESET}=                              ${TRUE}

# Should semi auto tests be performed
${SEMI_AUTO}=                                       ${FALSE}

# Hello, world!
${HELLO_EFI_STRING}=                                UEFI Hello, Dasharo Universe!
${SB_ERROR_STRING}=                                 The image signature is invalid or missing!

# See: https://github.com/Dasharo/dasharo-issues/issues/614
${LAPTOP_EC_SERIAL_WORKAROUND}=                     ${FALSE}

# Library config
# Option library: UEFI configuration variable backend.
# - options-lib_uefi-setup-menu: Will set options via the UEFI Setup menu (serial)
# - dcu: Will use Dasharo Configuration Utility to configure options.
${OPTIONS_LIB}=                                     options-lib_uefi-setup-menu

# OS config
${DEVICE_OS_USERNAME}=                              ${TBD}
${DEVICE_OS_PASSWORD}=                              ${TBD}
${DEVICE_OS_USER_PROMPT}=                           ${TBD}
${DEVICE_OS_ROOT_PROMPT}=                           ${TBD}

${3_MDEB_WIFI_NETWORK}=                             3mdeb_Laboratorium

${FW_VERSION}=                                      ${TBD}
${DMIDECODE_SERIAL_NUMBER}=                         ${TBD}
${DMIDECODE_FIRMWARE_VERSION}=                      ${TBD}
${DMIDECODE_PRODUCT_NAME}=                          ${TBD}
${DMIDECODE_RELEASE_DATE}=                          ${TBD}
${DMIDECODE_MANUFACTURER}=                          ${TBD}
${DMIDECODE_VENDOR}=                                ${TBD}
${DMIDECODE_FAMILY}=                                ${TBD}
${DMIDECODE_TYPE}=                                  ${TBD}

${DEVICE_USB_KEYBOARD}=                             ${TBD}
${DEVICE_NVME_DISK}=                                ${TBD}
${WIFI_CARD_UBUNTU}=                                ${TBD}
${USB_MODEL}=                                       ${TBD}
${USB_DEVICE}=                                      ${TBD}
@{ATTACHED_USB}=                                    ${TBD}

${FLASHROM_FLAGS}=                                  ${TBD}

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=                       ${FALSE}
${TESTS_IN_UBUNTU_SUPPORT}=                         ${FALSE}
${TESTS_IN_DEBIAN_SUPPORT}=                         ${FALSE}
${TESTS_IN_WINDOWS_SUPPORT}=                        ${FALSE}
${TESTS_IN_METATB_SUPPORT}=                         ${FALSE}
${TESTS_IN_HEADS_SUPPORT}=                          ${FALSE}
${TESTS_IN_FEDORA_SUPPORT}=                         ${FALSE}
${TESTS_IN_OPENWRT_SUPPORT}=                        ${FALSE}

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
${DASHARO_SERIAL_PORT_MENU_SUPPORT}=                ${TRUE}
# Test module: dasharo-compatibility
${ACPI_DRIVER_SUPPORT}=                             ${FALSE}
${BASE_PORT_ALLOCATOR_V4_SUPPORT}=                  ${FALSE}
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=                    ${FALSE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=                   ${FALSE}
${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}=             ${FALSE}
${CUSTOM_BOOT_ORDER_SUPPORT}=                       ${FALSE}
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
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=               ${FALSE}
${IPXE_BOOT_SUPPORT}=                               ${FALSE}
${NVME_DISK_SUPPORT}=                               ${FALSE}
${NVME_X2_SLOT_SUPPORT}=                            ${FALSE}
${SD_CARD_READER_SUPPORT}=                          ${FALSE}
${WIRELESS_CARD_SUPPORT}=                           ${FALSE}
${WIRELESS_CARD_WIFI_SUPPORT}=                      ${FALSE}
${WIRELESS_CARD_BLUETOOTH_SUPPORT}=                 ${FALSE}
${NVIDIA_GRAPHICS_CARD_SUPPORT}=                    ${FALSE}
${AUDIO_SUBSYSTEM_SUPPORT}=                         ${FALSE}
${EXTERNAL_HEADSET_SUPPORT}=                        ${FALSE}
${INTERNAL_AUDIO_SUPPORT}=                          ${FALSE}
${HDMI_AUDIO_SUPPORT}=                              ${FALSE}
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
${EMMC_SUPPORT}=                                    ${FALSE}
${DTS_SUPPORT}=                                     ${FALSE}
${FIRMWARE_BUILDING_SUPPORT}=                       ${FALSE}
${DOCKING_STATION_NET_INTERFACE}=                   ${FALSE}
${DOCKING_STATION_HDMI}=                            ${FALSE}
${DOCKING_STATION_DISPLAY_PORT}=                    ${FALSE}
${UPLOAD_ON_USB_SUPPORT}=                           ${FALSE}
${DOCKING_STATION_SD_CARD_READER_SUPPORT}=          ${FALSE}
${CPU_TESTS_SUPPORT}=                               ${FALSE}
${HYPER_THREADING_SUPPORT}=                         ${FALSE}
${INTEL_HYBRID_ARCH_SUPPORT}=                       ${FALSE}
${RESET_TO_DEFAULTS_SUPPORT}=                       ${FALSE}
${L2_CACHE_SUPPORT}=                                ${TRUE}
${L3_CACHE_SUPPORT}=                                ${FALSE}
${L4_CACHE_SUPPORT}=                                ${FALSE}
${MEMORY_PROFILE_SUPPORT}=                          ${FALSE}
${MEMORY_IBECC_SUPPORT}=                            ${FALSE}
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
${SATA_SUPPORT}=                                    ${FALSE}
${HIBERNATION_AND_RESUME_SUPPORT}=                  ${FALSE}
${ME_STATICALLY_DISABLED}=                          ${FALSE}
${APU_CONFIGURATION_MENU_SUPPORT}=                  ${FALSE}
${WATCHDOG_SUPPORT}=                                ${FALSE}
${DCU_UUID_SUPPORT}=                                ${FALSE}
${DCU_SERIAL_SUPPORT}=                              ${FALSE}
${ROMHOLE_SUPPORT}=                                 ${FALSE}
${IR_CAMERA_SUPPORT}=                               ${FALSE}
${ACPI_CAMERA_SWITCH_SUPPORT}=                      ${TRUE}
${EXTRA_1_TB_DISK}=                                 ${FALSE}
# The same is not a guarantee for Windows
${POWERSHELL_STR_INTERNAL_OUT}=                     Speakers (Realtek(R) Audio)
${POWERSHELL_STR_INTERNAL_IN}=                      Microphone Array (Realtek(R) Audio)
# Since Realtek driver shows the same device for Headset and Internal audio
# for now we just copy the value, and will need better solution in future.
${POWERSHELL_STR_HEADSET_OUT}=                      ${POWERSHELL_STR_INTERNAL_OUT}
${POWERSHELL_STR_HEADSET_IN}=                       Microphone (Realtek(R) Audio)
${POWERSHELL_STR_HDMI_OUT}=                         Audio Driver for Display Audio

# Test module: dasharo-security
${TPM_SUPPORTED_VERSION}=                           ${NONE}
${TPM_EXPECTED_CHIP}=                               FILL_WITH_CORRECT_VALUE_BEFORE_TESTING
${TPM_SINGLE_BANK}=                                 ${FALSE}
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
${HAS_SUPERIO_SERIAL}=                              ${FALSE}
${INTEL_CBNT_SUPPORT}=                              ${FALSE}
${INTEL_CBNT_STATUS_MENU_SUPPORT}=                  ${FALSE}
${INTEL_CBNT_BOOTGUARD_FUSED}=                      ${FALSE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                             ${FALSE}
${CPU_TEMPERATURE_MEASURE}=                         ${FALSE}
${CPU_FREQUENCY_MEASURE}=                           ${FALSE}
${PLATFORM_STABILITY_CHECKING}=                     ${FALSE}
${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}=            ${FALSE}
${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}=       ${FALSE}
${CUSTOM_FAN_CURVE_OFF_MODE_SUPPORT}=               ${FALSE}
${DGPU_ONLY_SUPPORT}=                               ${FALSE}
# Variables used in lib/sensors to determine platform-specific methods of
# measuring temperatures, fans etc.
${SENSORS_CONFIG_FILE}=                             include/sensors/default-sensors-config.yaml
${CUSTOM_FAN_CURVE_FILE}=                           ${TBD}
${DISK_IO_PERFORMANCE_TESTS}=                       ${FALSE}
${CPU_PERFORMANCE_TESTS_SUPPORT}=                   ${FALSE}
${GPU_PERFORMANCE_TESTS_SUPPORT}=                   ${FALSE}
${MAX_ACCEPTABLE_AVERAGE_COLDBOOT_TIME_S}=          10
${MAX_ACCEPTABLE_COLDBOOT_TIME_STD_DEV_S}=          10
${MAX_ACCEPTABLE_COLDBOOT_TIME_S}=                  20
${MAX_ACCEPTABLE_AVERAGE_WARMBOOT_TIME_S}=          10
${MAX_ACCEPTABLE_WARMBOOT_TIME_STD_DEV_S}=          10
${MAX_ACCEPTABLE_WARMBOOT_TIME_S}=                  20
${MAX_ACCEPTABLE_AVERAGE_REBOOT_TIME_S}=            10
${MAX_ACCEPTABLE_REBOOT_TIME_STD_DEV_S}=            10
${MAX_ACCEPTABLE_REBOOT_TIME_S}=                    20
${FAST_AND_QUIET_BOOT_SUPPORT}=                     ${FALSE}

@{UPP_BENCHMARKS}=                                  ${TBD}
&{UPP_BLAKE2_BENCHMARK}=                            &{EMPTY}
&{UPP_CACHEBENCH_BENCHMARK}=                        &{EMPTY}
&{UPP_CRAFTY_BENCHMARK}=                            &{EMPTY}
&{UPP_SMALLPT_BENCHMARK}=                           &{EMPTY}

# Test module: dasharo-stab
${M2_WIFI_SUPPORT}=                                 ${FALSE}
${TPM_DETECT_SUPPORT}=                              ${FALSE}
${NVME_DETECTION_SUPPORT}=                          ${FALSE}
${USB_TYPE_A_DEVICES_DETECTION_SUPPORT}=            ${FALSE}
${NETWORK_INTERFACE_AFTER_SUSPEND_SUPPORT}=         ${FALSE}
${CAPSULE_UPDATE_SUPPORT}=                          ${FALSE}

# Test module: trenchboot
${TRENCHBOOT_SUPPORT}=                              ${FALSE}

# OpenWRT-specific variables
${OPENWRT_IMAGE_FILE}=                              ${TBD}
${OPENWRT_TARGET_DEVICE}=                           ${TBD}
${OPENWRT_ETHERNET_CONTROLLER}=                     ${TBD}
${OPENWRT_WIFI_UP_ATTEMPTS}=                        ${TBD}
${OPENWRT_WIFI_SCAN_ATTEMPTS}=                      ${TBD}

# Test cases iterations number
# Booting OS from USB stick test cases
${BOOT_FROM_USB_ITERATIONS_NUMBER}=                 0
# Sticks detection test cases
${USB_DETECTION_ITERATIONS_NUMBER}=                 0

# DTS
# Default DTS link for iPXE boot, can be overwritten by CMD:
${DTS_IPXE_LINK}=                                   http://boot.dasharo.com/dts/dts.ipxe
${BOOT_DTS_FROM_IPXE_SHELL}=                        ${FALSE}

# Other platform flags and counters
# Cooling procedure iterations
${COOLING_PROCEDURE_ITERATIONS}=                    0
# Stability tests duration in seconds
${STABILITY_TEST_DURATION}=                         900
# Interval between the following readings in stability tests
${STABILITY_TEST_MEASURE_INTERVAL}=                 300
# Frequency measure test duration
${FREQUENCY_TEST_DURATION}=                         3600
# Interval between the following readings in frequency measure tests
${FREQUENCY_TEST_MEASURE_INTERVAL}=                 60
# Temperature measure test duration
${TEMPERATURE_TEST_DURATION}=                       3600
# Interval between the following readings in temperature measure tests
${TEMPERATURE_TEST_MEASURE_INTERVAL}=               60
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
${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}=         NetworkBoot
${WINDOWS_SHUTDOWN_AWAITING_SECONDS}=               120

@{TESTED_LINUX_DISTROS}=                            ${ENV_ID_UBUNTU}
@{TESTED_BSD_DISTROS}=                              @{EMPTY}
${DEFAULT_BOOT_OS_ID}=                              ${ENV_ID_UBUNTU}
${BOOTED_OS_ID}=                                    ${DEFAULT_BOOT_OS_ID}

${USE_ANSIBLE}=                                     ${TRUE}
${TESTS_IN_XCP_NG_SUPPORT}=                         ${FALSE}
${TESTS_IN_ESXI_SUPPORT}=                           ${FALSE}

@{ETH_PERF_PAIR_10_G}=                              @{EMPTY}
@{ETH_PERF_PAIR_1_G}=                               @{EMPTY}
@{ETH_PERF_PAIR_2_G}=                               @{EMPTY}
@{ETH_PERF_2_ND_PAIR_2_G}=                          @{EMPTY}
@{ETH_PORTS}=                                       @{EMPTY}
@{ETH_SFP_PORTS}=                                   @{EMPTY}

${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=                3

@{MICROCODE_REVISIONS}=                             @{EMPTY}

# These were missing in default.robot and have been automatically
# identified and added via: ./scripts/ci/check_platform_configs_vars.py

${BLAKE2_TEST_SCORE}=                               ${TBD}
${BLUETOOTH_CARD_UBUNTU}=                           ${TBD}
${CACHEBENCH_TEST_SCORE}=                           ${TBD}
${CLEVO_BATTERY_CAPACITY}=                          ${TBD}
${CLEVO_USB_C_HUB}=                                 ${TBD}
${COREMARK_SINGLE}=                                 ${TBD}
${CPU_E_CORES_MAX}=                                 ${TBD}
${CPU_MAX_FREQUENCY}=                               ${TBD}
${CPU_MIN_FREQUENCY}=                               ${TBD}
${CPU_P_CORES_MAX}=                                 ${TBD}
${CPU_TEMPERATURE_MEASUREMENT_METHOD}=              ${TBD}
${CRAFTY_TEST_SCORE}=                               ${TBD}
${CRAY_1080_P_RENDER}=                              ${TBD}
${CRAY_4_K_RENDER}=                                 ${TBD}
${CRAY_5_K_RENDER}=                                 ${TBD}
${CUSTOM_FAN_CURVE_COOLDOWN_SECONDS}=               ${TBD}
${DEF_CORES_PER_SOCKET}=                            ${TBD}
${DEF_CORES}=                                       ${TBD}
${DEF_CPU}=                                         ${TBD}
${DEF_ONLINE_CPU}=                                  ${TBD}
${DEF_SOCKETS}=                                     ${TBD}
${DEF_THREADS_PER_CORE}=                            ${TBD}
${DEF_THREADS_TOTAL}=                               ${TBD}
${DEF_THREADS}=                                     ${TBD}
${DEVICE_AUDIO1_WIN}=                               ${TBD}
${DEVICE_AUDIO1}=                                   ${TBD}
${DEVICE_AUDIO2}=                                   ${TBD}
${DEVICE_USB_PASSWORD}=                             ${TBD}
${DEVICE_USB_PROMPT}=                               ${TBD}
${DEVICE_USB_ROOT_PROMPT}=                          ${TBD}
${DEVICE_USB_USERNAME}=                             ${TBD}
${DRAM_SIZE}=                                       ${TBD}
${EC_NO_SYNC_DOWNLOAD_LINK}=                        ${TBD}
${EC_NO_SYNC_VERSION}=                              ${TBD}
${ETHERNET_ID}=                                     ${TBD}
${EXTERNAL_HEADSET}=                                ${TBD}
${E_MMC_NAME}=                                      ${TBD}
${FAN_PWM_MEASUREMENT_HWMON_PATH}=                  ${TBD}
${FAN_PWM_MEASUREMENT_METHOD}=                      ${TBD}
${FAN_RPM_MEASUREMENT_METHOD}=                      ${TBD}
${FAN_RPM_MEASUREMENT_SENSOR}=                      ${TBD}
${FLASH_VERIFY_OPTION}=                             ${TBD}
${FW_NO_EC_SYNC_DOWNLOAD_LINK}=                     ${TBD}
${FW_NO_EC_SYNC_VERSION}=                           ${TBD}
${HAS_E_CORES}=                                     ${TBD}
${HIBERNATION_ITERATIONS_NUMBER}=                   ${TBD}
${INITIAL_CPU_FREQUENCY}=                           ${TBD}
${ITERATIONS}=                                      ${TBD}
${LTE_CARD}=                                        ${TBD}
${MAX_CPU_TEMP_THRESHOLD}=                          ${TBD}
${ONLY_FLASH_BIOS}=                                 ${TBD}
${OPEN_BMC_PASSWORD}=                               ${TBD}
${OPEN_BMC_ROOT_PROMPT}=                            ${TBD}
${OPEN_BMC_USERNAME}=                               ${TBD}
${PLATFORM_CPU_SPEED}=                              ${TBD}
${PLATFORM_RAM_SIZE}=                               ${TBD}
${PLATFORM_RAM_SPEED}=                              ${TBD}
${SD_WIRES_CONNECTED}=                              ${TBD}
${SD_WIRE_SERIAL1}=                                 ${TBD}
${SMALLPT_TEST_SCORE}=                              ${TBD}
${UBU_RAND_READ_NONQUE}=                            ${TBD}
${UBU_RAND_READ_QUEUED}=                            ${TBD}
${UBU_RAND_WRITE_NONQUE}=                           ${TBD}
${UBU_RAND_WRITE_QUEUED}=                           ${TBD}
${UBU_SEQ_READ_NONQUE}=                             ${TBD}
${UBU_SEQ_READ_QUEUED}=                             ${TBD}
${UBU_SEQ_WRITE_NONQUE}=                            ${TBD}
${UBU_SEQ_WRITE_QUEUED}=                            ${TBD}
${UNIGINE_SUPERPOSITION_RESULT_AC}=                 ${TBD}
${UNIGINE_SUPERPOSITION_RESULT_BAT}=                ${TBD}
${WEBCAM_UBUNTU}=                                   ${TBD}
${WIN_RAND_READ_NONQUE}=                            ${TBD}
${WIN_RAND_READ_QUEUED}=                            ${TBD}
${WIN_RAND_WRITE_NONQUE}=                           ${TBD}
${WIN_RAND_WRITE_QUEUED}=                           ${TBD}
${WIN_SEQ_READ_NONQUE}=                             ${TBD}
${WIN_SEQ_READ_QUEUED}=                             ${TBD}
${WIN_SEQ_WRITE_NONQUE}=                            ${TBD}
${WIN_SEQ_WRITE_QUEUED}=                            ${TBD}
${ZIP_MULTI_COMPRESSION}=                           ${TBD}
${ZIP_MULTI_DECOMPRESSION}=                         ${TBD}
${FAN_RPM_MEASUREMENT_SENSOR_MODULE}=               ${TBD}
${DEVICE_DETECT_TEST_IN_SCOPE}=                     ${FALSE}

#### DTS E2E variables, should start with DTS_TEST_ ####
# Base fw version set for every workflow
${DTS_TEST_VERSION_BASE}=                           v0.0.0
&{DTS_TEST_VERSIONS_BASE}=
...                                                 &{{ {workflow: "${DTS_TEST_VERSION_BASE}" for workflow in ${DTS_TEST_POSSIBLE_WORKFLOWS} } }}
...                                                 UEFI Update=Dasharo (coreboot+UEFI) ${DTS_TEST_VERSION_BASE}
...                                                 UEFI->Heads Transition=Dasharo (coreboot+UEFI) ${DTS_TEST_VERSION_BASE}
...                                                 Dasharo (coreboot+UEFI) to Dasharo (Slim Bootloader+UEFI) Transition=Dasharo (coreboot+UEFI) ${DTS_TEST_VERSION_BASE}
...                                                 Fuse Platform=Dasharo (coreboot+UEFI) ${DTS_TEST_VERSION_BASE}
&{DTS_TEST_VERSIONS}=                               &{DTS_TEST_VERSIONS_BASE}
# TEST_SYSTEM_MODEL, TEST_BOARD_MODEL, TEST_SYSTEM_VENDOR variables to export
${DTS_TEST_BOARD_MODEL}=                            ${EMPTY}
${DTS_TEST_SYSTEM_VENDOR}=                          ${EMPTY}
${DTS_TEST_HAS_EC}=                                 ${False}
&{DTS_TEST_BASE_EXPORTS}=
...                                                 DTS_TESTING=true
...                                                 TEST_SYSTEM_MODEL=${DMIDECODE_PRODUCT_NAME}
...                                                 TEST_BOARD_MODEL=${DTS_TEST_BOARD_MODEL}
...                                                 TEST_SYSTEM_VENDOR=${DTS_TEST_SYSTEM_VENDOR}
...                                                 TEST_BIOS_VENDOR=${DMIDECODE_VENDOR}
...                                                 TEST_CPU_VERSION=${CPU}
...                                                 TEST_INTERNAL_PROGRAMMER_CHIPNAME=${INTERNAL_PROGRAMMER_CHIPNAME}
...                                                 TEST_USING_OPENSOURCE_EC_FIRM=${{"true" if ${DTS_TEST_HAS_EC} else "false" }}
&{DTS_TEST_EXPORTS}=                                &{DTS_TEST_BASE_EXPORTS}
&{DTS_TEST_EXPORTS_PER_WORKFLOW_BASE}=
...                                                 UEFI Update=&{{ {"TEST_IS_COREBOOT": "true"} }}
...                                                 SeaBIOS Update=&{{ {"TEST_IS_COREBOOT": "true", "TEST_EFI_PRESENT": "false", "TEST_IS_SEABIOS": "true"} }}
...                                                 UEFI->Heads Transition=&{{ {"TEST_IS_COREBOOT": "true"} }}
...                                                 SeaBIOS->UEFI Transition=&{{ {"TEST_IS_COREBOOT": "true", "TEST_EFI_PRESENT": "false", "TEST_IS_SEABIOS": "true"} }}
...                                                 Dasharo (coreboot+UEFI) to Dasharo (Slim Bootloader+UEFI) Transition=&{{ {"TEST_IS_COREBOOT": "true"} }}
...                                                 Initial Deployment=&{{ {"TEST_BIOS_VENDOR": "proprietary", "TEST_USING_OPENSOURCE_EC_FIRM": "false"} }}
...                                                 Fuse Platform=${{ {"TEST_MEI_CONF_PRESENT": "false"} }}
# dict[workflow, dict[variable, value]]
&{DTS_TEST_EXPORTS_PER_WORKFLOW}=                   &{DTS_TEST_EXPORTS_PER_WORKFLOW_BASE}
# dict[tuple[workflow,release], dict[variable, value]]
# Export variables per matching workflow and release
# Used if e.g. DCR and DPP updates need different exports
# Example usage:
# &{DTS_TEST_EXPORTS_PER_FULL_WORKFLOW}=
# ...    ${{ ("UEFI Update", "DCR") }}=${{ {"TEST_FMAP_REGIONS": "", "TEST_ME_DISABLED": "false"] }}
# ...    ${{ ("UEFI Update", "DPP") }}=${{ {"TEST_FMAP_REGIONS": "BOOTSPLASH"] }}
&{DTS_TEST_EXPORTS_PER_FULL_WORKFLOW}=              &{EMPTY}
# Possible values: check DTS_TEST_POSSIBLE_WORKFLOWS
@{DTS_TEST_WORKFLOWS}=                              @{EMPTY}
@{DTS_TEST_POSSIBLE_WORKFLOWS}=
...                                                 Initial Deployment
...                                                 UEFI Update
...                                                 SeaBIOS Update
...                                                 UEFI->Heads Transition
...                                                 SeaBIOS->UEFI Transition
...                                                 Dasharo (coreboot+UEFI) to Dasharo (Slim Bootloader+UEFI) Transition
...                                                 Dasharo (Slim Bootloader+UEFI) Initial Deployment
...                                                 Fuse Platform
# Set to e.g. DPP for platforms where only DPP workflows work
@{DTS_TEST_DEFAULT_RELEASES}=                       DCR    DPP
&{DTS_TEST_WORKFLOW_RELEASES_BASE}=
...                                                 &{{ {workflow: ${DTS_TEST_DEFAULT_RELEASES} for workflow in ${DTS_TEST_POSSIBLE_WORKFLOWS} } }}
# Set UEFI->Heads Transition to DPP by default as currently we don't offer community
# version
&{DTS_TEST_WORKFLOW_RELEASES}=
...                                                 &{DTS_TEST_WORKFLOW_RELEASES_BASE}
...                                                 UEFI->Heads Transition=@{{["DPP"]}}
...                                                 Dasharo (coreboot+UEFI) to Dasharo (Slim Bootloader+UEFI) Transition=@{{["DPP"]}}
...                                                 Dasharo (Slim Bootloader+UEFI) Initial Deployment=@{{["DPP"]}}
...                                                 Fuse Platform=@{{["DCR"]}}
# List of workflows which require profile comparison in the format:
# list[tuple[workflow, release]] e.g.:
# @{DTS_TEST_WORKFLOW_PROFILES}=
# ...    ${{ ("UEFI->Heads Transition", "DPP") }}
# ...    ${{ ("UEFI Update", "DPP") }}
@{DTS_TEST_WORKFLOW_PROFILES}=                      @{EMPTY}


*** Keywords ***
Power On Default
    [Documentation]    The default implementation of the Power On keyword.
    ...    Keyword clears terminal buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers.
    Restore Initial DUT Connection Method
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    Sleep    2s
    Rte Power Off
    Sleep    10s
    Read From Terminal
    Power Cycle On
