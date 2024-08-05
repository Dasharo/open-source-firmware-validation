*** Settings ***
Documentation       This suite verifies the correct operation of keywords
...                 getting and setting state of boolean options.

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
BOT001.001 Boot To Ubuntu Multiple Times
    [Documentation]    This test verifies if the DUT can boot to Ubuntu multiple times in a row.
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    FOR    ${i}    IN RANGE    5
        ${index}=    Evaluate    ${i} + 1
        Log To Console    Iteration: ${index}
        Power On
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
    END

BOT002.001 Boot To Windows Multiple Times
    [Documentation]    This test verifies if the DUT can boot to Windows multiple times in a row.
    Depends On    ${TESTS_IN_WINDOWS_SUPPORT}
    FOR    ${i}    IN RANGE    5
        ${index}=    Evaluate    ${i} + 1
        Log To Console    Iteration: ${index}
        Power On
        Login To Windows
        ${out}=    Execute Command In Terminal    ls
    END

BOT003.001 Boot To Ubuntu Then Boot To Windows
    [Documentation]    This test verifies if the DUT can boot to multiple OS one after another multiple times.
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Depends On    ${TESTS_IN_WINDOWS_SUPPORT}
    FOR    ${i}    IN RANGE    5
        ${index}=    Evaluate    ${i} + 1
        Log To Console    Iteration: ${index}
        Power On
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        Power On
        Login To Windows
        Execute Command In Terminal    ls
    END

BOT004.001 Power On Test
    Log To Console    \n
    FOR    ${i}    IN RANGE    10
        ${index}=    Evaluate    ${i} + 1
        Log To Console    Iteration: ${index}
        Power On
        ${result}=    Wait For Serial Output
    END

TEST
    Set Test Variable    ${DUT_CONNECTION_METHOD}    SSH
    Login To Windows Via SSH    ${DEVICE_WINDOWS_USERNAME}    ${DEVICE_WINDOWS_PASSWORD}

    #Power On
    #Login To Windows

    Log To Console    \nOUT1 START\n
    ${out1}=    Execute Command In Terminal    Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
    #${out1}=    Execute Command In Terminal    ls    
    Log To Console    \nOUT1:\n${out1}

    Log To Console    \nOUT2 START\n
    ${out2}=    Execute Command In Terminal    Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
    #${out2}=    Execute Command In Terminal    ls
        Log To Console    \nOUT2:\n${out2}
    Should Be Equal As Strings    ${out1}    ${out2}
