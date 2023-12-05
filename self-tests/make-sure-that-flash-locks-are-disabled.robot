*** Settings ***
Documentation       This suite verifies the correct operation of the keyword making
...                 sure that flash locks are disabled in various starting scenarios.

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
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
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
Both locks are present and enabled
    [Documentation]    Tests Make Sure That Flash Locks Are Disabled Keyword
    Test Make Sure That Flash Locks Are Disabled    ${TRUE}    ${TRUE}

Both locks are present and disabled
    [Documentation]    Tests Make Sure That Flash Locks Are Disabled Keyword
    Test Make Sure That Flash Locks Are Disabled    ${FALSE}    ${FALSE}

BIOS lock is enabled, SMM protection is disabled
    [Documentation]    Tests Make Sure That Flash Locks Are Disabled Keyword
    Test Make Sure That Flash Locks Are Disabled    ${TRUE}    ${FALSE}

BIOS lock is disabled, SMM protection is enabled
    [Documentation]    Tests Make Sure That Flash Locks Are Disabled Keyword
    Test Make Sure That Flash Locks Are Disabled    ${FALSE}    ${TRUE}


*** Keywords ***
Test Make Sure That Flash Locks Are Disabled
    [Documentation]    Tests Make Sure That Flash Locks Are Disabled Keyword
    ...    Accepts initial state of the BIOS lock and SMM protection as args
    [Arguments]    ${bios_lock_init}    ${smm_lock_init}
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Submenu From Snapshot And Return Construction    ${setup_menu}    Dasharo System Features
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${security_menu}    Lock the BIOS boot medium    ${bios_lock_init}
    Save Changes
    Reenter Menu
    Set Option State    ${security_menu}    Enable SMM BIOS write    ${smm_lock_init}
    Save Changes And Reset    2    4
    Sleep    5s

    Make Sure That Flash Locks Are Disabled

    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Submenu From Snapshot And Return Construction    ${setup_menu}    Dasharo System Features
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    ${bios_lock}=    Get Option State    ${security_menu}    Lock the BIOS boot medium
    ${smm_lock}=    Get Option State    ${security_menu}    Enable SMM BIOS write
    Should Not Be True    ${bios_lock}
    Should Not Be True    ${smm_lock}
