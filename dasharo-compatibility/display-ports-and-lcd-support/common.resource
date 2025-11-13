*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for DSP tests

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
Check External HDMI Display Linux
    [Documentation]    Check whether an external HDMI display is visible in
    ...    Linux OS. Assumes already booted and logged in as root.
    Check External HDMI In Linux

Check Internal Display Linux
    [Documentation]    Check whether an internal display is visible in Linux.
    ...    Assumes already booted and logged in as root.
    Check Internal LCD Linux

Check External DP Display Linux
    [Documentation]    Check whether an external Display Port is visible in
    ...    Linux OS. Assumes already booted and logged in as root.
    Check External DP In Linux
