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
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
CPU001.001 CPU works (Ubuntu 22.04)
    [Documentation]    Check whether the CPU mounted on the DUT works.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPU001.001 not supported
    Skip If    not ${CPU_TESTS_SUPPORT}    CPU001.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux

CPU001.002 CPU works (Windows 11)
    [Documentation]    Check whether the CPU mounted on the DUT works.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPU001.002 not supported
    Skip If    not ${CPU_TESTS_SUPPORT}    CPU001.002 not supported
    Power On
    Login To Windows

CPU002.001 CPU cache enabled (Ubuntu 22.04)
    [Documentation]    Check whether the all declared for the DUT cache levels
    ...    are enabled.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPU002.001 not supported
    Skip If    not ${CPU_TESTS_SUPPORT}    CPU002.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    ${mem_info}=    Execute Linux Command    getconf -a | grep CACHE
    Check Cache Support    ${mem_info}    LEVEL1
    Pass Execution If    not ${L2_CACHE_SUPPORT}    DUT supports only L1 cache
    Check Cache Support    ${mem_info}    LEVEL2
    Pass Execution If    not ${L3_CACHE_SUPPORT}    DUT supports only L1 and L2 cache
    Check Cache Support    ${mem_info}    LEVEL3
    Pass Execution If    not ${L4_CACHE_SUPPORT}    DUT supports only L1, L2 and L3 cache
    Check Cache Support    ${mem_info}    LEVEL4

CPU002.002 CPU cache enabled (Windows 11)
    [Documentation]    Check whether the all declared for the DUT cache levels
    ...    are enabled.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPU002.002 not supported
    Skip If    not ${CPU_TESTS_SUPPORT}    CPU002.002 not supported
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

CPU003.001 Multiple CPU support (Ubuntu 22.04)
    [Documentation]    Check whether the DUT has multiple CPU support.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPU003.001 not supported
    Skip If    not ${CPU_TESTS_SUPPORT}    CPU003.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    ${cpu_info}=    Execute Linux Command    lscpu
    Set Suite Variable    ${CPU_INFO}
    ${cpu}=    Get Line    ${CPU_INFO}    3
    Should Contain    ${cpu}    ${DEF_CPU}    Different number of CPU's than ${DEF_CPU}
    ${online}=    Execute Linux Command    cat /sys/devices/system/cpu/online
    Should Contain    ${online}    ${DEF_ONLINE_CPU}    There are more than ${DEF_ONLINE_CPU[2]} on-line CPU's

CPU003.002 Multiple CPU support (Windows 11)
    [Documentation]    Check whether the DUT has multiple CPU support.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPU003.002 not supported
    Skip If    not ${CPU_TESTS_SUPPORT}    CPU003.002 not supported
    Power On
    Login To Windows
    ${cpu_info}=    Execute Command In Terminal    WMIC CPU Get NumberOfCores
    ${cpu_count}=    Get Line    ${cpu_info}    -1
    ${cpu_count}=    Convert To Number    ${cpu_count}
    Should Be True    ${cpu_count} > 1

CPU004.001 Multiple-core support (Ubuntu 22.04)
    [Documentation]    Check whether the DUT has multi-core support.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPU004.001 not supported
    Skip If    not ${CPU_TESTS_SUPPORT}    CPU004.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    ${cpu_info}=    Execute Linux Command    lscpu
    ${sockets}=    Get Lines Containing String    ${cpu_info}    Socket(s):
    Should Contain    ${sockets}    ${DEF_SOCKETS}    Different number of sockets than ${DEF_SOCKETS}
    ${cores}=    Get Lines Containing String    ${cpu_info}    Core(s) per socket:
    Should Contain    ${cores}    ${DEF_CORES}    Different number of cores per socket than ${DEF_CORES}
    ${threads}=    Get Lines Containing String    ${cpu_info}    Thread(s) per core:
    Should Contain    ${threads}    ${DEF_THREADS}    Different number of threads per core than ${DEF_THREADS}

CPU004.002 Multiple-core support (Windows 11)
    [Documentation]    Check whether the DUT has multi-core support.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPU004.002 not supported
    Skip If    not ${CPU_TESTS_SUPPORT}    CPU004.002 not supported
    Power On
    Login To Windows
    ${cpu_info}=    Execute Command In Terminal    WMIC CPU Get NumberOfCores
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
    ${lines}=    Split To Lines    ${lines}
    FOR    ${line}    IN    @{lines}
        ${mem}=    Get Substring    ${line}    -6
        ${mem}=    Convert To Integer    ${mem}
        IF    '${mem}'=='0'    Fail    ${line}    ELSE    Log    ${line}
    END
