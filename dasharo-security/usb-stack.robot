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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${DASHARO_USB_MENU_SUPPORT}    Dasharo USB configuration menu not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
USS001.001 Enable USB stack (firmware)
    [Documentation]    Check whether If the stack is activated, there will be an
    ...    option to use USB bootable drives and USB keyboards on
    ...    the firmware level.
    Skip If    not ${USB_STACK_SUPPORT}    USS001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    USS001.001 not supported
    Skip If    "${OPTIONS_LIB}" == "dcu"
    Set UEFI Option    UsbDriverStack    Enabled
    Set UEFI Option    UsbMassStorage    Enabled
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Check That USB Devices Are Detected    ${boot_menu}

USS002.001 Disable USB stack (firmware)
    [Documentation]    Check whether If the stack is deactivated, there will be
    ...    no option to use USB bootable drives and USB keyboards on
    ...    the firmware level.
    Skip If    not ${USB_STACK_SUPPORT}    USS002.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    USS002.001 not supported
    Skip If    "${OPTIONS_LIB}" == "dcu"
    Set UEFI Option    UsbMassStorage    Disabled
    Set UEFI Option    UsbDriverStack    Disabled
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    # Check That USB Devices Are Not Detected    ${boot_menu}

USS003.001 Enable USB Mass Storage (firmware)
    [Documentation]    Check whether If the storage support is activated, there
    ...    will be an option to use USB bootable drives on the
    ...    firmware level.
    Skip If    not ${USB_MASS_STORAGE_SUPPORT}    USS003.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    USS003.001 not supported
    Skip If    "${OPTIONS_LIB}" == "dcu"
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${usb_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    USB Configuration
    ${usb_stack_state}=    Get Option State    ${usb_menu}    Enable USB stack
    IF    ${usb_stack_state} != ${TRUE}
        Set Option State    ${usb_menu}    Enable USB stack    ${TRUE}
        Save Changes And Reset
        ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
        ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
        ${usb_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    USB Configuration
    END
    Set Option State    ${usb_menu}    Enable USB Mass Storage    ${TRUE}
    Save Changes And Reset
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Check That USB Devices Are Detected    ${boot_menu}

USS004.001 Disable USB Mass Storage (firmware)
    [Documentation]    Check whether If the storage support is deactivated,
    ...    there will be no option to use USB bootable drives on the
    ...    firmware level.
    Skip If    not ${USB_MASS_STORAGE_SUPPORT}    USS004.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    USS004.001 not supported
    Skip If    "${OPTIONS_LIB}" == "dcu"
    Power On
    # Enable USB stack first to get mass storage option
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${usb_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    USB Configuration
    ${usb_stack_state}=    Get Option State    ${usb_menu}    Enable USB stack
    IF    ${usb_stack_state} != ${TRUE}
        Set Option State    ${usb_menu}    Enable USB stack    ${TRUE}
        Save Changes And Reset
        ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
        ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
        ${usb_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    USB Configuration
    END
    Set Option State    ${usb_menu}    Enable USB Mass Storage    ${FALSE}
    Save Changes And Reset
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    # Check That USB Devices Are Not Detected    ${boot_menu}
