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
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
BGS001.201 Boot Guard support (Ubuntu)
    [Documentation]    Intel Boot Guard is a hardware-based technology intended
    ...    to protect the device against executing non-genuine firmware. This
    ...    test aims to verify that the implemented Boot Guard mechanism works
    ...    correctly by examining the CBnT output in cbmem log.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Execute Manual Step    [1/5] Power on the DUT
    Execute Manual Step    [2/5] Boot into Ubuntu
    Execute Manual Step    [3/5] Log into the system using the proper login and password
    Execute Manual Step    [4/5] Open a terminal window and execute: sudo ./cbmem -1 | grep CBnT
    Execute Manual Step
    ...    [5/5] Confirm that the output contains CBnT fields including NEM status: 1,
    ...    and if Boot Guard profile is 4 or 5 FACB: 1, and if profile is 3 or 5
    ...    measured boot: 1 and verified boot: 1
