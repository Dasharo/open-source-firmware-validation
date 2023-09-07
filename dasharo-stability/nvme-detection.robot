*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
# Tests will work on laptops with access to the serial console and possibility
# of remote power control
# SNV0001.001 NVMe detection after cold boot (Ubuntu 22.04)
#    [Documentation]    Check whether the NVMe disk is detected and working
#    ...    correctly after performing a cold boot.
#    Skip If    not ${nvme_detection_support}    SNV001.001 not supported
#    Skip If    not ${tests_in_ubuntu_support}    SNV001.001 not supported
#    Power On
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

# SNV0002.001 NVMe detection after warm boot (Ubuntu 22.04)
#    [Documentation]    Check whether the NVMe disk is detected and working
#    ...    correctly after performing a warm boot.
#    Skip If    not ${nvme_detection_support}    SNV002.001 not supported
#    Skip If    not ${tests_in_ubuntu_support}    SNV002.001 not supported
#    Power On
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    List devices in Linux    pci
#    Should Contain    ${out}    ${device_nvme_disk}
#    FOR    ${INDEX}    IN RANGE    0    ${stability_detection_warmboot_iterations}
#    Power On
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    List devices in Linux    pci
#    Should Contain    ${out}    ${device_nvme_disk}
#    END
#    Exit from root user

SNV003.001 NVMe detection after reboot (Ubuntu 22.04)
    [Documentation]    Check whether the NVMe disk is detected and working
    ...    correctly after performing a reboot.
    Skip If    not ${NVME_DETECTION_SUPPORT}    SNV003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SNV003.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}
    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Execute Reboot Command
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${out}=    List Devices In Linux    pci
        Should Contain    ${out}    ${DEVICE_NVME_DISK}
    END

SNV004.001 NVMe detection after suspension (Ubuntu 22.04)
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    Skip If    not ${NVME_DETECTION_SUPPORT}    SNV004.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SNV004.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu Login to Linux
    Switch To Root User
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}
    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_SUSPEND_ITERATIONS}
        Perform Suspend Test Using FWTS
        ${out}=    List Devices In Linux    pci
        Should Contain    ${out}    ${DEVICE_NVME_DISK}
    END
    Exit From Root User
