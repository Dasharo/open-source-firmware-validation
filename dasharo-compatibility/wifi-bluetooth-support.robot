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
# Important notice:
# If both are technically supported, as is the case for Novacustom NV4x, the
# test should be carried out separately for both the default Intel network card
# and the Atheros one.


*** Test Cases ***
WLE001.001 Wireless card detection (Ubuntu)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${WIRELESS_CARD_SUPPORT}    WLE001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    WLE001.001 not supported
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    pciutils
    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
    Log To Console    The test passed for the ${WIFI_CARD_UBUNTU} wireless card
    Log    The test passed for the ${WIFI_CARD_UBUNTU} wireless card    WARN
    Exit From Root User

WLE001.002 Wireless card detection (Windows)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${WIRELESS_CARD_SUPPORT}    WLE001.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    WLE001.002 not supported
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal
    ...    Get-PnpDevice | Where-Object {$_.Class -eq "Net" -and $_.FriendlyName -match "Wireless|Wi-Fi" -and $_.FriendlyName -notmatch "Virtual|Tunnel|TAP"}
    Should Match    ${out}    *${WIFI_CARD}*
    Log To Console    The test passed for the ${WIFI_CARD} wireless card
    Log    The test passed for the ${WIFI_CARD} wireless card    WARN

WLE002.001 Wi-Fi scanning (Ubuntu)
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system..
    [Tags]    minimal-regression
    Skip If    not ${WIRELESS_CARD_WIFI_SUPPORT}    WLE002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    WLE002.001 not supported
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Scan For Wi-Fi In Linux
    Detect Or Install Package    pciutils
    ${current_card}=    Execute Command In Terminal    lspci | grep "Network controller: | awk -F": " '{print $2}"
    Exit From Root User
    Log To Console    The test passed for the ${current_card} wireless card
    Log    The test passed for the ${current_card} wireless card    WARN

WLE002.002 Wi-Fi scanning (Windows)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${WIRELESS_CARD_WIFI_SUPPORT}    WLE002.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    WLE002.002 not supported
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Power On
    Login To Windows
    Execute Command In Terminal    Start-Service WlanSvc
    ${out}=    Execute Command In Terminal    netsh wlan show network
    Should Contain    ${out}    ${3_MDEB_WIFI_NETWORK}
    ${current_card}=
    ...    Execute Command In Terminal    Get-NetAdapter -Name "Wi-Fi" | Format-List -Property "InterfaceDescription"
    Log To Console    The test passed for the ${current_card} wireless card
    Log    The test passed for the ${current_card} wireless card    WARN

WLE003.001 Bluetooth scanning (Ubuntu)
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Skip If    not ${WIRELESS_CARD_BLUETOOTH_SUPPORT}    WLE003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    WLE003.001 not supported
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Scan For Bluetooth In Linux
    Detect Or Install Package    pciutils
    ${current_card}=    Execute Command In Terminal    lspci | grep "Network controller: | awk -F": " '{print $2}"
    Exit From Root User
    Log To Console    The test passed for the ${current_card} wireless card
    Log    The test passed for the ${current_card} wireless card    WARN

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
