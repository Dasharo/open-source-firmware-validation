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

CBP007.001 No ASSERTION ERROR in boot log
    [Documentation]    Check that the coreboot boot log does not contain any
    ...    ASSERTION ERROR messages, which indicate critical
    ...    misconfigurations such as missing PMC GPE routes.
    Skip If    not ${BASE_PORT_LOG_CHECK_SUPPORT}    CBP007.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBP007.001 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${output}=    Execute Command In Terminal    cbmem -1
    Should Not Contain    ${output}    ASSERTION ERROR

CBP008.001 No missing static PCI devices in boot log
    [Documentation]    Check that the coreboot boot log does not contain messages
    ...    about static PCI devices not being found, which indicate
    ...    wrong device states in the devicetree.cb configuration.
    Skip If    not ${BASE_PORT_LOG_CHECK_SUPPORT}    CBP008.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBP008.001 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${output}=    Execute Command In Terminal    cbmem -1
    Should Not Contain    ${output}    not found, disabling it.

CBP009.001 No resource allocation failures in boot log
    [Documentation]    Check that the coreboot boot log does not contain resource
    ...    allocation failure messages, which typically indicate PCI
    ...    resource conflicts or misconfigured hotplug ports.
    Skip If    not ${BASE_PORT_LOG_CHECK_SUPPORT}    CBP009.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBP009.001 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${output}=    Execute Command In Terminal    cbmem -1
    Should Not Contain    ${output}    Resource didn't fit!!!

CBP010.001 No BUG messages in boot log
    [Documentation]    Check that the coreboot boot log does not contain any BUG
    ...    messages, which indicate code-level problems such as
    ...    requests for hidden devices.
    Skip If    not ${BASE_PORT_LOG_CHECK_SUPPORT}    CBP010.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBP010.001 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${output}=    Execute Command In Terminal    cbmem -1
    Should Not Contain    ${output}    BUG:

CBP011.001 No devicetree.cb warnings in boot log
    [Documentation]    Check that the coreboot boot log does not contain messages
    ...    suggesting the devicetree.cb needs to be reviewed, which
    ...    indicate leftover or misconfigured static device entries.
    Skip If    not ${BASE_PORT_LOG_CHECK_SUPPORT}    CBP011.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBP011.001 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${output}=    Execute Command In Terminal    cbmem -1
    Should Not Contain    ${output}    Check your devicetree.cb
