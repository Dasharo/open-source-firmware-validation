*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for USB HID and MSC support tests

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot


*** Variables ***
${PLATFORM_STATE_CONTROL}=      ${TRUE}


*** Keywords ***
USB Suite Setup
    [Documentation]    Prepare USB HID Test Suite
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

Check USB Devices Detected Linux
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in Linux OS.
    ${out}=    Execute Command In Terminal    lsusb -v | grep bInterfaceClass
    IF    ${HAS_KEYBOARD}    Should Contain    ${out}    Human Interface Device
    IF    ${HAS_USB_STORAGE}    Should Contain    ${out}    Mass Storage

Check USB Keyboard Detection Linux
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the Linux OS.
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${DEVICE_USB_KEYBOARD}

Check Upload 1GB File On USB Storage Linux
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage.
    Execute Linux Command    openssl rand -out test_file.txt -base64 $(( 2**30 * 3/4 ))
    ${path_to_usb}=    Identify Path To USB
    Execute Linux Command    mount ${path_to_usb} /mnt
    Execute Linux Command    yes | cp -f test_file.txt /mnt    120
    Execute Linux Command    sync    120
    Check If Files Are Identical In Linux    test_file.txt    /mnt/test_file.txt
    Execute Linux Command    yes | rm test_file.txt /mnt/test_file.txt
    Execute Linux Command    sync && umount ${path_to_usb}    120
