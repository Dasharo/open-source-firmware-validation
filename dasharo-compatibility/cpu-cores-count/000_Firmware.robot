*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         CCC Suite Setup
Suite Teardown      CCC Suite Teardown

Default Tags        automated


*** Test Cases ***
CCC001.001 Check core count with HT disabled (Ubuntu)
    [Documentation]    Disable HT and check the number of cores as seen by the OS.
    Depends On    ${HYPER_THREADING_SUPPORT}
    Set UEFI Option    HyperThreading    ${FALSE}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${out}=    Get Threads Per Core
    Should Contain    ${out}    1

CCC002.001 Check core count with HT enabled
    [Documentation]    Enable HT and check the number of cores as seen by the OS.
    Depends On    ${HYPER_THREADING_SUPPORT}
    Set UEFI Option    HyperThreading    ${TRUE}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${out}=    Get Threads Per Core
    Should Contain    ${out}    ${DEF_THREADS_PER_CORE}

CCC003.001 Check core count (HT Enabled, P: All, E: 0) (Ubuntu)
    Depends On    ${INTEL_HYBRID_ARCH_SUPPORT}
    Power On
    Enter Setup Menu Tianocore
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    ActiveECores    0
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${p_cores}=    Get P Cores Count
    ${e_cores}=    Get E Cores Count
    ${expected_p_cores}=    Evaluate    ${DEF_THREADS_PER_CORE} * ${CPU_P_CORES_MAX}
    Should Be Equal As Integers    ${p_cores}    ${expected_p_cores}
    Should Be Equal As Integers    ${e_cores}    0

CCC004.001 Check core count (HT Enabled, P: All, E: All) (Ubuntu)
    Depends On    ${INTEL_HYBRID_ARCH_SUPPORT}
    Power On
    Enter Setup Menu Tianocore
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    ActiveECores    All active
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${p_cores}=    Get P Cores Count
    ${e_cores}=    Get E Cores Count
    ${expected_p_cores}=    Evaluate    ${DEF_THREADS_PER_CORE} * ${CPU_P_CORES_MAX}
    Should Be Equal As Integers    ${p_cores}    ${expected_p_cores}
    Should Be Equal As Integers    ${e_cores}    ${CPU_E_CORES_MAX}

CCC005.001 Check core count (HT Disabled, P: All, E: 0) (Ubuntu)
    Depends On    ${INTEL_HYBRID_ARCH_SUPPORT}
    Power On
    Enter Setup Menu Tianocore
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    HyperThreading    ${FALSE}
    Set UEFI Option    ActiveECores    0
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${p_cores}=    Get P Cores Count
    ${e_cores}=    Get E Cores Count
    Should Be Equal As Integers    ${p_cores}    ${CPU_P_CORES_MAX}
    Should Be Equal As Integers    ${e_cores}    0

CCC006.001 Check core count (HT Disabled, P: All, E: 0) (Ubuntu)
    Depends On    ${INTEL_HYBRID_ARCH_SUPPORT}
    Power On
    Enter Setup Menu Tianocore
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    ActiveECores    0
    Set UEFI Option    HyperThreading    ${FALSE}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${p_cores}=    Get P Cores Count
    ${e_cores}=    Get E Cores Count
    Should Be Equal As Integers    ${p_cores}    ${CPU_P_CORES_MAX}
    Should Be Equal As Integers    ${e_cores}    0

CCC007.001 Check core count (HT Enabled, P: 1, E: A) (Ubuntu)
    Depends On    ${INTEL_HYBRID_ARCH_SUPPORT}
    Power On
    Enter Setup Menu Tianocore
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    ActivePCores    1
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${p_cores}=    Get P Cores Count
    ${e_cores}=    Get E Cores Count
    ${expected_p_cores}=    Evaluate    ${DEF_THREADS_PER_CORE} * 1
    Should Be Equal As Integers    ${p_cores}    ${expected_p_cores}
    Should Be Equal As Integers    ${e_cores}    ${CPU_E_CORES_MAX}

CCC008.001 Check core count (HT Disabled, P: 1, E: A) (Ubuntu)
    Depends On    ${INTEL_HYBRID_ARCH_SUPPORT}
    Power On
    Enter Setup Menu Tianocore
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    HyperThreading    ${FALSE}
    Set UEFI Option    ActivePCores    1
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${p_cores}=    Get P Cores Count
    ${e_cores}=    Get E Cores Count
    Should Be Equal As Integers    ${p_cores}    1
    Should Be Equal As Integers    ${e_cores}    ${CPU_E_CORES_MAX}

CCC009.001 Check core count (HT Enabled, P: 1, E: 1) (Ubuntu)
    Depends On    ${INTEL_HYBRID_ARCH_SUPPORT}
    Power On
    Enter Setup Menu Tianocore
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    HyperThreading    ${TRUE}
    Set UEFI Option    ActivePCores    1
    Set UEFI Option    ActiveECores    1
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${p_cores}=    Get P Cores Count
    ${e_cores}=    Get E Cores Count
    ${expected_p_cores}=    Evaluate    ${DEF_THREADS_PER_CORE} * 1
    Should Be Equal As Integers    ${p_cores}    ${expected_p_cores}
    Should Be Equal As Integers    ${e_cores}    1

CCC010.001 Check core count (HT Disabled, P: 1, E: 1) (Ubuntu)
    Depends On    ${INTEL_HYBRID_ARCH_SUPPORT}
    Power On
    Enter Setup Menu Tianocore
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    HyperThreading    ${FALSE}
    Set UEFI Option    ActivePCores    1
    Set UEFI Option    ActiveECores    1
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${p_cores}=    Get P Cores Count
    ${e_cores}=    Get E Cores Count
    Should Be Equal As Integers    ${p_cores}    1
    Should Be Equal As Integers    ${e_cores}    1

CCC011.001 Check core count (HT Enabled, P: A, E: 1) (Ubuntu)
    Depends On    ${INTEL_HYBRID_ARCH_SUPPORT}
    Power On
    Enter Setup Menu Tianocore
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    HyperThreading    ${TRUE}
    Set UEFI Option    ActiveECores    1
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${p_cores}=    Get P Cores Count
    ${e_cores}=    Get E Cores Count
    ${expected_p_cores}=    Evaluate    ${DEF_THREADS_PER_CORE} * ${CPU_P_CORES_MAX}
    Should Be Equal As Integers    ${p_cores}    ${expected_p_cores}
    Should Be Equal As Integers    ${e_cores}    1

CCC012.001 Check core count (HT Disabled, P: A, E: 1) (Ubuntu)
    Depends On    ${INTEL_HYBRID_ARCH_SUPPORT}
    Power On
    Enter Setup Menu Tianocore
    Reset To Defaults Tianocore
    Save Changes And Reset
    Set UEFI Option    HyperThreading    ${FALSE}
    Set UEFI Option    ActiveECores    1
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${p_cores}=    Get P Cores Count
    ${e_cores}=    Get E Cores Count
    ${expected_p_cores}=    Evaluate    ${CPU_P_CORES_MAX}
    Should Be Equal As Integers    ${p_cores}    ${expected_p_cores}
    Should Be Equal As Integers    ${e_cores}    1
