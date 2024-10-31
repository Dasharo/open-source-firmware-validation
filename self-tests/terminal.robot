# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

*** Settings ***
Documentation       This suite verifies the correct operation of keywords
...                 entering and parsing UEFI shell commands

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
Execute UEFI Shell Command
    [Documentation]    Test Execute Shell Command kwd
    Power On
    Enter UEFI Shell
    ${out}=    Execute UEFI Shell Command    map
    Should Contain    ${out}    Alias(s):
    ${out}=    Execute UEFI Shell Command    devices
    Should Contain    ${out}    Device Name
    ${out}=    Execute UEFI Shell Command    bcfg boot dump
    Should Contain    ${out}    Optional- N

Execute Command In Terminal over SSH (Windows)
    [Documentation]    Test Execute Command In Terminal keyword over SSH. This is related
    ...    to bug: https://github.com/Dasharo/open-source-firmware-validation/issues/355
    ...    when a command was run multiple times, every time it produced different outputs.
    ...    Usually containing parts of previously run command.

    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    Execute Command In Terminal over SSH (Windows) not supported
    Power On
    Login To Windows
    Set Test Variable    ${COMMAND}    Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
    ${out1}=    Execute Command In Terminal    ${COMMAND}
    ${out2}=    Execute Command In Terminal    ${COMMAND}
    Should Be Equal As Strings    ${out1}    ${out2}
    Should Not Contain    ${out1}    ${COMMAND}
    Should Not Contain    ${out2}    ${COMMAND}

    Set Test Variable    ${COMMAND}    ls
    ${out1}=    Execute Command In Terminal    ${COMMAND}
    ${out2}=    Execute Command In Terminal    ${COMMAND}
    Should Be Equal As Strings    ${out1}    ${out2}
    Should Not Contain    ${out1}    ${COMMAND}
    Should Not Contain    ${out2}    ${COMMAND}

    Set Test Variable    ${COMMAND}    driverquery
    ${out1}=    Execute Command In Terminal    ${COMMAND}
    ${out2}=    Execute Command In Terminal    ${COMMAND}
    Should Be Equal As Strings    ${out1}    ${out2}
    Should Not Contain    ${out1}    ${COMMAND}
    Should Not Contain    ${out2}    ${COMMAND}
