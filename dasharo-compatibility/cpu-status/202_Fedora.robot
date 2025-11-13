*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${CPU_TESTS_SUPPORT}    CPU tests not supported
...                     AND    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    Fedora not supported
...                     AND    Reset UEFI Options To Defaults
...                     AND    Init CPU Fedora
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CPU001.202 CPU works (Fedora)
    [Documentation]    Check whether the CPU mounted on the DUT works.
    Pass Execution    Booted into OS

CPU002.202 CPU cache enabled (Fedora)
    [Documentation]    Check whether the all declared for the DUT cache levels
    ...    are enabled.
    CPU Cache Enabled Linux

CPU003.202 Multiple CPU support (Fedora)
    [Documentation]    Check whether the DUT has multiple CPU support.
    Multiple CPU Support Linux

CPU004.202 Multiple-core support (Fedora)
    [Documentation]    Check whether the DUT has multi-core support.
    Multiple-Core Support Linux


*** Keywords ***
Init CPU Fedora
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
