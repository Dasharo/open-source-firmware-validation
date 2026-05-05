*** Comments ***
# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Keywords for preparing the device for testing

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


*** Keywords ***
Prepare Platform
    [Documentation]    Keyword allows to flashing the device with the required
    ...    firmware version. Number of files used in the flashing procedure and
    ...    method of the flashing depends on the platform specify:
    ...    -> for the platforms that have external flashing enabled,
    ...    flashrom utility installed on the RTE is used.
    ...    -> for the platforms that have BMC, pflash utility built in OBMC is
    ...    used.
    ...    -> for the platforms that don't both don't have external flashing
    ...    enabled and OBMC, internal flashing mechanism is used.
    IF    '${CONFIG}'=='raptor-cs_talos2'
        Variable Should Exist    ${FW_FILE}
        Variable Should Exist    ${BOOTBLOCK_FILE}
        Variable Should Exist    ${Z_IMAGE_FILE}
        Prepare Test Suite
        Check FW File SHA256
        Flash Heads From OpenBMC    ${BOOTBLOCK_FILE}    ${FW_FILE}    ${Z_IMAGE_FILE}
        ${fw_ver_file}=    Get Firmware Version From Coreboot File    ${FW_FILE}
        Power On
        ${fw_ver_bootblock}    ${fw_ver_romstage}=    Get Firmware Version From Bootlogs
        Log Out And Close Connection
        Should Be Equal    ${fw_ver_file}    ${fw_ver_bootblock}
        Should Be Equal    ${fw_ver_bootblock}    ${fw_ver_romstage}
    ELSE
        Variable Should Exist    ${FW_FILE}
        Prepare Test Suite
        Check FW File SHA256
        Flash Firmware    ${FW_FILE}
        Power On
        ${version}=    Get Firmware Version
        ${coreboot_version}=    Get Firmware Version From Binary    ${FW_FILE}
        Log Out And Close Connection
        Should Contain    ${coreboot_version}    ${version}
    END

Check FW File SHA256
    [Documentation]    Computes sha256sum of FW_FILE and stores it as suite metadata.
    ...    If EXPECTED_FW_SHA256 is set in platform config, logs a warning when
    ...    the hashes don't match (does not fail).
    ${fw_sha256}=    Run    sha256sum ${FW_FILE} | awk '{print $1}'
    Set Suite Metadata    FW_FILE sha256sum    ${fw_sha256}
    IF    '${EXPECTED_FW_SHA256}' != '${EMPTY}' and '${fw_sha256}' != '${EXPECTED_FW_SHA256}'
        Log    Non-release firmware detected: sha256 mismatch (got ${fw_sha256}, expected ${EXPECTED_FW_SHA256})
        ...    console=True
    END
