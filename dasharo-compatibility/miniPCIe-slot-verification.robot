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
MWL001.001 Wireless card detection (Ubuntu 22.04)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${miniPCIe_slot_support}    MWL001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    MWL001.001 not supported
    Power On
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    pci
    Should Contain    ${out}    ${wifi_card}
    Exit from root user

MWL001.002 Wireless card detection (Windows 11)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${miniPCIe_slot_support}    WLE001.002 not supported
    Skip If    not ${tests_in_windows_support}    WLE001.002 not supported
    Power On
    Login to Windows
    ${out}=    Execute Command in Terminal    Get-PnpDevice -PresentOnly | Select-String -Pattern "Wi-Fi"
    Should Contain    ${out}    ${wifi_card}

MWL002.001 Wi-Fi scanning (Ubuntu 22.04)
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system..
    Skip If    not ${miniPCIe_slot_support}    MWL002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    MWL002.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Scan for Wi-Fi in Linux
    Exit from root user

MWL002.002 Wi-Fi scanning (Windows 11)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${miniPCIe_slot_support}    MLW002.002 not supported
    Skip If    not ${tests_in_windows_support}    MLW002.002 not supported
    Power On
    Login to Windows
    ${out}=    Execute Command in Terminal    netsh wlan show network
    Should Contain    ${out}    3mdeb_abr
    Should Contain    ${out}    3mdeb_abr_5GHz

MWL003.001 Bluetooth scanning (Ubuntu 22.04)
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Skip If    not ${miniPCIe_slot_support}    MWL003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    MWL003.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Scan for Bluetooth in Linux
    Exit from root user

# MWL003.002 Bluetooth scanning (Windows 11)
#    [Documentation]    TBD

MWL004.001 LTE card detection (Ubuntu 22.04)
    [Documentation]    Check whether the LTE card is detected correctly in the
    ...    operating system.
    Skip If    not ${miniPCIe_slot_support}    MWL004.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    MWL004.001 not supported
    Power On
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    usb
    Should Contain    ${out}    ${LTE_card}
    Exit from root user

# MWL004.002 LTE card detection (Windows 11)
#    [Documentation]    Check whether the LTE card is detected correctly in the
#    ...    Windows OS.
#    Skip If    not ${miniPCIe_slot_support}    MWL004.002 not supported
#    Skip If    not ${tests_in_windows_support}    MWL004.002 not supported
#    Power On
#    Login to Windows
#    ${out}=    List Windows USB Devices
#    Should Contain    ${out}    ${LTE_card}
