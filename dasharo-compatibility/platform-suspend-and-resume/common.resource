*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for platform suspend and resume tests

Library             Collections
Library             DateTime
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds
Library             SSHLibrary    timeout=20 seconds
Library             RequestsLibrary
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot


*** Variables ***
${PLATFORM_STATE_CONTROL}=      ${TRUE}


*** Keywords ***
SUSP Suite Setup
    [Documentation]    Common suite setup for suspend and resume tests
    Prepare Test Suite
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    Suspend and resume tests not supported
    Check If Platform Sleep Type Can Be Selected
    Set UEFI Option    MeMode    Enabled

Cyclic Platform Suspend And Resume
    [Arguments]    ${platform_sleep_type}=${EMPTY}
    VAR    ${suspend_detected_fails}=    ${0}
    Check Platform Sleep Type Is Correct On Linux    ${platform_sleep_type}
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
