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

Default Tags        automated


*** Test Cases ***
NVM001.001 NVMe support in firmware
    [Documentation]    Check whether the firmware is able to correctly detect
    ...    NVMe disk in M.2 slot.
    Depends On    ${NVME_DISK_SUPPORT}
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Power On
    ${out}=    Enter Boot Menu Tianocore And Return Construction
    ${ssd_list}=    Get Current CONFIG List Element    Storage_SSD
    ${ssd_list_length}=    Get Length    ${ssd_list}
    IF    ${ssd_list_length} == 0    Fail    No SSD disks connected
    FOR    ${disk}    IN    @{ssd_list}
        IF    '${disk.interface}' == 'NVME'
            ${found}=    Evaluate    '${disk.boot_name}' in ${out}
            IF    ${found}    BREAK
        END
    END
    Should Be True    ${found}    None of the connected disks is visible in boot menu

NVM001.201 NVMe support in OS (Ubuntu)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    ...    Previous IDs: NVM001.002
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    NVM001.201 not supported
    NVMe Support In OS    ${ENV_ID_UBUNTU}

NVM001.202 NVMe support in OS (Fedora)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    NVM001.202 not supported
    NVMe Support In OS    ${ENV_ID_FEDORA}

NVM001.205 NVMe support in OS (XCP-NG)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    ...    Previous IDs: NVM001.010
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    NVM001.202 not supported
    Power On
    Boot And Login To OS    ${ENV_ID_XCP_NG}
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}

NVM001.301 NVMe support in OS (Windows)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    ...    Previous IDs: NVM001.003
    Depends On    ${TESTS_IN_WINDOWS_SUPPORT}
    Power On
    Login To Windows
    # Switch to root user
    ${out}=    Execute Command In Terminal    Get-PnpDevice -Status "OK" | where { $_.InstanceId -like "*NVME*"}
    Should Contain    ${out}    DiskDrive
    # Exit from root user
    Execute Shutdown Command

NVM001.401 NVMe support in OS (ESXi)
    [Documentation]    Verify that ESXi is installed and booted from an NVMe drive.
    ...    Check that NVMe is detected and marked as the boot device.
    ...    Previous IDs: NVM001.011
    Depends On    ${TESTS_IN_ESXI_SUPPORT}
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Boot And Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli storage core nvme device list
    Should Contain All    ${out}    Vendor: NVMe    Is Boot Device: true

NVM002.201 NVMe slot change to x2 support in OS (Ubuntu)
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Depends On    ${NVME_X2_SLOT_SUPPORT}
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    NVM001.201 not supported
    NVMe Slot Change Support In OS    ${ENV_ID_UBUNTU}


*** Keywords ***
NVMe Support In OS
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}
    Exit From Root User

NVMe Slot Change Support In OS
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    lspci -vvv
    @{lines}=    Split To Lines    ${out}
    VAR    ${found}=    False
    FOR    ${line}    IN    @{lines}
        ${match}=    Evaluate    __import__('re').search(r"Speed \\d+GT/s.*Width x2", """${line}""")
        IF    ${match}
            VAR    ${found}=    True
        END
    END
    Should Be True    ${found}
