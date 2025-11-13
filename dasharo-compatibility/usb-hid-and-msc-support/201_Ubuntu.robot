*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     USB Suite Setup
...                     AND    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
...                     AND    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    Ubuntu not supported
...                     AND    Init USB Ubuntu
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
USB001.201 USB devices detected by OS (Ubuntu)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in Ubuntu OS.
    ...    Previous IDs: USB001.002
    Depends On    ${USB_DISKS_DETECTION_SUPPORT}
    Check USB Devices Detected Linux

USB002.201 USB keyboard in OS (Ubuntu)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the Ubuntu OS.
    ...    Previous IDs: USB002.002
    Depends On    ${USB_KEYBOARD_DETECTION_SUPPORT}
    Depends On    ${HAS_KEYBOARD}
    Check USB Keyboard Detection Linux

USB003.201 Upload 1GB file on USB storage (Ubuntu)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage.
    ...    Previous IDs: USB003.002
    Depends On    ${UPLOAD_ON_USB_SUPPORT}
    Depends On    ${HAS_USB_STORAGE}
    Check Upload 1GB File On USB Storage Linux


*** Keywords ***
Init USB Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
