*** Settings ***
Resource    protectli-common.robot

*** Variables ***
${FLASH_SIZE}=                                      ${16*1024*1024}
${VERIFIED_BOOT_SUPPORT}=                           y
${IPXE_BOOT_ENTRY}=                                 Network Boot and Utilities


*** Keywords ***
Power On
    Restore Initial DUT Connection Method
    Rte Power Off
    Sleep    5s
    Power Cycle On
