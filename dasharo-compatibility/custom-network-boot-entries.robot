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
...                     Skip If    not ${IPXE_BOOT_SUPPORT}    iPXE Network Boot not supported
...                     AND
...                     Skip If    not ${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}
...                     AND
...                     Run Keyword If    ${DASHARO_NETWORKING_MENU_SUPPORT}
...                     Make Sure That Network Boot Is Enabled
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CNB001.201 Only one iPXE in boot menu
    [Documentation]    Check whether the network boot option with iPXE appears
    ...    only once in the boot option list.
    ...    Previous IDs: CNB001.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CNB001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CNB001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    ${boot_menu}=    Get UEFI Boot Manager Entries
    Should Contain X Times    ${boot_menu}    ${IPXE_BOOT_ENTRY}    1

CNB001.202 Only one iPXE in boot menu
    [Documentation]    Check whether the network boot option with iPXE appears
    ...    only once in the boot option list.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CNB001.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    ${boot_menu}=    Get UEFI Boot Manager Entries
    Should Contain X Times    ${boot_menu}    ${IPXE_BOOT_ENTRY}    1
