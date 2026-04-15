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
IBECC001.201 Verify IBECC does not work when disabled (Ubuntu)
    [Documentation]    EDAC driver in Linux will attempt to use IBECC.
    ...    If IBECC is disabled an error will occur in dmesg.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    IBECC001.201 not supported
    Set UEFI Option    IBECC    ${FALSE}
    # Verify that IBECC causes error in dmesg
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    dmesg | grep -i 'edac'
    Should Contain    ${out}    HANDLING IBECC MEMORY ERROR

IBECC002.201 Verify IBECC works when enabled (Ubuntu)
    [Documentation]    EDAC driver in Linux will attempt to use IBECC.
    ...    If IBECC is enabled no error should occur in dmesg.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    IBECC002.201 not supported
    Set UEFI Option    IBECC    ${TRUE}
    # Verify that IBECC does not cause error in dmesg
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    dmesg | grep -i 'edac'
    Should Not Contain    ${out}    HANDLING IBECC MEMORY ERROR
    # Restore default IBECC state and let the memory be trained again
    Set UEFI Option    IBECC    ${FALSE}
    Enter Setup Menu Tianocore
