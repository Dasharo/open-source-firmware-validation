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
Resource            ../lib/tpm2.robot
Resource            ../keys.robot

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

Default Tags        automated


*** Test Cases ***
TPM001.001 TPM Support (firmware)
    [Documentation]    This test aims to verify that the TPM is initialized,
    ...    detected and logged correctly by FW via cbmem, directly in Ubuntu
    Skip If    '${DEFAULT_BOOT_OS_ID}' not in ${TESTED_LINUX_DISTROS}    TPM001.001 not supported
    Prepare TPM Test On Linux
    ${result}=    Run Keyword And Ignore Error    Validate Expected TPM Chip Via Cbmem Console Log
    IF    '${result}[0]' == 'FAIL'
        Log To Console    \nChip detection failed, attempting cbmem log detection\n
        Validate Expected TPM Version Via Cbmem TPM Eventlog
    END

TPM002.001 Verify TPM version (firmware)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the firmware.
    Skip If    '${DEFAULT_BOOT_OS_ID}' not in ${TESTED_LINUX_DISTROS}    TPM002.001 not supported
    Prepare TPM Test On Linux
    ${result}=    Run Keyword And Ignore Error    Validate Expected TPM Chip Via Cbmem Console Log
    IF    '${result}[0]' == 'FAIL'
        Log To Console    \nChip detection failed, attempting cbmem log detection\n
        Validate Expected TPM Version Via Cbmem TPM Eventlog
    END

TPM003.001 Check TPM Physical Presence Interface (firmware)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is supported by the firmware and the log can be detected
    ...    with cbmem within Ubuntu
    Skip If    '${DEFAULT_BOOT_OS_ID}' not in ${TESTED_LINUX_DISTROS}    TPM003.001 not supported
    Prepare TPM Test On Linux
    ${out}=    Execute Command In Terminal    cbmem -1 | grep PPI
    Should Contain    ${out}    PPI: Pending OS request
    Should Contain    ${out}    PPI: OS response

TPM001.201 TPM Support (Ubuntu)
    [Documentation]    Check whether the TPM is initialized correctly and the
    ...    PCRs can be accessed from the Linux OS.
    ...    Previous IDs: TPM001.002
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Prepare TPM Test On Linux    ${ENV_ID_UBUNTU}
    Verify Presence Of Any PCRs Via Sysfs

TPM002.201 Verify TPM version (Ubuntu)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the operating system.
    ...    Previous IDs: TPM002.002
    [Tags]    automated    minimal-regression
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM002.101 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    TPM002.201 not supported
    Prepare TPM Test On Linux    ${ENV_ID_UBUNTU}
    Validate Expected TPM Version Via Sysfs

TPM003.201 Check TPM Physical Presence Interface (Ubuntu)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the operating system.
    ...    Previous IDs: TPM003.002
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    TPM003.201 not supported
    Prepare TPM Test On Linux    ${ENV_ID_UBUNTU}
    Check TPM Physical Presence Interface

TPM001.202 TPM Support (Fedora)
    [Documentation]    Check whether the TPM is initialized correctly and the
    ...    PCRs can be accessed from the Linux OS.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    TPM001.202 not supported
    Prepare TPM Test On Linux    ${ENV_ID_FEDORA}
    Verify Presence Of Any PCRs Via Sysfs

TPM002.202 Verify TPM version (Fedora)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the operating system.
    [Tags]    automated    minimal-regression
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    TPM002.202 not supported
    Prepare TPM Test On Linux    ${ENV_ID_FEDORA}
    Validate Expected TPM Version Via Sysfs

TPM003.202 Check TPM Physical Presence Interface (Fedora)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the operating system.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    TPM003.202 not supported
    Prepare TPM Test On Linux    ${ENV_ID_FEDORA}
    Check TPM Physical Presence Interface

TPM001.301 TPM Support (Windows)
    [Documentation]    Check whether the TPM is initialized correctly and the
    ...    PCRs can be accessed from Windows.
    ...    Previous IDs: TPM001.003
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM001.301 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    get-tpm
    ${tpm_present}=    Get Lines Matching Regexp    ${out}    ^TpmPresent\\s+:\\s.*$
    ${tpm_ready}=    Get Lines Matching Regexp    ${out}    ^TpmReady\\s+:\\s.*$
    ${tpm_enabled}=    Get Lines Matching Regexp    ${out}    ^TpmEnabled\\s+:\\s.*$
    Should Contain    ${tpm_present}    True
    Should Contain    ${tpm_ready}    True
    Should Contain    ${tpm_enabled}    True

TPM002.301 Verify TPM version (Windows)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the operating system.
    ...    Previous IDs: TPM002.003
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM002.301 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal
    ...    tpmtool getdeviceinformation
    Should Contain    ${out}    TPM Version: 2.0

TPM003.301 Check TPM Physical Presence Interface (Windows)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the operating system.
    ...    Previous IDs: TPM003.003
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM003.301 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    tpmtool getdeviceinformation
    Should Contain    ${out}    PPI Version: 1.3

TPM011.101 Change active PCR banks with TPM PPI (EDK2 UEFI)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is working properly in the firmware by changing active TPM PCR banks.
    ...    Previous IDs: TPM003.004
    Skip If    not ${TPM_SUPPORTED_VERSION} == 2    TPM003.101 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM003.101 not supported
    Power On
    Enter The TCG Configuration Menu
    ${sha1_position}=    Search For Option Not Visible After Entering Menu    PCR Bank: SHA1
    ${sha256_position}=    Search For Option Not Visible After Entering Menu    PCR Bank: SHA256
    Reenter Menu
    # Set all PCR Banks to True
    ${target_option_index}=    Search For Option Not Visible After Entering Menu    TPM2 Operation
    Reenter Menu
    Press Key N Times And Enter    ${target_option_index}    ${ARROW_DOWN}
    VAR    ${checkpoint}=    \---------------------------------------------------------------------/
    ${tpm2_operation_menu}=    Get Menu Construction    ${checkpoint}    0    0
    Enter Submenu From Snapshot    ${tpm2_operation_menu}    TCG2 LogAllDigests
    Save Changes And Reset
    Enter The TCG Configuration Menu
    # Order of checks below cannot be changed without changing desired TPM2 Banks states
    # sha1 = True, sha256 = False
    Press Key N Times And Enter    ${sha256_position}    ${ARROW_DOWN}
    Check TPM2 Banks State After FW Changes    ${TRUE}    ${FALSE}
    Execute Reboot Command
    Enter The TCG Configuration Menu
    # sha1 = False, sha256 = True
    Press Key N Times And Enter    ${sha256_position}    ${ARROW_DOWN}
    Reenter Menu
    Press Key N Times And Enter    ${sha1_position}    ${ARROW_DOWN}
    Check TPM2 Banks State After FW Changes    ${FALSE}    ${TRUE}
    Execute Reboot Command
    Enter The TCG Configuration Menu
    # Get to the starting state: sha1 = True, sha256 = True
    Press Key N Times And Enter    ${sha1_position}    ${ARROW_DOWN}
    Check TPM2 Banks State After FW Changes    ${TRUE}    ${TRUE}

TPM012.201 Check if the ChangeEPS works (Ubuntu)
    [Documentation]    Check if the `TPM2 ChangeEPS` setup menu option works properly.
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Verify Presence Of TPM Via Sysfs
    Detect Or Install Package    tpm2-tools
    Flush TPM Contexts
    Execute Linux Tpm2 Tools Command    tpm2_createprimary -C e -c primary_key.ctx    60
    Execute Linux Tpm2 Tools Command    tpm2_create -u key.pub -r key.priv -C primary_key.ctx
    Flush TPM Contexts
    Execute Linux Tpm2 Tools Command    tpm2_load -C primary_key.ctx -u key.pub -r key.priv -c key.ctx
    Execute Linux Command    echo "my secret" > secret.data
    Execute Linux Tpm2 Tools Command    tpm2_sign -c key.ctx -o sig.rssa secret.data
    Flush TPM Contexts
    Execute Linux Tpm2 Tools Command    tpm2_verifysignature -c key.ctx -s sig.rssa -m secret.data
    Execute Linux Command    rm -f primary_key.ctx sig.rssa secret.data
    Execute Reboot Command
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_manager_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Enter Submenu From Snapshot
    ...    ${device_manager_menu}
    ...    TCG2 Configuration
    ${target_option_index}=    Search For Option Not Visible After Entering Menu    TPM2 Operation
    Reenter Menu
    Press Key N Times And Enter    ${target_option_index}    ${ARROW_DOWN}
    VAR    ${checkpoint}=    \---------------------------------------------------------------------/
    ${tpm2_operation_menu}=    Get Menu Construction    ${checkpoint}    0    0
    Enter Submenu From Snapshot    ${tpm2_operation_menu}    TPM2 ChangeEPS
    Save Changes And Reset
    Read From Terminal Until
    ...    Press F12 to clear and change identity of the TPM
    Press Key N Times    1    ${F12}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Execute Linux Tpm2 Tools Command    tpm2_createprimary -C e -c primary_key.ctx    60
    Flush TPM Contexts
    ${result}=    Run Keyword And Ignore Error    Execute Linux Tpm2 Tools Command
    ...    tpm2_load -C primary_key.ctx -u key.pub -r key.priv -c key.ctx
    Execute Linux Command    rm -f primary_key.ctx key.pub key.priv key.ctx
    IF    '${result}[0]' == 'FAIL'
        Should Contain    ${result}[1]    0x1DF
    ELSE
        FAIL    msg=tpm2_load should result in an error.\n
    END

TPM013.201 TPM PPI Prompt (Ubuntu)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface pop-up is displayed upon sending a PPI request to the TPM,
    ...    and that the requested operation is performed only if the user
    ...    accepts it.
    Skip If    not ${TPM_SUPPORTED_VERSION} == 2    TPM013.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM013.201 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPM013.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    TPM013.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    TPM2 Set Owner Key Password Linux
    ${set}=    TPM2 Check Owner Key Password Set
    Should Be True    ${set}
    TPM2 PPI Request Clear TPM Linux

    # Deny changes
    Execute Reboot Command
    ${prompt}=    Read From Terminal Until
    ...    Press ESC to reject this change request and continue
    Should Contain    ${prompt}    clear the TPM
    Press Key N Times    1    ${ESC}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${set}=    TPM2 Check Owner Key Password Set
    Should Be True    ${set}
    TPM2 PPI Request Clear TPM Linux

    # Accept changes
    Execute Reboot Command
    ${prompt}=    Read From Terminal Until
    ...    Press ESC to reject this change request and continue
    Should Contain    ${prompt}    clear the TPM
    Press Key N Times    1    ${F12}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${set}=    TPM2 Check Owner Key Password Set
    Should Not Be True    ${set}

TPM013.301 TPM PPI Prompt (Windows)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface pop-up is displayed upon sending a PPI request to the TPM,
    ...    and that the requested operation is performed only if the user
    ...    accepts it.
    Skip If    not ${TPM_SUPPORTED_VERSION} == 2    TPM013.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM013.201 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPM013.201 not supported
    Power On
    Login To Windows

    ${owner_key}=    TPM2 Get Owner Key Windows
    TPM2 PPI Request Clear TPM Windows

    # Deny changes
    Execute Reboot Command    os=windows
    ${prompt}=    Read From Terminal Until
    ...    Press ESC to reject this change request and continue
    Should Contain    ${prompt}    clear the TPM
    Press Key N Times    1    ${ESC}
    Login To Windows
    ${new_key}=    TPM2 Get Owner Key Windows
    Should Be Equal    ${new_key}    ${owner_key}
    TPM2 PPI Request Clear TPM Windows

    # Accept changes
    Execute Reboot Command    os=windows
    ${prompt}=    Read From Terminal Until
    ...    Press ESC to reject this change request and continue
    Should Contain    ${prompt}    clear the TPM
    Press Key N Times    1    ${F12}
    Login To Windows
    ${new_key}=    TPM2 Get Owner Key Windows
    Should Not Be Equal As Strings    ${new_key}    ${owner_key}

TPM014.101 TPM single bank detection
    [Documentation]    TBD
    #Power On
    Enter The TCG Configuration Menu
    ${last_sha}=    Search For Option Not Visible After Entering Menu    PCR Bank: SHA384
    IF    ${last_sha} == -1
        Reenter Menu
        ${last_sha}=    Search For Option Not Visible After Entering Menu    PCR Bank: SHA256
    END
    IF    ${last_sha} == -1
        Reenter Menu
        ${last_sha}=    Search For Option Not Visible After Entering Menu    PCR Bank: SHA1
    END
    Press Key N Times    ${last_sha}    ${ARROW_DOWN}
    VAR    ${checkpoint}=    F9=Reset to Defaults
    ${tpm2_operation_menu}=    Get Menu Construction    ${checkpoint}    0    0
    Log To Console    ${last_sha}
    Log To Console    ${tpm2_operation_menu}
    IF    ${TPM_SINGLE_BANK} == ${TRUE}
        Log To Console    TPM_SINGLE_BANK True

    ELSE
        Log To Console    TPM_SINGLE_BANK False
    END



TPM001.205 TPM Support (XCP-NG)
    [Documentation]    Check whether the TPM is initialized correctly and the
    ...    PCRs can be accessed from the XCP-NG OS.
    ...    Previous IDs: TPM001.010
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    TPM001.203 not supported
    Power On
    Login To OS    ${ENV_ID_XCP_NG}
    Verify Presence Of TPM Via Sysfs
    Verify Presence Of Any PCRs Via Sysfs

TPM002.205 Verify TPM version (XCP-NG)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the XCP-NG OS.
    ...    Previous IDs: TPM002.010
    [Tags]    automated    minimal-regression
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    TPM002.203 not supported
    Power On
    Login To OS    ${ENV_ID_XCP_NG}
    Verify Presence Of TPM Via Sysfs
    Validate Expected TPM Version Via Sysfs

TPM003.205 Check TPM Physical Presence Interface (XCP-NG)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the XCP-NG OS.
    ...    Previous IDs: TPM003.010
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    TPM003.203 not supported
    Power On
    Login To OS    ${ENV_ID_XCP_NG}
    Verify Presence Of TPM Via Sysfs
    Check TPM Physical Presence Interface


*** Keywords ***
Prepare TPM Test On Linux
    [Documentation]    Run common actions required for TPM tests in Linux
    [Arguments]    ${env_id}=${DEFAULT_BOOT_OS_ID}
    Power On
    Boot System Or From Connected Disk    ${env_id}
    Login To Linux
    Switch To Root User
    Verify Presence Of TPM Via Sysfs

Check TPM Physical Presence Interface
    ${out}=    Execute Command In Terminal    cat /sys/class/tpm/tpm0/ppi/version
    IF    '${TPM_SUPPORTED_VERSION}' == '1'
        Should Contain    ${out}    1.2
    ELSE IF    '${TPM_SUPPORTED_VERSION}' == '2'
        Should Contain    ${out}    1.3
    ELSE
        Fail    Invalid expected version, please verify config
    END

TPM2 Set Owner Key Password Linux
    [Documentation]    Set the owner key password for the TPM2
    [Arguments]    ${password}=tpm2pass
    Execute Command In Terminal    sudo tpm2_changeauth -c o ${password}

TPM2 Check Owner Key Password Set
    [Documentation]    Check if the owner key password is set for the TPM2
    ${out}=    Execute Command In Terminal    sudo tpm2_getcap properties-variable
    ${out}=    Get Lines Matching Regexp    ${out}    ownerAuthSet    partial_match=True
    ${status}=    Run Keyword And Return Status    Should Contain    ${out}    1
    RETURN    ${status}

TPM2 PPI Request Clear TPM Linux
    [Documentation]    Clear the TPM using the TPM PPI in Linux
    # 5 - PPI function ClearTPM, PPI Specification, Family “1.2” and “2.0”
    #    Version 1.30 Revision 00.52 table 2
    Execute Command In Terminal    echo 5 | sudo tee /sys/class/tpm/tpm0/ppi/request

TPM2 PPI Request Clear TPM Windows
    [Documentation]    Clear the TPM using the TPM PPI in Windows
    # 5 - PPI function ClearTPM, PPI Specification, Family “1.2” and “2.0”
    #    Version 1.30 Revision 00.52 table 2
    Execute Command In Terminal    Clear-Tpm -UsePPI    timeout=300s

TPM2 Get Owner Key Windows
    [Documentation]    Check if the owner key password is set for the TPM2
    ${out}=    Execute Command In Terminal    Get-Tpm    timeout=300s
    ${key}=    Get Lines Matching Regexp    ${out}    OwnerAuth    partial_match=True
    ${key}=    Get Regexp Matches    ${key}    OwnerAuth\ +:\ (.*)    1
    RETURN    ${key}
