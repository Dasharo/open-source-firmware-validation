*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${CPU_TESTS_SUPPORT}    CPU tests not supported
...                     AND    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    ESXi not supported
...                     AND    Reset UEFI Options To Defaults
...                     AND    Init CPU ESXi
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CPU001.401 CPU works (ESXi)
    [Documentation]    Verify that the CPU on the DUT is functional and boots the ESXi OS.
    ...    The test passes if the ESXi login screen (DCUI) is visible after boot.
    ...    Previous IDs: CPU001.011
    Pass Execution    Booted into OS

CPU002.401 CPU cache enabled (ESXi)
    [Documentation]    Verify that all CPU cache levels are detected and reported by ESXi.
    ...    Expected output includes L2 and L3 cache size, associativity, and CPU count.
    ...    Previous IDs: CPU002.011
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli hardware cpu list | grep Cache
    ${count}=    Evaluate
    ...    len(re.findall(r'''${CACHE_REGEX}''', '''${out}'''))
    ...    re
    IF    ${count} < 2    FAIL    There are no multiple cache levels detected.

CPU003.401 Multiple CPU support (ESXi)
    [Documentation]    Verify that ESXi detects more than one CPU core, indicating multi-CPU support.
    ...    Previous IDs: CPU003.011
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli hardware cpu global get
    ${cores_match}=    Get Regexp Matches    ${out}    CPU Cores:\\s*(\\d+)    1
    ${core_str}=    Get From List    ${cores_match}    0
    ${cores}=    Convert To Integer    ${core_str}
    IF    ${cores} < 2    Fail    Quantitty of cores less than 2.

CPU004.401 Multiple-core support (ESXi)
    [Documentation]    Verify that the system supports multiple CPU cores using Package ID mapping.
    ...    Previous IDs: CPU004.011
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli hardware cpu list | grep Id
    ${lines}=    Split To Lines    ${out}
    @{package_ids}=    Get Regexp Matches    ${out}    Package Id:
    FOR    ${item}    IN    @{package_ids}
        ${package_ids_count}=    Evaluate    ${PACKAGE_IDS_COUNT} + 1
    END
    IF    ${package_ids_count} < 2    FAIL There Are No Multiple Package Ids.


*** Keywords ***
Init CPU ESXi
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Login To OS    ${ENV_ID_ESXI}
