*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for NVMe support tests

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot


*** Variables ***
${PLATFORM_STATE_CONTROL}=      ${TRUE}


*** Keywords ***
NVM Suite Setup
    [Documentation]    Common suite setup for NVMe support tests
    Prepare Test Suite
    Skip If    not ${NVME_DISK_SUPPORT}    NVMe disk tests not supported

Check NVMe Support Linux
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}

Check NVMe Slot Change Support Linux
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    ${out}=    Execute Command In Terminal    lspci -vvv
    @{lines}=    Split To Lines    ${out}
    VAR    ${found}=    False
    FOR    ${line}    IN    @{lines}
        ${match}=    Evaluate    __import__('re').search(r"Speed \\d+GT/s.*Width x2", """${line}""")
        IF    ${match}
            VAR    ${found}=    True
        END
    END
    Should Be True    ${found}
