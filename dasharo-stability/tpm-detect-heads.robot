*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../keys-and-keywords/heads-keywords.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
TPD001.004 Detect TPM after coldboot (heads)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly after the platform's coldboot. Currently test is compatible
    ...    only with the platforms with Heads bootloader.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPD001.004 not supported
    Skip If    not ${TESTS_IN_HEADS_SUPPORT}    TPD001.004 not supported
    Skip If    not ${TPM_DETECT_SUPPORT}    TPD001.004 not supported
    Set Global Variable    ${FAILED_DETECTS}    0
    @{pcrs_subsequent_boots}=    Create List
    Power On
    FOR    ${index}    IN RANGE    0    3
        TRY
            Detect Heads Main Menu
            Enter Heads Recovery Shell
            ${tpm_pcrs}=    Get TPM PCRs
            Check TPM PCRs Correctness    ${tpm_pcrs}
            Append To List    ${pcrs_subsequent_boots}    ${tpm_pcrs}
        EXCEPT
            ${failed_detects}=    Evaluate    ${FAILED_DETECTS} + 1
        END
        Power Cycle On
    END
    IF    '${failed_detects}' > '0'
        FAIL    \nTest case marked as Failed; ${failed_detects} iterations failed.
    END
    Check TPM PCRs Correctness Between Subsequent Boots    ${pcrs_subsequent_boots}

TPD002.004 Detect TPM after warmboot (heads)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly after the platform's warmboot. Currently test is compatible
    ...    only with the platforms with Heads bootloader.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPD002.004 not supported
    Skip If    not ${TESTS_IN_HEADS_SUPPORT}    TPD002.004 not supported
    Skip If    not ${TPM_DETECT_SUPPORT}    TPD002.004 not supported
    Set Global Variable    ${FAILED_DETECTS}    0
    @{pcrs_subsequent_boots}=    Create List
    Power On
    FOR    ${index}    IN RANGE    0    3
        TRY
            Detect Heads Main Menu
            Enter Heads Recovery Shell
            ${tpm_pcrs}=    Get TPM PCRs
            Check TPM PCRs Correctness    ${tpm_pcrs}
            Append To List    ${pcrs_subsequent_boots}    ${tpm_pcrs}
        EXCEPT
            ${failed_detects}=    Evaluate    ${FAILED_DETECTS} + 1
        END
        Power On
    END
    IF    '${failed_detects}' > '0'
        FAIL    \nTest case marked as Failed; ${failed_detects} iterations failed.
    END
    Check TPM PCRs Correctness Between Subsequent Boots    ${pcrs_subsequent_boots}

TPD003.004 Detect TPM after platform reboot (heads)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly after the platform's reboot. Currently test is compatible
    ...    only with the platforms with Heads bootloader.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPD003.004 not supported
    Skip If    not ${TESTS_IN_HEADS_SUPPORT}    TPD003.004 not supported
    Skip If    not ${TPM_DETECT_SUPPORT}    TPD003.004 not supported
    Set Global Variable    ${FAILED_DETECTS}    0
    @{pcrs_subsequent_boots}=    Create List
    Power On
    FOR    ${index}    IN RANGE    0    3
        TRY
            Detect Heads Main Menu
            Enter Heads Recovery Shell
            ${tpm_pcrs}=    Get TPM PCRs
            Check TPM PCRs Correctness    ${tpm_pcrs}
            Append To List    ${pcrs_subsequent_boots}    ${tpm_pcrs}
        EXCEPT
            ${failed_detects}=    Evaluate    ${FAILED_DETECTS} + 1
        END
        Reboot Platform From Shell
    END
    IF    '${failed_detects}' > '0'
        FAIL    \nTest case marked as Failed; ${failed_detects} iterations failed.
    END
    Check TPM PCRs Correctness Between Subsequent Boots    ${pcrs_subsequent_boots}
