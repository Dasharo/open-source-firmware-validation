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
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
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
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly and the PCRs can be accessed from the firmware.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM001.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Cbmem From Cloud
    ${out}=    Execute Command In Terminal    cbmem -L
    Should Contain    ${out}    TPM2 log

TPM001.002 TPM Support (Ubuntu 20.04)
    [Documentation]    Check whether the TPM is initialized correctly and the
    ...    PCRs can be accessed from the Linux OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM001.002 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    tpm2-tools
    ${out}=    Execute Command In Terminal    tpm2_pcrread
    Should Contain    ${out}    sha1:
    Should Contain    ${out}    sha256:

TPM001.003 TPM Support (Windows 11)
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

TPM001.004 TPM Support (BIOS)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly and the PCRs can be accessed from the firmware.
    Skip If    not ${TPM_SUPPORT}    TPM001.004 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPM001.004 not supported
    Power On
    ${menu}=    Enter TCG2 Menu And Return Construction
    ${current_device}=    Get From Dictionary    ${menu}    Current TPM Device
    Should Contain Any    ${current_device}    TPM 2.0    TPM 1.2

TPM002.001 Verify TPM version (firmware)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the firmware.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM002.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Cbmem From Cloud
    ${out}=    Execute Command In Terminal    cbmem -L
    Should Contain    ${out}    TPM2 log

TPM002.002 Verify TPM version (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the operating system.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM002.002 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    cat /sys/class/tpm/tpm0/tpm_version_major
    # TPM 2.0
    Should Contain    ${out}    2

TPM002.003 Verify TPM version (Windows 11)
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
    ...    Interface is supported by the firmware.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM003.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Cbmem From Cloud
    ${out}=    Execute Command In Terminal    cbmem -1 | grep PPI
    Should Contain    ${out}    PPI: Pending OS request
    Should Contain    ${out}    PPI: OS response

TPM003.002 Check TPM Physical Presence Interface (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the operating system.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM003.002 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    cat /sys/class/tpm/tpm0/ppi/version
    Should Contain    ${out}    1.3

TPM003.003 Check TPM Physical Presence Interface (Windows 11)
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
