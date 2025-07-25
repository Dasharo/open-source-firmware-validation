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

Default Tags        automated


*** Test Cases ***
SUSP005.201 Cyclic platform suspend and resume (Ubuntu)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    ...    Previous IDs: SUSP005.001
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SUSP005.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUSP005.201 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP005.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SUSP005.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume
    Exit From Root User

SUSP006.201 Cyclic platform suspend and resume (Ubuntu) (S0ix)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    ...    Previous IDs: SUSP005.002
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SUSP006.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUSP006.201 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP006.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SUSP006.201 not supported
    Set Platform Sleep Type    S0ix
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume    S0ix
    Exit From Root User

SUSP007.201 Cyclic platform suspend and resume (Ubuntu) (S3)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    ...    Previous IDs: SUSP005.003
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SUSP007.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUSP007.201 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP007.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SUSP007.201 not supported
    Set Platform Sleep Type    S3
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume    S3
    Exit From Root User

SUSP005.202 Cyclic platform suspend and resume (Fedora)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SUSP005.202 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP005.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SUSP005.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume
    Exit From Root User

SUSP006.202 Cyclic platform suspend and resume (Fedora) (S0ix)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SUSP006.202 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP006.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SUSP006.202 not supported
    Set Platform Sleep Type    S0ix
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume    S0ix
    Exit From Root User

SUSP007.202 Cyclic platform suspend and resume (Fedora) (S3)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SUSP007.202 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP007.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SUSP007.202 not supported
    Set Platform Sleep Type    S3
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume    S3
    Exit From Root User


*** Keywords ***
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
