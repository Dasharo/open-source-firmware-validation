*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for Wi-Fi and Bluetooth support tests

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
Check Wireless Card Detection Linux
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
    Log To Console    The test passed for the ${WIFI_CARD_UBUNTU} wireless card
    Log    The test passed for the ${WIFI_CARD_UBUNTU} wireless card    WARN

Check Wi-Fi Scanning Linux
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    # with interfaces DOWN, dhclient takes around 37s
    Execute Command In Terminal    dhclient    60s
    IF    "${BOOTED_OS_ID}"=="${ENV_ID_UBUNTU}"
        Detect Or Install Package    network-manager
    END
    Scan For Wi-Fi In Linux
    IF    "${BOOTED_OS_ID}"=="${ENV_ID_UBUNTU}"
        Detect Or Install Package    pciutils
    END
    ${current_card}=    Execute Command In Terminal    lspci | grep "Network controller: | awk -F": " '{print $2}"
    Log To Console    The test passed for the ${current_card} wireless card
    Log    The test passed for the ${current_card} wireless card    WARN

Check Bluetooth Scanning Linux
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Scan For Bluetooth In Linux
    ${current_card}=    Execute Command In Terminal    lspci | grep "Network controller:" | awk -F": " '{print $2}'
    Log To Console    The test passed for the ${current_card} wireless card
    Log    The test passed for the ${current_card} wireless card    WARN
