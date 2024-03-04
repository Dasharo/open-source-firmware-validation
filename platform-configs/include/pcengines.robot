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

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=                       ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                         ${TRUE}

# Regression test flags
${DASHARO_SECURITY_MENU_SUPPORT}=                   ${TRUE}
# Test module: dasharo-compatibility
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=                    ${TRUE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=                   ${TRUE}
${EC_AND_SUPER_IO_SUPPORT}=                         ${TRUE}
${USB_DISKS_DETECTION_SUPPORT}=                     ${TRUE}
${UEFI_SHELL_SUPPORT}=                              ${TRUE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=               ${TRUE}
${IPXE_BOOT_SUPPORT}=                               ${TRUE}
${SD_CARD_READER_SUPPORT}=                          ${TRUE}
${WIRELESS_CARD_SUPPORT}=                           ${TRUE}
${WIRELESS_CARD_WIFI_SUPPORT}=                      ${TRUE}
${SERIAL_NUMBER_VERIFICATION}=                      ${TRUE}
${FIRMWARE_NUMBER_VERIFICATION}=                    ${TRUE}
${FIRMWARE_FROM_BINARY}=                            ${TRUE}
${PRODUCT_NAME_VERIFICATION}=                       ${TRUE}
${RELEASE_DATE_VERIFICATION}=                       ${TRUE}
${RELEASE_DATE_FROM_SOL}=                           ${TRUE}
${MANUFACTURER_VERIFICATION}=                       ${TRUE}
${VENDOR_VERIFICATION}=                             ${TRUE}
${FAMILY_VERIFICATION}=                             ${TRUE}
${TYPE_VERIFICATION}=                               ${TRUE}
${HARDWARE_WP_SUPPORT}=                             ${TRUE}
${DTS_SUPPORT}=                                     ${TRUE}
${FIRMWARE_BUILDING_SUPPORT}=                       ${TRUE}
${CPU_TESTS_SUPPORT}=                               ${TRUE}
${RESET_TO_DEFAULTS_SUPPORT}=                       ${TRUE}
${L2_CACHE_SUPPORT}=                                ${TRUE}
${L3_CACHE_SUPPORT}=                                ${TRUE}
${DEFAULT_POWER_STATE_AFTER_FAIL}=                  Powered On
${ESP_SCANNING_SUPPORT}=                            ${TRUE}
${DTS_FIRMWARE_FLASHING_SUPPORT}=                   ${TRUE}
${MINI_PC_IE_SLOT_SUPPORT}=                         ${TRUE}

# Test module: dasharo-security
${TPM_SUPPORT}=                                     ${TRUE}
${VERIFIED_BOOT_SUPPORT}=                           ${TRUE}
${VERIFIED_BOOT_POPUP_SUPPORT}=                     ${TRUE}
${MEASURED_BOOT_SUPPORT}=                           ${TRUE}
${SECURE_BOOT_SUPPORT}=                             ${TRUE}
${SECURE_BOOT_DEFAULT_STATE}=                       Disabled
${UEFI_PASSWORD_SUPPORT}=                           ${TRUE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                             ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                         ${TRUE}
${CPU_FREQUENCY_MEASURE}=                           ${TRUE}
${PLATFORM_STABILITY_CHECKING}=                     ${TRUE}

# Test module: dasharo-stab
${TPM_DETECT_SUPPORT}=                              ${TRUE}
${USB_TYPE-A_DEVICES_DETECTION_SUPPORT}=            ${TRUE}

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
