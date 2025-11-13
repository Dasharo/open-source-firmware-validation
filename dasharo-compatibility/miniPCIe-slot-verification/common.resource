*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for miniPCIe slot verification tests

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
MWL Suite Setup
    [Documentation]    Common suite setup for miniPCIe slot tests
    Prepare Test Suite
    Skip If    not ${MINI_PC_IE_SLOT_SUPPORT}    MiniPCIe slot tests not supported

Check Wireless Card Detection Linux
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${WIFI_CARD_UBUNTU}

Check Wi-Fi Scanning Linux
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Scan For Wi-Fi In Linux

Check Bluetooth Scanning Linux
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Scan For Bluetooth In Linux

Check LTE Card Detection Linux
    [Documentation]    Check whether the LTE card is detected correctly in the
    ...    operating system.
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${LTE_CARD}
