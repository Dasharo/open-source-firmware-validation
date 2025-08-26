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

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${SMM_WRITE_PROTECTION_SUPPORT}    SMM BIOS write protection not supported
...                     AND
...                     Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}    Dasharo Security menu not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
Reproduce issue #1293
    [Documentation]    Test preparation involves: enabling both quiet and fast boot,
    ...    making sure that UEFI shell will be the 1st entry.
    ...    In test, we power cycle until we can see the boot strings again,
    ...    indicating quiet boot has been disabled (reset to default).
    ${start_time}=    Get Time    epoch
    Rte Psu Off
    Sleep    5
    Rte Psu On
    Sleep    5
    Rte Power Off
    Sleep    5
    FOR    ${i}    IN RANGE    100
        ${iteration_start}=    Get Time    epoch
        Log To Console    \n--- Iteration ${i+1}/100 ---
        Rte Power On
        ${out}=    Read From Terminal Until    UEFI Interactive Shell
        Should Not Contain    ${out}    ${TIANOCORE_STRING}
        Rte Power Off    time=${1}
        ${iteration_end}=    Get Time    epoch
        ${iteration_duration}=    Evaluate    round(${iteration_end} - ${iteration_start}, 2)
        ${total_elapsed}=    Evaluate    round(${iteration_end} - ${start_time}, 2)
        Log To Console    Iteration ${i+1} completed in ${iteration_duration}s | Total elapsed: ${total_elapsed}s
        Sleep    1
    END
    ${final_time}=    Get Time    epoch
    ${total_test_time}=    Evaluate    round(${final_time} - ${start_time}, 2)
    Log To Console    \nTest completed in ${total_test_time} seconds
