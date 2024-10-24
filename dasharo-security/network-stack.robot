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
...                     Skip If    not ${DASHARO_NETWORKING_MENU_SUPPORT}    Dasharo Networking menu not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
NBA001.001 Enable Network Boot (firmware)
    [Documentation]    This test aims to verify that the Network Boot option
    ...    might be enabled. If this option is activated, an additional option
    ...    in the Boot menu which allows to boot the system from iPXE servers
    ...    will appear.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    NBA001.001 not supported
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'    Remap Keys Variables To PiKVM
    Set UEFI Option    NetworkBoot    ${TRUE}

    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Should Contain    ${boot_menu}    ${IPXE_BOOT_ENTRY}

NBA002.001 Disable Network Boot (firmware)
    [Documentation]    This test aims to verify that the Network Boot option
    ...    might be disabled. If this option is deactivated, an additional option
    ...    in the Boot menu which allows to boot the system from iPXE servers
    ...    will be hidden.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    NBA002.001 not supported
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'    Remap Keys Variables To PiKVM
    Set UEFI Option    NetworkBoot    ${FALSE}

    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Should Not Contain    ${boot_menu}    ${IPXE_BOOT_ENTRY}
