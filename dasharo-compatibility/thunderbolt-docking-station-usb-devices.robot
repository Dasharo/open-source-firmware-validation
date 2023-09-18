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
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
TDU001.002 USB devices recognition (Ubuntu 22.04)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly in Linux OS.
    Skip If    not ${thunderbolt_docking_station_usb_support}    TDU001.002 not supported
    Skip If    not ${tests_in_ubuntu_support}    TDU001.002 not supported
    Power On
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    usb
    Should Contain    ${out}    SanDisk
    Exit from root user

TDU001.003 USB devices recognition (Windows 11)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly in Windows OS.
    Skip If    not ${thunderbolt_docking_station_usb_support}    TDU001.003 not supported
    Skip If    not ${tests_in_windows_support}    TDU001.003 not supported
    Power On
    Login to Windows
    ${out}=    Execute Command in Terminal    Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
    Should Contain    ${out}    OK${SPACE * 9}DiskDrive${SPACE * 8}USB${SPACE * 2}SanDisk

TDU002.002 USB keyboard detection (Ubuntu 22.04)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly by the Linux OS.
    Skip If    not ${thunderbolt_docking_station_keyboard_support}    TDU002.002 not supported
    Skip If    not ${tests_in_ubuntu_support}    TDU002.002 not supported
    Power On
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    usb
    Should Contain    ${out}    ${device_usb_keyboard}
    Exit from root user

TDU002.003 USB keyboard detection (Windows 11)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly by the Windows OS.
    Skip If    not ${thunderbolt_docking_station_keyboard_support}    TDU002.003 not supported
    Skip If    not ${tests_in_windows_support}    TDU002.003 not supported
    Power On
    Login to Windows
    ${out}=    Execute Command in Terminal    Get-CimInstance win32_KEYBOARD
    Should Contain    ${out}    Description${SPACE * 17}: USB Input Device    strip_spaces=True

TDU003.001 Upload 1GB file on USB storage (Ubuntu 22.04)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage connected to the docking station.
    Skip If    not ${thunderbolt_docking_station_upload_support}    TDU003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    TDU003.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Execute Linux command    openssl rand -out test_file.txt -base64 $(( 2**30 * 3/4 ))
    ${path_to_usb}=    Identify Path To USB
    Execute Linux command    cp test_file.txt ${path_to_usb}    120
    Check if files are identical in Linux    test_file.txt    ${path_to_usb}/test_file.txt
    Execute Linux command    rm test_file.txt ${path_to_usb}/test_file.txt
    Exit from root user

TDU003.002 Upload 1GB file on USB storage (Windows 11)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage connected to the docking station.
    Skip If    not ${thunderbolt_docking_station_upload_support}    TDU003.002 not supported
    Skip If    not ${tests_in_windows_support}    TDU003.002 not supported
    Power On
    Login to Windows
    Generate 1GB File in Windows
    # Work only with one attached USB storage
    ${drive_letter}=    Get Drive Letter Of USB
    Execute Command in Terminal    Copy-Item -Path C:\\Users\\user\\test_file.txt ${drive_letter}:
    ${hash1}=    Get Hash Of File    test_file.txt
    ${hash2}=    Get Hash Of File    ${drive_letter}:\\test_file.txt
    Execute Command in Terminal    Remove-Item -Path C:\\Users\\user\\test_file.txt
    Execute Command in Terminal    Remove-Item -Path ${drive_letter}:\\test_file.txt
    Should Be Equal    ${hash1}    ${hash2}
