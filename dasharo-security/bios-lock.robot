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
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${BIOS_LOCK_SUPPORT}    BIOS lock not supported
...                     AND
...                     Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}    Dasharo Security menu not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
BLS001.201 BIOS lock support (Ubuntu)
    [Documentation]    BIOS lock is a method to prevent a specific region of the
    ...    firmware from being flashed. This test aims to verify that,
    ...    after turning on the mechanism, the BIOS region should be correctly
    ...    recognized during attempt to overwrite it by using flashrom tool.
    ...    Previous IDs: BLS001.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    BLS001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    BLS001.201 not supported
    BIOS Lock Support    ${ENV_ID_UBUNTU}

BLS002.201 BIOS lock support deactivation (Ubuntu)
    [Documentation]    BIOS lock is a method to prevent a specific region of the
    ...    firmware from being flashed. This test aims to verify that, after
    ...    turning off the mechanism, the BIOS region overwriting operation is
    ...    available again.
    ...    Previous IDs: BLS002.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    BLS002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    BLS002.201 not supported
    BIOS Lock Support Deactivation    ${ENV_ID_UBUNTU}

BLS001.202 BIOS lock support (Fedora)
    [Documentation]    BIOS lock is a method to prevent a specific region of the
    ...    firmware from being flashed. This test aims to verify that,
    ...    after turning on the mechanism, the BIOS region should be correctly
    ...    recognized during attempt to overwrite it by using flashrom tool.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    BLS001.202 not supported
    BIOS Lock Support    ${ENV_ID_FEDORA}

BLS002.202 BIOS lock support deactivation (Fedora)
    [Documentation]    BIOS lock is a method to prevent a specific region of the
    ...    firmware from being flashed. This test aims to verify that, after
    ...    turning off the mechanism, the BIOS region overwriting operation is
    ...    available again.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    BLS002.202 not supported
    BIOS Lock Support Deactivation    ${ENV_ID_FEDORA}


*** Keywords ***
BIOS Lock Support
    [Tags]    robot:private
    [Arguments]    ${os_id}
    ${pr0}=    Get Bios Lock State    ${os_id}
    Should Not Be Empty    ${pr0}

BIOS Lock Support Deactivation
    [Tags]    robot:private
    [Arguments]    ${os_id}
    ${pr0}=    Get Bios Lock State    ${os_id}
    Should Not Be Empty    ${pr0}

Get Bios Lock State
    [Tags]    robot:private
    [Arguments]    ${os_id}
    Set UEFI Option    LockBios    ${TRUE}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    ${pr0}=    Get Lines Matching Regexp    ${out_flashrom}    ^PR0: Warning: 0x.{8}-0x.{8} is read-only.$
    Exit From Root User
    RETURN    ${pr0}
