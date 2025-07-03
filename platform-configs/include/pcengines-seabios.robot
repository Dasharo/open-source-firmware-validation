*** Settings ***
Resource    pcengines.robot


*** Variables ***
${BIOS_LIB}=                        seabios
${FW_STRING}=                       F10
${SEABIOS_BOOT_DEVICE}=             4
${BOOT_MENU_KEY}=                   ${F10}
${TESTS_IN_FIRMWARE_SUPPORT}=       ${FALSE}
