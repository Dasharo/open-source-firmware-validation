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
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
WBS001.201 Wifi and Bluetooth card power switch disabled (Ubuntu)
    [Documentation]    Checks whether Wifi + Bluetooth is detected by Linux
    ...    after setting Enable Wi-Fi + BT radios option to false
    Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}
    Skip If    not ${WIFI_BLUETOOTH_CARD_SWITCH_SUPPORT}    WBS001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    WBS001.201 not supported
    Wifi And Bluetooth Card Power Switch Disabled    ${ENV_ID_UBUNTU}

WBS002.201 Wifi and Bluetooth card power switch enabled (Ubuntu)
    [Documentation]    Checks whether Wifi + Bluetooth is detected by Linux
    ...    after setting Enable Wi-Fi + BT radios option to true
    Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}
    Skip If    not ${WIFI_BLUETOOTH_CARD_SWITCH_SUPPORT}    WBS002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    WBS002.201 not supported
    Wifi And Bluetooth Card Power Switch    ${ENV_ID_UBUNTU}

WBS001.202 Wifi and Bluetooth card power switch disabled (Fedora)
    [Documentation]    Checks whether Wifi + Bluetooth is detected by Linux
    ...    after setting Enable Wi-Fi + BT radios option to false
    Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}
    Skip If    not ${WIFI_BLUETOOTH_CARD_SWITCH_SUPPORT}    WBS001.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    WBS001.202 not supported
    Wifi And Bluetooth Card Power Switch Disabled    ${ENV_ID_FEDORA}

WBS002.202 Wifi and Bluetooth card power switch enabled (Fedora)
    [Documentation]    Checks whether Wifi + Bluetooth is detected by Linux
    ...    after setting Enable Wi-Fi + BT radios option to true
    Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}
    Skip If    not ${WIFI_BLUETOOTH_CARD_SWITCH_SUPPORT}    WBS002.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    WBS002.202 not supported
    Wifi And Bluetooth Card Power Switch    ${ENV_ID_FEDORA}


*** Keywords ***
Wifi And Bluetooth Card Power Switch Disabled
    [Documentation]    Checks whether Wifi + Bluetooth is detected by Linux
    ...    after setting Enable Wi-Fi + BT radios option to false
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Set UEFI Option    EnableWifiBt    ${FALSE}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${wifi}=    Check The Presence Of WiFi Card
    Should Not Be True    ${wifi}
    ${bt}=    Check The Presence Of Bluetooth Card
    Should Not Be True    ${bt}

Wifi And Bluetooth Card Power Switch
    [Documentation]    Checks whether Wifi + Bluetooth is detected by Linux
    ...    after setting Enable Wi-Fi + BT radios option to true
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Set UEFI Option    EnableWifiBt    ${TRUE}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${wifi}=    Check The Presence Of WiFi Card
    Should Be True    ${wifi}
    ${bt}=    Check The Presence Of Bluetooth Card
    Should Be True    ${bt}
