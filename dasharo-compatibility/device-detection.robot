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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${DEVICE_DETECT_TEST_IN_SCOPE}
Suite Teardown      Run Keywords
...                     Run Keyword If    '${SUITE_STATUS}' != 'SKIP'    Set UEFI Option    UsbDriverStack    Enabled
...                     AND
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
DDET001.201 USB Stack disable (Ubuntu)
    [Documentation]    Test disabling the USB stack
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DDET001.201 not supported
    Set UEFI Option    UsbDriverStack    Disabled
    Set DUT Response Timeout    30s
    Power On
    Boot And Login To OS    ${ENV_ID_UBUNTU}
    Switch To Root User
    ${out}=    Execute Command In Terminal
    ...    cbmem -1 | grep "UsbBusStart:"

    Should Not Contain    ${out}    usb bus started
    ...    ignore_case=True

DDET002.201 USB Stack enable (Ubuntu)
    [Documentation]    Test enabling the USB stack
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DDET002.201 not supported
    Set UEFI Option    UsbDriverStack    Enabled
    Set DUT Response Timeout    30s
    Power On
    Boot And Login To OS    ${ENV_ID_UBUNTU}
    Switch To Root User
    ${out}=    Execute Command In Terminal
    ...    cbmem -1 | grep "UsbBusStart"

    Should Contain    ${out}    usb bus started
    ...    ignore_case=True

DDET003.201 Usb Devices Detected In Firmware Warmboot (Ubuntu)
    [Documentation]    Test if USB devices are detected after a warmboot
    [Tags]    automated    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DDET003.201 not supported
    Skip If
    ...    not ${RTC_BOOT_SUPPORT} and ${INCLUDE_TAGS} is not ${None} and 'semiauto' not in ${INCLUDE_TAGS}
    Power On
    Boot And Login To OS    ${ENV_ID_UBUNTU}
    Switch To Root User
    Perform Warmboot Using Rtcwake

    Power On
    Boot And Login To OS    ${ENV_ID_UBUNTU}
    Switch To Root User
    ${out}=    Execute Command In Terminal
    ...    cbmem -1 | grep -i 'UsbEnumeratePort'

    Should Contain    ${out}    new device connected
    ...    ignore_case=True

DDET004.201 NET Controller Detected After Reboot (Ubuntu)
    [Documentation]    Test if a network controller is detected on an PCI lane
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DDET004.201 not supported
    Power On
    Boot And Login To OS    ${ENV_ID_UBUNTU}
    Switch To Root User
    Execute Reboot Command

    Boot And Login To OS    ${ENV_ID_UBUNTU}
    Switch To Root User
    ${out}=    Execute Command In Terminal
    ...    lspci | grep -i 'net'

    Should Contain Any    ${out}    Network Controller    Ethernet Controller
    ...    ignore_case=True
