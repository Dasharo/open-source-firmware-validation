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
Resource            ../lib/bios/menus.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggests (not
#    exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${MEMORY_IBECC_SUPPORT}    Memory IBECC tests not supported
# As a result of this suite, we might get stuck with bricked platform. Make sure
# to flash working firmware.
Suite Teardown      Run Keywords
...                     Log Out And Close Connection


*** Test Cases ***
IBECC001.001 Verify IBECC does not work when disabled
    [Documentation]    EDAC driver in Linux will attempt to use IBECC.
    ...    If IBECC is disabled an error will occur in dmesg.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    MPS001.001 not supported
    Set IBECC State    ${FALSE}
    # Verify that IBECC causes error in dmesg
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    dmesg | grep -i 'edac'
    Should Contain    ${out}    HANDLING IBECC MEMORY ERROR

IBECC002.001 Verify IBECC works when enabled
    [Documentation]    EDAC driver in Linux will attempt to use IBECC.
    ...    If IBECC is enabled no error should occur in dmesg.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    MPS002.001 not supported
    Set IBECC State    ${TRUE}
    # Verify that IBECC does not cause error in dmesg
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    dmesg | grep -i 'edac'
    Should Not Contain    ${out}    HANDLING IBECC MEMORY ERROR
    # Restore default IBECC state and let the memory be trained again
    Set IBECC State    ${FALSE}
    Enter Setup Menu Tianocore


*** Keywords ***
Set IBECC State
    [Arguments]    ${target_state}
    Power On
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    # Get IBECC state and change it if necessary
    ${setup_menu}=    Parse Menu Snapshot Into Construction    ${out}    3    1
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${memory_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Memory Configuration
    ${status}=    Set Option State    ${memory_menu}    Memory In-Band ECC    ${target_state}
    Save Changes And Reset
    # Changing IBECC state cause memory re-training
    Telnet.Set Timeout    5 min
