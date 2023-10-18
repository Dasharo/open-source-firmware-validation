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
WBS001.001 Wifi and Bluetooth card power switch disabled (Ubuntu 22.04)
    [Documentation]    Checks whether Wifi + Bluetooth is detected by Linux
    ...    after setting Enable Wi-Fi + BT radios option to false
    Skip If    not ${WIFI_BLUETOOTH_CARD_SWITCH_SUPPORT}    WBS001.001 not supported

    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${security_menu}    Enable Wi-Fi + BT radios    ${FALSE}
    Save Changes And Reset    2    4
    Login To Linux
    ${wifi}=    Check The Presence Of WiFi Card
    Should Not Be True    ${wifi}
    ${bt}=    Check The Presence Of Bluetooth Card
    Should Not Be True    ${bt}

WBS002.001 Wifi and Bluetooth card power switch enabled (Ubuntu 22.04)
    [Documentation]    Checks whether Wifi + Bluetooth is detected by Linux
    ...    after setting Enable Wi-Fi + BT radios option to true
    Skip If    not ${WIFI_BLUETOOTH_CARD_SWITCH_SUPPORT}    WBS002.001 not supported

    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${security_menu}    Enable Wi-Fi + BT radios    ${TRUE}
    Save Changes And Reset    2    4
    Login To Linux
    ${wifi}=    Check The Presence Of WiFi Card
    Should Be True    ${wifi}
    ${bt}=    Check The Presence Of Bluetooth Card
    Should Be True    ${bt}
