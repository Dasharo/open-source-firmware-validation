*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${WIRELESS_CARD_SUPPORT}    Wireless card not supported
...                     AND    Skip If    not ${TESTS_IN_XCP_NG_SUPPORT}    XCP-NG not supported
...                     AND    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    XCP-NG not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
WLE001.205 Wireless card detection (XCP-NG)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the XCP-NG OS.
    ...    Previous IDs: WLE001.010
    Power On
    Login To OS    ${ENV_ID_XCP_NG}
    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
    Log To Console    The test passed for the ${WIFI_CARD_UBUNTU} wireless card
    Log    The test passed for the ${WIFI_CARD_UBUNTU} wireless card    WARN
