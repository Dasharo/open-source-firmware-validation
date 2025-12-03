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
...                     Skip If    not ${SD_CARD_READER_SUPPORT}    SD card reader tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
SDC001.201 SD Card reader detection (Ubuntu)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    ...    Previous IDs: SDC001.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SDC001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SDC001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${disks}=    Identify Disks In Linux
    Should Match    str(${disks})    *SD*
    Exit From Root User

SDC002.201 SD Card read/write (Ubuntu)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    ...    Previous IDs: SDC002.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SDC002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SDC002.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Execute Linux Command    dd if=/dev/urandom of=/tmp/in.bin bs=4K count=100
    Execute Linux Command    dd if=/tmp/in.bin of=/dev/mmcblk0 bs=4K count=100
    Execute Linux Command    dd if=/dev/mmcblk0 of=/tmp/out.bin bs=4K count=100
    ${result}=    Check If Files Are Identical In Linux    /tmp/in.bin    /tmp/out.bin
    Should Be True    ${result}
    Exit From Root User

SDC001.202 SD Card reader detection (Fedora)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SDC001.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    ${disks}=    Identify Disks In Linux
    Should Match    str(${disks})    *SD*
    Exit From Root User

SDC002.202 SD Card read/write (Fedora)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SDC002.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Execute Linux Command    dd if=/dev/urandom of=/tmp/in.bin bs=4K count=100
    Execute Linux Command    dd if=/tmp/in.bin of=/dev/mmcblk0 bs=4K count=100
    Execute Linux Command    dd if=/dev/mmcblk0 of=/tmp/out.bin bs=4K count=100
    ${result}=    Check If Files Are Identical In Linux    /tmp/in.bin    /tmp/out.bin
    Should Be True    ${result}
    Exit From Root User

SDC001.301 SD Card reader detection (Windows)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    ...    Previous IDs: SDC001.002
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SDC001.301 not supported
    Power On
    Login To Windows
    # Switch to root user
    ${out}=    Execute Command In Terminal    Get-PnpDevice -Status "OK" -Class "DiskDrive"
    Should Contain    ${out}    DiskDrive
    # Exit from root user
    Execute Shutdown Command

SDC002.301 SD Card read/write (Windows)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    ...    Previous IDs: SDC002.002
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SDC002.301 not supported
    Power On
    Login To Windows
    SSHLibrary.Put File    drive_letters.ps1    /C:/Users/user
    ${drive_letter}=    Identify Path To SD Card In Windows
    Check Read Write To External Drive In Windows    ${drive_letter}
    Execute Shutdown Command

SDC001.203 SD Card reader detection (QubesOS)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${TESTS_IN_QUBESOS_SUPPORT}    SDC001.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SDC001.203 not supported
    Login To OS    ${ENV_ID_QUBES}
    ${disks}=    Identify Disks In QubesOS
    Should Match    str(${disks})    *SD*

SDC002.203 SD Card read/write (QubesOS)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${TESTS_IN_QUBESOS_SUPPORT}    SDC001.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SDC001.203 not supported
    Login To OS    ${ENV_ID_QUBES}
    Execute Linux Command    sudo dd if=/dev/urandom of=/tmp/in.bin bs=4K count=100
    Execute Linux Command    sudo dd if=/tmp/in.bin of=/dev/mmcblk0 bs=4K count=100
    Execute Linux Command    sudo dd if=/dev/mmcblk0 of=/tmp/out.bin bs=4K count=100
    ${result}=    Check If Files Are Identical In Linux    /tmp/in.bin    /tmp/out.bin
    Should Be True    ${result}


*** Keywords ***
Identify Disks In QubesOS
    [Documentation]    Check whether any disk is recognized in Linux system
    ...    and identify their vndor and model.
    ${out}=    Execute Linux Command    lsblk --nodeps --output NAME
    @{disks}=    Get Regexp Matches    ${out}    sd.|mmcblk.
    VAR    @{disks_info}=    @{EMPTY}
    FOR    ${disk}    IN    @{disks}
        ${vendor}=    Execute Linux Command    sudo cat /sys/class/block/${disk}/device/vendor
        ${model}=    Execute Linux Command    sudo cat /sys/class/block/${disk}/device/model
        ${type}=    Execute Linux Command    sudo cat /sys/class/block/${disk}/device/type
        ${vendor_name}=    Fetch From Left    ${vendor}    \r\n
        ${model_name}=    Fetch From Left    ${model}    \r\n
        ${vendor_name}=    Fetch From Right    ${vendor_name}    \r
        ${model_name}=    Fetch From Right    ${model_name}    \r
        # ${vendor_name}=    Fetch From Left    ${vendor_name}    \x20
        # ${model_name}=    Fetch From Left    ${model_name}    \x20
        Append To List    ${disks_info}    ${disk}
        Append To List    ${disks_info}    ${type}
        Append To List    ${disks_info}    ${vendor_name}
        Append To List    ${disks_info}    ${model_name}
    END
    RETURN    ${disks_info}
