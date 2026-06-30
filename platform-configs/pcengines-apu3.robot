*** Settings ***
Resource    include/pcengines.robot


*** Variables ***
${DMIDECODE_PRODUCT_NAME}=          apu3
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v0.9.1
${DMIDECODE_RELEASE_DATE}=          11/20/2025
${FLASH_VERIFY_METHOD}=             none
${APU_FLASH_WP_GPIO}=               1
${EXPECTED_FW_SHA256}=              d72578e873d0f3dc284304c84ddded8f8fa9273f9d91d6c6b7846dc47838baf9

# DTS E2E variables
