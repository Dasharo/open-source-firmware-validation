*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     MWL Suite Setup
...                     AND    Skip If    "${ENV_ID_FEDORA}" not in "${TESTED_LINUX_DISTROS}"    Fedora not supported
...                     AND    Init MWL Fedora
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
MWL001.202 Wireless card detection (Fedora)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    Check Wireless Card Detection Linux

MWL002.202 Wi-Fi scanning (Fedora)
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Check Wi-Fi Scanning Linux

MWL003.202 Bluetooth scanning (Fedora)
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    Check Bluetooth Scanning Linux

MWL004.202 LTE card detection (Fedora)
    [Documentation]    Check whether the LTE card is detected correctly in the
    ...    operating system.
    Check LTE Card Detection Linux


*** Keywords ***
Init MWL Fedora
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
