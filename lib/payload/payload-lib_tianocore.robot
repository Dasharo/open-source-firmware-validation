*** Settings ***
Documentation       Payload library: EDK2/Tianocore UEFI implementation of the
...                 firmware-specific boot flow. Implements the payload
...                 interface consumed by the generic boot keywords in
...                 keywords.robot and lib/bios/menus.robot. See
...                 lib/payload/payload-lib_linuxboot.robot for the LinuxBoot
...                 counterpart.

Library             Collections
Library             String
Resource            ../bios/menus.robot
Resource            ../../keywords.robot


*** Keywords ***
Payload Select Boot Device    # robocop: off=too-long-keyword
    [Documentation]    Tianocore/UEFI implementation of the payload boot-device
    ...    selection. Selects the boot entry for the requested OS from the UEFI
    ...    boot menu, falling back to a connected disk (SSD/HDD/MMC) from the
    ...    platform config if the OS entry is not present. Honours a SeaBIOS boot
    ...    device when configured and an already-read boot menu construction.
    ...
    ...    === Requirements ===
    ...    - Has to be called in quick succession after powering on or rebooting in order to
    ...    \ react before the auto boot time-out passes
    ...
    ...    === Arguments ===
    ...    - ``${env_id}`` - environment ID of the OS to boot
    ...    - ``${system_name}`` - boot menu entry name for that OS
    ...    - ``${boot_menu}`` - optional pre-read boot menu construction
    ...
    ...    === Effects ===
    ...    - Boots into the selected OS
    [Arguments]    ${env_id}    ${system_name}    ${boot_menu}=NOT_SET

    # Allow providing boot menu construction, if we are already in boot menu screen
    # and want to boot into OS from there
    IF    '''${boot_menu}''' == 'NOT_SET'
        ${menu_construction}=    Enter Boot Menu Tianocore And Return Construction
    ELSE
        VAR    ${menu_construction}=    ${boot_menu}
    END

    # When ESP scanning feature is there, boot entries are named differently than
    # they used to
    IF    ${ESP_SCANNING_SUPPORT} == ${TRUE}
        IF    "${system_name}" == "ubuntu"
            VAR    ${system_name}=    Ubuntu
        END
        IF    "${system_name}" == "fedora"
            VAR    ${system_name}=    Fedora
        END
        IF    "${system_name}" == "trenchboot" and "${MANUFACTURER}" == "QEMU"
            VAR    ${system_name}=    QEMU HARDDISK
        END
    ELSE
        # Without ESP_SCANNING it does not matter if the entry has lowercase
        # or upperase.
        VAR    @{lowercase_menu}=    @{EMPTY}
        FOR    ${line}    IN    @{menu_construction}
            ${lower}=    Convert To Lowercase    ${line}
            Append To List    ${lowercase_menu}    ${lower}
        END
        VAR    ${menu_construction}=    ${lowercase_menu}
        ${system_name}=    Convert To Lower Case    ${system_name}
    END
    ${is_system_present}=    Evaluate    "${system_name}" in """${menu_construction}"""
    IF    not ${is_system_present}
        Log    ${system_name} not found in Boot Menu
        ${ssd_list}=    Get Current CONFIG List Param    Storage_SSD    boot_name
        ${ssd_list_length}=    Get Length    ${ssd_list}
        IF    ${ssd_list_length} == 0
            ${hdd_list}=    Get Current CONFIG List Param    HDD_Storage    boot_name
            ${hdd_list_length}=    Get Length    ${hdd_list}
            IF    ${hdd_list_length} == 0
                ${mmc_list}=    Get Current CONFIG List Param    MMC_Storage    boot_name
                ${mmc_list_length}=    Get Length    ${mmc_list}
                IF    ${mmc_list_length} == 0
                    FAIL    "System was not found and there are no disk connected"
                END
                VAR    ${disk_name}=    ${mmc_list[0]}
            ELSE
                VAR    ${disk_name}=    ${hdd_list[0]}
            END
        ELSE
            VAR    ${disk_name}=    ${ssd_list[0]}
        END
        ${system_index}=    Get Index From List    ${menu_construction}    ${disk_name}
        IF    ${system_index} == -1
            Fail    Disk: ${disk_name} not found in Boot Menu
        END
    ELSE
        ${system_index}=    Get Index Of Matching Option In Menu    ${menu_construction}    ${system_name}
    END
    Press Key N Times And Enter    ${system_index}    ${ARROW_DOWN}

Payload Enter Setup Menu
    [Documentation]    Tianocore implementation: enter the UEFI setup menu.
    Enter Setup Menu Tianocore

Payload Enter Setup Menu And Return Construction
    [Documentation]    Tianocore implementation: enter the UEFI setup menu and
    ...    return its construction.
    ${menu}=    Enter Setup Menu Tianocore And Return Construction
    RETURN    ${menu}

Payload Enter Boot Menu And Return Construction
    [Documentation]    Tianocore implementation: enter the UEFI boot menu and
    ...    return its construction.
    ${menu}=    Enter Boot Menu Tianocore And Return Construction
    RETURN    ${menu}

Payload Reset To Defaults
    [Documentation]    Tianocore implementation: reset firmware settings to
    ...    defaults from within the setup menu.
    Reset To Defaults Tianocore
