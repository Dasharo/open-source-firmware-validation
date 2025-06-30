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

Force Tags          automated


*** Variables ***
${SIZE_OF_33_GB}=       35433480192    # 33*1024*1024*1024
${SIZE_OF_31_GB}=       33285996544    # 31*1024*1024*1024


*** Test Cases ***
MEM001.401 Expected RAM size detected in OS (ESXi)
    [Documentation]    Verify that the installed RAM is correctly recognized by ESXi.
    ...    Total memory reported should match the expected amount within a reasonable margin.
    ...    Previous IDs: MEM001.011
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    MEM001.401 not supported
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli hardware memory get
    ${ram_size_line}=    Get Regexp Matches    ${out}    Physical Memory:\\s*(\\d+)    1
    ${ram_size_str}=    Get From List    ${ram_size_line}    0
    ${ram_size}=    Convert To Integer    ${ram_size_str}
    IF    ${ram_size} <= ${SIZE_OF_31_GB} or ${ram_size} >= ${SIZE_OF_33_GB}
        Fail    RAM size out of scope.\n
    END
