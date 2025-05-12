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
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${CPU_TESTS_SUPPORT}    CPU tests not supported
...                     AND
...                     Reset UEFI Options To Defaults
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
CPU001.401 CPU works (ESXi)
    [Documentation]    Verify that the CPU on the DUT is functional and boots the ESXi OS.
    ...    The test passes if the ESXi login screen (DCUI) is visible after boot.
    ...    Previous IDs: CPU001.011
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    CPU001.401 not supported
    Skip If    '${ENV_ID_ESXI}' not in ${TESTED_LINUX_DISTROS}    CPU001.401 not supported

    Pause Execution
    ...    This is a manual test to verify that the CPU is working and the system boots into ESXi.

    Execute Manual Step    [1/2] Power on the DUT
    Execute Manual Step    [2/2] Wait for the ESXi login screen (DCUI) to appear on the display

CPU002.401 CPU cache enabled (ESXi)
    [Documentation]    Verify that all CPU cache levels are detected and reported by ESXi.
    ...    Expected output includes L2 and L3 cache size, associativity, and CPU count.
    ...    Previous IDs: CPU002.011
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    CPU002.401 not supported
    Skip If    '${ENV_ID_ESXI}' not in ${TESTED_LINUX_DISTROS}    CPU002.401 not supported

    Pause Execution
    ...    This is a manual test to verify CPU cache detection via esxcli on ESXi.

    Execute Manual Step    [1/4] Power on the DUT
    Execute Manual Step    [2/4] Boot into ESXi
    Execute Manual Step    [3/4] Log in via SSH
    Execute Manual Step    [4/4] Run: esxcli hardware cpu list | grep Cache
    ...    - Confirm the output includes info about L2/L3 cache size, associativity, and CPU count

CPU003.401 Multiple CPU support (ESXi)
    [Documentation]    Verify that ESXi detects more than one CPU core, indicating multi-CPU support.
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    CPU003.401 not supported
    Skip If    '${ENV_ID_ESXI}' not in ${TESTED_LINUX_DISTROS}    CPU003.401 not supported

    Pause Execution
    ...    This is a manual test to verify multiple CPU support via esxcli on ESXi.

    Execute Manual Step    [1/4] Power on the DUT
    Execute Manual Step    [2/4] Boot into ESXi
    Execute Manual Step    [3/4] Log in via SSH
    Execute Manual Step    [4/4] Run: esxcli hardware cpu global get
    ...    - Confirm that the output shows "CPU Cores" greater than 1

CPU004.401 Multiple-core support (ESXi)
    [Documentation]    Verify that the system supports multiple CPU cores using Package ID mapping.
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    CPU004.401 not supported
    Skip If    '${ENV_ID_ESXI}' not in ${TESTED_LINUX_DISTROS}    CPU004.401 not supported

    Pause Execution
    ...    This is a manual test to verify multi-core support via esxcli on ESXi.

    Execute Manual Step    [1/4] Power on the DUT
    Execute Manual Step    [2/4] Boot into ESXi
    Execute Manual Step    [3/4] Log in via SSH
    Execute Manual Step    [4/4] Run: esxcli hardware cpu list | grep Id
    ...    - Confirm that multiple cores share the same Package Id, indicating multi-core support
