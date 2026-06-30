*** Settings ***
Resource    include/pcengines.robot


*** Variables ***
${DMIDECODE_PRODUCT_NAME}=          apu6
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v0.9.1
${DMIDECODE_RELEASE_DATE}=          11/20/2025
${FLASH_VERIFY_METHOD}=             none
${APU_FLASH_WP_GPIO}=               1
${EXPECTED_FW_SHA256}=              2308b3f4faa460df9fbbd18765183c9c630520625cba1bf7fed7d5e474d1a69b
# DTS E2E variables
