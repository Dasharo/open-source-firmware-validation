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
Resource            ../keys-and-keywords/heads-keywords.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${TPM_DETECT_SUPPORT}    TPM detection tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
TPD001.004 Detect TPM after coldboot (heads)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly after the platform's coldboot. Currently test is compatible
    ...    only with the platforms with Heads bootloader.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPD001.004 not supported
    Skip If    not ${TESTS_IN_HEADS_SUPPORT}    TPD001.004 not supported
    Skip If    '${POWER_CTRL}' == 'none'    Coldboot automatic tests not supported
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

TPM001.002 TPM Support (Ubuntu)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly and the PCRs can be accessed from the operating system.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM001.002 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    tpm2-tools
    ${out}=    Execute Linux Command    tpm2_pcrread
    Should Contain    ${out}    sha1:
    Should Contain    ${out}    sha256:
    Exit From Root User

TPM001.003 TPM Support (Windows)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly and the PCRs can be accessed from the operating system.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM001.003 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    get-tpm
    Should Contain    ${out}    TpmPresent${SPACE*16}: True    strip_spaces=True
    Should Contain    ${out}    TpmReady${SPACE*18}: True    strip_spaces=True
    Should Contain    ${out}    TpmEnabled${SPACE*16}: True    strip_spaces=True
