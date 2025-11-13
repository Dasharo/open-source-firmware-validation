*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for SD card reader tests

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
SDC Suite Setup
    [Documentation]    Common suite setup for SD card reader tests
    Prepare Test Suite
    Skip If    not ${SD_CARD_READER_SUPPORT}    SD card reader tests not supported

Check SD Card Detection Linux
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    ${disks}=    Identify Disks In Linux
    Should Match    str(${disks})    *SD*

Check SD Card Read Write Linux
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Execute Linux Command    dd if=/dev/urandom of=/tmp/in.bin bs=4K count=100
    Execute Linux Command    dd if=/tmp/in.bin of=/dev/mmcblk0 bs=4K count=100
    Execute Linux Command    dd if=/dev/mmcblk0 of=/tmp/out.bin bs=4K count=100
    ${result}=    Check If Files Are Identical In Linux    /tmp/in.bin    /tmp/out.bin
    Should Be True    ${result}
