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
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${TPM_SUPPORT}    TPM tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
TPM001.001 TPM Support (firmware)
    [Documentation]    This test aims to verify that the TPM is initialized,
    ...    detected and logged correctly by FW via cbmem, directly in Ubuntu
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM001.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${result}=    Run Keyword And Ignore Error    Validate Expected TPM Via Cbmem Chip
    IF    '${result}[0]' == 'FAIL'
        Log To Console    \nChip detection failed, attempting cbmem log detection\n
        Validate Expected TPM Via Cbmem Log
    END

TPM001.002 TPM Support (Ubuntu)
    [Documentation]    Check whether the TPM is initialized correctly and the
    ...    PCRs can be accessed from the Linux OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM001.002 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Any PCRs Via Sysfs

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
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${result}=    Run Keyword And Ignore Error    Validate Expected TPM Via Cbmem Chip
    IF    '${result}[0]' == 'FAIL'
        Log To Console    \nChip detection failed, attempting cbmem log detection\n
        Validate Expected TPM Via Cbmem Log
    END

TPM002.002 Verify TPM version (Ubuntu)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the operating system.
    [Tags]    minimal-regression
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM002.002 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Validate Expected TPM Via Sysfs

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
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Cbmem From Cloud
    ${out}=    Execute Command In Terminal    cbmem -1 | grep PPI
    Should Contain    ${out}    PPI: Pending OS request
    Should Contain    ${out}    PPI: OS response

TPM003.002 Check TPM Physical Presence Interface (Ubuntu)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the operating system.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM003.002 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    cat /sys/class/tpm/tpm0/ppi/version
    IF    '${TPM_EXPECTED_VERSION}' == '1'
        Should Contain    ${out}    1.2
    ELSE IF    '${TPM_EXPECTED_VERSION}' == '2'
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

# TPM003.004 Change active PCR banks with TPM PPI (firmware)
#    [Documentation]    This test aims to verify that the TPM Physical Presence
#    ...    Interface is working properly in the firmware by changing active TPM PCR banks.
#    Skip If    not ${tpm_support}    TPM003.004 not supported
#    Skip If    not ${tests_in_ubuntu_support}    TPM003.004 not supported
# TODO: https://docs.dasharo.com/unified-test-documentation/dasharo-security/200-tpm-support/#tpm003004-change-active-pcr-banks-with-tpm-ppi-firmware


*** Keywords ***
Get Any PCRs Via Sysfs
    [Documentation]    Check sysfs interface for presence of PCRs
    ${pcr_state}=    Execute Command In Terminal    ls /sys/class/tpm/tpm0/pcr-sha* &>/dev/null && echo "Found PCRs"
    Should Contain    ${pcr_state}    Found PCRs

Validate Expected TPM Via Sysfs
    [Documentation]    Checks if detected major TPM version matches the expected
    ...    value.
    ${tpm_ver}=    Execute Command In Terminal    cat /sys/class/tpm/tpm0/tpm_version_major
    IF    '${TPM_EXPECTED_VERSION}' != '${tpm_ver}'
        Fail    Platform TPM version mismatch
    END

Validate Expected TPM Via Cbmem Chip
    [Documentation]    Check that correct TPM chip is found while FW boots
    Get Cbmem From Cloud
    ${tpm_chip_found}=    Execute Command In Terminal    cbmem -1 | grep -i "Found TPM"
    Should Contain    ${tpm_chip_found}    ${TPM_EXPECTED_CHIP}

Validate Expected TPM Via Cbmem Log
    [Documentation]    Check if appropriate log is created by FW
    Get Cbmem From Cloud
    ${out}=    Execute Command In Terminal    cbmem -L
    IF    '${TPM_EXPECTED_VERSION}' == '1'
        Should Contain    ${out}    TCPA log
    ELSE IF    '${TPM_EXPECTED_VERSION}' == '2'
        Should Contain    ${out}    TPM2 log
    ELSE
        Fail    Invalid expected version, please verify config
    END
