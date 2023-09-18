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
SDC001.001 SD Card reader detection (Ubuntu 20.04)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${sd_card_reader_support}    SDC001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SDC001.001 not supported
    Power On
    Login to Linux
    Switch to root user
    ${disks}=    Identify Disks in Linux
    Should Contain    ${disks}    ${sd_card_vendor}
    Should Contain    ${disks}    ${sd_card_model}
    Exit from root user

SDC001.002 SD Card reader detection (Windows 11)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${sd_card_reader_support}    SDC001.001 not supported
    Skip If    not ${tests_in_windows_support}    SDC001.001 not supported
    Power On
    Login to Windows
    # Switch to root user
    ${out}=    Execute Command in Terminal    Get-PnpDevice -Status "OK" -Class "DiskDrive"
    Should Contain    ${out}    DiskDrive
    # Exit from root user

SDC002.001 SD Card read/write (Ubuntu 20.04)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${sd_card_reader_support}    SDC002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SDC002.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Execute Linux command    dd if=/dev/urandom of=/tmp/in.bin bs=4K count=100
    Execute Linux command    dd if=/tmp/in.bin of=/dev/mmcblk0 bs=4K count=100
    Execute Linux command    dd if=/dev/mmcblk0 of=/tmp/out.bin bs=4K count=100
    ${result}=    Check if files are identical in Linux    /tmp/in.bin    /tmp/out.bin
    Should Be True    ${result}
    Exit from root user

SDC002.002 SD Card read/write (Windows 11)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${sd_card_reader_support}    SDC002.001 not supported
    Skip If    not ${tests_in_windows_support}    SDC002.001 not supported
    Power On
    ${out}=    Run
    ...    sshpass -p ${device_windows_password} scp drive_letters.ps1 ${device_windows_username}@${device_ip}:/C:/Users/user
    Should Be Empty    ${out}
    Login to Windows
    ${drive_letter}=    Identify Path To SD Card in Windows
    Check Read Write To External Drive in Windows    ${drive_letter}
