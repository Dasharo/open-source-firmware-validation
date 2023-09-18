*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


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
#    FOR    ${INDEX}    IN RANGE    0    ${nvme_detection_iterations}
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
#    FOR    ${INDEX}    IN RANGE    0    ${nvme_detection_iterations}
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
    Skip If    not ${nvme_detection_support}    SNV003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SNV003.001 not supported
    Power On
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    pci
    Should Contain    ${out}    ${device_nvme_disk}
    FOR    ${INDEX}    IN RANGE    0    ${nvme_detection_iterations}
        Write Into Terminal    reboot
        Sleep    60s
        Login to Linux
        Switch to root user
        ${out}=    List devices in Linux    pci
        Should Contain    ${out}    ${device_nvme_disk}
    END

SNV004.001 NVMe detection after suspension (Ubuntu 22.04)
    [Documentation]    Check whether the NVMe disk is correctly detected after
    ...    performing suspension.
    Skip If    not ${nvme_detection_support}    SNV004.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SNV004.001 not supported
    Power On
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    pci
    Should Contain    ${out}    ${device_nvme_disk}
    Detect or install FWTS
    FOR    ${INDEX}    IN RANGE    0    ${nvme_detection_iterations}
        Perform suspend test using FWTS
        ${out}=    List devices in Linux    pci
        Should Contain    ${out}    ${device_nvme_disk}
    END
    Exit from root user
