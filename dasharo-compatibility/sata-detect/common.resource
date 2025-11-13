*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for SATA detection tests

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot


*** Variables ***
${PLATFORM_STATE_CONTROL}=      ${TRUE}


*** Keywords ***
Check SATA Support In Linux
    [Documentation]    Check SATA support using smartctl in Linux
    Detect Or Install Package    smartmontools

    ${lsblk_out}=    Execute Command In Terminal    lsblk -d -o NAME -n
    @{disks}=    Split String    ${lsblk_out}    \n

    FOR    ${disk}    IN    @{disks}
        ${out}=    Execute Command In Terminal    sudo smartctl -i /dev/${disk}
        Log    ${out}
        ${sata_present}=    Run Keyword And Return Status    Should Contain    ${out}    SATA Version is:
        Pass Execution If    '${sata_present}' == 'True'    'SATA disk found, passing test'
    END

    Fail    No SATA disk was found, failing test
