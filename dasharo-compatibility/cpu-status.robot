*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
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
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
CPU001.001 CPU works (Ubuntu 22.04)
    [Documentation]    Check whether the CPU mounted on the DUT works.
    Skip If    not ${tests_in_ubuntu_support}    CPU001.001 not supported
    Skip If    not ${cpu_tests_support}    CPU001.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux

CPU001.002 CPU works (Windows 11)
    [Documentation]    Check whether the CPU mounted on the DUT works.
    Skip If    not ${tests_in_windows_support}    CPU001.002 not supported
    Skip If    not ${cpu_tests_support}    CPU001.002 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows

CPU002.001 CPU cache enabled (Ubuntu 22.04)
    [Documentation]    Check whether the all declared for the DUT cache levels
    ...    are enabled.
    Skip If    not ${tests_in_ubuntu_support}    CPU002.001 not supported
    Skip If    not ${cpu_tests_support}    CPU002.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    ${mem_info}=    Execute Linux command    getconf -a | grep CACHE
    Check Cache Support    ${mem_info}    LEVEL1
    Pass Execution If    not ${L2_cache_support}    DUT supports only L1 cache
    Check Cache Support    ${mem_info}    LEVEL2
    Pass Execution If    not ${L3_cache_support}    DUT supports only L1 and L2 cache
    Check Cache Support    ${mem_info}    LEVEL3
    Pass Execution If    not ${L4_cache_support}    DUT supports only L1, L2 and L3 cache
    Check Cache Support    ${mem_info}    LEVEL4

CPU002.002 CPU cache enabled (Windows 11)
    [Documentation]    Check whether the all declared for the DUT cache levels
    ...    are enabled.
    Skip If    not ${tests_in_windows_support}    CPU002.002 not supported
    Skip If    not ${cpu_tests_support}    CPU002.002 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    ${mem_info}=    Execute Command In Terminal
    ...    Get-Wmiobject -class win32_cachememory | fl Purpose, CacheType, InstalledSize
    Should Contain    ${mem_info}    CACHE1
    Pass Execution If    not ${L2_cache_support}    DUT supports only L1 cache
    Should Contain    ${mem_info}    CACHE2
    Pass Execution If    not ${L3_cache_support}    DUT supports only L1 and L2 cache
    Should Contain    ${mem_info}    CACHE3
    Pass Execution If    not ${L4_cache_support}    DUT supports only L1, L2 and L3 cache
    Should Contain    ${mem_info}    CACHE4

CPU003.001 Multiple CPU support (Ubuntu 22.04)
    [Documentation]    Check whether the DUT has multiple CPU support.
    Skip If    not ${tests_in_ubuntu_support}    CPU003.001 not supported
    Skip If    not ${cpu_tests_support}    CPU003.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    ${cpu_info}=    Execute Linux command    lscpu
    Set Suite Variable    ${cpu_info}
    ${cpu}=    Get Line    ${cpu_info}    3
    Should Contain    ${cpu}    ${def_cpu}    Different number of CPU's than ${def_cpu}
    ${online}=    Execute Linux command    cat /sys/devices/system/cpu/online
    Should Contain    ${online}    ${def_online_cpu}    There are more than ${def_online_cpu[2]} on-line CPU's

CPU003.002 Multiple CPU support (Windows 11)
    [Documentation]    Check whether the DUT has multiple CPU support.
    Skip If    not ${tests_in_windows_support}    CPU003.002 not supported
    Skip If    not ${cpu_tests_support}    CPU003.002 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    ${cpu_info}=    Execute Command In Terminal    WMIC CPU Get NumberOfCores
    ${cpu_count}=    Get Line    ${cpu_info}    2
    ${cpu_count}=    Convert To Number    ${cpu_count}
    Should Be True    ${cpu_count} > 1

CPU004.001 Multiple-core support (Ubuntu 22.04)
    [Documentation]    Check whether the DUT has multi-core support.
    Skip If    not ${tests_in_ubuntu_support}    CPU004.001 not supported
    Skip If    not ${cpu_tests_support}    CPU004.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    ${cpu_info}=    Execute Linux command    lscpu
    ${sockets}=    Get Lines Containing String    ${cpu_info}    Socket(s):
    Should Contain    ${sockets}    ${def_sockets}    Different number of sockets than ${def_sockets}
    ${cores}=    Get Lines Containing String    ${cpu_info}    Core(s) per socket:
    Should Contain    ${cores}    ${def_cores}    Different number of cores per socket than ${def_cores}
    ${threads}=    Get Lines Containing String    ${cpu_info}    Thread(s) per core:
    Should Contain    ${threads}    ${def_threads}    Different number of threads per core than ${def_threads}

CPU004.002 Multiple-core support (Windows 11)
    [Documentation]    Check whether the DUT has multi-core support.
    Skip If    not ${tests_in_windows_support}    CPU004.002 not supported
    Skip If    not ${cpu_tests_support}    CPU004.002 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    ${cpu_info}=    Execute Command In Terminal    WMIC CPU Get NumberOfCores
    ${cpu_count}=    Get Line    ${cpu_info}    2
    ${cpu_count}=    Convert To Number    ${cpu_count}
    ${socket_count}=    Execute Command In Terminal
    ...    (Get-CimInstance -ClassName Win32_ComputerSystem).NumberOfProcessors
    ${socket_count}=    Get Line    ${socket_count}    0
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
