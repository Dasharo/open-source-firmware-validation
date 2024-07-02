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
Resource            ../lib/options/dcu.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Login And Remove Test Boot Entry
Suite Teardown      Run Keywords
...                     Login And Remove Test Boot Entry
...                     AND
...                     Log Out And Close Connection


*** Variables ***
${TEST_BOOT_ENTRY_NAME}=    dasharo-compatibility_efibootmgr-custom-boot-entry


*** Keywords ***
Login And Remove Test Boot Entry
    Login To Linux
    Switch To Root User
    Remove Test Boot Entry Return Bootorder

Remove Test Boot Entry Return Bootorder
    [Documentation]    Removes the custom boot entry which name is defined in ***Variables***
    ${id}=    Set Variable
    ...    $(efibootmgr | grep "${TEST_BOOT_ENTRY_NAME}" | cut -d" " -f1 | grep -Eo '[0-9A-F]{4}' | grep -Eo '[^0][0-9A-F]{0,3}|0$')
    ${out}=    Execute Command In Terminal    efibootmgr -b ${id} -B
    RETURN    ${out}

Find Test Boot Entry Id
    [Documentation]    Returns the Id of custom boot entry
    ${id}=    Set Variable
    ...    $(efibootmgr | grep "${TEST_BOOT_ENTRY_NAME}" | cut -d" " -f1 | grep -Eo '[0-9A-F]{4}' | grep -Eo '[^0][0-9A-F]{0,3}|0$')
    RETURN    ${id}

*** Test Cases ***
EBM001.001 Network Boot enable
    [Documentation]    Test if enabling network boot entry works.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NCN001.001 not supported
    Skip If    not ${DASHARO_NETWORKING_MENU_SUPPORT}    NCN001.001 not supported

    ${boot_menu}=    Get UEFI Boot Manager Entries
    Should Not Contain    ${boot_menu}    ${IPXE_BOOT_ENTRY}

    Set UEFI Option    NetworkBoot    Enabled
    Login To Linux
    Switch To Root User

    ${boot_menu}=    Get UEFI Boot Manager Entries
    Should Contain    ${boot_menu}    ${IPXE_BOOT_ENTRY}

EBM002.001 Network Boot disable
    [Documentation]    Test if disabling network boot entry works.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NCN001.001 not supported
    Skip If    not ${DASHARO_NETWORKING_MENU_SUPPORT}    NCN001.001 not supported

    ${boot_menu}=    Get UEFI Boot Manager Entries
    Should Contain    ${boot_menu}    ${IPXE_BOOT_ENTRY}

    Set UEFI Option    NetworkBoot    Disabled
    Login To Linux
    Switch To Root User

    ${boot_menu}=    Get UEFI Boot Manager Entries
    Should Not Contain    ${boot_menu}    ${IPXE_BOOT_ENTRY}

EBM003.001 Custom Boot Order Add
    [Documentation]    Test if adding a custom boot entry works.

    Login To Linux
    Switch To Root User

    # Find a suitable drive and create an entry for it
    # ${drive}=    Set Variable
    # ...    $(ls /sys/block | grep -E "nvme|sda" | head -n 1)
    ${drive}=    Execute Command In Terminal    findmnt -n -o SOURCE /
    ${old_order}=    Execute Command In Terminal    efibootmgr | grep -i "bootorder" | cut -d" " -f2

    ${out}=    Execute Command In Terminal
    ...    efibootmgr -c -L "${TEST_BOOT_ENTRY_NAME}" -d ${drive} -l /boot/efi/EFI/ubuntu/grubx64.efi
    ${id}=    Find Test Boot Entry Id
    Execute Command In Terminal    efibootmgr --bootorder ${old_order}
    # Makes the new bootentry "inactive" to prevent booting to it and hanging
    # because the entry is not valid
    # Execute Command In Terminal    efibootmgr -A -b ${id}


    # Check if entry was added
    Should Contain    ${out}    ${TEST_BOOT_ENTRY_NAME}

    # Check if entry persists after reboot
    Execute Reboot Command
    Sleep    10s
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    efibootmgr
    Should Contain    ${out}    ${TEST_BOOT_ENTRY_NAME}

EBM004.001 Custom Boot Order Remove
    [Documentation]    Test if removing a custom boot entry works.

    Login To Linux
    Switch To Root User

    # Remove entry
    ${out}=    Remove Test Boot Entry Return Bootorder

    # Check if entry was removed
    Should Not Contain    ${out}    ${TEST_BOOT_ENTRY_NAME}

    # Check if entry stays removed after reboot
    Execute Reboot Command
    Sleep    10s
    Login To Linux
    Switch To Root User

    ${out}=    Execute Command In Terminal    efibootmgr
    Should Not Contain    ${out}    ${TEST_BOOT_ENTRY_NAME}
