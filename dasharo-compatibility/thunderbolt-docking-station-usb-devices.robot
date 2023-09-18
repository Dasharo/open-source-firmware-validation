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
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
TDU001.002 USB devices recognition (Ubuntu 22.04)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly in Linux OS.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_USB_SUPPORT}    TDU001.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TDU001.002 not supported
    Power On
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    SanDisk
    Exit From Root User

TDU001.003 USB devices recognition (Windows 11)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly in Windows OS.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_USB_SUPPORT}    TDU001.003 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TDU001.003 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
    Should Contain    ${out}    OK${SPACE*9}DiskDrive${SPACE*8}USB${SPACE*2}SanDisk

TDU002.002 USB keyboard detection (Ubuntu 22.04)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly by the Linux OS.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_KEYBOARD_SUPPORT}    TDU002.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TDU002.002 not supported
    Power On
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${DEVICE_USB_KEYBOARD}
    Exit From Root User

TDU002.003 USB keyboard detection (Windows 11)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly by the Windows OS.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_KEYBOARD_SUPPORT}    TDU002.003 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TDU002.003 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    Get-CimInstance win32_KEYBOARD
    Should Contain    ${out}    Description${SPACE*17}: USB Input Device    strip_spaces=True

TDU003.001 Upload 1GB file on USB storage (Ubuntu 22.04)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage connected to the docking station.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_UPLOAD_SUPPORT}    TDU003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TDU003.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Execute Linux Command    openssl rand -out test_file.txt -base64 $(( 2**30 * 3/4 ))
    ${path_to_usb}=    Identify Path To USB
    Execute Linux Command    cp test_file.txt ${path_to_usb}    120
    Check If Files Are Identical In Linux    test_file.txt    ${path_to_usb}/test_file.txt
    Execute Linux Command    rm test_file.txt ${path_to_usb}/test_file.txt
    Exit From Root User

TDU003.002 Upload 1GB file on USB storage (Windows 11)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage connected to the docking station.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_UPLOAD_SUPPORT}    TDU003.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TDU003.002 not supported
    Power On
    Login To Windows
    Generate 1GB File In Windows
    # Work only with one attached USB storage
    ${drive_letter}=    Get Drive Letter Of USB
    Execute Command In Terminal    Copy-Item -Path C:\\Users\\user\\test_file.txt ${drive_letter}:
    ${hash1}=    Get Hash Of File    test_file.txt
    ${hash2}=    Get Hash Of File    ${drive_letter}:\\test_file.txt
    Execute Command In Terminal    Remove-Item -Path C:\\Users\\user\\test_file.txt
    Execute Command In Terminal    Remove-Item -Path ${drive_letter}:\\test_file.txt
    Should Be Equal    ${hash1}    ${hash2}
