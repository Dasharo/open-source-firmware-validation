*** Settings ***
Resource    include/msi-z690-common.robot


*** Variables ***
${FW_VERSION}=                      v0.9.2-rc3
${DMIDECODE_SERIAL_NUMBER}=         N/A
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v0.9.2-rc3
${DMIDECODE_PRODUCT_NAME}=          MS-7E06
${DMIDECODE_RELEASE_DATE}=          11/27/2023

${CPU_MAX_FREQUENCY}=               5200
${CPU_MIN_FREQUENCY}=               300

${DEVICE_AUDIO2}=                   Raptorlake HDMI
