*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for CCC tests

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
CCC Suite Setup
    [Documentation]    Common suite setup for CPU cores count tests
    Prepare Test Suite
    Skip If    not ${CPU_CORES_TESTS_SUPPORT}    CPU tests not supported

CCC Suite Teardown
    [Documentation]    Common suite teardown - reset UEFI to defaults
    IF    ${CPU_CORES_TESTS_SUPPORT}
        Power On
        Enter Setup Menu Tianocore
        Reset To Defaults Tianocore
        Save Changes And Reset
        Log Out And Close Connection
    END

Get Threads Per Core
    ${out}=    Execute Command In Terminal    lscpu | grep "Thread(s) per core: "
    ${words}=    Split String    ${out}    ${SPACE}
    ${threads}=    Get From List    ${words}    -1
    IF    '${threads[:1]}' == '1'
        VAR    ${count}=    1
    ELSE IF    '${threads[:1]}' == '2'
        VAR    ${count}=    2
    ELSE
        Fail    Hyper-Threading status could not be established.
    END
    RETURN    ${count}

Get P Cores Count
    [Documentation]    In intel hybrid architecture, return number of
    ...    Performance cores
    ${count}=    Execute Command In Terminal    cpuid -l 0x1a | grep 'Intel Core' | wc -l
    RETURN    ${count}

Get E Cores Count
    [Documentation]    In intel hybrid architecture, return number of
    ...    Efficient cores
    ${count}=    Execute Command In Terminal    cpuid -l 0x1a | grep 'Intel Atom' | wc -l
    RETURN    ${count}
