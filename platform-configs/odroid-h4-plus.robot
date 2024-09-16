*** Settings ***
Resource    include/default.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=       pikvm
${DUT_CONNECTION_METHOD}=               pikvm
${FLASH_SIZE}=                          ${16*1024*1024}
${FLASH_LENGTH}=                        ${TBD}
${MANUFACTURER}=                        Hardkernel
${CPU}=                                 Intel(R) N97
${POWER_CTRL}=                          RteCtrl
${FLASH_VERIFY_METHOD}=                 tianocore-shell
${WIFI_CARD}=                           ${TBD}
${MAX_CPU_TEMP}=                        ${TBD}
${FW_VERSION}=                          ${TBD}
${DMIDECODE_SERIAL_NUMBER}=             123456789
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v0.9.0-rc1
${DMIDECODE_PRODUCT_NAME}=              ODROID-H4
${DMIDECODE_RELEASE_DATE}=              ${TBD}
${DMIDECODE_MANUFACTURER}=              HARDKERNEL
${DMIDECODE_VENDOR}=                    ${TBD}
${DMIDECODE_FAMILY}=                    Default String
${DMIDECODE_TYPE}=                      Desktop
${DEVICE_USB_KEYBOARD}=                 ${TBD}
${DEVICE_NVME_DISK}=                    Samsung Electronics Co Ltd Device a80c
${DEVICE_AUDIO1}=                       HDA Intel PCH    # codespell:ignore
${DEVICE_AUDIO2}=                       ${TBD}
${DEVICE_AUDIO1_WIN}=                   ${TBD}
${WIFI_CARD_UBUNTU}=                    ${TBD}
${USB_MODEL}=                           ${TBD}
${USB_DEVICE}=                          ${TBD}
${FLASHROM_FLAGS}=                      ${TBD}
${TESTS_IN_FIRMWARE_SUPPORT}=           ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=             ${TRUE}
${TESTS_IN_WINDOWS_SUPPORT}=            ${TRUE}
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=        ${TRUE}

${INITIAL_CPU_FREQUENCY}=               800
${PLATFORM_CPU_SPEED}=                  3,60
${CPU_MIN_FREQUENCY}=                   800
${CPU_MAX_FREQUENCY}=                   3600
${PLATFORM_RAM_SPEED}=                  4800
${PLATFORM_RAM_SIZE}=                   8192
${E_MMC_NAME}=                          PJ3032
${DEF_THREADS_TOTAL}=                   4
${DEF_THREADS_PER_CORE}=                1
${DEF_CORES_PER_SOCKET}=                4
${DEF_SOCKETS}=                         1
${DEF_ONLINE_CPU}=                      0-3
${FLASH_VERIFY_OPTION}=                 UEFI Shell    # Selected One Time Boot option
${RESET_TO_DEFAULTS_SUPPORT}=           ${TRUE}
${TPM_SUPPORT}=                         ${TRUE}
${IPXE_BOOT_SUPPORT}=                   ${TRUE}
${FIRMWARE_NUMBER_VERIFICATION}=        ${TRUE}
${PRODUCT_NAME_VERIFICATION}=           ${TRUE}
${WIRELESS_CARD_WIFI_SUPPORT}=          ${TRUE}
${PLATFORM_STABILITY_CHECKING}=         ${TRUE}
${ONLY_FLASH_BIOS}=                     ${TRUE}
${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=    2


*** Keywords ***
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    Restore Initial DUT Connection Method
    Sleep    2s
    Rte Relay Power Cycle Off
    Sleep    5s
    # read the old output
    Telnet.Read
    Rte Relay Power Cycle On
