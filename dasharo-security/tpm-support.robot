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

# TPM003.004 Change active PCR banks with TPM PPI (firmware)
#    [Documentation]    This test aims to verify that the TPM Physical Presence
#    ...    Interface is working properly in the firmware by changing active TPM PCR banks.
#    Skip If    not ${TPM_SUPPORTED_VERSION} == None    TPM003.004 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM003.004 not supported
# TODO: https://docs.dasharo.com/unified-test-documentation/dasharo-security/200-tpm-support/#tpm003004-change-active-pcr-banks-with-tpm-ppi-firmware

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
    [Tags]    minimal-regression
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
    [Tags]    minimal-regression
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
    ...    wmic /namespace:\\\\root\\cimv2\\security\\microsofttpm path win32_tpm get * /format:textvaluelist.xsl
    Should Contain    ${out}    SpecVersion=2.0

TPM003.003 Check TPM Physical Presence Interface (Windows)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the operating system.
    ...    Previous IDs: TPM003.003
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM003.301 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    tpmtool getdeviceinformation
    Should Contain    ${out}    PPI Version: 1.3


*** Keywords ***
Prepare TPM Test On Linux
    [Documentation]    Run common actions required for TPM tests in Ubuntu
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
