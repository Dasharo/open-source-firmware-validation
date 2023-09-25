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
Resource            ../pikvm-rest-api/pikvm_comm.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# Required setup keywords:
# Prepare Test Suite - elementary setup keyword for all tests.
# Required teardown keywords:
# Log Out And Close Connection - elementary teardown keyword for all tests.
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
USB001.001 USB devices detected in FW
    [Documentation]    Check whether USB devices are detected in Tianocore
    ...    (edk2).
    Skip If    not ${USB_DISKS_DETECTION_SUPPORT}    USB001.001 not supported
    Upload And Mount DTS Flash Iso
    Power On
    Enter Boot Menu Tianocore
    Check That USB Devices Are Detected    ${TRUE}

USB001.002 USB devices detected by OS (Ubuntu 20.04)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in Linux OS.
    Skip If    not ${USB_DISKS_DETECTION_SUPPORT}    USB001.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    USB001.002 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${USB_MODEL}
    Exit From Root User

USB001.003 USB devices detected by OS (Windows 10)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in Windows OS.
    Skip If    not ${USB_DISKS_DETECTION_SUPPORT}    USB001.003 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    USB001.003 not supported
    Power On
    Boot System Or From Connected Disk    ${OS_WINDOWS}
    Login To Windows
    ${out}=    Execute Command In Terminal    Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
    ${drives}=    Get Lines Matching Regexp    ${out}    ^OK\\s+DiskDrive\\s+.*$
    Should Contain    ${drives}    ${USB_MODEL}

USB002.001 USB keyboard detected in FW
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the firmware and all basic keys work
    ...    according to their labels.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Save Changes And Reset

USB002.002 USB keyboard in OS (Ubuntu 20.04)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the Linux OS and all basic keys work
    ...    according to their labels.
    IF    not ${USB_KEYBOARD_DETECTION_SUPPORT}
        SKIP    USB002.002 not supported
    END
    IF    not ${TESTS_IN_UBUNTU_SUPPORT}    SKIP    USB002.002 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${DEVICE_USB_KEYBOARD}

USB002.003 USB keyboard in OS (Windows 11)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the Windows OS.
    IF    not ${USB_KEYBOARD_DETECTION_SUPPORT}
        SKIP    USB002.003 not supported
    END
    IF    not ${TESTS_IN_WINDOWS_SUPPORT}    SKIP    USB002.003 not supported
    Power On
    Boot System Or From Connected Disk    ${OS_WINDOWS}
    Login To Windows
    ${out}=    Execute Command In Terminal    Get-CimInstance win32_KEYBOARD
    ${keyboard}=    Get Lines Matching Regexp    ${out}    ^CreationClassName\\s+:\\sWin32_Keyboard.*$
    Should Not Be Empty    ${keyboard}

# These does not work correctly and provide little value. Maybe fix them or
# propose more useful scenarios.
# USB003.001 Upload 1GB file on USB storage (Ubuntu 22.04)
#    [Documentation]    Check whether the 1GB file can be transferred from the
#    ...    operating system to the USB storage.
#    IF    not ${UPLOAD_ON_USB_SUPPORT}    SKIP    USB003.001 not supported
#    IF    not ${TESTS_IN_UBUNTU_SUPPORT}    SKIP    USB003.001 not supported
#    Power On
#    Boot System Or From Connected Disk    ubuntu
#    Login To Linux
#    Switch To Root User
#    Execute Linux Command    openssl rand -out test_file.txt -base64 $(( 2**30 * 3/4 ))
#    ${path_to_usb}=    Identify Path To USB
#    Execute Linux Command    cp test_file.txt ${path_to_usb}    120
#    Check If Files Are Identical In Linux    test_file.txt    ${path_to_usb}/test_file.txt
#    Execute Linux Command    rm test_file.txt ${path_to_usb}/test_file.txt
#    Exit From Root User
#
# USB003.002 Upload 1GB file on USB storage (Windows 11)
#    [Documentation]    Check whether the 1GB file can be transferred from the
#    ...    operating system to the USB storage.
#    IF    not ${UPLOAD_ON_USB_SUPPORT}    SKIP    USB003.002 not supported
#    IF    not ${TESTS_IN_WINDOWS_SUPPORT}    SKIP    USB003.002 not supported
#    Power On
#    Boot System Or From Connected Disk    ${OS_WINDOWS}
#    Login To Windows
#    Generate 1GB File In Windows
#    # Work only with one attached USB storage
#    ${drive_letter}=    Get Drive Letter Of USB
#    Execute Command In Terminal    Copy-Item -Path C:\\Users\\user\\test_file.txt ${drive_letter}:
#    ${hash1}=    Get Hash Of File    test_file.txt
#    ${hash2}=    Get Hash Of File    ${drive_letter}:\\test_file.txt
#    Execute Command In Terminal    Remove-Item -Path C:\\Users\\user\\test_file.txt
#    Execute Command In Terminal    Remove-Item -Path ${drive_letter}:\\test_file.txt
#    Should Be Equal    ${hash1}    ${hash2}
