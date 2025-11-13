*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for CPU tests

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
${PACKAGE_IDS_COUNT}=           0
${CACHE_REGEX}=
...                             (?s)[ ]+L2 Cache Size:
...                             \\d+\\r?\\n[ ]+L2 Cache Associativity:
...                             \\d+\\r?\\n[ ]+L2 Cache Line Size:
...                             \\d+\\r?\\n[ ]+L2 Cache CPU Count:
...                             \\d+\\r?\\n[ ]+L3 Cache Size:
...                             \\d+\\r?\\n[ ]+L3 Cache Associativity:
...                             \\d+\\r?\\n[ ]+L3 Cache Line Size:
...                             \\d+\\r?\\n[ ]+L3 Cache CPU Count:
...                             \\d+\\r?\\n[ ]+L2 Cache Size: \\d+
${PLATFORM_STATE_CONTROL}=      ${TRUE}


*** Keywords ***
CPU Suite Setup
    [Documentation]    Common suite setup for all CPU tests. Includes CPU tests support check
    ...    and reset of UEFI options to defaults.
    Prepare Test Suite
    Skip If    not ${CPU_TESTS_SUPPORT}    CPU tests not supported
    Reset UEFI Options To Defaults

Check Cache Support
    [Arguments]    ${string}    ${cache}
    ${lines}=    Get Lines Containing String    ${string}    ${cache}
    ${lines}=    Get Lines Containing String    ${lines}    CACHE_SIZE
    @{lines}=    Split To Lines    ${lines}
    FOR    ${line}    IN    @{lines}
        ${cache_string}    ${cache_size}=    Split String    ${line}    ${SPACE}    1
        ${cache_size}=    Replace String    ${cache_size}    ${SPACE}    ${EMPTY}
        IF    '${cache_size}' == ''    Fail    Cache size can't be empty
        ${mem}=    Convert To Integer    ${cache_size}
        IF    '${mem}'=='0'    Fail    ${line}    ELSE    Log    ${line}
    END

CPU Cache Enabled Linux
    [Documentation]    Check whether the all declared for the DUT cache levels
    ...    are enabled.
    ${mem_info}=    Execute Linux Command    getconf -a | grep CACHE
    Check Cache Support    ${mem_info}    LEVEL1
    Pass Execution If    not ${L2_CACHE_SUPPORT}    DUT supports only L1 cache
    Check Cache Support    ${mem_info}    LEVEL2
    Pass Execution If    not ${L3_CACHE_SUPPORT}    DUT supports only L1 and L2 cache
    Check Cache Support    ${mem_info}    LEVEL3
    Pass Execution If    not ${L4_CACHE_SUPPORT}    DUT supports only L1, L2 and L3 cache
    Check Cache Support    ${mem_info}    LEVEL4

Multiple CPU Support Linux
    [Documentation]    Check whether the DUT has multiple CPU support.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPU003.001 not supported
    ${cpu_info}=    Execute Linux Command    lscpu
    ${cpu}=    Get Lines Matching Regexp    ${cpu_info}    ^CPU\\(s\\):\\s+\\d+$    flags=MULTILINE
    Should Contain    ${cpu}    ${DEF_THREADS_TOTAL}    Different number of CPU's than ${DEF_THREADS_TOTAL}
    ${online}=    Execute Linux Command    cat /sys/devices/system/cpu/online
    Should Contain    ${online}    ${DEF_ONLINE_CPU}    There are more than ${DEF_ONLINE_CPU[2]} on-line CPU's

Multiple-Core Support Linux
    [Documentation]    Check whether the DUT has multi-core support.
    ${cpu_info}=    Execute Linux Command    lscpu
    ${sockets}=    Get Lines Containing String    ${cpu_info}    Socket(s):
    Should Contain    ${sockets}    ${DEF_SOCKETS}    Different number of sockets than ${DEF_SOCKETS}
    ${cores}=    Get Lines Containing String    ${cpu_info}    Core(s) per socket:
    Should Contain
    ...    ${cores}
    ...    ${DEF_CORES_PER_SOCKET}
    ...    Different number of cores per socket than ${DEF_CORES_PER_SOCKET}
    ${threads}=    Get Lines Containing String    ${cpu_info}    Thread(s) per core:
    Should Contain
    ...    ${threads}
    ...    ${DEF_THREADS_PER_CORE}
    ...    Different number of threads per core than ${DEF_THREADS_PER_CORE}
