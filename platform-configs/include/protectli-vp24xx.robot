*** Settings ***
Resource    protectli-pro.robot
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                  ${16*1024*1024}
${WIFI_CARD_UBUNTU}=            Intel Corporation Wi-Fi 6 AX200 (rev 1a)
${LTE_CARD}=                    Qualcomm, Inc. MDG200
${DEVICE_USB_KEYBOARD}=         Logitech, Inc. Keyboard K120
${MAX_CPU_TEMP}=                95
${DMIDECODE_MANUFACTURER}=      Protectli
${DMIDECODE_VENDOR}=            3mdeb
${DMIDECODE_FAMILY}=            Vault Pro


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
