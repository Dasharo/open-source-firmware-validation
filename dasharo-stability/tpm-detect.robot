# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

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
TPD003.001 Detect TPM after platform reboot (Ubuntu)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly after the platform's reboot.
    Skip If    not ${TPM_DETECT_SUPPORT}    TPD003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPD003.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}
    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Execute Reboot Command
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        Detect Or Install Package    tpm2-tools
        ${out}=    Execute Command In Terminal    tpm2_pcrread
        Should Contain    ${out}    sha1:
        Should Contain    ${out}    sha256:
    END
    Exit From Root User

TPD004.001 Detect TPM after platform suspend (Ubuntu)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly after the platform's reboot.    Skip If    not ${tests_in_firmware_support}    TPD001.001 not supported
    Skip If    not ${TPM_DETECT_SUPPORT}    TPD001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPD004.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}
    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Perform Suspend Test Using FWTS
        Detect Or Install Package    tpm2-tools
        ${out}=    Execute Command In Terminal    tpm2_pcrread
        Should Contain    ${out}    sha1:
        Should Contain    ${out}    sha256:
    END
    Exit From Root User
