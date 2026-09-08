*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Library             ../lib/coreboot_boot_log.py
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/cbmem.robot

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

CBP007.201 No ASSERTION ERROR in boot log (Ubuntu)
    [Documentation]    Check that the coreboot console log does not contain
    ...    ASSERTION ERROR, which indicates a failed ASSERT() such as
    ...    missing PMC GPE routes.
    ...
    ...    References: dasharo-issues#1409 dasharo-issues#1364
    ...    coreboot src/include/assert.h
    Skip If    not ${BASE_PORT_LOG_CHECK_SUPPORT}    CBP007.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBP007.201 not supported
    ${boot_log}=    Get Coreboot Console Log
    Coreboot Boot Log Should Not Contain    ${boot_log}    ASSERTION ERROR

CBP008.201 No missing static PCI devices in boot log (Ubuntu)
    [Documentation]    Check that the coreboot console log does not contain
    ...    static PCI devices that were not found and were disabled.
    ...    Those messages come from incorrect enabled entries in
    ...    devicetree.cb. Hidden PMC/P2SB devices can also emit this
    ...    line; enable the flag only on ports where that is not
    ...    accepted.
    ...
    ...    References: dasharo-issues#1409 dasharo-issues#1364
    ...    coreboot src/device/pci_device.c
    Skip If    not ${BASE_PORT_LOG_CHECK_SUPPORT}    CBP008.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBP008.201 not supported
    ${boot_log}=    Get Coreboot Console Log
    Coreboot Boot Log Should Not Contain    ${boot_log}    not found, disabling it.

CBP009.201 No resource allocation failures in boot log (Ubuntu)
    [Documentation]    Check that the coreboot console log does not contain
    ...    resource allocator failures (Resource didn't fit!!!).
    ...    Typical causes are PCI resource conflicts or hotplug
    ...    windows that do not fit below 4G.
    ...
    ...    References: dasharo-issues#1364
    ...    coreboot src/device/resource_allocator_v4.c
    Skip If    not ${BASE_PORT_LOG_CHECK_SUPPORT}    CBP009.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBP009.201 not supported
    ${boot_log}=    Get Coreboot Console Log
    Coreboot Boot Log Should Not Contain    ${boot_log}    Resource didn't fit!!!

CBP010.201 No BUG messages in boot log (Ubuntu)
    [Documentation]    Check that the coreboot console log does not contain
    ...    BUG: printks or the BUG() macro text ERROR: BUG ENCOUNTERED.
    ...
    ...    References: dasharo-issues#1364
    ...    coreboot src/include/assert.h
    Skip If    not ${BASE_PORT_LOG_CHECK_SUPPORT}    CBP010.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBP010.201 not supported
    ${boot_log}=    Get Coreboot Console Log
    Coreboot Boot Log Should Not Contain    ${boot_log}    BUG:    ERROR: BUG ENCOUNTERED

CBP011.201 No leftover static devices in boot log (Ubuntu)
    [Documentation]    Check that the coreboot console log does not ask to
    ...    Check your devicetree.cb (leftover static devices).
    ...
    ...    This is a BIOS_WARNING present on almost all boards and is
    ...    safe to ignore according to dasharo-issues#1409. It is
    ...    therefore gated by BASE_PORT_DEVICETREE_CHECK_SUPPORT
    ...    (default FALSE, not enabled on QEMU) rather than treated as
    ...    a hard failure of BASE_PORT_LOG_CHECK_SUPPORT.
    ...
    ...    References: dasharo-issues#1409 dasharo-issues#1364
    ...    coreboot src/device/pci_device.c
    Skip If    not ${BASE_PORT_DEVICETREE_CHECK_SUPPORT}    CBP011.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBP011.201 not supported
    ${boot_log}=    Get Coreboot Console Log
    Coreboot Boot Log Should Not Contain    ${boot_log}    Check your devicetree.cb
