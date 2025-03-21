*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../lib/tpm.robot
Resource            ../keys.robot
# Resource            tpm2-commands.robot    # For the 'Check Which TPM2 Banks Are Enabled' KWD

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    ${TPM_SUPPORTED_VERSION} == None    TPM tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
TPM001.001 TPM Support (firmware)
    [Documentation]    This test aims to verify that the TPM is initialized,
    ...    detected and logged correctly by FW via cbmem, directly in Ubuntu
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM001.001 not supported
    Prepare TPM Test On Ubuntu
    ${result}=    Run Keyword And Ignore Error    Validate Expected TPM Chip Via Cbmem Console Log
    IF    '${result}[0]' == 'FAIL'
        Log To Console    \nChip detection failed, attempting cbmem log detection\n
        Validate Expected TPM Version Via Cbmem TPM Eventlog
    END

TPM001.002 TPM Support (Ubuntu)
    [Documentation]    Check whether the TPM is initialized correctly and the
    ...    PCRs can be accessed from the Linux OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM001.002 not supported
    Prepare TPM Test On Ubuntu
    Verify Presence Of Any PCRs Via Sysfs

TPM001.003 TPM Support (Windows)
    [Documentation]    Check whether the TPM is initialized correctly and the
    ...    PCRs can be accessed from Windows.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM001.003 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    get-tpm
    ${tpm_present}=    Get Lines Matching Regexp    ${out}    ^TpmPresent\\s+:\\s.*$
    ${tpm_ready}=    Get Lines Matching Regexp    ${out}    ^TpmReady\\s+:\\s.*$
    ${tpm_enabled}=    Get Lines Matching Regexp    ${out}    ^TpmEnabled\\s+:\\s.*$
    Should Contain    ${tpm_present}    True
    Should Contain    ${tpm_ready}    True
    Should Contain    ${tpm_enabled}    True

TPM002.001 Verify TPM version (firmware)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the firmware.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM002.001 not supported
    Prepare TPM Test On Ubuntu
    ${result}=    Run Keyword And Ignore Error    Validate Expected TPM Chip Via Cbmem Console Log
    IF    '${result}[0]' == 'FAIL'
        Log To Console    \nChip detection failed, attempting cbmem log detection\n
        Validate Expected TPM Version Via Cbmem TPM Eventlog
    END

TPM002.002 Verify TPM version (Ubuntu)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the operating system.
    [Tags]    minimal-regression
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM002.002 not supported
    Prepare TPM Test On Ubuntu
    Validate Expected TPM Version Via Sysfs

TPM002.003 Verify TPM version (Windows)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the operating system.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM002.003 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal
    ...    wmic /namespace:\\\\root\\cimv2\\security\\microsofttpm path win32_tpm get * /format:textvaluelist.xsl
    Should Contain    ${out}    SpecVersion=2.0

TPM003.001 Check TPM Physical Presence Interface (firmware)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is supported by the firmware and the log can be detected
    ...    with cbmem within Ubuntu
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM003.001 not supported
    Prepare TPM Test On Ubuntu
    Get Cbmem From Cloud
    ${out}=    Execute Command In Terminal    cbmem -1 | grep PPI
    Should Contain    ${out}    PPI: Pending OS request
    Should Contain    ${out}    PPI: OS response

TPM003.002 Check TPM Physical Presence Interface (Ubuntu)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the operating system.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM003.002 not supported
    Prepare TPM Test On Ubuntu
    ${out}=    Execute Command In Terminal    cat /sys/class/tpm/tpm0/ppi/version
    IF    '${TPM_SUPPORTED_VERSION}' == '1'
        Should Contain    ${out}    1.2
    ELSE IF    '${TPM_SUPPORTED_VERSION}' == '2'
        Should Contain    ${out}    1.3
    ELSE
        Fail    Invalid expected version, please verify config
    END

TPM003.003 Check TPM Physical Presence Interface (Windows)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the operating system.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM003.003 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    tpmtool getdeviceinformation
    Should Contain    ${out}    PPI Version: 1.3

TPM003.004 Change active PCR banks with TPM PPI (firmware)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is working properly in the firmware by changing active TPM PCR banks.
    Skip If    not ${TPM_SUPPORTED_VERSION} == 2    TPM003.004 not supported    #maby this should be NONE
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM003.004 not supported
    Prepare TPM Test On Ubuntu
    ${sha1}    ${sha256}=    Check Which TPM2 Banks Are Enabled
    Execute Reboot Command
    Enter The TCG2 Configuration Menu
    ${SHA1_position}=    Search For Option Not Visible After Entering Menu    PCR Bank: SHA1
    ${SHA256_position}=    Search For Option Not Visible After Entering Menu    PCR Bank: SHA256
    Reenter Menu
    # Making sure both PCR Banks are high
    IF    ${sha1} == ${False} or ${sha256} == ${False}
        IF    ${sha1} == False
            Press Key N Times And Enter    ${SHA1_position}    ${ARROW_DOWN}
        ELSE    # ${sha1} == False
            Press Key N Times And Enter    ${SHA256_position}    ${ARROW_DOWN}
        END
    Check TPM2 Banks State After FW Changes    ${True}    ${True}
    END
    #Order of checks below cannot be changed without changing desired TPM2 Banks states
    # sha1 = True, sha256 = False
    Press Key N Times And Enter    ${SHA256position}    ${ARROW_DOWN}
    Check TPM2 Banks State After FW Changes    ${True}    ${False}
    # sha1 = False, sha256 = True
    Press Key N Times And Enter    ${SHA1position}    ${ARROW_DOWN}
    Reenter Menu
    Press Key N Times And Enter    ${SHA256position}    ${ARROW_DOWN}
    Check TPM2 Banks State After FW Changes    ${False}    ${True}
    # Get to the starting state: sha1 = True, sha256 = True
    Press Key N Times And Enter    ${SHA1position}    ${ARROW_DOWN}
    Check TPM2 Banks State After FW Changes    ${True}    ${True}

*** Keywords ***
Check TPM2 Banks State After FW Changes
    [Documentation]    Verifies the state of TPM Banks. Fails test if they are differerent then input.
    [Arguments]    ${sha1_desired}    ${sha256_desired}
    Save Changes And Reset
    Read From Terminal Until    F12
    Press Key N Times    1    ${F12}    # confirm changes
    Prepare TPM Test On Ubuntu
    ${sha1}    ${sha256}=    Check Which TPM2 Banks Are Enabled
    Should Be Equal    ${sha1}    ${sha1_desired}
    Should Be Equal    ${sha256}    ${sha256_desired}
    Execute Reboot Command
    Enter The TCG2 Configuration Menu

Enter The TCG2 Configuration Menu
    [Documentation]    Enters the TCG2 Configuration menu after reboot
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_manager_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Enter Submenu From Snapshot
    ...    ${device_manager_menu}
    ...    TCG2 Configuration

Check Which TPM2 Banks Are Enabled
    [Documentation]    Checks which Bank is enabled, returns tuple (bool, bool)
    ${out}=    Execute Linux Command    tpm2_getcap pcrs
    ${sha1}=    Run Keyword And Return Status
    ...    Should Contain
    ...    ${out}
    ...    sha1: [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 ]
    ${sha256}=    Run Keyword And Return Status
    ...    Should Contain
    ...    ${out}
    ...    sha256: [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 ]
    RETURN    ${sha1}    ${sha256}
Create A Phony Menu
    [Arguments]    ${list_length}    ${option}
    ${list}    Create List
    FOR    ${i}    IN RANGE    1    ${list_length}
        Append To List    ${list}    0    # '0' is totally random
    END
    Append To List    ${list}    ${option}
    Log To Console    ${list}
    RETURN    ${list}

Prepare TPM Test On Ubuntu
    [Documentation]    Run common actions required for TPM tests in Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Verify Presence Of TPM Via Sysfs
