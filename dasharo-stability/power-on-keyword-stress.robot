*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
Stress test Power On keyword for stability when in firmware
    # Set DUT Response Timeout    30s
    ${failures}=    Set Variable    0
    FOR    ${count}    IN RANGE    10
        Log To Console    \nIteration number: ${count}
        ${result}=    Run Keyword And Ignore Error    Test Power On Kwd In Firmware
        Log To Console    ${SPACE}Result: ${result}
        IF    '${result}[0]' == 'FAIL'
            ${failures}=    Evaluate    ${failures} + 1
        END
    END
    Log To Console    \nFailures: ${failures}
    Should Be Equal As Integers    ${failures}    0    msg=No failures were expected

Stress test Power On keyword for stability when in OS
    # Set DUT Response Timeout    30s
    ${failures}=    Set Variable    0
    FOR    ${count}    IN RANGE    10
        Log To Console    \nIteration number: ${count}
        ${result}=    Run Keyword And Ignore Error    Test Power On Kwd In OS
        Log To Console    ${SPACE}Result: ${result}
        IF    '${result}[0]' == 'FAIL'
            ${failures}=    Evaluate    ${failures} + 1
        END
    END
    Log To Console    \nFailures: ${failures}
    Should Be Equal As Integers    ${failures}    0    msg=No failures were expected


*** Keywords ***
Test Power On Kwd In Firmware
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    Sleep    10s

Test Power On Kwd In OS
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Execute Command In Terminal    sleep 10
