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
    Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}
    Test Make Sure That Flash Locks Are Disabled    Enabled    Enabled

Both locks are present and disabled
    [Documentation]    Tests Make Sure That Flash Locks Are Disabled Keyword
    Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}
    Test Make Sure That Flash Locks Are Disabled    Disabled    Disabled

BIOS lock is enabled, SMM protection is disabled
    [Documentation]    Tests Make Sure That Flash Locks Are Disabled Keyword
    Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}
    Test Make Sure That Flash Locks Are Disabled    Enabled    Disabled

BIOS lock is disabled, SMM protection is enabled
    [Documentation]    Tests Make Sure That Flash Locks Are Disabled Keyword
    Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}
    Test Make Sure That Flash Locks Are Disabled    Disabled    Enabled


*** Keywords ***
Test Make Sure That Flash Locks Are Disabled
    [Documentation]    Tests Make Sure That Flash Locks Are Disabled Keyword
    ...    Accepts initial state of the BIOS lock and SMM protection as args
    [Arguments]    ${bios_lock_init}    ${smm_lock_init}
    IF    "${smm_lock_init}"=="Enabled" and "${OPTIONS_LIB}"=="dcu"    Skip
    Set UEFI Option    LockBios    ${bios_lock_init}
    Set UEFI Option    SmmBwp    ${smm_lock_init}
    IF    "${bios_lock_init}"=="Enabled" or "${smm_lock_init}"=="Enabled"
        # Run Keyword And Expect Error    REGEXP:*contains*    Make Sure That Flash Locks Are Disabled
        Run Keyword And Expect Error    *    Make Sure That Flash Locks Are Disabled
    ELSE
        Make Sure That Flash Locks Are Disabled
    END
