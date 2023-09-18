*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
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
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
WLE001.001 Wireless card detection (Ubuntu 20.04)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${wireless_card_support}    WLE001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    WLE001.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Should Match    ${out}    *${wifi_card_ubuntu}*
    Exit from root user

WLE001.002 Wireless card detection (Windows 11)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${wireless_card_support}    WLE001.002 not supported
    Skip If    not ${tests_in_windows_support}    WLE001.002 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    ${out}=    Execute Command in Terminal    Get-PnpDevice -PresentOnly | Select-String -Pattern "Wi-Fi"
    Should Contain    ${out}    ${wifi_card}

WLE002.001 Wi-Fi scanning (Ubuntu 20.04)
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system..
    Skip If    not ${wireless_card_wifi_support}    WLE002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    WLE002.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Scan for Wi-Fi in Linux
    Exit from root user

WLE002.002 Wi-Fi scanning (Windows 11)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${wireless_card_wifi_support}    WLE002.002 not supported
    Skip If    not ${tests_in_windows_support}    WLE002.002 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    Execute Command in Terminal    Start-Service WlanSvc
    ${out}=    Execute Command in Terminal    netsh wlan show network
    Should Contain    ${out}    3mdeb_abr
    Should Contain    ${out}    3mdeb_abr_5GHz

WLE003.001 Bluetooth scanning (Ubuntu 20.04)
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Skip If    not ${wireless_card_bluetooth_support}    WLE003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    WLE003.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Scan for Bluetooth in Linux
    Exit from root user

# TBD - Run scanning bluetooth via powershell and list aviailable devices
# test case bellow just check connected bluetooth devices
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
