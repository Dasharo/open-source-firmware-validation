*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     EBM Suite Setup
...                     AND    Power Cycle On
...                     AND    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
...                     AND    Login To Linux
...                     AND    Switch To Root User
...                     AND    Remove Test Boot Entry Return Bootorder
Suite Teardown      EBM Suite Teardown

Default Tags        automated


*** Test Cases ***
EBM001.201 Network Boot enable
    [Documentation]    Test if enabling network boot entry works.
    Skip If    not ${DASHARO_NETWORKING_MENU_SUPPORT}    EBM001.001 not supported

    Set UEFI Option    NetworkBoot    ${FALSE}

    ${boot_menu}=    Get UEFI Boot Manager Entries
    Should Not Contain    ${boot_menu}    ${IPXE_BOOT_ENTRY}

    Set UEFI Option    NetworkBoot    ${TRUE}

    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${boot_menu}=    Get UEFI Boot Manager Entries
    Should Contain    ${boot_menu}    ${IPXE_BOOT_ENTRY}

EBM002.201 Network Boot disable
    [Documentation]    Test if disabling network boot entry works.
    Skip If    not ${DASHARO_NETWORKING_MENU_SUPPORT}    EBM002.001 not supported

    ${boot_menu}=    Get UEFI Boot Manager Entries
    Should Contain    ${boot_menu}    ${IPXE_BOOT_ENTRY}

    Set UEFI Option    NetworkBoot    ${FALSE}

    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${boot_menu}=    Get UEFI Boot Manager Entries
    Should Not Contain    ${boot_menu}    ${IPXE_BOOT_ENTRY}

EBM003.201 Custom Boot Order Add
    [Documentation]    Test if adding a custom boot entry works.
    Skip If    not ${CUSTOM_BOOT_ORDER_SUPPORT}    EBM003.001 not supported

    Power On

    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
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

    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${out}=    Execute Command In Terminal    efibootmgr
    Should Contain    ${out}    ${TEST_BOOT_ENTRY_NAME}

EBM004.201 Custom Boot Order Remove
    [Documentation]    Test if removing a custom boot entry works.
    Skip If    not ${CUSTOM_BOOT_ORDER_SUPPORT}    EBM004.001 not supported

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    # Remove entry
    ${out}=    Remove Test Boot Entry Return Bootorder

    # Check if entry was removed
    Should Not Contain    ${out}    ${TEST_BOOT_ENTRY_NAME}

    # Check if entry stays removed after reboot
    Execute Reboot Command
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${out}=    Execute Command In Terminal    efibootmgr
    Should Not Contain    ${out}    ${TEST_BOOT_ENTRY_NAME}
