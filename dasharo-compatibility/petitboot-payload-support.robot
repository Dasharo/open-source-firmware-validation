*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
PBT001.001 Petitboot installation
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    Petitboot menu
    Skip If    not ${tests_in_firmware_support}    PBT001.001 not supported
    Skip If    not ${petitboot_payload_support}    PBT001.001 not supported
    Variable Should Exist    ${fw_file}
    Variable Should Exist    ${bootblock_file}
    Variable Should Exist    ${pnor_file}
    Flash Petitboot From OpenBMC    ${bootblock_file}    ${fw_file}    ${pnor_file}

PBT002.001 Boot into Petitboot
    [Documentation]    This test verifies that the DUT during booting procedure
    ...    reaches Petitboot menu.
    Skip If    not ${tests_in_firmware_support}    PBT002.001 not supported
    Skip If    not ${petitboot_payload_support}    PBT002.001 not supported
    Power On
    Set DUT Response Timeout    200s
    Read From Terminal Until    Petitboot

PBT003.001 Read System Information from Petitboot
    [Documentation]    This test verifies that Petitboot System Information
    ...    option is available and works correctly.
    Skip If    not ${tests_in_firmware_support}    PBT003.001 not supported
    Skip If    not ${petitboot_payload_support}    PBT003.001 not supported
    Power On
    Set DUT Response Timeout    200s
    Read From Terminal Until    Petitboot
    Write Bare Into Terminal    ${ARROW_DOWN}
    Sleep    10s
    Read System information in Petitboot

PBT004.001 Rescan Devices by Petitboot
    [Documentation]    This test verifies that Petitboot Rescan Device option
    ...    is available and works correctly.
    Skip If    not ${tests_in_firmware_support}    PBT004.001 not supported
    Skip If    not ${petitboot_payload_support}    PBT004.001 not supported
    Power On
    Set DUT Response Timeout    200s
    Read From Terminal Until    Petitboot
    Sleep    2s
    Write Bare Into Terminal    ${ARROW_DOWN}
    Sleep    10s
    Rescan devices in Petitboot
