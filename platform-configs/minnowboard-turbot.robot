*** Settings ***
Resource    include/default.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=           Telnet
${DUT_CONNECTION_METHOD}=                   ${INITIAL_DUT_CONNECTION_METHOD}
${PAYLOAD}=                                 tianocore
${RTE_S2_N_PORT}=                           13542
${FLASH_SIZE}=                              ${8*1024*1024}
${FLASH_LENGTH}=                            ${EMPTY}
${TIANOCORE_STRING}=                        to enter Boot Manager Menu
${BOOT_MENU_STRING}=                        Please select boot device:
${BOOT_MENU_KEY}=                           ${F7}
${SETUP_MENU_KEY}=                          ${F2}
${SETUP_MENU_STRING}=                       Select Entry
${EDK2_IPXE_CHECKPOINT}=                    iPXE Shell
${MANUFACTURER}=                            MinnowBoard
${CPU}=                                     Intel Atom E3845 SoC
${POWER_CTRL}=                              RteCtrl
${FLASH_VERIFY_METHOD}=                     tianocore-shell
${FLASH_VERIFY_OPTION}=                     UEFI Shell
${WIFI_CARD}=                               ${EMPTY}
${MAX_CPU_TEMP}=                            ${EMPTY}

${DEVICE_USB_KEYBOARD}=                     Logitech, Inc. Keyboard K120

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=               ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                 ${TRUE}
${TESTS_IN_DEBIAN_SUPPORT}=                 ${FALSE}
${TESTS_IN_WINDOWS_SUPPORT}=                ${FALSE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=       ${TRUE}

# Regression test flags
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=            ${TRUE}
${SERIAL_NUMBER_VERIFICATION}=              ${TRUE}
${FIRMWARE_NUMBER_VERIFICATION}=            ${TRUE}
${PRODUCT_NAME_VERIFICATION}=               ${TRUE}
${UEFI_SHELL_SUPPORT}=                      ${TRUE}
${EXTERNAL_HDMI_DISPLAY_SUPPORT}=           ${TRUE}
${ESP_SCANNING_SUPPORT}=                    ${TRUE}
${IPXE_BOOT_SUPPORT}=                       ${TRUE}
${CUSTOM_LOGO_SUPPORT}=                     ${TRUE}
${USB_STACK_SUPPORT}=                       ${TRUE}
${USB_MASS_STORAGE_SUPPORT}=                ${TRUE}
${USB_TYPE-A_DEVICES_DETECTION_SUPPORT}=    ${TRUE}
${USB_MODEL}=                               SanDisk
${USB_DEVICE}=                              SanDisk

${DMIDECODE_SERIAL_NUMBER}=                 123456789
${DMIDECODE_FIRMWARE_VERSION}=              Dasharo (coreboot+UEFI) 0.9.0-rc1
${DMIDECODE_PRODUCT_NAME}=                  Minnow Max
${DMIDECODE_RELEASE_DATE}=                  07/26/2024
${DMIDECODE_MANUFACTURER}=                  Intel
${DMIDECODE_VENDOR}=                        3mdeb
${DMIDECODE_FAMILY}=                        Atom
${DMIDECODE_TYPE}=                          Desktop
${DEVICE_AUDIO1}=                           HDMI

${DTS_SUPPORT}=                             ${TRUE}
${DTS_FIRMWARE_FLASHING_SUPPORT}=           ${TRUE}
${CPU_TESTS_SUPPORT}=                       ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                 ${TRUE}
${CPU_FREQUENCY_MEASURE}=                   ${TRUE}
${SECURE_BOOT_SUPPORT}=                     ${TRUE}
${BIOS_LOCK_SUPPORT}=                       ${TRUE}
${SMM_WRITE_PROTECTION_SUPPORT}=            ${TRUE}
${UEFI_PASSWORD_SUPPORT}=                   ${TRUE}
${DASHARO_SECURITY_MENU_SUPPORT}=           ${TRUE}
${DASHARO_USB_MENU_SUPPORT}=                ${TRUE}
${DASHARO_NETWORKING_MENU_SUPPORT}=         ${TRUE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=           ${FALSE}
${DASHARO_CHIPSET_MENU_SUPPORT}=            ${FALSE}
${MEASURED_BOOT_SUPPORT}=                   ${FALSE}
${PLATFORM_STABILITY_CHECKING}=             ${TRUE}
${DEF_SOCKETS}=                             1
${DEF_CORES_PER_SOCKET}=                    4
${DEF_THREADS_PER_CORE}=                    1
${DEF_THREADS_TOTAL}=                       4
${L2_CACHE_SUPPORT}=                        ${TRUE}


*** Keywords ***
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    Restore Initial DUT Connection Method
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    Sleep    3s
    Rte Power Off
    Sleep    1s
    Telnet.Read
    Rte Relay Set    on
    Sleep    1s
