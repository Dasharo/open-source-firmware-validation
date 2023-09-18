*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
MNE001.001 Intel ME mode option is available and has the correct default state
    [Documentation]    Check whether the Intel ME mode state after flashing the
    ...    platform with the Dasharo firmware is correct.
    Skip If    not ${me_neuter_support}    MNE001.001 not supported
    Skip If    not ${tests_in_firmware_support}    MNE001.001 not supported
    Power On
    Enter Setup Menu Tianocore
    ${menu}=    Return Intel ME Options
    Should Contain    ${menu}    <Enabled>

MNE002.001 Intel ME mode option Enabled works correctly (Ubuntu 22.04)
    [Documentation]    Check whether the Intel ME mode option in state Enabled
    ...    works correctly.
    Skip If    not ${me_neuter_support}    MNE002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    MNE002.001 not supported
    Power On
    Enter Setup Menu Tianocore
    ${menu}=    Return Intel ME Options
    ${actual_state}=    Get Intel ME Mode State    ${menu}
    IF    '${actual_state}' != 'Enabled'
        Setup Intel ME mode    ${actual_state}    Enabled
    END
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    pci
    Should Contain    ${out}    00:16.0

MNE003.001 Intel ME mode option Disable (Soft) works correctly (Ubuntu 22.04)
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disable (Soft) works correctly
    Skip If    not ${me_neuter_support}    MNE003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    MNE003.001 not supported
    Power On
    Enter Setup Menu Tianocore
    ${menu}=    Return Intel ME Options
    ${actual_state}=    Get Intel ME Mode State    ${menu}
    IF    '${actual_state}' != 'Disabled (Soft)'
        Setup Intel ME mode    ${actual_state}    Disabled (Soft)
    END
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    pci
    Should Not Contain    ${out}    00:16.0

MNE004.001 Intel ME mode option Disable (HAP) works correctly (Ubuntu 22.04)
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disable (HAP) works correctly.
    Skip If    not ${me_neuter_support}    MNE004.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    MNE004.001 not supported
    Power On
    Enter Setup Menu Tianocore
    ${menu}=    Return Intel ME Options
    ${actual_state}=    Get Intel ME Mode State    ${menu}
    IF    '${actual_state}' != 'Disabled (HAP)'
        Setup Intel ME mode    ${actual_state}    Disabled (HAP)
    END
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    pci
    Should Not Contain    ${out}    00:16.0

MNE006.001 Check Intel ME version (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the Intel ME version might
    ...    be read on the Operating System level. The read version should be
    ...    the same as in the release notes.
    Skip If    not ${me_neuter_support}    MNE006.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    MNE006.001 not supported
    Power On
    Enter Setup Menu Tianocore
    ${menu}=    Return Intel ME Options
    ${actual_state}=    Get Intel ME Mode State    ${menu}
    IF    '${actual_state}' != 'Enabled'
        Setup Intel ME mode    ${actual_state}    Enabled
    END
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out}=    Execute Command In Terminal    cat /sys/class/mei/mei0/fw_ver
    Should Not Be Empty    ${out}
