# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
WBS001.001 Wifi and Bluetooth card power switch disabled (Ubuntu)
    [Documentation]    Checks whether Wifi + Bluetooth is detected by Linux
    ...    after setting Enable Wi-Fi + BT radios option to false
    Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}
    Skip If    not ${WIFI_BLUETOOTH_CARD_SWITCH_SUPPORT}    WBS001.001 not supported
    Set UEFI Option    EnableWifiBt    ${FALSE}
    Login To Linux
    Switch To Root User
    Detect Or Install Package    pciutils
    Detect Or Install Package    usbutils
    ${wifi}=    Check The Presence Of WiFi Card
    Should Not Be True    ${wifi}
    ${bt}=    Check The Presence Of Bluetooth Card
    Should Not Be True    ${bt}

WBS002.001 Wifi and Bluetooth card power switch enabled (Ubuntu)
    [Documentation]    Checks whether Wifi + Bluetooth is detected by Linux
    ...    after setting Enable Wi-Fi + BT radios option to true
    Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}
    Skip If    not ${WIFI_BLUETOOTH_CARD_SWITCH_SUPPORT}    WBS002.001 not supported
    Set UEFI Option    EnableWifiBt    ${TRUE}
    Login To Linux
    Switch To Root User
    Detect Or Install Package    pciutils
    Detect Or Install Package    usbutils
    ${wifi}=    Check The Presence Of WiFi Card
    Should Be True    ${wifi}
    ${bt}=    Check The Presence Of Bluetooth Card
    Should Be True    ${bt}
