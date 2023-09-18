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
MWL001.001 Wireless card detection (Ubuntu 22.04)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${MINI_PC_IE_SLOT_SUPPORT}    MWL001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MWL001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${WIFI_CARD}
    Exit From Root User

MWL001.002 Wireless card detection (Windows 11)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${MINI_PC_IE_SLOT_SUPPORT}    WLE001.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    WLE001.002 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    Get-PnpDevice -PresentOnly | Select-String -Pattern "Wi-Fi"
    Should Contain    ${out}    ${WIFI_CARD}

MWL002.001 Wi-Fi scanning (Ubuntu 22.04)
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system..
    Skip If    not ${MINI_PC_IE_SLOT_SUPPORT}    MWL002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MWL002.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Scan For Wi-Fi In Linux
    Exit From Root User

MWL002.002 Wi-Fi scanning (Windows 11)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${MINI_PC_IE_SLOT_SUPPORT}    MLW002.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    MLW002.002 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    netsh wlan show network
    Should Contain    ${out}    3mdeb_abr
    Should Contain    ${out}    3mdeb_abr_5GHz

MWL003.001 Bluetooth scanning (Ubuntu 22.04)
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Skip If    not ${MINI_PC_IE_SLOT_SUPPORT}    MWL003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MWL003.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Scan For Bluetooth In Linux
    Exit From Root User

# MWL003.002 Bluetooth scanning (Windows 11)
#    [Documentation]    TBD

MWL004.001 LTE card detection (Ubuntu 22.04)
    [Documentation]    Check whether the LTE card is detected correctly in the
    ...    operating system.
    Skip If    not ${MINI_PC_IE_SLOT_SUPPORT}    MWL004.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MWL004.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${LTE_CARD}
    Exit From Root User

# MWL004.002 LTE card detection (Windows 11)
#    [Documentation]    Check whether the LTE card is detected correctly in the
#    ...    Windows OS.
#    Skip If    not ${miniPCIe_slot_support}    MWL004.002 not supported
#    Skip If    not ${tests_in_windows_support}    MWL004.002 not supported
#    Power On
#    Login to Windows
#    ${out}=    List Windows USB Devices
#    Should Contain    ${out}    ${LTE_card}
