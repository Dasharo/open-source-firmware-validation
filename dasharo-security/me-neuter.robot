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
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${DASHARO_INTEL_ME_MENU_SUPPORT}    Dasharo Intel ME menu not supported
...                     AND
...                     Set UEFI Option    MeMode    Enabled
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
MNE001.001 Intel ME mode option is available and has the correct default state
    [Documentation]    Check whether the Intel ME mode state after flashing the
    ...    platform with the Dasharo firmware is correct.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    MNE001.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${me_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Intel Management Engine Options
    ${state}=    Get Option State    ${me_menu}    Intel ME mode
    Should Be Equal    ${state}    Enabled

MNE002.001 Intel ME mode option Enabled works correctly (Ubuntu)
    [Documentation]    Check whether the Intel ME mode option in state Enabled
    ...    works correctly.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MNE002.001 not supported
    Set UEFI Option    MeMode    Enabled
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${result}=    Check ME Out
    Should Be Equal As Strings    ${result}    Enabled

MNE003.001 Intel ME mode option Disabled (Soft) works correctly (Ubuntu)
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disabled (Soft) works correctly
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MNE003.001 not supported
    Set UEFI Option    MeMode    Disabled (Soft)
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${result}=    Check ME Out
    IF    '${result}' == 'Disabled'
        Log    ME Device Is Disabled (HAP/Soft) Or Does Not Exist    WARN
    ELSE
        Should Be Equal As Strings    ${result}    Disabled (Soft)
    END

MNE004.001 Intel ME mode option Disabled (HAP) works correctly (Ubuntu)
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disabled (HAP) works correctly.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MNE004.001 not supported
    Set UEFI Option    MeMode    Disabled (HAP)
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${result}=    Check ME State
    IF    '${result}' == 'Disabled'
        Log    ME Device Is Disabled (HAP/Soft) Or Does Not Exist    WARN
    ELSE
        Should Be Equal As Strings    ${result}    Disabled (HAP)
    END

MNE006.001 Check Intel ME version (Ubuntu)
    [Documentation]    This test aims to verify that the Intel ME version might
    ...    be read on the Operating System level. The read version should be
    ...    the same as in the release notes.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MNE006.001 not supported
    Set UEFI Option    MeMode    Enabled
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    cat /sys/class/mei/mei0/fw_ver
    Should Not Be Empty    ${out}
