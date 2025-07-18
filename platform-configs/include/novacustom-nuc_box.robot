*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=       Telnet
${DUT_CONNECTION_METHOD}=               Telnet
${POWER_CTRL}=                          sonoff
${TESTS_IN_FIRMWARE_SUPPORT}=           ${TRUE}

${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v0.9.0-rc1
${DMIDECODE_PRODUCT_NAME}=              NUC_BOX
${FLASH_LENGTH}=                        ${TBD}
${FW_VERSION}=                          v0.9.0-rc1
${FLASHROM_FLAGS}=                      ${EMPTY}

${WIFI_CARD}=                           Intel Corporation Meteor Lake PCH CNVi WiFi

${DEFAULT_BOOT_OS_ID}=                  ${ENV_ID_UBUNTU}
@{TESTED_LINUX_DISTROS}=
...                                     ${ENV_ID_UBUNTU}    # ${ENV_ID_FEDORA}
${TESTS_IN_WINDOWS_SUPPORT}=            ${TRUE}

${CLEVO_USB_C_HUB}=                     Billboard Device

${GPU_PERFORMANCE_TESTS_SUPPORT}=       ${TRUE}
${ESP_SCANNING_SUPPORT}=                ${TRUE}
${USB_DISKS_DETECTION_SUPPORT}=         ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=      ${TRUE}
${FAN_SPEED_MEASURE_SUPPORT}=           ${TRUE}
