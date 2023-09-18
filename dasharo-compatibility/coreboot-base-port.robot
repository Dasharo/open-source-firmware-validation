*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
CBP001.001 Boot into coreboot stage bootblock
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage bootblock.
    Skip If    not ${base_port_bootblock_support}    CBP001.001 not supported
    Skip If    not ${tests_in_firmware_support}    CBP001.001 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    bootblock starting

CBP002.001 Boot into coreboot stage romstage
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage romstage.
    Skip If    not ${base_port_romstage_support}    CBP002.001 not supported
    Skip If    not ${tests_in_firmware_support}    CBP002.001 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    romstage starting

CBP003.001 Boot into coreboot stage postcar
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage postcar.
    Skip If    not ${base_port_postcar_support}    CBP003.001 not supported
    Skip If    not ${tests_in_firmware_support}    CBP003.001 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    postcar starting

CBP004.001 Boot into coreboot stage ramstage
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage ramstage.
    Skip If    not ${base_port_ramstage_support}    CBP004.001 not supported
    Skip If    not ${tests_in_firmware_support}    CBP004.001 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    ramstage starting

CBP005.001 Resource allocator v4 - gathering requirements
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    gathering requirements stage for Resource Allocator v4.
    Skip If    not ${base_port_allocator_v4_support}    CBP005.001 not supported
    Skip If    not ${tests_in_firmware_support}    CBP005.001 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    Pass 1 (gathering requirements)

CBP006.001 Resource allocator v4 - allocating resources
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    gathering allocating resources stage for Resource
    ...    Allocator v4.
    Skip If    not ${base_port_allocator_v4_support}    CBP006.001 not supported
    Skip If    not ${tests_in_firmware_support}    CBP006.001 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    Pass 2 (allocating resources)
