*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for EFI Boot Manager tests

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
${TEST_BOOT_ENTRY_NAME}=        dasharo-compatibility_efibootmgr-custom-boot-entry
${PLATFORM_STATE_CONTROL}=      ${TRUE}


*** Keywords ***
EBM Suite Setup
    [Documentation]    Common suite setup for EFI Boot Manager tests
    Prepare Test Suite
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Efi Boot Manager requires Ubuntu

EBM Suite Teardown
    [Documentation]    If tests are supported, remove test boot entries
    ...    and then close connection to DUT
    IF    ${TESTS_IN_UBUNTU_SUPPORT}
        Power Cycle On
        Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
        Login To Linux
        Switch To Root User
        Remove Test Boot Entry Return Bootorder
    END
    Log Out And Close Connection

Remove Test Boot Entry Return Bootorder
    [Documentation]    Removes the custom boot entry which name is defined in ***Variables***
    VAR    ${id}=
    ...    $(efibootmgr | grep "${TEST_BOOT_ENTRY_NAME}" | cut -d" " -f1 | grep -Eo '[0-9A-F]{4}' | grep -Eo '[^0][0-9A-F]{0,3}|0$')
    ${out}=    Execute Command In Terminal    efibootmgr -b ${id} -B
    RETURN    ${out}

Find Test Boot Entry Id
    [Documentation]    Returns the Id of custom boot entry
    VAR    ${id}=
    ...    $(efibootmgr | grep "${TEST_BOOT_ENTRY_NAME}" | cut -d" " -f1 | grep -Eo '[0-9A-F]{4}' | grep -Eo '[^0][0-9A-F]{0,3}|0$')
    RETURN    ${id}
