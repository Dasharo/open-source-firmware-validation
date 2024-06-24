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
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${CPU_TESTS_SUPPORT}    CPU tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
CCC001.001 CPU Hyper-Threading disabled (Ubuntu)
    [Documentation]    Check if Hyper-Threading is disabled.
    Set UEFI Option    HyperThreading    ${FALSE}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Detect Or Install Package    util-linux
    ${out}=    Get Threads Per Core
    Should Contain    ${out}    1

CCC001.002 CPU Hyper-Threading enabled (Ubuntu)
    [Documentation]    Check if Hyper-Threading is enabled.
    Set UEFI Option    HyperThreading    ${TRUE}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Detect Or Install Package    util-linux
    ${out}=    Get Threads Per Core
    Should Contain    ${out}    ${DEF_THREADS_PER_CORE}

CCC002.001 CPU E-cores none active, Hyper-Threading enabled (Ubuntu)
    [Documentation]    Check if the correct amount of cores is active when
    ...    all of E-cores are disabled, all P-cores are enabled and 
    ...    Hyper-Threading is enabled.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    ActiveECores    0
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Detect Or Install Package    util-linux
    ${out}=    Execute Command In Terminal    lscpu | grep -v "NUMA" | grep "Core(s) per socket:"
    ${threads}=    Get Threads Per Core
    ${core_count}=    Evaluate    ${DEF_THREADS_TOTAL} - ${DEF_CORES_PER_SOCKET}
    ${core_count}=    Convert To String    ${core_count}
    Should Contain    ${out}    ${core_count}

CCC002.002 CPU E-cores all active, Hyper-Threading enabled (Ubuntu)
    [Documentation]    Check if the correct amount of cores is active when
    ...    all of E-cores are enabled, all P-cores are enabled and 
    ...    Hyper-Threading is enabled.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    ActiveECores    All active
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Detect Or Install Package    util-linux
    ${out}=    Execute Command In Terminal    lscpu | grep -v "NUMA" | grep "Core(s) per socket:"
    Should Contain    ${out}    ${DEF_THREADS_TOTAL}

CCC002.003 CPU E-cores none active, Hyper-Threading disabled (Ubuntu)
    [Documentation]    Check if the correct amount of cores is active when
    ...    all of E-cores are disabled, all P-cores are enabled and 
    ...    Hyper-Threading is disabled.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    HyperThreading    ${FALSE}
    Set UEFI Option    ActiveECores    0
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Detect Or Install Package    util-linux
    ${out}=    Execute Command In Terminal    lscpu | grep -v "NUMA" | grep "Core(s) per socket:"   
    ${core_count}=    Evaluate    ${DEF_THREADS_TOTAL} - ${DEF_CORES_PER_SOCKET}
    Should Contain    ${out}    ${core_count}

CCC002.004 CPU E-cores all active, Hyper-Threading disabled (Ubuntu)
    [Documentation]    Check if the correct amount of cores is active when
    ...    all of E-cores are enabled, all P-cores are enabled and 
    ...    Hyper-Threading is disabled.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    ActiveECores    All active
    Set UEFI Option    HyperThreading    ${FALSE}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Detect Or Install Package    util-linux
    ${out}=    Execute Command In Terminal    lscpu | grep -v "NUMA" | grep "Core(s) per socket:"
    Should Contain    ${out}    ${DEF_CORES_PER_SOCKET}

CCC003.001 CPU P-cores only one active, Hyper-Threading enabled (Ubuntu)
    [Documentation]    Check if the correct amount of cores is active when
    ...    all of E-cores are enabled, only one P-core is enabled and 
    ...    Hyper-Threading is enabled.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    ActivePCores    1
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Detect Or Install Package    util-linux
    ${out}=    Execute Command In Terminal    lscpu | grep -v "NUMA" | grep "Core(s) per socket:"
    ${cores}=    Get Amount Of E Cores
    ${cores}=    Evaluate    ${cores} + 1
    ${cores}=    Convert To String    ${cores}
    Should Contain    ${out}    ${cores}

CCC003.002 CPU P-cores all active, Hyper-Threading enabled (Ubuntu)
    [Documentation]    Check if the correct amount of cores is active when
    ...    all of E-cores are enabled, all P-cores are enabled and 
    ...    Hyper-Threading is enabled.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    ActivePCores    All active
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Detect Or Install Package    util-linux    
    ${out}=    Execute Command In Terminal    lscpu | grep -v "NUMA" | grep "Core(s) per socket:"
    Should Contain    ${out}    ${DEF_THREADS_TOTAL}

CCC003.003 CPU P-cores only one active, Hyper-Threading disabled (Ubuntu)
    [Documentation]    Check if the correct amount of cores is active when
    ...    all of E-cores are enabled, only one P-core is enabled and 
    ...    Hyper-Threading is disabled.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    HyperThreading    ${FALSE}
    Set UEFI Option    ActivePCores    1
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Detect Or Install Package    util-linux
    ${out}=    Execute Command In Terminal    lscpu | grep -v "NUMA" | grep "Core(s) per socket:"
    ${cores}=    Get Amount Of E Cores + 1
    ${cores}=    Evaluate    ${cores} + 1
    ${cores}=    Convert To String    ${cores}
    Should Contain    ${out}    ${cores}

CCC003.004 CPU P-cores all active, Hyper-Threading disabled (Ubuntu)
    [Documentation]    Check if the correct amount of cores is active when
    ...    all of E-cores are enabled, all P-cores are enabled and 
    ...    Hyper-Threading is disabled.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    HyperThreading    ${FALSE}
    Set UEFI Option    ActivePCores    All active
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Detect Or Install Package    util-linux    
    ${out}=    Execute Command In Terminal    lscpu | grep -v "NUMA" | grep "Core(s) per socket:"
    ${cores}=    Get Amount Of E cores
    ${cores}=    Evaluate    ${cores} + 2
    ${cores}=    Convert To String    ${cores}
    Should Contain    ${out}    ${cores}

CCC004.001 CPU P-cores only one active, CPU E-cores disabled, Hyper-Threading disabled (Ubuntu)
    [Documentation]    Check if the correct amount of cores is active when
    ...    all of E-cores are disabled, all P-cores are disabled and 
    ...    Hyper-Threading is disabled.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    HyperThreading    ${FALSE}
    Set UEFI Option    ActiveECores    0
    Set UEFI Option    ActivePCores    1
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Detect Or Install Package    util-linux    
    ${out}=    Execute Command In Terminal    lscpu | grep -v "NUMA" | grep "Core(s) per socket:"    
    Should Contain    ${out}    1

CCC004.002 CPU P-cores only one active, CPU E-cores disabled, Hyper-Threading enabled (Ubuntu)
    [Documentation]    Check if the correct amount of cores is active when
    ...    all of E-cores are disabled, all P-cores are disabled and 
    ...    Hyper-Threading is disabled.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    ActiveECores    0
    Set UEFI Option    ActivePCores    1
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Detect Or Install Package    util-linux    
    ${out}=    Execute Command In Terminal    lscpu | grep -v "NUMA" | grep "Core(s) per socket:"    
    Should Contain    ${out}    2

CCC005.001 CPU P-cores all active, CPU E-cores all active, Hyper-Threading enabled (Ubuntu)
    [Documentation]    Check if the correct amount of cores is active when
    ...    all of E-cores are disabled, all P-cores are disabled and 
    ...    Hyper-Threading is disabled.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Reset To Defaults Tianocore
    Save Changes And Reset
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Detect Or Install Package    util-linux    
    ${out}=    Execute Command In Terminal    lscpu | grep -v "NUMA" | grep "Core(s) per socket:"    
    Should Contain    ${out}    ${DEF_THREADS_TOTAL}

CCCXXX.001 Lol
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Reset To Defaults Tianocore

*** Keywords ***
Get Threads Per Core
    [Arguments]
    ${out}=    Execute Command In Terminal    lscpu | grep "Thread(s) per core: "
    ${threads}=    Get Last Word From String    ${out}
    IF    '${threads[:1]}' == '1' 
        ${count}=    Set Variable    1
    ELSE IF    '${threads[:1]}' == '2'
        ${count}=    Set Variable    2 
    ELSE
        Fail    Hyper-Threading status could not be established.
    END
    RETURN     ${count}

Get Last Word From String
    [Arguments]    ${str}    
    @{out}=    Evaluate    "${str}".split(" ")
    ${len}=    Get length    ${out}
    ${pos}=    Evaluate    ${len}-1
    RETURN    ${out}[${pos}]

Get Amount Of E Cores
    [Arguments]
    ${cores}=    Evaluate    ${DEF_THREADS_TOTAL}-${DEF_CORES_PER_SOCKET}
    ${cores}=    Evaluate    ${cores}*${DEF_THREADS_PER_CORE}
    ${cores}=    Evaluate    ${DEF_THREADS_TOTAL}-${cores}
    RETURN    ${cores}