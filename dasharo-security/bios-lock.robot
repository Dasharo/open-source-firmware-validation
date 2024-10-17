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


*** Test Cases ***
BLS001.001 BIOS lock support (Ubuntu)
    [Documentation]    BIOS lock is a method to prevent a specific region of the
    ...    firmware from being flashed. This test aims to verify that,
    ...    after turning on the mechanism, the BIOS region should be correctly
    ...    recognized during attempt to overwrite it by using flashrom tool.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    BLS001.001 not supported
    Set UEFI Option    LockBios    ${TRUE}
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    ${pr0}=    Get Lines Matching Regexp    ${out_flashrom}    ^PR0: Warning: 0x.{8}-0x.{8} is read-only.$
    Should Not Be Empty    ${pr0}

BLS002.001 BIOS lock support deactivation (Ubuntu)
    [Documentation]    BIOS lock is a method to prevent a specific region of the
    ...    firmware from being flashed. This test aims to verify that, after
    ...    turning off the mechanism, the BIOS region overwriting operation is
    ...    available again.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    BLS002.001 not supported
    Set UEFI Option    LockBios    ${FALSE}
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    ${pr0}=    Get Lines Matching Regexp    ${out_flashrom}    ^PR0: Warning: 0x.{8}-0x.{8} is read-only.$
    Should Be Empty    ${pr0}
