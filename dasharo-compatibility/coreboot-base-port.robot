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
CBP001.001 Boot into coreboot stage bootblock
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage bootblock.
    Skip If    not ${BASE_PORT_BOOTBLOCK_SUPPORT}    CBP001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP001.001 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    bootblock starting

CBP002.001 Boot into coreboot stage romstage
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage romstage.
    Skip If    not ${BASE_PORT_ROMSTAGE_SUPPORT}    CBP002.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP002.001 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    romstage starting

CBP003.001 Boot into coreboot stage postcar
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage postcar.
    Skip If    not ${BASE_PORT_POSTCAR_SUPPORT}    CBP003.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP003.001 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    postcar starting

CBP004.001 Boot into coreboot stage ramstage
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage ramstage.
    Skip If    not ${BASE_PORT_RAMSTAGE_SUPPORT}    CBP004.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP004.001 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    ramstage starting

CBP005.001 Resource allocator v4 - gathering requirements
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    gathering requirements stage for Resource Allocator v4.
    Skip If    not ${BASE_PORT_ALLOCATOR_V4_SUPPORT}    CBP005.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP005.001 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    Pass 1 (gathering requirements)

CBP006.001 Resource allocator v4 - allocating resources
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    gathering allocating resources stage for Resource
    ...    Allocator v4.
    Skip If    not ${BASE_PORT_ALLOCATOR_V4_SUPPORT}    CBP006.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP006.001 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    Pass 2 (allocating resources)
