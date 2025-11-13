*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     USB Suite Setup
...                     AND    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    Fedora not supported
...                     AND    Init USB Fedora
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
USB001.202 USB devices detected by OS (Fedora)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in Fedora OS.
    Depends On    ${USB_DISKS_DETECTION_SUPPORT}
    Check USB Devices Detected Linux

USB002.202 USB keyboard in OS (Fedora)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the Fedora OS.
    Depends On    ${USB_KEYBOARD_DETECTION_SUPPORT}
    Depends On    ${HAS_KEYBOARD}
    Check USB Keyboard Detection Linux

USB003.202 Upload 1GB file on USB storage (Fedora)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage.
    Depends On    ${UPLOAD_ON_USB_SUPPORT}
    Depends On    ${HAS_USB_STORAGE}
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Check Upload 1GB File On USB Storage Linux


*** Keywords ***
Init USB Fedora
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
