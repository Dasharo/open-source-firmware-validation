*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${CPU_TESTS_SUPPORT}    CPU tests not supported
...                     AND    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Ubuntu not supported
...                     AND    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    Ubuntu not supported
...                     AND    Reset UEFI Options To Defaults
...                     AND    Init CPU Ubuntu
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CPU001.201 CPU works (Ubuntu)
    [Documentation]    Check whether the CPU mounted on the DUT works.
    ...    Previous IDs: CPU001.001
    Pass Execution    Booted into OS

CPU002.201 CPU cache enabled (Ubuntu)
    [Documentation]    Check whether the all declared for the DUT cache levels
    ...    are enabled.
    ...    Previous IDs: CPU002.001
    CPU Cache Enabled Linux

CPU003.201 Multiple CPU support (Ubuntu)
    [Documentation]    Check whether the DUT has multiple CPU support.
    ...    Previous IDs: CPU003.001
    Multiple CPU Support Linux

CPU004.201 Multiple-core support (Ubuntu)
    [Documentation]    Check whether the DUT has multi-core support.
    ...    Previous IDs: CPU004.001
    Multiple-Core Support Linux


*** Keywords ***
Init CPU Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
