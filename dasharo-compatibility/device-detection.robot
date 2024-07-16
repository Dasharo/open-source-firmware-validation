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
Resource            ../pikvm-rest-api/pikvm_comm.robot
Resource            ../lib/options/dcu.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Set UEFI Option    UsbDriverStack    Enabled
Suite Teardown      Run Keywords
...                     Log Out And Close Connection
...                     AND
...                     Set UEFI Option    UsbDriverStack    Enabled


*** Test Cases ***
DDET001.001 USB Stack disable
    [Documentation]    Test disabling the USB stack

    Login To Linux With Root Privileges
    Set UEFI Option    UsbDriverStack    Disabled

    Execute Reboot Command
    Sleep    10s

    Set DUT Response Timeout    30s
    Login To Linux With Root Privileges
    ${out}=    Execute Command In Terminal
    ...    cbmem -1 | grep "UsbBusStart:"

    Should Not Contain    ${out}    usb bus started
    ...    ignore_case=True

DDET002.001 USB Stack enable
    [Documentation]    Test enabling the USB stack

    Login To Linux With Root Privileges
    Set UEFI Option    UsbDriverStack    Enabled
    Execute Reboot Command
    Sleep    10s

    Set DUT Response Timeout    30s
    Login To Linux With Root Privileges
    ${out}=    Execute Command In Terminal
    ...    cbmem -1 | grep "UsbBusStart"

    Should Contain    ${out}    usb bus started
    ...    ignore_case=True

DDET003.001 Usb Devices Detected In Firmware Warmboot
    [Documentation]    Test if USB devices are detected after a warmboot

    Login To Linux With Root Privileges
    Perform Warmboot Using Rtcwake
    Login To Linux With Root Privileges

    ${out}=    Execute Command In Terminal
    ...    cbmem -1 | grep -i 'UsbEnumeratePort'

    Should Contain    ${out}    new device connected
    ...    ignore_case=True

DDET004.001 NET Controller Detected After Reboot
    [Documentation]    Test if a network controller is detected on an PCI lane

    Login To Linux With Root Privileges
    Execute Reboot Command
    Login To Linux With Root Privileges

    ${out}=    Execute Command In Terminal
    ...    lspci | grep -i 'net'

    Should Contain Any    ${out}    Network Controller    Ethernet Controller
    ...    ignore_case=True
