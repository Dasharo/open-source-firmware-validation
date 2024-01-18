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
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
CNB001.001 Only one iPXE in boot menu
    [Documentation]    Check whether the network boot option with iPXE appears
    ...    only once in the boot option list.
    Skip If    not ${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}    CNB001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CNB001.001 not supported
    Power On
    Enter Boot Menu
    Check IPXE Appears Only Once
