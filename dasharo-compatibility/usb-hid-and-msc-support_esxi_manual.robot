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

# Required setup keywords:
# Prepare Test Suite - elementary setup keyword for all tests.
# Required teardown keywords:
# Log Out And Close Connection - elementary teardown keyword for all tests.
Suite Setup         Run Keyword
...                     Prepare USB HID Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
USB001.401 USB devices detection in OS (ESXi)
    [Documentation]    Check whether USB devices are correctly detected
    ...    in VMware ESXi using lsusb monitoring.
    ...    Previous IDs: USB001.004
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    USB001.401 not supported
    Skip If    '${ENV_ID_ESXI}' not in ${TESTED_LINUX_DISTROS}    USB001.401 not supported

    Pause Execution
    ...    This is a manual test to verify USB device detection on ESXi.
    ...    You will follow the checklist to complete the test manually.

    Execute Manual Step    [1/5] Power on the DUT
    Execute Manual Step    [2/5] Boot into ESXi
    Execute Manual Step    [3/5] Log in via SSH
    Execute Manual Step    [4/5] Run command in terminal: watch -n1 lsusb
    Execute Manual Step    [5/5] Connect USB devices to a USB-A port
    ...    and verify that new entries appear in the `lsusb` output

USB002.401 USB keyboard detection in OS (ESXi)
    [Documentation]    Verify that an external USB keyboard is correctly detected in ESXi.
    ...    Detection includes visibility in `lsusb` and verification of working input via basic typing test.
    ...    Previous IDs: USB002.004
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    USB002.401 not supported
    Skip If    '${ENV_ID_ESXI}' not in ${TESTED_LINUX_DISTROS}    USB002.401 not supported

    Pause Execution
    ...    This is a manual test to verify USB keyboard functionality on ESXi.
    ...    You will use lsusb and attempt input in a terminal or text field.

    Execute Manual Step    [1/7] Power on the DUT
    Execute Manual Step    [2/7] Boot into ESXi
    Execute Manual Step    [3/7] Log in via SSH
    Execute Manual Step    [4/7] Connect external USB keyboard to DUT
    Execute Manual Step    [5/7] Run command in terminal: lsusb
    Execute Manual Step    [6/7] Verify the keyboard appears in lsusb output
    Execute Manual Step    [7/7] Open a shell or text field and test key input:
    ...    - Type alphanumeric characters
    ...    - Use modifier keys (Shift, Ctrl, Alt)
    ...    - Confirm characters are correctly entered and combinations work
