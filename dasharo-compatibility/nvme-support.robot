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
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
# NVM001.001 NVMe support in firmware
#    [Documentation]    Check whether the firmware is able to correctly detect
#    ...    NVMe disk in M.2 slot.
#    Skip If    not ${nvme_disk_support}    NVM001.001 not supported
#    Power On
#    Enter Tianocore
#    Telnet.Set Timeout    30s
#    Enter One Time Boot in Tianocore
#    Telnet.Read Until    ${clevo_disk}

NVM001.002 NVMe support in OS (Ubuntu 20.04)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    Skip If    not ${nvme_disk_support}    NVM001.002 not supported
    Skip If    not ${tests_in_ubuntu_support}    NVM001.002 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    pci
    Should Contain    ${out}    ${device_nvme_disk}
    Exit from root user

NVM001.003 NVMe support in OS (Windows 10)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    Skip If    not ${nvme_disk_support}    NVM001.003 not supported
    Skip If    not ${tests_in_windows_support}    NVM001.003 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    # Switch to root user
    ${out}=    Execute Command in Terminal    Get-PnpDevice -Status "OK" | where { $_.InstanceId -like "*NVME*"}
    Should Contain    ${out}    DiskDrive
    # Exit from root user
