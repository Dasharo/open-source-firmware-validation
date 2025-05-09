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


*** Test Cases ***

MEM001.203 Expected RAM size detected in OS (XCP-NG)
    [Documentation]    This test verifies that the installed physical memory (RAM)
    ...    is properly detected and reported by the XCP-NG OS.
    ...    Previous IDs: MEM001.003
    Skip If    not ${TESTS_IN_XCP_NG_SUPPORT}    MEM001.203 not supported
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    MEM001.203 not supported
    Execute Manual Step    RAM Size Detected In OS    ${ENV_ID_XCP_NG}    ${DEF_EXPECTED_RAM_KB}

*** Keywords ***

RAM Size Detected In OS
    [Arguments]    ${env_id}    ${expected_kb}
    [Documentation]    Power on, boot, login, and verify RAM size in OS.
    [Tags]    robot:private

    Power On
    Boot System Or From Connected Disk    ${env_id}
    Login To Linux

    ${meminfo}=    Execute Linux Command    cat /proc/meminfo | grep MemTotal
    Log    ${meminfo}

    ${actual_kb}=    Evaluate    int('${meminfo}'.split(':')[1].strip().split()[0])
    ${delta}=        Evaluate    abs(${actual_kb} - ${expected_kb})
    ${tolerance}=    Set Variable    524288    # Allow 512MB difference

    Run Keyword Unless    ${delta} < ${tolerance}    Fail    RAM size mismatch: expected ~${expected_kb} kB, got ${actual_kb} kB (delta: ${delta})
