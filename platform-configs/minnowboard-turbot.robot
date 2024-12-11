*** Settings ***
Resource    include/default.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=       Telnet
${DUT_CONNECTION_METHOD}=               ${INITIAL_DUT_CONNECTION_METHOD}
${PAYLOAD}=                             tianocore
${RTE_S2_N_PORT}=                       13542
${FLASH_SIZE}=                          ${8*1024*1024}
${FLASH_LENGTH}=                        ${TBD}
${TIANOCORE_STRING}=                    to enter Boot Manager Menu
${BOOT_MENU_STRING}=                    Please select boot device:
${BOOT_MENU_KEY}=                       ${F7}
${SETUP_MENU_KEY}=                      ${F2}
${SETUP_MENU_STRING}=                   Select Entry
${EDK2_IPXE_CHECKPOINT}=                iPXE Shell
${MANUFACTURER}=                        MinnowBoard
${CPU}=                                 Intel Atom E3845 SoC
${POWER_CTRL}=                          RteCtrl
${FLASH_VERIFY_METHOD}=                 tianocore-shell
${FLASH_VERIFY_OPTION}=                 UEFI Shell
${WIFI_CARD}=                           ${TBD}
${MAX_CPU_TEMP}=                        ${TBD}

${DEVICE_USB_KEYBOARD}=                 Logitech, Inc. Keyboard K120

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=           ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=             ${FALSE}
${TESTS_IN_DEBIAN_SUPPORT}=             ${FALSE}
${TESTS_IN_WINDOWS_SUPPORT}=            ${FALSE}

# Regression test flags
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=        ${TRUE}
${CPU_THROTTLING_SUPPORT}=              ${TRUE}


*** Keywords ***
Power On
    Power On Default
