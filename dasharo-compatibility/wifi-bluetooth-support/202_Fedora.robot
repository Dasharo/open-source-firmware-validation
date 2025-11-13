*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    Fedora not supported
...                     AND    Init WLE Fedora
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
WLE001.202 Wireless card detection (Fedora)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${WIRELESS_CARD_SUPPORT}    WLE001.202 not supported
    Check Wireless Card Detection Linux

WLE002.202 Wi-Fi scanning (Fedora)
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system..
    [Tags]    automated    minimal-regression
    Skip If    not ${WIRELESS_CARD_WIFI_SUPPORT}    WLE002.202 not supported
    Check Wi-Fi Scanning Linux

WLE003.202 Bluetooth scanning (Fedora)
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Skip If    not ${WIRELESS_CARD_BLUETOOTH_SUPPORT}    WLE003.202 not supported
    Check Bluetooth Scanning Linux


*** Keywords ***
Init WLE Fedora
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
