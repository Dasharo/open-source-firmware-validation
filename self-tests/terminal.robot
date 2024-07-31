*** Settings ***
Documentation       This suite verifies the correct operation of keywords
...                 entering and parsing UEFI shell commands

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
Execute UEFI Shell Command
    [Documentation]    Test Execute Shell Command kwd
    Power On
    Enter UEFI Shell
    ${out}=    Execute UEFI Shell Command    map
    Should Contain    ${out}    Alias(s):
    ${out}=    Execute UEFI Shell Command    devices
    Should Contain    ${out}    Device Name
    ${out}=    Execute UEFI Shell Command    bcfg boot dump
    Should Contain    ${out}    Optional- N

TEST Testy test of tests
    Set Test Variable    ${MENU_TEST}    Device manager
    Set Test Variable    ${DEVICE_MGR_MENU_TEST}    Secure Boot Configuration
    Set Test Variable    ${SB_MENU_TEST}    Current Secure Boot State

    FOR    ${i}    IN RANGE    200
        Log To Console    \n--------------------------------------------
        Log To Console    Iteration: ${i}
        Power On
        Enter Setup Menu Tianocore

        Log To Console    Menu Tianocore:\n

        ${menu}=    Get Setup Menu Construction

        # Run Keyword And Continue On Failure    Should Contain    ${menu}    ${menu_test}
        Run Keyword And Continue On Failure    Should Not Be Empty    ${menu}

        FOR    ${line}    IN    @{menu}
            Log To Console    Line: ${line}
            Run Keyword And Continue On Failure    Should Not Contain    ${line}    <This section will>
        END

        Log To Console    \nDevice Manager:\n

        ${device_mgr_menu}=    Enter Submenu From Snapshot And Return Construction    ${menu}    Device Manager

        # Run Keyword And Continue On Failure    Should Contain    ${device_mgr_menu}    ${device_mgr_menu_test}
        Run Keyword And Continue On Failure    Should Not Be Empty    ${device_mgr_menu}

        FOR    ${line}    IN    @{device_mgr_menu}
            Log To Console    Line: ${line}
            Run Keyword And Continue On Failure    Should Not Contain    ${line}    Devices List
            Run Keyword And Continue On Failure    Should Not Contain    ${line}    Select to manage
        END

        Log To Console    \nSecure Boot Configuration:\n

        ${sb_menu}=    Enter Submenu From Snapshot And Return Construction
        ...    ${device_mgr_menu}
        ...    Secure Boot Configuration

        # Run Keyword And Continue On Failure    Should Contain    ${sb_menu}    ${sb_menu_test}
        Run Keyword And Continue On Failure    Should Not Be Empty    ${sb_menu}

        FOR    ${line}    IN    @{sb_menu}
            Log To Console    Line: ${line}
            Run Keyword And Continue On Failure    Should Not Contain    ${line}    state: enabled or
            Run Keyword And Continue On Failure    Should Not Contain    ${line}    disabled.
        END
    END
