*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             TelnetLibrary    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CBP001.101 Boot into coreboot stage bootblock (EDK2 UEFI)
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage bootblock.
    Skip If    not ${BASE_PORT_BOOTBLOCK_SUPPORT}    CBP001.101 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP001.101 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    bootblock starting

CBP002.101 Boot into coreboot stage romstage (EDK2 UEFI)
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage romstage.
    Skip If    not ${BASE_PORT_ROMSTAGE_SUPPORT}    CBP002.101 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP002.101 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    romstage starting

CBP003.101 Boot into coreboot stage postcar (EDK2 UEFI)
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage postcar.
    Skip If    not ${BASE_PORT_POSTCAR_SUPPORT}    CBP003.101 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP003.101 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    postcar starting

CBP004.101 Boot into coreboot stage ramstage (EDK2 UEFI)
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage ramstage.
    Skip If    not ${BASE_PORT_RAMSTAGE_SUPPORT}    CBP004.101 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP004.101 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    ramstage starting

CBP005.101 Resource allocator v4 - gathering requirements (EDK2 UEFI)
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    gathering requirements stage for Resource Allocator v4.
    Skip If    not ${BASE_PORT_ALLOCATOR_V4_SUPPORT}    CBP005.101 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP005.101 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    Pass 1 (gathering requirements)

CBP006.101 Resource allocator v4 - allocating resources (EDK2 UEFI)
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    gathering allocating resources stage for Resource
    ...    Allocator v4.
    Skip If    not ${BASE_PORT_ALLOCATOR_V4_SUPPORT}    CBP006.101 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP006.101 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    Pass 2 (allocating resources)

CBP001.107 Boot into coreboot stage bootblock (LinuxBoot)
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage bootblock. On a TF-A-based platform (e.g. Arm RD-V3) this is
    ...    the first coreboot (BL33) console output, and proves TF-A BL31
    ...    handed off to coreboot correctly.
    Skip If    not ${BASE_PORT_BOOTBLOCK_SUPPORT}    CBP001.107 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP001.107 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    bootblock starting

CBP002.107 Boot into coreboot stage romstage (LinuxBoot)
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage romstage. On a TF-A-based platform, DRAM is already up
    ...    before BL33 (coreboot) is entered, so romstage's own raminit is
    ...    expected to be a no-op where the stage exists at all; set
    ...    BASE_PORT_ROMSTAGE_SUPPORT to ${FALSE} in the platform config if
    ...    this port does not have a distinct romstage.
    Skip If    not ${BASE_PORT_ROMSTAGE_SUPPORT}    CBP002.107 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP002.107 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    romstage starting

CBP004.107 Boot into coreboot stage ramstage (LinuxBoot)
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    stage ramstage. This only proves ramstage was entered, not that it
    ...    completed device init and handed off to the LinuxBoot payload -
    ...    see LBB002.107 in rdv3-linuxboot-bringup.robot for that.
    Skip If    not ${BASE_PORT_RAMSTAGE_SUPPORT}    CBP004.107 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBP004.107 not supported
    Power On
    Set DUT Response Timeout    120s
    Read From Terminal Until    ramstage starting
