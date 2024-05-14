*** Settings ***
Resource    default.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=               Telnet
${DUT_CONNECTION_METHOD}=                       ${INITIAL_DUT_CONNECTION_METHOD}
${PAYLOAD}=                                     tianocore
${RTE_S2_N_PORT}=                               13541
${FLASH_LENGTH}=                                ${EMPTY}
${TIANOCORE_STRING}=                            to boot directly
${BOOT_MENU_KEY}=                               ${F11}
${SETUP_MENU_KEY}=                              ${DELETE}
${BOOT_MENU_STRING}=                            Please select boot device
${SETUP_MENU_STRING}=                           Select Entry
${IPXE_BOOT_ENTRY}=                             Network Boot and Utilities
${EDK2_IPXE_CHECKPOINT}=                        Advanced
${MANUFACTURER}=                                ${EMPTY}
${CPU}=                                         ${EMPTY}
${POWER_CTRL}=                                  RteCtrl
${FLASH_VERIFY_METHOD}=                         tianocore-shell
${FLASH_VERIFY_OPTION}=                         UEFI Shell

${DMIDECODE_SERIAL_NUMBER}=                     N/A
${DMIDECODE_MANUFACTURER}=                      Protectli
${DMIDECODE_VENDOR}=                            3mdeb
${DMIDECODE_TYPE}=                              Desktop

${USB_MODEL}=                                   Kingston

${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=            6

${DEVICE_USB_USERNAME}=                         user
${DEVICE_USB_PASSWORD}=                         ubuntu
${DEVICE_USB_PROMPT}=                           ${DEVICE_USB_USERNAME}@3mdeb:~$
${DEVICE_USB_ROOT_PROMPT}=                      root@3mdeb:/home/${DEVICE_USB_USERNAME}#

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=                   ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                     ${TRUE}
${TESTS_IN_WINDOWS_SUPPORT}=                    ${TRUE}

# Regression test flags
${DASHARO_USB_MENU_SUPPORT}=                    ${TRUE}

# Test module: dasharo-compatibility
${AUDIO_SUBSYSTEM_SUPPORT}=                     ${TRUE}
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=                ${TRUE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=               ${TRUE}
${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}=         ${TRUE}
${EXTERNAL_HDMI_DISPLAY_SUPPORT}=               ${TRUE}
${EXTERNAL_DISPLAY_PORT_SUPPORT}=               ${TRUE}
${CUSTOM_LOGO_SUPPORT}=                         ${TRUE}
${UEFI_SHELL_SUPPORT}=                          ${TRUE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=           ${TRUE}
${NETBOOT_UTILITIES_SUPPORT}=                   ${TRUE}
${WIRELESS_CARD_SUPPORT}=                       ${TRUE}
${WIRELESS_CARD_WIFI_SUPPORT}=                  ${TRUE}
${WIRELESS_CARD_BLUETOOTH_SUPPORT}=             ${TRUE}
${FIRMWARE_NUMBER_VERIFICATION}=                ${TRUE}
${PRODUCT_NAME_VERIFICATION}=                   ${TRUE}
${RELEASE_DATE_VERIFICATION}=                   ${TRUE}
${MANUFACTURER_VERIFICATION}=                   ${TRUE}
${VENDOR_VERIFICATION}=                         ${TRUE}
${FAMILY_VERIFICATION}=                         ${TRUE}
${TYPE_VERIFICATION}=                           ${TRUE}
${EMMC_SUPPORT}=                                ${TRUE}
${CPU_TESTS_SUPPORT}=                           ${TRUE}
${L2_CACHE_SUPPORT}=                            ${TRUE}
${L3_CACHE_SUPPORT}=                            ${TRUE}
${RESET_TO_DEFAULTS_SUPPORT}=                   ${TRUE}
${DEFAULT_POWER_STATE_AFTER_FAIL}=              Powered On
${ESP_SCANNING_SUPPORT}=                        ${TRUE}
${USB_DISKS_DETECTION_SUPPORT}=                 ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=              ${TRUE}
${DCU_UUID_SUPPORT}=                            ${TRUE}
${DCU_SERIAL_SUPPORT}=                          ${TRUE}

# Test module: dasharo-security
${TPM_SUPPORT}=                                 ${TRUE}
${TPM_FIRMWARE_CONFIG}=                         ${TRUE}
${SECURE_BOOT_SUPPORT}=                         ${TRUE}
${SECURE_BOOT_DEFAULT_STATE}=                   Disabled
${USB_STACK_SUPPORT}=                           ${TRUE}
${USB_MASS_STORAGE_SUPPORT}=                    ${TRUE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                         ${TRUE}
${CPU_FREQUENCY_MEASURE}=                       ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                     ${TRUE}
${PLATFORM_STABILITY_CHECKING}=                 ${TRUE}

# Test cases iterations number
${ITERATIONS}=                                  5
# Booting OS from USB stick test cases
${BOOT_FROM_USB_ITERATIONS_NUMBER}=             5
# Sticks detection test cases
${USB_DETECTION_ITERATIONS_NUMBER}=             5
# Platform boot measure test cases

# Other platform flags and counters
# Cooling procedure iterations
${COOLING_PROCEDURE_ITERATIONS}=                0
# Stability tests duration in minutes
${STABILITY_TEST_DURATION}=                     300
# Interval between the following readings in stability tests
${STABILITY_TEST_MEASURE_INTERVAL}=             10
# Frequency measure test duration
${FREQUENCY_TEST_DURATION}=                     60
# Interval between the following readings in frequency measure tests
${FREQUENCY_TEST_MEASURE_INTERVAL}=             1
# Temperature measure test duration
${TEMPERATURE_TEST_DURATION}=                   60
# Interval between the following readings in temperature measure tests
${TEMPERATURE_TEST_MEASURE_INTERVAL}=           1
# Custom fan curve tests duration in minutes
${CUSTOM_FAN_CURVE_TEST_DURATION}=              30
# Interval between the following readings in custom fan curve tests
${CUSTOM_FAN_CURVE_MEASURE_INTERVAL}=           1
# Maximum fails during during performing test suite usb-boot.robot
${ALLOWED_FAILS_USB_BOOT}=                      0
# Maximum fails during during performing test suite usb-detect.robot
${ALLOWED_FAILS_USB_DETECT}=                    0
# Number of suspend and resume cycles performed during suspend test
${SUSPEND_ITERATIONS_NUMBER}=                   15
# Maximum number of fails during performing suspend and resume cycles
${SUSPEND_ALLOWED_FAILS}=                       0
# Maximum fails during performing docking station detect tests
${ALLOWED_DOCKING_STATION_DETECT_FAILS}=        0
# Number of iterations in stability detection tests
${STABILITY_DETECTION_COLDBOOT_ITERATIONS}=     2
${STABILITY_DETECTION_WARMBOOT_ITERATIONS}=     2
${STABILITY_DETECTION_REBOOT_ITERATIONS}=       5
${STABILITY_DETECTION_SUSPEND_ITERATIONS}=      5


*** Keywords ***
Check Coreboot Components Measurement
    [Documentation]    Check whether the hashes of the coreboot components
    ...    measurements have been stored in the TPM PCR registers.
    ${out}=    Execute Linux Command    ./cbmem -c | grep -i PCR | cat
    Should Contain    ${out}    fallback/payload` to PCR 2 measured
    Should Contain    ${out}    fallback/dsdt.aml` to PCR 2 measured
    Should Contain    ${out}    vbt.bin` to PCR 2 measured
    Should Not Contain    ${out}    Extending hash into PCR failed
