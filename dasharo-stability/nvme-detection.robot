*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${NVME_DETECTION_SUPPORT}    NVMe detection tests not supported
...                     AND
...                     Check If Platform Sleep Type Can Be Selected
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
SNV001.201 NVMe detection after cold boot (Ubuntu)
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a cold boot.
    [Tags]    semiauto
    Skip If    not ${NVME_DETECTION_SUPPORT}    SNV001.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SNV001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SNV001.201 not supported
    Pause Execution    This is a manual test.
    Execute Manual Step    [1/5] Power off the DUT completely (cold boot).
    Execute Manual Step    [2/5] Power on the DUT and boot into Ubuntu.
    Execute Manual Step    [3/5] Log in and open a terminal.
    Execute Manual Step    [4/5] Run: lspci | grep -i nvme
    Execute Manual Step    [5/5] Verify that the NVMe disk is listed in the output.

SNV002.201 NVMe detection after warm boot (Ubuntu)
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a warm boot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SNV002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SNV002.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    NVMe Detection After Warm Boot
    Exit From Root User

SNV003.201 NVMe detection after reboot (Ubuntu)
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SNV003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SNV003.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    NVMe Detection After Reboot
    Exit From Root User

SNV004.201 NVMe detection after suspension (Ubuntu)
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SNV004.201 not supported
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SNV004.201 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SNV004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SNV004.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    NVMe Detection After Suspension
    Exit From Root User

SNV005.201 NVMe detection after suspension (Ubuntu) (S0ix)
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SNV005.201 not supported
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SNV005.201 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SNV005.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SNV005.201 not supported
    Set Platform Sleep Type    S0ix
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    NVMe Detection After Suspension    S0ix
    Exit From Root User

SNV006.201 NVMe detection after suspension (Ubuntu) (S3)
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SNV006.201 not supported
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SNV006.201 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SNV006.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SNV006.201 not supported
    Set Platform Sleep Type    S3
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    NVMe Detection After Suspension    S3
    Exit From Root User

SNV002.202 NVMe detection after warm boot (Fedora)
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a warm boot.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SNV002.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    NVMe Detection After Warm Boot
    Exit From Root User

SNV003.202 NVMe detection after reboot (Fedora)
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a reboot.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SNV003.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    NVMe Detection After Reboot
    Exit From Root User

SNV004.202 NVMe detection after suspension (Fedora)
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SNV004.202 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SNV004.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SNV004.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    NVMe Detection After Suspension
    Exit From Root User

SNV005.202 NVMe detection after suspension (Fedora) (S0ix)
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SNV005.202 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SNV005.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SNV005.202 not supported
    Set Platform Sleep Type    S0ix
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    NVMe Detection After Suspension    S0ix
    Exit From Root User

SNV006.202 NVMe detection after suspension (Fedora) (S3)
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SNV006.202 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SNV006.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SNV006.202 not supported
    Set Platform Sleep Type    S3
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    NVMe Detection After Suspension    S3
    Exit From Root User

SNV001.203 NVMe detection after cold boot (Qubes OS)
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a cold boot.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SNV001.203 not supported
    Pause Execution
    ...    This is a manual test.
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal (or any text editor).
    Execute Manual Step    [3/4] Type in: `lspci`
    Execute Manual Step    [4/4] In the command output look for DUT's NVMe

SNV002.203 NVMe detection after warm boot (Qubes OS)
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a cold boot.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SNV002.203 not supported
    Pause Execution
    ...    This is a manual test.
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal (or any text editor).
    Execute Manual Step    [3/4] Type in: `lspci`
    Execute Manual Step    [4/4] In the command output look for DUT's NVMe

SNV003.203 NVMe detection after reboot (Qubes OS)
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a cold boot.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SNV003.203 not supported
    Pause Execution
    ...    This is a manual test.
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal (or any text editor).
    Execute Manual Step    [3/4] Type in: `lspci`
    Execute Manual Step    [4/4] In the command output look for DUT's NVMe

SNV004.203 NVMe detection after suspend (Qubes OS)
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a cold boot.
    [Tags]    semiauto
    Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    SNV004.203 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SNV004.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SNV004.203 not supported
    Pause Execution
    ...    This is a manual test.
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal (or any text editor).
    Execute Manual Step    [3/4] Type in: `lspci`
    Execute Manual Step    [4/4] In the command output look for DUT's NVMe


*** Keywords ***
NVMe Detection After Suspension
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    [Arguments]    ${platform_sleep_type}=${EMPTY}
    Check Platform Sleep Type Is Correct On Linux    ${platform_sleep_type}
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}
    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_SUSPEND_ITERATIONS}
        Perform Suspend Test Using FWTS
        ${out}=    List Devices In Linux    pci
        Should Contain    ${out}    ${DEVICE_NVME_DISK}
    END

NVMe Detection After Reboot
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a reboot.
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}
    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Execute Reboot Command
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
        Login To Linux
        Switch To Root User
        ${out}=    List Devices In Linux    pci
        Should Contain    ${out}    ${DEVICE_NVME_DISK}
    END

NVMe Detection After Warm Boot
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a warm boot.
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}
    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_WARMBOOT_ITERATIONS}
        Perform Warmboot Using Rtcwake
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
        Login To Linux
        Switch To Root User
        ${out}=    List Devices In Linux    pci
        Should Contain    ${out}    ${DEVICE_NVME_DISK}
    END
