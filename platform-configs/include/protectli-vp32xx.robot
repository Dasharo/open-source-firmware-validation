*** Settings ***
Resource    protectli-common.robot
Resource    protectli-pro.robot


*** Variables ***
${FLASH_SIZE}=      ${16*1024*1024}


*** Keywords ***
Power On
    Rte Power Off
    Sleep    5s
    Power Cycle On
