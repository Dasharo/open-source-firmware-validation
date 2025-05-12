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
ETH001.411 All expected NET controllers detected (ESXi)
    [Documentation]    Verify that all expected onboard or add-in Ethernet controllers
    ...    are detected and reported by ESXi with valid driver, link, and MAC.
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    ETH001.411 not supported
    Skip If    '${ENV_ID_ESXI}' not in ${TESTED_LINUX_DISTROS}    ETH001.411 not supported

    Pause Execution
    ...    This is a manual test to verify Ethernet controller detection via esxcli on ESXi.

    Execute Manual Step    [1/4] Power on the DUT
    Execute Manual Step    [2/4] Boot into ESXi
    Execute Manual Step    [3/4] Log in via SSH
    Execute Manual Step    [4/4] Run: esxcli network nic list
    ...    - Confirm that all expected Ethernet controllers are listed
    ...    - Each device should show a valid driver, link status, and MAC address
