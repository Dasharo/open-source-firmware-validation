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
Resource            ../lib/custom_bootentries.robot

# Required setup keywords:
# Prepare Test Suite - elementary setup keyword for all tests.
# Required teardown keywords:
# Log Out And Close Connection - elementary teardown keyword for all tests.
Suite Setup         Run Keyword
...                     Prepare USB HID Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
USB001.001 USB devices detected in FW
    [Documentation]    Check whether USB devices are detected in Tianocore
    ...    (edk2).
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Depends On    ${USB_DISKS_DETECTION_SUPPORT}
    Depends On    ${HAS_USB_STORAGE}
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Check USB Stick Detection In Edk2    ${boot_menu}

USB002.001 USB keyboard detected in FW
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the firmware and all basic keys work
    ...    according to their labels.
    [Tags]    automated    minimal-regression
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Depends On    ${HAS_KEYBOARD}
    Deploy Uefi Shell
    Power On
    Enter UEFI Shell
    ${out}=    Execute UEFI Shell Command    devices
    Should Contain    ${out}    Usb Keyboard

USB001.201 USB devices detected by OS (Ubuntu)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in Ubuntu OS.
    ...    Previous IDs: USB001.002
    Depends On    ${USB_DISKS_DETECTION_SUPPORT}
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    USB Devices Detected By OS    ${ENV_ID_UBUNTU}

USB001.401 USB devices detection in OS (ESXi)
    [Documentation]    Check whether USB devices are correctly detected
    ...    in VMware ESXi using lsusb monitoring.
    ...    Previous IDs: USB001.011
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    USB001.401 not supported
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Boot And Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    lsusb
    Should Contain    ${out}    ${USB_MODEL}

USB002.201 USB keyboard in OS (Ubuntu)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the Ubuntu OS.
    ...    Previous IDs: USB002.002
    Depends On    ${USB_KEYBOARD_DETECTION_SUPPORT}
    Depends On    ${HAS_KEYBOARD}
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    USB Keyboard In OS    ${ENV_ID_UBUNTU}

USB003.201 Upload 1GB file on USB storage (Ubuntu)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage.
    ...    Previous IDs: USB003.002
    Depends On    ${UPLOAD_ON_USB_SUPPORT}
    Depends On    ${HAS_USB_STORAGE}
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Upload 1GB File On USB Storage    ${ENV_ID_UBUNTU}

USB001.202 USB devices detected by OS (Fedora)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in Fedora OS.
    Depends On    ${USB_DISKS_DETECTION_SUPPORT}
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    USB Devices Detected By OS    ${ENV_ID_FEDORA}

USB002.202 USB keyboard in OS (Fedora)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the Fedora OS.
    Depends On    ${USB_KEYBOARD_DETECTION_SUPPORT}
    Depends On    ${HAS_KEYBOARD}
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    USB Keyboard In OS    ${ENV_ID_FEDORA}

USB002.401 USB keyboard detection in OS (ESXi)
    [Documentation]    Verify that an external USB keyboard is correctly detected in ESXi.
    ...    Detection includes visibility in `lsusb` and verification of working input via basic typing test.
    ...    Previous IDs: USB002.011
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    USB002.401 not supported
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Boot And Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    lsusb
    Should Contain    ${out}    ${DEVICE_USB_KEYBOARD}

USB003.202 Upload 1GB file on USB storage (Fedora)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage.
    Depends On    ${UPLOAD_ON_USB_SUPPORT}
    Depends On    ${HAS_USB_STORAGE}
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Upload 1GB File On USB Storage    ${ENV_ID_FEDORA}

USB001.205 USB devices detected by OS (XCP-NG)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in XCP-NG.
    ...    Previous IDs: USB001.010
    Depends On    ${USB_DISKS_DETECTION_SUPPORT}
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot And Login To OS    ${ENV_ID_XCP_NG}
    ${out}=    Execute Command In Terminal    lsusb -v | grep bInterfaceClass
    IF    ${HAS_KEYBOARD}    Should Contain    ${out}    Human Interface Device
    IF    ${HAS_USB_STORAGE}    Should Contain    ${out}    Mass Storage

USB002.205 USB keyboard in OS (XCP-NG)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the XCP-NG.
    ...    Previous IDs: USB002.010
    Depends On    ${USB_KEYBOARD_DETECTION_SUPPORT}
    Depends On    ${HAS_KEYBOARD}
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot And Login To OS    ${ENV_ID_XCP_NG}
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${DEVICE_USB_KEYBOARD}

USB003.205 Upload 1GB file on USB storage (XCP-NG)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage.
    ...    Previous IDs: USB003.010
    Depends On    ${UPLOAD_ON_USB_SUPPORT}
    Depends On    ${HAS_USB_STORAGE}
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot And Login To OS    ${ENV_ID_XCP_NG}
    Execute Linux Command    openssl rand -out test_file.txt -base64 $(( 2**30 * 3/4 ))
    ${path_to_usb}=    Identify Path To USB
    Execute Linux Command    mount ${path_to_usb} /mnt
    Execute Linux Command    yes | cp -f test_file.txt /mnt    120
    Execute Linux Command    sync    120
    Check If Files Are Identical In Linux    test_file.txt    /mnt/test_file.txt
    Execute Linux Command    yes | rm test_file.txt /mnt/test_file.txt
    Execute Linux Command    sync && umount ${path_to_usb}    120

USB001.301 USB devices detected by OS (Windows)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in Windows OS.
    ...    Previous IDs: USB001.003
    Depends On    ${USB_DISKS_DETECTION_SUPPORT}
    Depends On    ${TESTS_IN_WINDOWS_SUPPORT}
    Power On
    Boot And Login To Windows
    ${out}=    Execute Command In Terminal
    ...    Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
    IF    ${HAS_KEYBOARD}    Should Contain    ${out}    HIDClass
    IF    ${HAS_USB_STORAGE}    Should Contain    ${out}    DiskDrive

USB002.301 USB keyboard in OS (Windows)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the Windows OS.
    ...    Previous IDs: USB002.003
    Depends On    ${USB_KEYBOARD_DETECTION_SUPPORT}
    Depends On    ${HAS_KEYBOARD}
    Depends On    ${TESTS_IN_WINDOWS_SUPPORT}
    Power On
    Boot And Login To Windows
    ${out}=    Execute Command In Terminal    Get-CimInstance win32_KEYBOARD
    ${keyboard}=    Get Lines Matching Regexp    ${out}    ^CreationClassName\\s+:\\sWin32_Keyboard.*$
    Should Not Be Empty    ${keyboard}

USB003.301 Upload 1GB file on USB storage (Windows)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage.
    ...    Previous IDs: USB003.003
    Depends On    ${UPLOAD_ON_USB_SUPPORT}
    Depends On    ${HAS_USB_STORAGE}
    Depends On    ${TESTS_IN_WINDOWS_SUPPORT}
    Power On
    Boot And Login To Windows
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

USB001.203 USB devices detected by OS (QubesOS)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    USB001.203 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    ${out}=    Execute Linux Command    qvm-usb
    Should Contain    ${out}    ${USB_MODEL}

USB002.203 USB keyboard detected by OS (QubesOS)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    USB02.203 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    ${out}=    Execute Linux Command    qvm-usb
    Should Contain    ${out}    ${DEVICE_USB_KEYBOARD}


*** Keywords ***
Prepare USB HID Test Suite
    [Documentation]    Prepare this test suite
    Prepare Test Suite
    IF    "${DEVICE_USB_KEYBOARD}" != "${EMPTY}" or "${DUT_CONNECTION_METHOD}" == "pikvm"
        VAR    ${HAS_KEYBOARD}=    ${TRUE}    scope=SUITE
    ELSE
        VAR    ${HAS_KEYBOARD}=    ${FALSE}    scope=SUITE
    END

    IF    "${DUT_CONNECTION_METHOD}" == "pikvm"
        Mount USB Disk Image    ${TEST_DATA_DIR}/secure-boot/sb_test_data.img
    END

    # Assume for now that we always have USB storage attached. In fact, all of
    # the platforms as of today should have the USB drive with DTS attached.
    # Refer to the lib/usb-hid-msc-lib.robot
    VAR    ${HAS_USB_STORAGE}=    ${TRUE}    scope=SUITE
    Skip If    not ${HAS_KEYBOARD} and not ${HAS_USB_STORAGE}
    ...    Platform doesn't have USB keyboard or USB storage attached

USB Devices Detected By OS
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in Linux OS.
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User

    ${out}=    Execute Command In Terminal    lsusb -v | grep bInterfaceClass
    IF    ${HAS_KEYBOARD}    Should Contain    ${out}    Human Interface Device
    IF    ${HAS_USB_STORAGE}    Should Contain    ${out}    Mass Storage
    Exit From Root User

USB Keyboard In OS
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the Linux OS.
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${DEVICE_USB_KEYBOARD}

Upload 1GB File On USB Storage
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage.
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    Execute Linux Command    openssl rand -out test_file.txt -base64 $(( 2**30 * 3/4 ))
    ${path_to_usb}=    Identify Path To USB
    Execute Linux Command    mount ${path_to_usb} /mnt
    Execute Linux Command    yes | cp -f test_file.txt /mnt    120
    Execute Linux Command    sync    120
    Check If Files Are Identical In Linux    test_file.txt    /mnt/test_file.txt
    Execute Linux Command    yes | rm test_file.txt /mnt/test_file.txt
    Execute Linux Command    sync && umount ${path_to_usb}    120
    Exit From Root User
