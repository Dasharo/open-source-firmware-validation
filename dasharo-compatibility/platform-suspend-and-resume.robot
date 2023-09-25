*** Settings ***
Library             Collections
Library             DateTime
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds
Library             SSHLibrary    timeout=20 seconds
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/suspend/windows/pwrtest.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
SUSP001.001 Cyclic platform suspend and resume (Windows 11)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    ${suspend_detected_fails}=    Set Variable    ${0}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Power On
        Boot System Or From Connected Disk    Windows Boot Manager
    END
    Login To Windows Via SSH    ${DEVICE_WINDOWS_USERNAME}    ${DEVICE_WINDOWS_PASSWORD}
    Detect Pwrtest
    FOR    ${cnt}    IN RANGE    ${SUSPEND_ITERATIONS_NUMBER}
        ${is_suspend_performed_correctly}=    Perform Suspend Test Using Pwrtest
        IF    not ${is_suspend_performed_correctly}
            ${suspend_detected_fails}=    Evaluate    ${suspend_detected_fails} + 1
        END
    END
    ${suspend_allowed_fails}=    Evaluate    1
    Log To Console
    ...    \n${SUSPEND_ITERATIONS_NUMBER} iterations were performed to check the suspend procedure. \n${suspend_detected_fails} iterations have failed.
    IF    ${suspend_detected_fails} > ${suspend_allowed_fails}
        FAIL
        ...    \nTest case SUSP001.001 has been marked as failed. \nThe number of detected errors is greater than the number of allowed fails: ${suspend_allowed_fails}.
    ELSE
        Pass Execution
        ...    \nTest case SUSP001.001 has been marked passed. \nThe number of detected errors is at least the same as the number of allowed fails: ${suspend_allowed_fails}.
    END

SUSP005.001 Cyclic platform suspend and resume (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SUSP005.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUSP005.001 not supported
    ${suspend_detected_fails}=    Set Variable    ${0}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install FWTS
    FOR    ${index}    IN RANGE    0    ${SUSPEND_ITERATIONS_NUMBER}
        ${is_suspend_performed_correctly}=    Perform Suspend Test Using FWTS
        IF    not ${is_suspend_performed_correctly}
            ${suspend_detected_fails}=    Evaluate    ${suspend_detected_fails} + 1
        END
    END
    Log To Console
    ...    \n${SUSPEND_ITERATIONS_NUMBER} iterations were performed to check the suspend procedure. \n${suspend_detected_fails} iterations have failed.
    IF    ${suspend_detected_fails} > ${SUSPEND_ALLOWED_FAILS}
        FAIL
        ...    \nTest case SUSP001.001 has been marked as failed. \nThe number of detected errors is greater than the number of allowed fails: ${SUSPEND_ALLOWED_FAILS}.
    ELSE
        Pass Execution
        ...    \nTest case SUSP001.001 has been marked passed. \nThe number of detected errors is at least the same as the number of allowed fails: ${SUSPEND_ALLOWED_FAILS}.
    END
