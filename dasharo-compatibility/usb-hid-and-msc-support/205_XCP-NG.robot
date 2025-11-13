*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     USB Suite Setup
...                     AND    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    XCP-NG not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
USB001.205 USB devices detected by OS (XCP-NG)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in XCP-NG.
    ...    Previous IDs: USB001.010
    Depends On    ${USB_DISKS_DETECTION_SUPPORT}
    Power On
    Login To OS    ${ENV_ID_XCP_NG}
    ${out}=    Execute Command In Terminal    lsusb -v | grep bInterfaceClass
    IF    ${HAS_KEYBOARD}    Should Contain    ${out}    Human Interface Device
    IF    ${HAS_USB_STORAGE}    Should Contain    ${out}    Mass Storage

USB002.205 USB keyboard in OS (XCP-NG)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the XCP-NG.
    ...    Previous IDs: USB002.010
    Depends On    ${USB_KEYBOARD_DETECTION_SUPPORT}
    Depends On    ${HAS_KEYBOARD}
    Power On
    Login To OS    ${ENV_ID_XCP_NG}
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${DEVICE_USB_KEYBOARD}

USB003.205 Upload 1GB file on USB storage (XCP-NG)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage.
    ...    Previous IDs: USB003.010
    Depends On    ${UPLOAD_ON_USB_SUPPORT}
    Depends On    ${HAS_USB_STORAGE}
    Power On
    Login To OS    ${ENV_ID_XCP_NG}
    Execute Linux Command    openssl rand -out test_file.txt -base64 $(( 2**30 * 3/4 ))
    ${path_to_usb}=    Identify Path To USB
    Execute Linux Command    mount ${path_to_usb} /mnt
    Execute Linux Command    yes | cp -f test_file.txt /mnt    120
    Execute Linux Command    sync    120
    Check If Files Are Identical In Linux    test_file.txt    /mnt/test_file.txt
    Execute Linux Command    yes | rm test_file.txt /mnt/test_file.txt
    Execute Linux Command    sync && umount ${path_to_usb}    120
