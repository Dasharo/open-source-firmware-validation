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
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
EBM001.001 Network Boot enable, disable
    [Documentation]    Test if disabling and enabling network boot entry works
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NCN001.001 not supported
    Skip If    not ${DASHARO_NETWORKING_MENU_SUPPORT}    NCN001.001 not supported

    Set UEFI Option    NetworkBoot    Disabled
    Login To Linux
    Switch To Root User

    ${boot_menu}=    Get UEFI Boot Manager Entries
    Should Not Contain    ${boot_menu}    ${IPXE_BOOT_ENTRY}

    Set UEFI Option    NetworkBoot    Enabled
    Login To Linux
    Switch To Root User

    ${boot_menu}=    Get UEFI Boot Manager Entries
    Should Contain    ${boot_menu}    ${IPXE_BOOT_ENTRY}

EBM002.001 Custom Boot Order Add Delete
    [Documentation]    Test if adding a custom boot entry works

    # Add entry
    Login To Linux
    Switch To Root User

    # Find a suitable drive and create an entry for it
    ${drive}=    Set Variable
    ...    $(ls /sys/block | grep -E "nvme|sda" | head -n 1)
    ${out}=    Execute Command In Terminal
    ...    efibootmgr -c -L "EBM003.001" -d /dev/${drive}

    # Check if entry was added
    Should Contain    ${out}    EBM003.001

    # Check if entry persists after reboot
    Execute Reboot Command
    Sleep    10s
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    efibootmgr
    Should Contain    ${out}    EBM003.001

    # Remove entry
    ${id}=    Set Variable
    ...    $(efibootmgr | grep "EBM003.001" | cut -d" " -f1 | grep -Eo '[0-9A-F]{4}' | grep -Eo '[^0][0-9A-F]{0,3}|0$')
    ${out}=    Execute Command In Terminal    efibootmgr -b ${id} -B
    # Check if entry was removed
    Should Not Contain    ${out}    EBM003.001

    # Check if entry stays removed after reboot
    Execute Reboot Command
    Sleep    10s
    Login To Linux
    Switch To Root User

    ${out}=    Execute Command In Terminal    efibootmgr
    Should Not Contain    ${out}    EBM003.001
