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
TEST
    Set Test Variable    ${DUT_CONNECTION_METHOD}    SSH
    Log    ${DUT_CONNECTION_METHOD}
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
