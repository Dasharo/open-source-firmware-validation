*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${CPU_TESTS_SUPPORT}    CPU tests not supported
...                     AND
...                     Reset UEFI Options To Defaults
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Variables ***
${SIZE_OF_33_GB}=       35433480192    # 33*1024*1024*1024
${SIZE_OF_31_GB}=       33285996544    # 31*1024*1024*1024


*** Test Cases ***
MEM001.205 Expected RAM size detected in OS (XCP-NG)
    [Documentation]    This test verifies that the installed physical memory (RAM)
    ...    is properly detected and reported by the XCP-NG OS.
    Skip If    not ${TESTS_IN_XCP_NG_SUPPORT}    MEM001.205 not supported
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    MEM001.205 not supported
    RAM Size Detected In OS    ${PLATFORM_RAM_SIZE}

MEM001.401 Expected RAM size detected in OS (ESXi)
    [Documentation]    Verify that the installed RAM is correctly recognized by ESXi.
    ...    Total memory reported should match the expected amount within a reasonable margin.
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    MEM001.401 not supported
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Boot And Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli hardware memory get
    ${ram_size_line}=    Get Regexp Matches    ${out}    Physical Memory:\\s*(\\d+)    1
    ${ram_size_str}=    Get From List    ${ram_size_line}    0
    ${ram_size}=    Convert To Integer    ${ram_size_str}
    IF    ${ram_size} <= ${SIZE_OF_31_GB} or ${ram_size} >= ${SIZE_OF_33_GB}
        Fail    RAM size out of scope.\n
    END


*** Keywords ***
RAM Size Detected In OS
    [Documentation]    Power on, boot, login, and verify RAM size in OS.
    [Arguments]    ${expected_kb}

    Power On
    Boot And Login To OS    ${ENV_ID_XCP_NG}

    ${meminfo}=    Execute Linux Command    cat /proc/meminfo | grep ^MemTotal
    Log    ${meminfo}

    ${mem_line}=    Fetch From Right    ${meminfo}    MemTotal:
    ${mem_line}=    Strip String    ${mem_line}
    ${mem_kb_str}=    Split String    ${mem_line}    ${SPACE}
    ${actual_kb}=    Convert To Integer    ${mem_kb_str}[0]

    ${delta}=    Evaluate    abs(${actual_kb} - ${expected_kb})
    VAR    ${tolerance}=    524288    # 512 MB tolerance

    Run Keyword Unless
    ...    ${delta} < ${tolerance}
    ...    Fail
    ...    RAM size mismatch: expected ~${expected_kb} kB, got ${actual_kb} kB (delta: ${delta})
