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
MEM001.411 Expected RAM size detected (ESXi)
    [Documentation]    Verify that the installed RAM is correctly recognized by ESXi.
    ...    Total memory reported should match the expected amount within a reasonable margin.
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    MEM001.411 not supported
    Skip If    '${ENV_ID_ESXI}' not in ${TESTED_LINUX_DISTROS}    MEM001.411 not supported

    Pause Execution
    ...    This is a manual test to verify physical memory detection on ESXi.

    Execute Manual Step    [1/4] Power on the DUT
    Execute Manual Step    [2/4] Boot into ESXi
    Execute Manual Step    [3/4] Log in via SSH
    Execute Manual Step    [4/4] Run: esxcli hardware memory get
    ...    - Confirm that the "Physical Memory" value matches the expected RAM size
