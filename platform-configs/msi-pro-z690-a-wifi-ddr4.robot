*** Settings ***
Resource    include/msi-z690-common.robot


*** Variables ***
${FW_VERSION}=                          v1.1.2
${DMIDECODE_SERIAL_NUMBER}=             N/A
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v1.1.3
${DMIDECODE_PRODUCT_NAME}=              MS-7D25
${DMIDECODE_RELEASE_DATE}=              11/27/2023

${WIFI_CARD}=                           Intel(R) Wi-Fi 6 AX201 160MHz

${WIRELESS_CARD_SUPPORT}=               ${TRUE}
${WIRELESS_CARD_WIFI_SUPPORT}=          ${TRUE}
${WIRELESS_CARD_BLUETOOTH_SUPPORT}=     ${TRUE}
