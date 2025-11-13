*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     MWL Suite Setup
...                     AND    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    Windows not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
MWL001.301 Wireless card detection (Windows)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    ...    Previous IDs: MWL001.002
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    Get-PnpDevice -PresentOnly | Select-String -Pattern "Wi-Fi"
    Should Contain    ${out}    ${WIFI_CARD}
    Execute Shutdown Command

MWL002.301 Wi-Fi scanning (Windows)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    ...    Previous IDs: MWL002.002
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    netsh wlan show network
    Should Contain    ${out}    3mdeb_abr
    Should Contain    ${out}    3mdeb_abr_5GHz
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
