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


*** Variables ***
${PACKAGE_IDS_COUNT}=       0
${CACHE_REGEX}=
...                         (?s)[ ]+L2 Cache Size:
...                         \\d+\\r?\\n[ ]+L2 Cache Associativity:
...                         \\d+\\r?\\n[ ]+L2 Cache Line Size:
...                         \\d+\\r?\\n[ ]+L2 Cache CPU Count:
...                         \\d+\\r?\\n[ ]+L3 Cache Size:
...                         \\d+\\r?\\n[ ]+L3 Cache Associativity:
...                         \\d+\\r?\\n[ ]+L3 Cache Line Size:
...                         \\d+\\r?\\n[ ]+L3 Cache CPU Count:
...                         \\d+\\r?\\n[ ]+L2 Cache Size: \\d+


*** Test Cases ***
CPU001.201 CPU works (Ubuntu)
    [Documentation]    Check whether the CPU mounted on the DUT works.
    ...    Previous IDs: CPU001.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPU001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPU001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux

CPU001.401 CPU works (ESXi)
    [Documentation]    Verify that the CPU on the DUT is functional and boots the ESXi OS.
    ...    The test passes if the ESXi login screen (DCUI) is visible after boot.
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    CPU001.401 not supported
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Login To OS    ${ENV_ID_ESXI}

CPU002.201 CPU cache enabled (Ubuntu)
    [Documentation]    Check whether the all declared for the DUT cache levels
    ...    are enabled.
    ...    Previous IDs: CPU002.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPU002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPU001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    CPU Cache Enabled Linux

CPU002.401 CPU cache enabled (ESXi)
    [Documentation]    Verify that all CPU cache levels are detected and reported by ESXi.
    ...    Expected output includes L2 and L3 cache size, associativity, and CPU count.
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    CPU002.401 not supported
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli hardware cpu list | grep Cache
    ${count}=    Evaluate
    ...    len(re.findall(r'''${CACHE_REGEX}''', '''${out}'''))
    ...    re
    IF    ${count} < 2    FAIL    [TBD] Fail message TBD

CPU003.201 Multiple CPU support (Ubuntu)
    [Documentation]    Check whether the DUT has multiple CPU support.
    ...    Previous IDs: CPU003.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPU003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPU003.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Multiple CPU Support Linux

CPU003.401 Multiple CPU support (ESXi)
    [Documentation]    Verify that ESXi detects more than one CPU core, indicating multi-CPU support.
    # Skip If    not ${TESTS_IN_ESXI_SUPPORT}    CPU001.401 not supported
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli hardware cpu global get
    ${cores_match}=    Get Regexp Matches    ${out}    CPU Cores:\\s*(\\d+)    1
    ${core_str}=    Get From List    ${cores_match}    0
    ${cores}=    Convert To Integer    ${core_str}
    IF    ${cores} < 2    Fail    Quantitty of cores less than 2.

CPU004.201 Multiple-core support (Ubuntu)
    [Documentation]    Check whether the DUT has multi-core support.
    ...    Previous IDs: CPU004.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPU004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPU004.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Multiple-Core Support Linux

CPU004.401 Multiple-core support (ESXi)    # tbd
    [Documentation]    Verify that the system supports multiple CPU cores using Package ID mapping.
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    CPU004.401 not supported
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli hardware cpu list | grep Id
    ${lines}=    Split To Lines    ${out}
    @{package_ids}=    Get Regexp Matches    ${out}    Package Id:
    FOR    ${item}    IN    @{package_ids}
        ${package_ids_count}=    Evaluate    ${PACKAGE_IDS_COUNT} + 1
    END
    IF    ${package_ids_count} < 2    FAIL There Are No Multiple Package Ids.

CPU001.202 CPU works (Fedora)
    [Documentation]    Check whether the CPU mounted on the DUT works.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPU001.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux

CPU002.202 CPU cache enabled (Fedora)
    [Documentation]    Check whether the all declared for the DUT cache levels
    ...    are enabled.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPU001.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    CPU Cache Enabled Linux

CPU003.202 Multiple CPU support (Fedora)
    [Documentation]    Check whether the DUT has multiple CPU support.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPU003.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Multiple CPU Support Linux

CPU004.202 Multiple-core support (Fedora)
    [Documentation]    Check whether the DUT has multi-core support.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPU004.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Multiple-Core Support Linux

CPU001.301 CPU works (Windows)
    [Documentation]    Check whether the CPU mounted on the DUT works.
    ...    Previous IDs: CPU001.002
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPU001.301 not supported
    Power On
    Login To Windows

CPU002.301 CPU cache enabled (Windows)
    [Documentation]    Check whether the all declared for the DUT cache levels
    ...    are enabled.
    ...    Previous IDs: CPU002.002
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPU002.301 not supported
    Power On
    Login To Windows
    ${mem_info}=    Execute Command In Terminal
    ...    Get-Wmiobject -class win32_cachememory | fl Purpose, CacheType, InstalledSize
    Should Contain    ${mem_info}    CACHE1
    Pass Execution If    not ${L2_CACHE_SUPPORT}    DUT supports only L1 cache
    Should Contain    ${mem_info}    CACHE2
    Pass Execution If    not ${L3_CACHE_SUPPORT}    DUT supports only L1 and L2 cache
    Should Contain    ${mem_info}    CACHE3
    Pass Execution If    not ${L4_CACHE_SUPPORT}    DUT supports only L1, L2 and L3 cache
    Should Contain    ${mem_info}    CACHE4

CPU003.301 Multiple CPU support (Windows)
    [Documentation]    Check whether the DUT has multiple CPU support.
    ...    Previous IDs: CPU003.002
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPU003.301 not supported
    Power On
    Login To Windows
    ${cpu_info}=    Execute Command In Terminal    (Get-CimInstance -ClassName Win32_Processor).NumberOfCores
    ${cpu_count}=    Get Line    ${cpu_info}    -1
    ${cpu_count}=    Convert To Number    ${cpu_count}
    Should Be True    ${cpu_count} > 1

CPU004.301 Multiple-core support (Windows)
    [Documentation]    Check whether the DUT has multi-core support.
    ...    Previous IDs: CPU004.002
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPU004.301 not supported
    Power On
    Login To Windows
    ${cpu_info}=    Execute Command In Terminal
    ...    Get-CimInstance -ClassName Win32_Processor | Select-Object -Property NumberOfCores
    ${cpu_count}=    Get Line    ${cpu_info}    -1
    ${cpu_count}=    Convert To Number    ${cpu_count}
    ${socket_count}=    Execute Command In Terminal
    ...    (Get-CimInstance -ClassName Win32_ComputerSystem).NumberOfProcessors
    ${socket_count}=    Get Line    ${socket_count}    -1
    ${socket_count}=    Convert To Number    ${socket_count}
    Should Be True    ${cpu_count} / ${socket_count} > 1


*** Keywords ***
Check Cache Support
    [Arguments]    ${string}    ${cache}
    ${lines}=    Get Lines Containing String    ${string}    ${cache}
    ${lines}=    Get Lines Containing String    ${lines}    CACHE_SIZE
    @{lines}=    Split To Lines    ${lines}
    FOR    ${line}    IN    @{lines}
        ${cache_string}    ${cache_size}=    Split String    ${line}    ${SPACE}    1
        ${cache_size}=    Replace String    ${cache_size}    ${SPACE}    ${EMPTY}
        IF    '${cache_size}' == ''    Fail    Cache size can't be empty
        ${mem}=    Convert To Integer    ${cache_size}
        IF    '${mem}'=='0'    Fail    ${line}    ELSE    Log    ${line}
    END

CPU Cache Enabled Linux
    [Documentation]    Check whether the all declared for the DUT cache levels
    ...    are enabled.
    [Tags]    robot:private
    ${mem_info}=    Execute Linux Command    getconf -a | grep CACHE
    Check Cache Support    ${mem_info}    LEVEL1
    Pass Execution If    not ${L2_CACHE_SUPPORT}    DUT supports only L1 cache
    Check Cache Support    ${mem_info}    LEVEL2
    Pass Execution If    not ${L3_CACHE_SUPPORT}    DUT supports only L1 and L2 cache
    Check Cache Support    ${mem_info}    LEVEL3
    Pass Execution If    not ${L4_CACHE_SUPPORT}    DUT supports only L1, L2 and L3 cache
    Check Cache Support    ${mem_info}    LEVEL4

Multiple CPU Support Linux
    [Documentation]    Check whether the DUT has multiple CPU support.
    [Tags]    robot:private
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPU003.001 not supported
    ${cpu_info}=    Execute Linux Command    lscpu
    Set Suite Variable    ${CPU_INFO}
    ${cpu}=    Get Lines Matching Regexp    ${CPU_INFO}    ^CPU\\(s\\):\\s+\\d+$    flags=MULTILINE
    Should Contain    ${cpu}    ${DEF_THREADS_TOTAL}    Different number of CPU's than ${DEF_THREADS_TOTAL}
    ${online}=    Execute Linux Command    cat /sys/devices/system/cpu/online
    Should Contain    ${online}    ${DEF_ONLINE_CPU}    There are more than ${DEF_ONLINE_CPU[2]} on-line CPU's

Multiple-Core Support Linux
    [Documentation]    Check whether the DUT has multi-core support.
    [Tags]    robot:private
    ${cpu_info}=    Execute Linux Command    lscpu
    ${sockets}=    Get Lines Containing String    ${cpu_info}    Socket(s):
    Should Contain    ${sockets}    ${DEF_SOCKETS}    Different number of sockets than ${DEF_SOCKETS}
    ${cores}=    Get Lines Containing String    ${cpu_info}    Core(s) per socket:
    Should Contain
    ...    ${cores}
    ...    ${DEF_CORES_PER_SOCKET}
    ...    Different number of cores per socket than ${DEF_CORES_PER_SOCKET}
    ${threads}=    Get Lines Containing String    ${cpu_info}    Thread(s) per core:
    Should Contain
    ...    ${threads}
    ...    ${DEF_THREADS_PER_CORE}
    ...    Different number of threads per core than ${DEF_THREADS_PER_CORE}
