*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for NVIDIA graphics card tests

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
NVI Suite Setup
    [Documentation]    Common suite setup for NVIDIA graphics card tests
    Prepare Test Suite
    Skip If    not ${NVIDIA_GRAPHICS_CARD_SUPPORT}    Nvidia GPU tests not supported

Check NVIDIA Graphics Detect Linux
    [Documentation]    Check whether the NVIDIA graphics card is initialized
    ...    correctly and can be detected by the Linux OS.
    ${out}=    Execute Linux Command    lspci | grep -i nvidia | cat
    Should Contain Any    ${out}    3D controller: NVIDIA Corporation    VGA compatible controller: NVIDIA Corporation

Check NVIDIA Graphics Power Management Linux
    [Documentation]    Check whether the NVIDIA graphics power management is
    ...    functional and the card powers on only while it's used.
    Check NVIDIA Power Management In Linux
