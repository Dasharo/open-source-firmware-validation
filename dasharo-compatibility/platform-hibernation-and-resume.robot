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

HIB001.001 Cyclic platform hibernation and resume (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the DUT platform hibernation
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${hibernation_and_resume_support}    HIB001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    HIB001.001 not supported
    ${hibernation_detected_fails}=    Set Variable    ${0}
    Power On
    Boot operating system    ubuntu
    Login to Linux
    Switch to root user
    Detect or Install Package    util-linux
    Detect or install FWTS
    FOR    ${INDEX}    IN RANGE    0    ${hibernation_iterations_number}
        ${is_hibernation_performed_correctly}=    Perform hibernation test using FWTS
        IF    not ${is_hibernation_performed_correctly}
            ${hibernation_detected_fails}=    Evaluate    ${hibernation_detected_fails} + 1
        END
    END
    Log To Console
    ...    \n${hibernation_iterations_number} iterations were performed to check the hibernation procedure. \n${hibernation_detected_fails} iterations have failed.
    IF    ${hibernation_detected_fails} > ${hibernation_allowed_fails}
        FAIL
        ...    \nTest case HIB001.001 has been marked as failed. \nThe number of detected errors is greater than the number of allowed fails: ${hibernation_allowed_fails}.
    ELSE
        Pass Execution
        ...    \nTest case HIB001.001 has been marked passed. \nThe number of detected errors is at least the same as the number of allowed fails: ${hibernation_allowed_fails}.
    END
