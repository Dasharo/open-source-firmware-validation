*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${CPU_TESTS_SUPPORT}    CPU tests not supported
...                     AND    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    Windows not supported
...                     AND    Reset UEFI Options To Defaults
...                     AND    Init CPU Windows
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CPU001.301 CPU works (Windows)
    [Documentation]    Check whether the CPU mounted on the DUT works.
    ...    Previous IDs: CPU001.002
    Pass Execution    Booted into OS

CPU002.301 CPU cache enabled (Windows)
    [Documentation]    Check whether the all declared for the DUT cache levels
    ...    are enabled.
    ...    Previous IDs: CPU002.002
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
    ${cpu_info}=    Execute Command In Terminal    (Get-CimInstance -ClassName Win32_Processor).NumberOfCores
    ${cpu_count}=    Get Line    ${cpu_info}    -1
    ${cpu_count}=    Convert To Number    ${cpu_count}
    Should Be True    ${cpu_count} > 1

CPU004.301 Multiple-core support (Windows)
    [Documentation]    Check whether the DUT has multi-core support.
    ...    Previous IDs: CPU004.002
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
Init CPU Windows
    Power On
    Login To Windows
