*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
PBT001.001 Petitboot installation
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    Petitboot menu
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PBT001.001 not supported
    Skip If    not ${PETITBOOT_PAYLOAD_SUPPORT}    PBT001.001 not supported
    Variable Should Exist    ${FW_FILE}
    Variable Should Exist    ${BOOTBLOCK_FILE}
    Variable Should Exist    ${PNOR_FILE}
    Flash Petitboot From OpenBMC    ${BOOTBLOCK_FILE}    ${FW_FILE}    ${PNOR_FILE}

PBT002.001 Boot into Petitboot
    [Documentation]    This test verifies that the DUT during booting procedure
    ...    reaches Petitboot menu.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PBT002.001 not supported
    Skip If    not ${PETITBOOT_PAYLOAD_SUPPORT}    PBT002.001 not supported
    Power On
    Set DUT Response Timeout    200s
    Read From Terminal Until    Petitboot

PBT003.001 Read System Information from Petitboot
    [Documentation]    This test verifies that Petitboot System Information
    ...    option is available and works correctly.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PBT003.001 not supported
    Skip If    not ${PETITBOOT_PAYLOAD_SUPPORT}    PBT003.001 not supported
    Power On
    Set DUT Response Timeout    200s
    Read From Terminal Until    Petitboot
    Write Bare Into Terminal    ${ARROW_DOWN}
    Sleep    10s
    Read System Information In Petitboot

PBT004.001 Rescan Devices by Petitboot
    [Documentation]    This test verifies that Petitboot Rescan Device option
    ...    is available and works correctly.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PBT004.001 not supported
    Skip If    not ${PETITBOOT_PAYLOAD_SUPPORT}    PBT004.001 not supported
    Power On
    Set DUT Response Timeout    200s
    Read From Terminal Until    Petitboot
    Sleep    2s
    Write Bare Into Terminal    ${ARROW_DOWN}
    Sleep    10s
    Rescan Devices In Petitboot
