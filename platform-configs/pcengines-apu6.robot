*** Settings ***
Resource    include/pcengines.robot


*** Variables ***
${DMIDECODE_PRODUCT_NAME}=          apu6
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v0.9.1
${DMIDECODE_RELEASE_DATE}=          11/20/2025
${FLASH_VERIFY_METHOD}=             none
${APU_FLASH_WP_GPIO}=               1

# DTS E2E variables
