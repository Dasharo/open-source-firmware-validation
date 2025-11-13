*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for EC and SuperI/O tests

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot


*** Variables ***
${PLATFORM_STATE_CONTROL}=      ${TRUE}


*** Keywords ***
ECR Suite Setup
    [Documentation]    Common suite setup for EC and SuperI/O tests
    Prepare Test Suite
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    EC and SuperI/O tests not supported

Keyboard Function Key Brightness Down In Linux
    [Documentation]    Check whether function key: brightness down works in
    ...    Linux OS.
    Turn On ACPI CALL Module In Linux
    ${max_brightness}=    Get Maximum Brightness In Linux
    Set Brightness In Linux    ${max_brightness}
    ${brightness1}=    Get Current Brightness In Linux
    Brightness Down Button In Linux
    ${brightness2}=    Get Current Brightness In Linux
    Should Be True    ${brightness2} < ${brightness1}

Keyboard Function Key Brightness Up In Linux
    [Documentation]    Check whether function key: brightness up works in
    ...    Linux OS.
    Turn On ACPI CALL Module In Linux
    Set Brightness In Linux    0
    ${brightness1}=    Get Current Brightness In Linux
    Brightness Up Button In Linux
    ${brightness2}=    Get Current Brightness In Linux
    Should Be True    ${brightness2} > ${brightness1}

Keyboard Function Key Camera OnOff In Linux
    [Documentation]    Check whether the camera on/off hotkey works correctly.
    Turn On ACPI CALL Module In Linux
    ${out}=    List Devices In Linux    usb
    Should Contain Any    ${out}    Camera    BisonCam
    Toggle Camera In Linux
    ${out}=    List Devices In Linux    usb
    Should Not Contain Any    ${out}    Camera    BisonCam
    Toggle Camera In Linux
    ${out}=    List Devices In Linux    usb
    Should Contain Any    ${out}    Camera    BisonCam

Keyboard Function Key Flight Mode In Linux
    [Documentation]    Check whether function key: flight mode works in
    ...    Linux OS.
    Turn On ACPI CALL Module In Linux
    ${wifi_status}=    Get WiFi Block Status
    ${bt_status}=    Get Bluetooth Block Status
    Should Be True    ${wifi_status} == False
    Should Be True    ${bt_status} == False
    Toggle Flight Mode In Linux
    ${wifi_status}=    Get WiFi Block Status
    ${bt_status}=    Get Bluetooth Block Status
    Should Be True    ${wifi_status} == True
    Should Be True    ${bt_status} == True
    Toggle Flight Mode In Linux
    ${wifi_status}=    Get WiFi Block Status
    ${bt_status}=    Get Bluetooth Block Status
    Should Be True    ${wifi_status} == False
    Should Be True    ${bt_status} == False

Charging Until 98% Level In Linux
    [Documentation]    Check whether the DUT stops charging the battery when the
    ...    98% threshold is reached.
    Sonoff On
    Charge Battery Until Target Level In Linux    98
    Sonoff Off
    Check Charging State Not Charging In Linux

Not Charging Between 95% And 98% In Linux
    [Documentation]    Check whether the DUT does not charge the battery when
    ...    the charge level is between 95% and 98%.
    ${percentage}=    Check Battery Percentage In Linux
    IF    ${percentage} < 95
        Sonoff On
        Charge Battery Until Target Level In Linux    96
        Sonoff Off
        Sleep    5
        Sonoff On
        Check Charging State Not Charging In Linux
    ELSE
        Sonoff Off
        Sleep    5
        Sonoff On
        Check Charging State Not Charging In Linux
    END
