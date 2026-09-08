*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/sleep-lib.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Tests in Firmware not supported
...                     AND
...                     Skip If    not ${STM_SUPPORT}    STM is not supported
...                     AND
...                     Enable STM
Suite Teardown      Run Keywords
...                     Disable STM
...                     AND
...                     Log Out And Close Connection
Test Setup          Restore Initial DUT Connection Method

Default Tags        automated


*** Variables ***
${STM_LAUNCHED_STRING}=     STM apparently launched
${STM_ERROR_STRING}=        EPTViolationHandler


*** Test Cases ***
STM001.201 STM dual-monitor treatment is active after boot (Ubuntu)
    [Documentation]    Verify The STM Loaded And The Dual Boot Monitor Treatment Is Active After Boot

    Skip If    Not ${TESTS_IN_UBUNTU_SUPPORT}    STM001.201 Not Supported
    Power On
    # TODO: boot from pre-provisioned image
    Login To Linux
    Switch To Root User
    Ensure STM Module Is Loaded

    ${dmesg_out}=    Execute Command In Terminal    dmesg | grep -i -E "stm|dual.monitor"
    Should Contain    ${dmesg_out}    ${STM_LAUNCHED_STRING}

STM002.201 SMI handler access outside BIOS Resource List is denied (Ubuntu)
    [Documentation]    Test Whether SMI Handler Access Outside BIOS Resource List Is Denied

    Skip If    Not ${TESTS_IN_UBUNTU_SUPPORT}    STM002.201 Not Supported
    Power On
    # TODO: boot from pre-provisioned image
    Login To Linux
    Switch To Root User
    Ensure STM Module Is Loaded

    Execute Command In Terminal    efibootmgr -t 4

    ${cbmem_out}=    Execute Command In Terminal    cbmem -1 | grep "(STM)"
    Should Not Contain    ${cbmem_out}    ${STM_ERROR_STRING}


*** Keywords ***
Ensure STM Module Is Loaded
    [Documentation]    Loads the dual_monitor_mode kernel module
    Execute Command In Terminal    modprobe dual_monitor_mode

Enable STM
    [Documentation]    Enables STM option
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${security_menu}    Enable SMI Transfer Monitor    ${TRUE}
    Save Changes And Reset

Disable STM
    [Documentation]    Disable STM option
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${security_menu}    Enable SMI Transfer Monitor    ${FALSE}
    Save Changes And Reset
