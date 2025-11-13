*** Settings ***
Resource            common.resource

Suite Setup         USB Suite Setup
Suite Teardown      Log Out And Close Connection

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
