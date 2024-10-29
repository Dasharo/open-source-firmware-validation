*** Settings ***
Resource    include/protectli-pro.robot
Resource    include/protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                      ${16*1024*1024}
${WIFI_CARD_UBUNTU}=                Intel Corporation Wi-Fi 6 AX200 (rev 1a)
${LTE_CARD}=                        Qualcomm, Inc. MDG200
${DEVICE_USB_KEYBOARD}=             Logitech, Inc. Keyboard K120
${INITIAL_CPU_FREQUENCY}=           3300
${MAX_CPU_TEMP}=                    95
${FLASHING_METHOD}=                 external

# eMMC driver support
${E_MMC_NAME}=                      BJTD4R

@{ATTACHED_USB}=                    ${TBD}

${DMIDECODE_SERIAL_NUMBER}=         N/A
${DMIDECODE_FIRMWARE_VERSION}=      N/A
${DMIDECODE_PRODUCT_NAME}=          VP2430
${DMIDECODE_RELEASE_DATE}=          N/A
${DMIDECODE_MANUFACTURER}=          Protectli
${DMIDECODE_VENDOR}=                3mdeb
${DMIDECODE_FAMILY}=                N/A
${DMIDECODE_TYPE}=                  N/A

${CPU_MAX_FREQUENCY}=               3400
${CPU_MIN_FREQUENCY}=               700

${WATCHDOG_SUPPORT}=                ${TRUE}


*** Keywords ***
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    Restore Initial DUT Connection Method
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    Sleep    2s
    Rte Power Off
    Sleep    10s
    Telnet.Read
    Rte Power On
