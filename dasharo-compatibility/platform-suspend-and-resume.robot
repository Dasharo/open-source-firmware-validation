*** Settings ***
Library             Collections
Library             DateTime
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds
Library             SSHLibrary    timeout=20 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     Check If Platform Sleep Type Can Be Selected
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
SUSP005.001 Cyclic platform suspend and resume (Ubuntu)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SUSP005.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUSP005.001 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP005.001 not supported
    Cyclic Platform Suspend And Resume (Ubuntu)

SUSP005.002 Cyclic platform suspend and resume (Ubuntu) (S0ix)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SUSP005.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUSP005.002 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP005.002 not supported
    Set Platform Sleep Type    S0ix
    Cyclic Platform Suspend And Resume (Ubuntu)    S0ix

SUSP005.003 Cyclic platform suspend and resume (Ubuntu) (S3)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SUSP005.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUSP005.003 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP005.003 not supported
    Set Platform Sleep Type    S3
    Cyclic Platform Suspend And Resume (Ubuntu)    S3


*** Keywords ***
Cyclic Platform Suspend And Resume (Ubuntu)
    [Arguments]    ${platform_sleep_type}=${EMPTY}
    ${suspend_detected_fails}=    Set Variable    ${0}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Check Platform Sleep Type Is Correct On Linux    ${platform_sleep_type}
    Switch To Root User
    Detect Or Install FWTS
    FOR    ${index}    IN RANGE    0    ${SUSPEND_ITERATIONS_NUMBER}
        ${is_suspend_performed_correctly}=    Perform Suspend Test Using FWTS
        IF    not ${is_suspend_performed_correctly}
            ${suspend_detected_fails}=    Evaluate    ${suspend_detected_fails} + 1
        END
        Log To Console    ${index} / ${SUSPEND_ITERATIONS_NUMBER}
    END
    Log To Console
    ...    \n${SUSPEND_ITERATIONS_NUMBER} iterations were performed to check the suspend procedure. \n${suspend_detected_fails} iterations have failed.
    IF    ${suspend_detected_fails} > ${SUSPEND_ALLOWED_FAILS}
        FAIL
        ...    \nTest case ${TEST_NAME} has been marked as failed. \nThe number of detected errors is greater than the number of allowed fails: ${SUSPEND_ALLOWED_FAILS}.
    ELSE
        Pass Execution
        ...    \nTest case ${TEST_NAME} has been marked passed. \nThe number of detected errors is at least the same as the number of allowed fails: ${SUSPEND_ALLOWED_FAILS}.
    END
