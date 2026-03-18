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
# Important notice:
# If both are technically supported, as is the case for Novacustom NV4x, the
# test should be carried out separately for both the default Intel network card
# and the Atheros one.


*** Test Cases ***
WLE001.201 Wireless card detection (Ubuntu)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${WIRELESS_CARD_SUPPORT}    WLE001.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    WLE001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    WLE001.201 not supported
    Wireless Card Detection    ${ENV_ID_UBUNTU}

WLE002.201 Wi-Fi scanning (Ubuntu)
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system..
    [Tags]    automated    minimal-regression
    Skip If    not ${WIRELESS_CARD_WIFI_SUPPORT}    WLE002.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    WLE002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    WLE002.201 not supported
    Wi-Fi Scanning    ${ENV_ID_UBUNTU}

WLE003.201 Bluetooth scanning (Ubuntu)
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Skip If    not ${WIRELESS_CARD_BLUETOOTH_SUPPORT}    WLE003.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    WLE003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    WLE003.201 not supported
    Bluetooth Scanning    ${ENV_ID_UBUNTU}

WLE001.202 Wireless card detection (Fedora)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${WIRELESS_CARD_SUPPORT}    WLE001.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    WLE001.202 not supported
    Wireless Card Detection    ${ENV_ID_FEDORA}

WLE002.202 Wi-Fi scanning (Fedora)
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system..
    [Tags]    automated    minimal-regression
    Skip If    not ${WIRELESS_CARD_WIFI_SUPPORT}    WLE002.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    WLE002.202 not supported
    Wi-Fi Scanning    ${ENV_ID_FEDORA}

WLE003.202 Bluetooth scanning (Fedora)
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Skip If    not ${WIRELESS_CARD_BLUETOOTH_SUPPORT}    WLE003.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    WLE003.202 not supported
    Bluetooth Scanning    ${ENV_ID_FEDORA}

WLE001.301 Wireless card detection (Windows)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${WIRELESS_CARD_SUPPORT}    WLE001.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    WLE001.301 not supported
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Power On
    Boot And Login To Windows
    ${out}=    Execute Command In Terminal
    ...    Get-PnpDevice -PresentOnly | Where-Object {$_.Class -eq "Net" -and $_.FriendlyName -match "Wireless|Wi-Fi" -and $_.FriendlyName -notmatch "Virtual|Tunnel|TAP"}
    Should Match    ${out}    *${WIFI_CARD}*
    Log To Console    The test passed for the ${WIFI_CARD} wireless card
    Log    The test passed for the ${WIFI_CARD} wireless card    WARN
    Execute Shutdown Command

WLE002.301 Wi-Fi scanning (Windows)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${WIRELESS_CARD_WIFI_SUPPORT}    WLE002.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    WLE002.301 not supported
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Power On
    Boot And Login To Windows
    Execute Command In Terminal    Start-Service WlanSvc
    # Ensure WiFi is enabled
    Execute Command In Terminal
    ...    Set-NetAdapterAdvancedProperty -Name "Wi-Fi" -AllProperties -RegistryKeyword "SoftwareRadioOff" -RegistryValue "0"
    ${out}=    Execute Command In Terminal    netsh wlan show network
    Should Contain    ${out}    ${3_MDEB_WIFI_NETWORK}
    ${current_card}=
    ...    Execute Command In Terminal    Get-NetAdapter -Name "Wi-Fi" | Format-List -Property "InterfaceDescription"
    Log To Console    The test passed for the ${current_card} wireless card
    Log    The test passed for the ${current_card} wireless card    WARN
    Execute Shutdown Command

WLE001.205 Wireless card detection (XCP-NG)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the XCP-NG OS.
    Skip If    not ${WIRELESS_CARD_SUPPORT}    WLE001.205 not supported
    Skip If    not ${TESTS_IN_XCP_NG_SUPPORT}    WLE001.205 not supported
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    WLE001.205 not supported
    Power On
    Boot And Login To OS    ${ENV_ID_XCP_NG}
    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
    Log To Console    The test passed for the ${WIFI_CARD_UBUNTU} wireless card
    Log    The test passed for the ${WIFI_CARD_UBUNTU} wireless card    WARN

# TBD - Run scanning bluetooth via powershell and list aviailable devices
# test case below just check connected bluetooth devices
# WLE003.002 Bluetooth scanning (Windows 11)
#    [Documentation]    Check whether the Bluetooth functionality of card is
#    ...    initialized correctly and can be used from within the
#    ...    operating system.
#    Skip If    not ${wireless_card_bluetooth_support}    WLE003.002 not supported
#    Skip If    not ${tests_in_windows_support}    WLE003.002 not supported
#    Power On
#    Login to Windows
#    ${out}=    Execute Command in Terminal    Get-PnpDevice -class Bluetooth
#    Should Contain X Times    ${out}    OK    4
#    Execute Shutdown Command

WLE002.203 Wi-Fi scanning (Qubes OS)
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system..
    [Tags]    automated    minimal-regression
    Skip If    not ${WIRELESS_CARD_WIFI_SUPPORT}    WLE002.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    WLE002.203 not supported
    Wi-Fi Scanning QB    ${ENV_ID_QUBES}

WLE003.203 Bluetooth scanning (Qubes OS)
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Skip If    not ${WIRELESS_CARD_BLUETOOTH_SUPPORT}    WLE003.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    WLE003.203 not supported
    Bluetooth Scanning QB    ${ENV_ID_QUBES}


*** Keywords ***
Wireless Card Detection
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User

    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
    Log To Console    The test passed for the ${WIFI_CARD_UBUNTU} wireless card
    Log    The test passed for the ${WIFI_CARD_UBUNTU} wireless card    WARN
    Exit From Root User

Wi-Fi Scanning
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system..
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User

    # with interfaces DOWN, dhclient takes around 37s
    Execute Command In Terminal    dhclient    60s
    IF    "${BOOTED_OS_ID}"=="${ENV_ID_UBUNTU}"
        Detect Or Install Package    network-manager
    END
    Scan For Wi-Fi In Linux
    IF    "${BOOTED_OS_ID}"=="${ENV_ID_UBUNTU}"
        Detect Or Install Package    pciutils
    END
    ${current_card}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Exit From Root User
    Log To Console    The test passed for the ${current_card} wireless card
    Log    The test passed for the ${current_card} wireless card    WARN

Wi-Fi Scanning QB
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system..
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux

    # with interfaces DOWN, dhclient takes around 37s
    Execute Command In Terminal    dhclient    60s
    ${current_card}=    Execute Command In Terminal    lspci | grep "Network controller: | awk -F": " '{print $2}'
    Exit From Root User
    Log To Console    The test passed for the ${current_card} wireless card
    Log    The test passed for the ${current_card} wireless card    WARN

Bluetooth Scanning
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    Scan For Bluetooth In Linux

    ${current_card}=    Execute Command In Terminal    lspci | grep "Network controller:" | awk -F": " '{print $2}'
    Log To Console    The test passed for the ${current_card} wireless card
    Log    The test passed for the ${current_card} wireless card    WARN

Bluetooth Scanning QB
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    Scan For Bluetooth In Linux

    ${current_card}=    Execute Command In Terminal    lspci | grep "Network controller:" | awk -F": " '{print $2}'
    Log To Console    The test passed for the ${current_card} wireless card
    Log    The test passed for the ${current_card} wireless card    WARN
