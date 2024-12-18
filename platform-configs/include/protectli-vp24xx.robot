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

${ETHERNET_ID}=                 8086:125c
