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

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
# For now, the test has to be done manually, because of the issue with rtcwake:
# https://github.com/Dasharo/dasharo-issues/issues/485

# Manual test steps:
#    1. Power on the DUT
#    2. Login to Linux
#    3. Open terminal window and execute following command: "systemctl hibernate"
#    4. When the machine finishes hibernation process, wake it up by pressing the
#    power button

# Expected result:
#    1. The DUT should power back on
#    2. All previously opened windows should remain open

HIB001.201 Cyclic platform hibernation and resume (Ubuntu)
    [Documentation]    This test aims to verify that the DUT platform hibernation
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${HIBERNATION_AND_RESUME_SUPPORT}    HIB001.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    HIB001.201 not supported
    VAR    ${hibernation_detected_fails}=    ${0}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    FOR    ${index}    IN RANGE    0    ${HIBERNATION_ITERATIONS_NUMBER}
        ${is_hibernation_performed_correctly}=    Perform Hibernation Test Using FWTS
        IF    not ${is_hibernation_performed_correctly}
            ${hibernation_detected_fails}=    Evaluate    ${hibernation_detected_fails} + 1
        END
    END
    Log To Console
    ...    \n${HIBERNATION_ITERATIONS_NUMBER} iterations were performed to check the hibernation procedure. \n${hibernation_detected_fails} iterations have failed.
    IF    ${hibernation_detected_fails} > ${HIBERNATION_ALLOWED_FAILS}
        FAIL
        ...    \nTest case HIB001.201 has been marked as failed. \nThe number of detected errors is greater than the number of allowed fails: ${HIBERNATION_ALLOWED_FAILS}.
    ELSE
        Pass Execution
        ...    \nTest case HIB001.201 has been marked passed. \nThe number of detected errors is at least the same as the number of allowed fails: ${HIBERNATION_ALLOWED_FAILS}.
    END

HBN001.201 Platform hibernation and resume (Ubuntu)
    [Documentation]    Check whether the platform hibernates and resumes correctly in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    HBN001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    HBN001.201 not supported
    Execute Manual Step    [1/4] Boot into Ubuntu
    Execute Manual Step    [2/4] Trigger hibernation (e.g. systemctl hibernate)
    Execute Manual Step    [3/4] Wait for the system to power off and then power it back on
    Execute Manual Step    [4/4] Confirm the system resumes from hibernation and all previous state is restored

HBN001.301 Platform hibernation and resume (Windows)
    [Documentation]    Check whether the platform hibernates and resumes correctly in Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    HBN001.301 not supported
    Execute Manual Step    [1/4] Boot into Windows
    Execute Manual Step    [2/4] Trigger hibernation via Start > Power > Hibernate
    Execute Manual Step    [3/4] Wait for the system to power off and then power it back on
    Execute Manual Step    [4/4] Confirm the system resumes from hibernation and all previous state is restored
