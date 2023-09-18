*** Settings ***
Library             SSHLibrary    timeout=20 seconds
Library             Telnet    timeout=20 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
Library             DateTime
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
SUSP005.001 Cyclic platform suspend and resume (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${suspend_and_resume_support}    SUSP005.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SUSP005.001 not supported
    ${suspend_detected_fails}=    Set Variable    ${0}
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Detect or install FWTS
    FOR    ${INDEX}    IN RANGE    0    ${suspend_iterations_number}
        ${is_suspend_performed_correctly}=    Perform suspend test using FWTS
        IF    not ${is_suspend_performed_correctly}
            ${suspend_detected_fails}=    Evaluate    ${suspend_detected_fails} + 1
        END
    END
    Log To Console
    ...    \n${suspend_iterations_number} iterations were performed to check the suspend procedure. \n${suspend_detected_fails} iterations have failed.
    IF    ${suspend_detected_fails} > ${suspend_allowed_fails}
        FAIL
        ...    \nTest case SUSP001.001 has been marked as failed. \nThe number of detected errors is greater than the number of allowed fails: ${suspend_allowed_fails}.
    ELSE
        Pass Execution
        ...    \nTest case SUSP001.001 has been marked passed. \nThe number of detected errors is at least the same as the number of allowed fails: ${suspend_allowed_fails}.
    END
