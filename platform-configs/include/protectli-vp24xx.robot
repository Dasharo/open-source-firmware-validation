*** Settings ***
Resource    protectli-pro.robot
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=      ${16*1024*1024}


*** Keywords ***
Power On
    Rte Power Off
    Sleep    5s
    Power Cycle On
