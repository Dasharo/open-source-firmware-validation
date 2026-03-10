*** Settings ***
Resource    include/pcengines.robot


*** Variables ***
${DMIDECODE_PRODUCT_NAME}=          apu2
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v0.9.1
${DMIDECODE_RELEASE_DATE}=          11/20/2025
${FLASH_VERIFY_METHOD}=             none
${PLATFORM_CPU_SPEED}=              1.0
${PLATFORM_RAM_SPEED}=              1333
${PLATFORM_RAM_SIZE}=               4096
${BIOS_LOCK_SUPPORT}=               ${True}
${APU_FLASH_WP_GPIO}=               1

# DTS E2E variables
