*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    Windows not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
WLE001.301 Wireless card detection (Windows)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    ...    Previous IDs: WLE001.002
    Skip If    not ${WIRELESS_CARD_SUPPORT}    WLE001.301 not supported
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal
    ...    Get-PnpDevice -PresentOnly | Where-Object {$_.Class -eq "Net" -and $_.FriendlyName -match "Wireless|Wi-Fi" -and $_.FriendlyName -notmatch "Virtual|Tunnel|TAP"}
    Should Match    ${out}    *${WIFI_CARD}*
    Log To Console    The test passed for the ${WIFI_CARD} wireless card
    Log    The test passed for the ${WIFI_CARD} wireless card    WARN
    Execute Shutdown Command

WLE002.301 Wi-Fi scanning (Windows)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    ...    Previous IDs: WLE002.002
    Skip If    not ${WIRELESS_CARD_WIFI_SUPPORT}    WLE002.301 not supported
    Log To Console    Remember to test all variants of wireless cards.
    Log    Remember to test all variants of wireless cards.    WARN
    Power On
    Login To Windows
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
