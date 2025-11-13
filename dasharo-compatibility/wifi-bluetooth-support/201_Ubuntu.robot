*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Ubuntu not supported
...                     AND    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    Ubuntu not supported
...                     AND    Init WLE Ubuntu
Suite Teardown      Log Out And Close Connection

Default Tags        automated
# Important notice:
# If both are technically supported, as is the case for Novacustom NV4x, the
# test should be carried out separately for both the default Intel network card
# and the Atheros one.


*** Test Cases ***
WLE001.201 Wireless card detection (Ubuntu)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    ...    Previous IDs: WLE001.001
    Skip If    not ${WIRELESS_CARD_SUPPORT}    WLE001.201 not supported
    Check Wireless Card Detection Linux

WLE002.201 Wi-Fi scanning (Ubuntu)
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system..
    ...    Previous IDs: WLE002.001
    [Tags]    automated    minimal-regression
    Skip If    not ${WIRELESS_CARD_WIFI_SUPPORT}    WLE002.201 not supported
    Check Wi-Fi Scanning Linux

WLE003.201 Bluetooth scanning (Ubuntu)
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    ...    Previous IDs: WLE003.001
    Skip If    not ${WIRELESS_CARD_BLUETOOTH_SUPPORT}    WLE003.201 not supported
    Check Bluetooth Scanning Linux


*** Keywords ***
Init WLE Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
