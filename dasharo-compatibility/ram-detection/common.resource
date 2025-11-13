*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for RAM detection tests

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
${SIZE_OF_33_GB}=               35433480192    # 33*1024*1024*1024
${SIZE_OF_31_GB}=               33285996544    # 31*1024*1024*1024
${PLATFORM_STATE_CONTROL}=      ${TRUE}


*** Keywords ***
MEM Suite Setup
    [Documentation]    Common suite setup for RAM detection tests
    Prepare Test Suite
    Skip If    not ${CPU_TESTS_SUPPORT}    CPU tests not supported
    Reset UEFI Options To Defaults
