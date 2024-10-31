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
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${BOOT_BLOCKING_SUPPORT}    Boot blocking not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
BBB001.001 Boot blocking (charger disconnected) (Ubuntu)
    [Documentation]    Discharge the battery to below 5% and check if booting is
    ...    blocked.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    BBB001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Sonoff Off
    Discharge The Battery Until Target Level In Linux    3
    Execute Command In Terminal    reboot

BBB001.002 Boot blocking (charger connected) (Ubuntu)
    [Documentation]    Discharge the battery to below 5% and check if booting is
    ...    blocked.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    BBB001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Sonoff Off
    Discharge The Battery Until Target Level In Linux    3
    Sonoff On
    Execute Command In Terminal    reboot
