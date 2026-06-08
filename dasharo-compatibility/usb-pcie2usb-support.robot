*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/custom_bootentries.robot
Resource            ../lib/usb-hid-msc-lib.robot

Suite Setup         Run Keyword
...                     Prepare USB PCIE2USB Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
USB004.203 USB devices detected via PCIe2USB converter (Qubes OS)
    [Documentation]    Check whether USB devices connected via the PCIe-to-USB
    ...    converter are detected correctly in Qubes OS.
    Depends On    ${PCIE2_USB_SUPPORT}
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    USB004.203 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    VAR    ${DUT_CONNECTION_METHOD}=    SSH    scope=TEST
    Login To Linux
    Verify USB Device On PCIE2USB Converter    ${USB_MODEL}

USB005.203 USB keyboard detected via PCIe2USB converter (Qubes OS)
    [Documentation]    Check whether the external USB keyboard connected via
    ...    the PCIe-to-USB converter is detected correctly in Qubes OS.
    Depends On    ${PCIE2_USB_SUPPORT}
    Depends On    ${HAS_KEYBOARD}
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    USB005.203 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    VAR    ${DUT_CONNECTION_METHOD}=    SSH    scope=TEST
    Login To Linux
    Verify USB Device On PCIE2USB Converter    ${DEVICE_USB_KEYBOARD}


*** Keywords ***
Prepare USB PCIE2USB Test Suite
    [Documentation]    Prepare this test suite.
    Prepare Test Suite
    Depends On    ${PCIE2_USB_SUPPORT}
    IF    "${DEVICE_USB_KEYBOARD}" != "${EMPTY}"
        VAR    ${HAS_KEYBOARD}=    ${TRUE}    scope=SUITE
    ELSE
        VAR    ${HAS_KEYBOARD}=    ${FALSE}    scope=SUITE
    END
    VAR    ${HAS_USB_STORAGE}=    ${TRUE}    scope=SUITE
    Skip If    not ${HAS_KEYBOARD} and not ${HAS_USB_STORAGE}
    ...    Platform doesn't have USB keyboard or USB storage attached
