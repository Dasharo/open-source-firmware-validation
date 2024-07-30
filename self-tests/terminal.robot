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
    FOR    ${i}    IN RANGE    50
        Power On
        Enter Setup Menu Tianocore

        Log To Console    \nIteration: ${i}

        ${menu}=    Get Setup Menu Construction
        Log To Console    Menu Tianocore:\n
        FOR    ${line}    IN    @{menu}
            Log To Console    Line: ${line}
            Run Keyword And Continue On Failure    Should Not Contain    ${line}    <This section will>
        END
        Run Keyword And Continue On Failure    Should Contain    ${menu}    Device Manager
        Run Keyword And Continue On Failure    Should Not Be Empty    ${menu}

        Log To Console    \nDevice Manager:\n
        ${device_mgr_menu}=    Enter Submenu From Snapshot And Return Construction    ${menu}    Device Manager
        FOR    ${line}    IN    @{device_mgr_menu}
            Log To Console    Line: ${line}
            Run Keyword And Continue On Failure    Should Not Contain    ${line}    Devices List
            Run Keyword And Continue On Failure    Should Not Contain    ${line}    Selecto to manage
        END
        Run Keyword And Continue On Failure    Should Contain    ${device_mgr_menu}    Secure Boot Configuration
        Run Keyword And Continue On Failure    Should Not Be Empty    ${device_mgr_menu}

        Log To Console    \nSecure Boot Configuration:\n
        ${sb_menu}=    Enter Submenu From Snapshot And Return Construction
        ...    ${device_mgr_menu}
        ...    Secure Boot Configuration
        FOR    ${line}    IN    @{sb_menu}
            Log To Console    Line: ${line}
            Run Keyword And Continue On Failure    Should Not Contain    ${line}    state: enabled or
            Run Keyword And Continue On Failure    Should Not Contain    ${line}    disabled.
        END
        Run Keyword And Continue On Failure    Should Contain    ${sb_menu}    Secure Boot Configuration
        Run Keyword And Continue On Failure    Should Not Be Empty    ${sb_menu}

        # Sleep    1s
        # Exit From Current Menu
        # Sleep    1s
        # Exit From Current Menu
        # Sleep    1s
        # Write Into Terminal    ${ARROW_UP}
        # Sleep    1s
        # Write Into Terminal    ${ARROW_UP}
        # Sleep    1s
    END
