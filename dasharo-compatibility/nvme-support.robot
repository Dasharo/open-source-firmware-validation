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
NVM001.001 NVMe support in firmware
    [Documentation]    Check whether the firmware is able to correctly detect
    ...    NVMe disk in M.2 slot.
    Skip If    not ${NVME_DISK_SUPPORT}    NVM001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}
    Power On
    ${out}=    Enter Boot Menu Tianocore And Return Construction
    Should Contain    ${out}    ${CLEVO_DISK}

NVM001.201 NVMe support in OS (Ubuntu)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NVM001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    NVM001.201 not supported
    NVMe Support In OS    ${ENV_ID_UBUNTU}

NVM001.202 NVMe support in OS (Fedora)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    NVM001.202 not supported
    NVMe Support In OS    ${ENV_ID_FEDORA}

NVM001.301 NVMe support in OS (Windows)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    NVM001.301 not supported
    Power On
    Login To Windows
    # Switch to root user
    ${out}=    Execute Command In Terminal    Get-PnpDevice -Status "OK" | where { $_.InstanceId -like "*NVME*"}
    Should Contain    ${out}    DiskDrive
    # Exit from root user


*** Keywords ***
NVMe Support In OS
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    [Tags]    robot:private
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}
    Exit From Root User
