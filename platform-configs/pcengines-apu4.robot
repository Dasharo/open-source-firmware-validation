*** Settings ***
Resource    include/pcengines.robot


*** Variables ***
${DMIDECODE_PRODUCT_NAME}=          apu4
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v0.9.1
${DMIDECODE_RELEASE_DATE}=          11/20/2025
${FLASH_VERIFY_METHOD}=             none
${APU_FLASH_WP_GPIO}=               1
${EXPECTED_FW_SHA256}=              8fc4a46c15dc97088c3b18052263125de9856e71726fc775b838c735937c4f8e
# DTS E2E variables
