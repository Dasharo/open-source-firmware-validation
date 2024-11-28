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
Resource            ../pikvm-rest-api/pikvm_comm.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# Required setup keywords:
# Prepare Test Suite - elementary setup keyword for all tests.
# Required teardown keywords:
# Log Out And Close Connection - elementary teardown keyword for all tests.
Suite Setup         Run Keyword
...                     Prepare USB HID Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
USB001.001 USB devices detected in FW
    [Documentation]    Check whether USB devices are detected in Tianocore
    ...    (edk2).
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Depends On    ${USB_DISKS_DETECTION_SUPPORT}
    Depends On    ${HAS_USB_STORAGE}
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Check USB Stick Detection in Edk2    ${boot_menu}

USB001.002 USB devices detected by OS (Ubuntu)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in Linux OS.
    Depends On    ${USB_DISKS_DETECTION_SUPPORT}
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    usbutils
    ${out}=    Execute Command In Terminal    lsusb -v | grep bInterfaceClass
    IF    ${HAS_KEYBOARD}    Should Contain    ${out}    Human Interface Device
    IF    ${HAS_USB_STORAGE}    Should Contain    ${out}    Mass Storage
    Exit From Root User

USB001.003 USB devices detected by OS (Windows)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in Windows OS.
    Depends On    ${USB_DISKS_DETECTION_SUPPORT}
    Depends On    ${TESTS_IN_WINDOWS_SUPPORT}
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal
    ...    Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
    IF    ${HAS_KEYBOARD}    Should Contain    ${out}    HIDClass
    IF    ${HAS_USB_STORAGE}    Should Contain    ${out}    DiskDrive

USB002.001 USB keyboard detected in FW
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the firmware and all basic keys work
    ...    according to their labels.
    [Tags]    minimal-regression
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Depends On    ${HAS_KEYBOARD}
    Power On
    Enter UEFI Shell
    ${out}=    Execute UEFI Shell Command    devices
    Should Contain    ${out}    Usb Keyboard

USB002.002 USB keyboard in OS (Ubuntu)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the Linux OS.
    Depends On    ${USB_KEYBOARD_DETECTION_SUPPORT}
    Depends On    "${DEVICE_USB_KEYBOARD}" == "${EMPTY}"
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${DEVICE_USB_KEYBOARD}

USB002.003 USB keyboard in OS (Windows)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the Windows OS.
    Depends On    ${USB_KEYBOARD_DETECTION_SUPPORT}
    Depends On    ${HAS_KEYBOARD}
    Depends On    ${TESTS_IN_WINDOWS_SUPPORT}
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    Get-CimInstance win32_KEYBOARD
    ${keyboard}=    Get Lines Matching Regexp    ${out}    ^CreationClassName\\s+:\\sWin32_Keyboard.*$
    Should Not Be Empty    ${keyboard}

USB003.001 Upload 1GB file on USB storage (Ubuntu)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage.
    Depends On    ${UPLOAD_ON_USB_SUPPORT}
    Depends On    ${HAS_USB_STORAGE}
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Execute Linux Command    openssl rand -out test_file.txt -base64 $(( 2**30 * 3/4 ))
    ${path_to_usb}=    Identify Path To USB
    Execute Linux Command    cp test_file.txt ${path_to_usb}    120
    Check If Files Are Identical In Linux    test_file.txt    ${path_to_usb}/test_file.txt
    Execute Linux Command    rm test_file.txt ${path_to_usb}/test_file.txt
    Exit From Root User

USB003.002 Upload 1GB file on USB storage (Windows)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage.
    Depends On    ${UPLOAD_ON_USB_SUPPORT}
    Depends On    ${HAS_USB_STORAGE}
    Depends On    ${TESTS_IN_WINDOWS_SUPPORT}
    Power On
    Login To Windows
    Generate 1GB File In Windows
    # Work only with one attached USB storage
    ${drive_letter}=    Get Drive Letter Of USB
    Execute Command In Terminal
    ...    Copy-Item -Path C:\\Users\\user\\test_file.txt ${drive_letter}:    120
    ${hash1}=    Get Hash Of File    test_file.txt
    ${hash2}=    Get Hash Of File    ${drive_letter}:\\test_file.txt
    Execute Command In Terminal    Remove-Item -Path C:\\Users\\user\\test_file.txt
    Execute Command In Terminal
    ...    Remove-Item -Path ${drive_letter}:\\test_file.txt    120
    Should Be Equal    ${hash1}    ${hash2}


*** Keywords ***
Prepare USB HID Test Suite
    [Documentation]    Prepare this test suite
    Prepare Test Suite
    IF    "${DEVICE_USB_KEYBOARD}" != "${EMPTY}" or "${DUT_CONNECTION_METHOD}" == "pikvm"
        Set Suite Variable    $HAS_KEYBOARD    ${TRUE}
    ELSE
        Set Suite Variable    $HAS_KEYBOARD    ${FALSE}
    END
    ${conf}=    Get Current CONFIG    ${CONFIG_LIST}
    ${has_storage}=    Evaluate    "USB_Storage" in """${conf}"""
    IF    "${DUT_CONNECTION_METHOD}" == "pikvm"
        Upload And Mount DTS Flash Iso
        ${has_storage}=    Set Variable    ${TRUE}
    END
    IF    "${ATTACHED_USB}" != "${EMPTY}" or ${has_storage}
        Set Suite Variable    $HAS_USB_STORAGE    ${TRUE}
    ELSE
        Set Suite Variable    $HAS_USB_STORAGE    ${FALSE}
    END
    Skip If    not ${HAS_KEYBOARD} and not ${HAS_USB_STORAGE}
    ...    Platform doesn't have USB keyboard or USB storage attached
