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
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
USS001.001 Enable USB stack (firmware)
    [Documentation]    Check whether If the stack is activated, there will be an
    ...    option to use USB bootable drives and USB keyboards on
    ...    the firmware level.
    Skip If    not ${USB_STACK_SUPPORT}    USS001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    USS001.001 not supported
    Power On
    Enter Setup Menu Tianocore
    ${menu_construction}=    Enter USB Configuration Submenu
    Enable Option In USB Configuration Submenu    ${menu_construction}    Enable USB stack
    Save Changes And Reset    2    4
    Enter Setup Menu Tianocore
    ${menu_construction}=    Enter USB Configuration Submenu
    Enable Option In USB Configuration Submenu    ${menu_construction}    Enable USB Mass Storage
    Save Changes And Reset    2    4
    Enter Boot Menu Tianocore
    Check That USB Devices Are Detected

USS002.001 Disable USB stack (firmware)
    [Documentation]    Check whether If the stack is deactivated, there will be
    ...    no option to use USB bootable drives and USB keyboards on
    ...    the firmware level.
    Skip If    not ${USB_STACK_SUPPORT}    USS002.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    USS002.001 not supported
    Power On
    Enter Setup Menu Tianocore
    ${menu_construction}=    Enter USB Configuration Submenu
    Disable Option In USB Configuration Submenu    ${menu_construction}    Enable USB stack
    Save Changes And Reset    2    4
    Enter Boot Menu Tianocore
    Check That USB Devices Are Not Detected

USS003.001 Enable USB Mass Storage (firmware)
    [Documentation]    Check whether If the storage support is activated, there
    ...    will be an option to use USB bootable drives on the
    ...    firmware level.
    Skip If    not ${USB_MASS_STORAGE_SUPPORT}    USS003.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    USS003.001 not supported
    Power On
    Enter Setup Menu Tianocore
    ${menu_construction}=    Enter USB Configuration Submenu
    Enable Option In USB Configuration Submenu    ${menu_construction}    Enable USB stack
    Save Changes And Reset    2    4
    Enter Setup Menu Tianocore
    ${menu_construction}=    Enter USB Configuration Submenu
    Enable Option In USB Configuration Submenu    ${menu_construction}    Enable USB Mass Storage
    Save Changes And Reset    2    4
    Enter Boot Menu Tianocore
    Check That USB Devices Are Detected

USS004.001 Disable USB Mass Storage (firmware)
    [Documentation]    Check whether If the storage support is deactivated,
    ...    there will be no option to use USB bootable drives on the
    ...    firmware level.
    Skip If    not ${USB_MASS_STORAGE_SUPPORT}    USS004.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    USS004.001 not supported
    Power On
    Enter Setup Menu Tianocore
    ${menu_construction}=    Enter USB Configuration Submenu
    Enable Option In USB Configuration Submenu    ${menu_construction}    Enable USB stack
    Save Changes And Reset    2    4
    Enter Setup Menu Tianocore
    ${menu_construction}=    Enter USB Configuration Submenu
    Disable Option In USB Configuration Submenu    ${menu_construction}    Enable USB Mass Storage
    Save Changes And Reset    2    4
    Enter Boot Menu Tianocore
    Check That USB Devices Are Not Detected
