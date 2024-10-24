*** Settings ***
Resource    include/msi-z690-common.robot


*** Variables ***
${FW_VERSION}=                      v1.1.4-rc1
${DMIDECODE_SERIAL_NUMBER}=         N/A
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) ${FW_VERSION}
${DMIDECODE_PRODUCT_NAME}=          MS-7D25
${DMIDECODE_RELEASE_DATE}=          09/27/2024

${DEVICE_AUDIO2}=                   Raptorlake HDMI

${CPU_MAX_FREQUENCY}=               5200
${CPU_MIN_FREQUENCY}=               300
