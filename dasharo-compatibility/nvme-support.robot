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
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${NVME_DISK_SUPPORT}    NVMe disk tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


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

NVM001.002 NVMe support in OS (Ubuntu)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NVM001.002 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}
    Exit From Root User

NVM001.003 NVMe support in OS (Windows)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    NVM001.003 not supported
    Power On
    Login To Windows
    # Switch to root user
    ${out}=    Execute Command In Terminal    Get-PnpDevice -Status "OK" | where { $_.InstanceId -like "*NVME*"}
    Should Contain    ${out}    DiskDrive
    # Exit from root user
