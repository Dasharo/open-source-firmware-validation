*** Settings ***
Resource    optiplex-7010.robot


*** Variables ***
${BIOS_LIB}=                        seabios
${FW_STRING}=                       ESC
${SEABIOS_BOOT_DEVICE}=             2
${BOOT_MENU_KEY}=                   ${ESC}
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+SeaBIOS) v0.1.0
${DMIDECODE_RELEASE_DATE}=          11/27/2024
${TESTS_IN_FIRMWARE_SUPPORT}=       {FALSE}
