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


*** Test Cases ***
SDC001.001 SD Card reader detection (Ubuntu)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SDC001.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${disks}=    Identify Disks In Linux
    Should Match    str(${disks})    *SD*
    Exit From Root User

SDC001.002 SD Card reader detection (Windows)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SDC001.001 not supported
    Power On
    Login To Windows
    # Switch to root user
    ${out}=    Execute Command In Terminal    Get-PnpDevice -Status "OK" -Class "DiskDrive"
    Should Contain    ${out}    DiskDrive
    # Exit from root user

SDC002.001 SD Card read/write (Ubuntu)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SDC002.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Execute Linux Command    dd if=/dev/urandom of=/tmp/in.bin bs=4K count=100
    Execute Linux Command    dd if=/tmp/in.bin of=/dev/mmcblk0 bs=4K count=100
    Execute Linux Command    dd if=/dev/mmcblk0 of=/tmp/out.bin bs=4K count=100
    ${result}=    Check If Files Are Identical In Linux    /tmp/in.bin    /tmp/out.bin
    Should Be True    ${result}
    Exit From Root User

SDC002.002 SD Card read/write (Windows)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SDC002.001 not supported
    Power On
    SSHLibrary.Put File    drive_letters.ps1    /C:/Users/user
    Login To Windows
    ${drive_letter}=    Identify Path To SD Card In Windows
    Check Read Write To External Drive In Windows    ${drive_letter}
