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

CBP007.201 No unexpected warnings or errors in coreboot boot log (Ubuntu)
    [Documentation]    Check whether the coreboot boot log does not contain
    ...    unexpected diagnostics that may point to base port misconfiguration.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBP007.201 not supported
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    ${diagnostics}=    Get Coreboot Boot Log Diagnostics
    Should Be Empty
    ...    ${diagnostics}
    ...    msg=Unexpected diagnostics found in coreboot boot log:\n${diagnostics}


*** Keywords ***
Get Coreboot Boot Log Diagnostics
    [Documentation]    Returns coreboot boot log lines that contain common
    ...    warning or error markers. The grep pattern is assembled in shell so
    ...    the echoed command itself does not trigger a false positive.
    ${diagnostics}=    Execute Command In Terminal
    ...    p='w''arn(ing)?|e''rror|f''ail(ed|ure)?|e''xception|p''anic|a''ssert|i''nvalid'; cbmem -1 | grep -Eini "$p" || true
    ${diagnostics}=    Remove String Using Regexp
    ...    ${diagnostics}
    ...    (?m)^.*cbmem -1.*grep -Eini.*\\n?
    ${diagnostics}=    Strip String    ${diagnostics}
    RETURN    ${diagnostics}
