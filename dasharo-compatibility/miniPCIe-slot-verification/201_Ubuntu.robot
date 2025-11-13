*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     MWL Suite Setup
...                     AND    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Ubuntu not supported
...                     AND    Skip If    "${ENV_ID_UBUNTU}" not in "${TESTED_LINUX_DISTROS}"    Ubuntu not supported
...                     AND    Init MWL Ubuntu
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
MWL001.201 Wireless card detection (Ubuntu)
    [Documentation]    Check whether the Wi-Fi/Bluetooth card is enumerated
    ...    correctly and can be detected from the operating system.
    ...    Previous IDs: MWL001.001
    Check Wireless Card Detection Linux

MWL002.201 Wi-Fi scanning (Ubuntu)
    [Documentation]    Check whether the Wi-Fi functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system..
    ...    Previous IDs: MWL002.001
    Check Wi-Fi Scanning Linux

MWL003.201 Bluetooth scanning (Ubuntu)
    [Documentation]    Check whether the Bluetooth functionality of card is
    ...    initialized correctly and can be used from within the
    ...    operating system.
    ...    Previous IDs: MWL003.001
    Check Bluetooth Scanning Linux

MWL004.201 LTE card detection (Ubuntu)
    [Documentation]    Check whether the LTE card is detected correctly in the
    ...    operating system.
    ...    Previous IDs: MWL004.001
    Check LTE Card Detection Linux


*** Keywords ***
Init MWL Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
