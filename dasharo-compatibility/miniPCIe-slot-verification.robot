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
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${MINI_PC_IE_SLOT_SUPPORT}    MiniPCIe slot tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
MWL001.201 Wireless card detection (Ubuntu)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    ...    Previous IDs: MWL001.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MWL001.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in "${TESTED_LINUX_DISTROS}"    MWL001.201 not supported
    Wireless Card Detection    ${ENV_ID_UBUNTU}

MWL002.201 Wi-Fi scanning (Ubuntu)
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system..
    ...    Previous IDs: MWL002.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MWL002.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in "${TESTED_LINUX_DISTROS}"    MWL002.201 not supported
    Wi-Fi Scanning    ${ENV_ID_UBUNTU}

MWL003.201 Bluetooth scanning (Ubuntu)
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    ...    Previous IDs: MWL003.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MWL003.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in "${TESTED_LINUX_DISTROS}"    MWL003.201 not supported
    Bluetooth Scanning    ${ENV_ID_UBUNTU}

MWL004.201 LTE card detection (Ubuntu)
    [Documentation]    Check whether the LTE card is detected correctly in the
    ...    operating system.
    ...    Previous IDs: MWL004.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MWL004.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in "${TESTED_LINUX_DISTROS}"    MWL004.201 not supported
    Skip If    "${LTE_CARD}"=="${TBD}"    LTE_CARD=="${TBD}""
    LTE Card Detection    ${ENV_ID_UBUNTU}

MWL001.202 Wireless card detection (Fedora)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MWL001.202 not supported
    Skip If    "${ENV_ID_FEDORA}" not in "${TESTED_LINUX_DISTROS}"    MWL001.202 not supported
    Wireless Card Detection    ${ENV_ID_FEDORA}

MWL002.202 Wi-Fi scanning (Fedora)
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Skip If    not ${MINI_PC_IE_SLOT_SUPPORT}    MWL002.202 not supported
    Skip If    "${ENV_ID_FEDORA}" not in "${TESTED_LINUX_DISTROS}"    MWL002.202 not supported
    Wi-Fi Scanning    ${ENV_ID_FEDORA}

MWL003.202 Bluetooth scanning (Fedora)
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Skip If    "${ENV_ID_FEDORA}" not in "${TESTED_LINUX_DISTROS}"    MWL003.202 not supported
    Bluetooth Scanning    ${ENV_ID_FEDORA}

MWL004.202 LTE card detection (Fedora)
    [Documentation]    Check whether the LTE card is detected correctly in the
    ...    operating system.
    Skip If    "${LTE_CARD}"=="${TBD}"    LTE_CARD=="${TBD}""
    Skip If    "${ENV_ID_FEDORA}" not in "${TESTED_LINUX_DISTROS}"    MWL004.202 not supported
    LTE Card Detection    ${ENV_ID_FEDORA}

MWL001.301 Wireless card detection (Windows)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    ...    Previous IDs: MWL001.002
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    WLE001.301 not supported
    Power On
    Boot And Login To Windows
    ${out}=    Execute Command In Terminal    Get-PnpDevice -PresentOnly | Select-String -Pattern "Wi-Fi"
    Should Contain    ${out}    ${WIFI_CARD}
    Execute Shutdown Command

MWL002.301 Wi-Fi scanning (Windows)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    ...    Previous IDs: MWL002.002
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    MLW002.301 not supported
    Power On
    Boot And Login To Windows
    ${out}=    Execute Command In Terminal    netsh wlan show network
    Should Contain    ${out}    ${3_MDEB_WIFI_NETWORK}
    Execute Shutdown Command

# MWL003.002 Bluetooth scanning (Windows)
#    [Documentation]    TBD

# MWL004.002 LTE card detection (Windows)
#    [Documentation]    Check whether the LTE card is detected correctly in the
#    ...    Windows OS.
#    Skip If    not ${tests_in_windows_support}    MWL004.002 not supported
#    Power On
#    Login to Windows
#    ${out}=    List Windows USB Devices
#    Should Contain    ${out}    ${LTE_card}


*** Keywords ***
Wireless Card Detection
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${WIFI_CARD_UBUNTU}
    Exit From Root User

Wi-Fi Scanning
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    Scan For Wi-Fi In Linux
    Exit From Root User

Bluetooth Scanning
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    Scan For Bluetooth In Linux
    Exit From Root User

LTE Card Detection
    [Documentation]    Check whether the LTE card is detected correctly in the
    ...    operating system.
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${LTE_CARD}
    Exit From Root User
