*** Settings ***
Documentation       Common header for OSFV Power management keywords

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             RequestsLibrary
Library             SSHLibrary

Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot


*** Keywords ***
Init Platform State Control
    IF    '${POWER_CTRL}'=='none'
        VAR    ${PLATFORM_BOOT_STATE}=    os    scope=GLOBAL
    ELSE
        VAR    ${PLATFORM_BOOT_STATE}=    ${None}    scope=GLOBAL
    END

Boot State Control Notify State
    [Documentation]    Allowed states:
    ...    ${None}
    ...    setup
    ...    booting
    ...    bootmenu
    ...    os
    [Arguments]    ${state}
    VAR    ${POWER_STATE_POWERED_ON}=    ${state}    scope=GLOBAL

