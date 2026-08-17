*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated    semiauto


*** Test Cases ***
CMOS001.101 Clearing CMOS resets firmware settings (EDK2 UEFI)
    [Tags]    automated    semiauto
    [Documentation]    Check whether clearing CMOS resets firmware settings
#    Skip If Not ${TESTS_IN_FIRMWARE_SUPPORT} CMOS001.101 Not Supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${usb_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    USB Configuration
    Set Option State    ${usb_menu}    Enable USB stack    ${FALSE}
    Save Changes And Reset

    IF    ${DUT_HAS_CMOS_RESET}
        Rte Psu Off
        Rte Clear Cmos
    ELSE
        Log    RTE CMOS clear not supported. Test becomes semiauto.    level=WARN
        Skip If    'semiauto' not in ${INCLUDE_TAGS}    `semiauto` tag not selected

        Execute Manual Step    Disconnect the CMOS battery
        Sleep    5s
        Execute Manual Step    Connect the CMOS battery and assemble back the device completely
        IF    ${POWER_CTRL} == 'none'
            Execute Manual Step    Make sure the device is plugged in
        END
    END

    Power On

    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${usb_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    USB Configuration
    ${usb_stack_state}=    Get Option State    ${usb_menu}    Enable USB stack
    Should Be True    ${usb_stack_state}
