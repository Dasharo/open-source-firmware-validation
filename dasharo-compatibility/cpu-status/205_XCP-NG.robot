*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${CPU_TESTS_SUPPORT}    CPU tests not supported
...                     AND    Skip If    not ${TESTS_IN_XCP_NG_SUPPORT}    XCP-NG not supported
...                     AND    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    XCP-NG not supported
...                     AND    Reset UEFI Options To Defaults
...                     AND    Init CPU XCP-NG
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CPU001.205 CPU works (XCP-NG)
    [Documentation]    Check whether the CPU mounted on the DUT works.
    ...    Previous IDs: CPU001.010
    Pass Execution    Booted into OS

CPU002.205 CPU cache enabled (XCP-NG)
    [Documentation]    Check whether all declared for the DUT cache levels
    ...    are enabled.
    ...    Previous IDs: CPU002.010
    CPU Cache Enabled Linux

CPU003.205 Multiple CPU support (XCP-NG)
    [Documentation]    Check whether the DUT has multiple CPU support.
    ...    Previous IDs: CPU003.010
    Multiple CPU Support Linux

CPU004.205 Multiple-core support (XCP-NG)
    [Documentation]    Check whether the DUT has multi-core support
    ...    Previous IDs: CPU004.010
    Multiple-Core Support Linux


*** Keywords ***
Init CPU XCP-NG
    Power On
    Login To OS    ${ENV_ID_XCP_NG}
