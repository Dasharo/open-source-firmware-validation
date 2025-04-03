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

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
TPD003.201 Detect TPM after platform reboot (Ubuntu)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly after the platform's reboot.
    ...    Previous IDs: TPD003.001
    Skip If    not ${TPM_DETECT_SUPPORT}    TPD003.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPD003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    TPD003.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Detect TPM After Platform Reboot
    Exit From Root User

TPD004.201 Detect TPM after platform suspend (Ubuntu)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly after the platform's reboot.
    ...    Previous IDs: TPD004.001
    Skip If    not ${TPM_DETECT_SUPPORT}    TPD004.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPD004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    TPD004.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Detect TPM After Platform Suspend
    Exit From Root User

TPD003.202 Detect TPM after platform reboot (Fedora)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly after the platform's reboot.
    Skip If    not ${TPM_DETECT_SUPPORT}    TPD003.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    TPD003.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Detect TPM After Platform Reboot
    Exit From Root User

TPD004.202 Detect TPM after platform suspend (Fedora)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly after the platform's reboot.
    Skip If    not ${TPM_DETECT_SUPPORT}    TPD004.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    TPD004.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Detect TPM After Platform Suspend
    Exit From Root User


*** Keywords ***
Detect TPM After Platform Reboot
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly after the platform's reboot.
    [Tags]    robot:private
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}
    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Execute Reboot Command
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
        Login To Linux
        Switch To Root User
        ${out}=    Execute Command In Terminal    tpm2_pcrread
        Should Contain    ${out}    sha1:
        Should Contain    ${out}    sha256:
    END

Detect TPM After Platform Suspend
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly after the platform's reboot.    Skip If    not ${tests_in_firmware_support}    TPD001.001 not supported
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}

    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Perform Suspend Test Using FWTS
        ${out}=    Execute Command In Terminal    tpm2_pcrread
        Should Contain    ${out}    sha1:
        Should Contain    ${out}    sha256:
    END
