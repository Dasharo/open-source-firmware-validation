*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    ESXi not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
SAT001.401 SATA support in OS (ESXi)
    [Documentation]    Verify that a SATA storage device is detected by the ESXi system
    ...    and optionally check SMART data if available.
    ...    Previous IDs: SAT001.011
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli storage core device list
    Should Contain Any    ${out}    Vendor: ATA    Vendor: SATA
    Should Contain    ${out}    Is Boot Device: true
