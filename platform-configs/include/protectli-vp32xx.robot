*** Settings ***
Resource    protectli-pro.robot
Resource    protectli-common.robot
Resource    protectli-pro.robot


*** Variables ***
${FLASH_SIZE}=                      ${16*1024*1024}
${VERIFIED_BOOT_SUPPORT}=           ${TRUE}
${IPXE_BOOT_ENTRY}=                 Network Boot and Utilities

# Test module: dasharo-security
${VERIFIED_BOOT_POPUP_SUPPORT}=     ${TRUE}


*** Keywords ***
Power On
    Rte Power Off
    Sleep    5s
    Power Cycle On
