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
WLE001.001 Wireless card detection (Ubuntu 20.04)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${WIRELESS_CARD_SUPPORT}    WLE001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    WLE001.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
    Exit From Root User

WLE001.002 Wireless card detection (Windows 11)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${WIRELESS_CARD_SUPPORT}    WLE001.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    WLE001.002 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    Get-PnpDevice -PresentOnly | Select-String -Pattern "Wi-Fi"
    Should Contain    ${out}    ${WIFI_CARD}

WLE002.001 Wi-Fi scanning (Ubuntu 20.04)
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system..
    Skip If    not ${WIRELESS_CARD_WIFI_SUPPORT}    WLE002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    WLE002.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Scan For Wi-Fi In Linux
    Exit From Root User

WLE002.002 Wi-Fi scanning (Windows 11)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${WIRELESS_CARD_WIFI_SUPPORT}    WLE002.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    WLE002.002 not supported
    Power On
    Login To Windows
    Execute Command In Terminal    Start-Service WlanSvc
    ${out}=    Execute Command In Terminal    netsh wlan show network
    Should Contain    ${out}    3mdeb_abr
    Should Contain    ${out}    3mdeb_abr_5GHz

WLE003.001 Bluetooth scanning (Ubuntu 20.04)
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Skip If    not ${WIRELESS_CARD_BLUETOOTH_SUPPORT}    WLE003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    WLE003.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Scan For Bluetooth In Linux
    Exit From Root User

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
