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
# Tests will work on laptops with access to the serial console and possibility
# of remote power control
# SNV0001.001 NVMe detection after cold boot (Ubuntu)
#    [Documentation]    Check whether the NVMe disk is detected and working
#    ...    correctly after performing a cold boot.
#    Skip If    not ${nvme_detection_support}    SNV001.001 not supported
#    Skip If    not ${tests_in_ubuntu_support}    SNV001.001 not supported
#    Skip If    '${POWER_CTRL}' == 'none'    Coldboot automatic tests not supported
#    Power On Ex    force_reboot=${TRUE}
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    List devices in Linux    pci
#    Should Contain    ${out}    ${device_nvme_disk}
#    FOR    ${INDEX}    IN RANGE    0    ${stability_detection_coldboot_iterations}
#    Power Cycle On
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    List devices in Linux    pci
#    Should Contain    ${out}    ${device_nvme_disk}
#    END
#    Exit from root user

SNV002.201 NVMe detection after warm boot (Ubuntu)
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a warm boot.
    ...    Previous IDs: SNV002.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SNV002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SNV002.201 not supported
    Power On Ex    force_reboot=${TRUE}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    NVMe Detection After Warm Boot
    Exit From Root User

SNV003.201 NVMe detection after reboot (Ubuntu)
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a reboot.
    ...    Previous IDs: SNV003.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SNV003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SNV003.201 not supported
    Power On Ex    force_reboot=${TRUE}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    NVMe Detection After Reboot
    Exit From Root User

SNV004.201 NVMe detection after suspension (Ubuntu)
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    ...    Previous IDs: SNV004.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SNV004.201 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SNV004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SNV004.201 not supported
    Power On Ex    force_reboot=${TRUE}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    NVMe Detection After Suspension
    Exit From Root User

SNV005.201 NVMe detection after suspension (Ubuntu) (S0ix)
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    ...    Previous IDs: SNV004.002
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SNV005.201 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SNV005.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SNV005.201 not supported
    Set Platform Sleep Type    S0ix
    Power On Ex    force_reboot=${TRUE}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    NVMe Detection After Suspension    S0ix
    Exit From Root User

SNV006.201 NVMe detection after suspension (Ubuntu) (S3)
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    ...    Previous IDs: SNV004.003
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SNV006.201 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SNV006.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SNV006.201 not supported
    Set Platform Sleep Type    S3
    Power On Ex    force_reboot=${TRUE}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    NVMe Detection After Suspension    S3
    Exit From Root User

SNV002.202 NVMe detection after warm boot (Fedora)
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a warm boot.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SNV002.202 not supported
    Power On Ex    force_reboot=${TRUE}
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    NVMe Detection After Warm Boot
    Exit From Root User

SNV003.202 NVMe detection after reboot (Fedora)
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a reboot.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SNV003.202 not supported
    Power On Ex    force_reboot=${TRUE}
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    NVMe Detection After Reboot
    Exit From Root User

SNV004.202 NVMe detection after suspension (Fedora)
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SNV004.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SNV004.202 not supported
    Power On Ex    force_reboot=${TRUE}
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    NVMe Detection After Suspension
    Exit From Root User

SNV005.202 NVMe detection after suspension (Fedora) (S0ix)
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SNV005.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SNV005.202 not supported
    Set Platform Sleep Type    S0ix
    Power On Ex    force_reboot=${TRUE}
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    NVMe Detection After Suspension    S0ix
    Exit From Root User

SNV006.202 NVMe detection after suspension (Fedora) (S3)
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SNV006.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SNV006.202 not supported
    Set Platform Sleep Type    S3
    Power On Ex    force_reboot=${TRUE}
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    NVMe Detection After Suspension    S3
    Exit From Root User


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
