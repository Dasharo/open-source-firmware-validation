*** Settings ***
Documentation       Collection of keywords related to EDK2 menus

Library             Collections
Library             String
Library             ./menus-dasharo.py
Resource            ./menus-common.robot


*** Keywords ***
Get Boot Menu Construction
    [Documentation]    Keyword allows to get and return boot menu construction.
    ${menu}=    Read From Terminal Until    exit
    # Lines to strip:
    #    TOP:
    #    Please select boot device:
    #    BOTTOM
    #    ^ and v to move selection
    #    ENTER to select boot device
    #    ESC to exit
    ${construction}=    Parse Menu Snapshot Into Construction    ${menu}    1    3
    RETURN    ${construction}

Get Setup Menu Construction
    [Documentation]    Keyword allows to get and return setup menu construction.
    [Arguments]    ${checkpoint}=Select Entry
    # Lines to strip:
    #    TOP:
    #    Standard PC (Q35 + ICH9 2009)
    #    pc-q35-7.2    2.00 GHz
    #    0.0.0    128 MB RAM
    #    BOTTOM
    #    ^v=Move Highlight    <Enter>=Select Entry
    ${menu}=    Get Menu Construction    ${checkpoint}    3    1
    RETURN    ${menu}

Get Menu Construction
    [Documentation]    Keyword allows to get and return setup menu construction.
    [Arguments]    ${checkpoint}=Esc=Exit    ${lines_top}=1    ${lines_bot}=0
    ${out}=    Read From Terminal Until    ${checkpoint}
    ${menu}=    Parse Menu Snapshot Into Construction    ${out}    ${lines_top}    ${lines_bot}
    RETURN    ${menu}

Parse Menu Snapshot Into Construction
    [Documentation]    Breaks grabbed menu data into lines.
    [Arguments]    ${menu}    ${lines_top}    ${lines_bot}
    ${slice_start}=    Set Variable    ${lines_top}
    IF    ${lines_bot} == 0
        ${slice_end}=    Set Variable    None
    ELSE
        ${slice_end}=    Evaluate    ${lines_bot} * -1
    END
    ${menu}=    Remove String    ${menu}    \r
    @{menu_lines}=    Split To Lines    ${menu}
    @{construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        # Replace multiple spaces with a single one
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        # Remove leading and trailing spaces
        ${line}=    Strip String    ${line}
        # Drop leading and trailing pipes (e.g. in One Time Boot Menu)
        ${line}=    Strip String    ${line}    characters=|
        # Remove leading and trailing spaces
        ${line}=    Strip String    ${line}
        # Drop all remaining borders
        ${line}=    Remove String Using Regexp    ${line}    ^[\\|\\s/\\\\-]+$
        # If the resulting line is not empty, add it as a menu entry
        ${length}=    Get Length    ${line}
        IF    ${length} > 0    Append To List    ${construction}    ${line}
    END
    Log    ${construction}
    ${construction}=    Get Slice From List    ${construction}    ${slice_start}    ${slice_end}
    # TODO: Improve parsing of the menu into construction. It can probably be
    # simplified, but at least we have this only in one kewyrod not in multiple
    # ones.
    # Make sure to remove control help text appearing in the screen if somehow
    # they are still there.
    Remove Values From List
    ...    ${construction}
    ...    Esc\=Exit
    ...    ^v\=Move High
    ...    <Enter>\=Select Entry
    ...    F9\=Reset to Defaults F10\=Save
    ...    LCtrl+LAlt+F12\=Save screenshot
    ...    <Spacebar>Toggle Checkbox
    RETURN    ${construction}

Get Submenu Construction
    [Arguments]    ${checkpoint}=Esc=Exit    ${lines_top}=1    ${lines_bot}=1    ${opt_only}="${FALSE}"
    # In most cases, we need to strip two lines:
    #    TOP:
    #    Title line, such as:    Dasharo System Features
    #    BOTTOM:
    #    Help line, such as:    F9=Reset to Defaults    Esc=Exit
    ${submenu}=    Get Menu Construction    ${checkpoint}    ${lines_top}    ${lines_bot}
    # Handling of additional exceptions appearing in submenus:
    #    1. Drop unselectable strings from Device Manager
    Remove Values From List    ${submenu}    Devices List

    IF    ${opt_only} == ${TRUE}
        # Handling exceptions caused by some options splitting into multiple lines.
        # For Dasharo System Features options, we can assume that each entry has
        # either ">", or "[ ]", or "< >". For other edk2 menus, this is not always
        # the case (yet?).
        FOR    ${entry}    IN    @{submenu}
            ${status}=    Check If Menu Line Is An Option    ${entry}
            IF    ${status} != ${TRUE}
                Remove Values From List    ${submenu}    ${entry}
            END
        END
    END
    RETURN    ${submenu}

Save BIOS Changes
    [Documentation]    This keyword saves introduced changes
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y

Enter Dasharo System Features
    [Arguments]    ${setup_menu}
    ${dasharo_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Dasharo System Features
    RETURN    ${dasharo_menu}

Enter Dasharo Submenu
    [Arguments]    ${dasharo_menu}    ${option}
    ${submenu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${dasharo_menu}
    ...    ${option}
    ...    opt_only=${TRUE}
    RETURN    ${submenu}

Set Option State
    [Documentation]    Gets menu construction option name, and desired state
    ...    as arguments.
    [Arguments]    ${menu}    ${option}    ${target_state}
    ${current_state}=    Get Option State    ${menu}    ${option}
    IF    '${current_state}' != '${target_state}'
        ${type}=    Get Option Type    ${current_state}
        Enter Submenu From Snapshot    ${menu}    ${option}
        IF    '${type}' == 'numeric'
            Write Bare Into Terminal    ${target_state}
            Press Enter
        END
        IF    '${type}' == 'list'
            ${out}=    Read From Terminal Until    ---/
            ${list}=    Extract Strings From Frame    ${out}
            # TODO: Temporarily disabled due to the complexity with
            # options spanning into multiple lines.
            # List Should Contain Value
            # ...    ${list}
            # ...    ${target_state}
            # ...    Target state ${target_state} not available in the list
            Select State From List    ${list}    ${current_state}    ${target_state}
        END
    ELSE
        Log    Nothing to do. Desired state is already set.
    END

Try To Insert Non-numeric Values Into Numeric Option
    [Documentation]    Check whether accepts only numeric values.
    [Arguments]    ${menu}    ${option}
    ${non_numeric_characters}=    Set Variable
    ...    abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()`~<>,./?;:'\|""[]{}=+-_
    ${current_state}=    Get Option State    ${menu}    ${option}
    ${type}=    Get Option Type    ${current_state}
    Enter Submenu From Snapshot    ${menu}    ${option}
    IF    '${type}' == 'numeric'
        @{characters}=    Split String To Characters    ${non_numeric_characters}
        FOR    ${char}    IN    @{characters}
            Log    ${char}
            Write Bare Into Terminal    ${char}
            Set DUT Response Timeout    3
            Read From Terminal Until    !!
        END
    ELSE
        Fail    Wrong option type (not accept numeric value)
    END

Get IPXE Boot Menu Construction
    [Documentation]    Keyword allows to get and return iPXE menu construction.
    [Arguments]    ${lines_top}=1    ${lines_bot}=0    ${checkpoint}=${EDK2_IPXE_CHECKPOINT}
    ${menu}=    Read From Terminal Until    ${checkpoint}
    ${construction}=    Parse Menu Snapshot Into Construction    ${menu}    ${lines_top}    ${lines_bot}
    RETURN    ${construction}

############################################################################
### Below keywords still must be reviewed and reworked. We should reuse the
### keywords from above, and remove as much as possible the ones below.
############################################################################

# TODO: Should probably stay in this file, if it works correctly. Adding test
# for QEMU under self-tests would be nice, to make sure it always works.

Reset To Defaults Tianocore
    [Documentation]    Resets all Tianocore options to defaults. It is invoked
    ...    by pressing F9 and confirming with 'y' when in option
    ...    setting menu.
    Read From Terminal
    Press Key N Times    1    ${F9}
    Read From Terminal Until    ignore.
    Write Bare Into Terminal    y

# TODO:
# The SeaBIOS part can be removed.
# The implementation should probably be replaced by a keyword selecting
# entry from boot menu. "Enter Submenu From Snapshot" would probably work here.
#
# Need to be changed in tests
#
# Test in QEMU under self-tests would be nice, but QEMU does not support
# network boot just yet.

Enter IPXE
    [Documentation]    Enter iPXE after device power cutoff.
    # TODO:    problem with iPXE string (e.g. when 3 network interfaces are available)
    ${boot_menu}=    Enter Boot Menu And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    ${IPXE_BOOT_ENTRY}
    ${ipxe_menu}=    Get IPXE Boot Menu Construction
    Enter Submenu From Snapshot    ${ipxe_menu}    iPXE Shell
    Set Prompt For Terminal    iPXE>
    Read From Terminal Until Prompt

Reenter Menu
    [Documentation]    Returns to the previous menu and enters the same one
    ...    again
    [Arguments]    ${forward}=${FALSE}
    IF    ${forward} == True
        Press Enter
        Exit From Current Menu
    ELSE
        Exit From Current Menu
        Press Enter
    END

Reenter Menu And Return Construction
    [Documentation]    Enters the same menu again, returning updated menu construction
    [Arguments]    ${forward}=${FALSE}
    Reenter Menu    ${forward}
    ${menu}=    Get Submenu Construction
    RETURN    ${menu}

# This should stay, maybe improved if needed

Type In The Password
    [Documentation]    Operation for typing in the password
    [Arguments]    @{keys_password}
    FOR    ${key}    IN    @{keys_password}
        Write Bare Into Terminal    ${key}
        Sleep    0.5s
    END
    Press Key N Times    1    ${ENTER}

# This should stay, maybe improved if needed

Type In New Disk Password
    [Documentation]    Types in new disk password when prompted. The actual
    ...    password is passed as list of keys.
    [Arguments]    @{keys_password}
    Read From Terminal Until    your new password
    Sleep    0.5s
    # FIXME: Often the TCG OPAL test fails to enter Setup Menu after typing
    # password, and the default boot path proceeds instead. Pressing Setup Key
    # at this point allows to enter Setup Menu much more reliably.
    Press Key N Times    1    ${SETUP_MENU_KEY}
    FOR    ${i}    IN RANGE    0    2
        Type In The Password    @{keys_password}
        Sleep    1s
    END

# This should stay, maybe improved if needed

Type In BIOS Password
    [Documentation]    Types in password in general BIOS prompt
    [Arguments]    @{keys_password}
    Read From Terminal Until    password
    Sleep    0.5s
    Type In The Password    @{keys_password}

# This should stay, maybe improved if needed

Type In Disk Password
    [Documentation]    Types in the disk password
    [Arguments]    @{keys_password}
    Read From Terminal Until    Unlock
    Sleep    0.5s
    # FIXME: See a comment in: Type in new disk password
    Press Key N Times    1    ${SETUP_MENU_KEY}
    Type In The Password    @{keys_password}
    Press Key N Times    1    ${ENTER}

# This should stay, maybe improved if needed

Remove Disk Password
    [Documentation]    Removes disk password
    [Arguments]    @{keys_password}
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${device_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    ${tcg_drive_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${device_mgr_menu}
    ...    TCG Drive Management
    # if we want to remove password, we can assume that it is turned on so, we
    # don't have to check all the options
    Log    Select entry: Admin Revert to factory default and Disable
    Press Key N Times    1    ${ENTER}
    Press Key N Times And Enter    4    ${ARROW_DOWN}
    Save Changes And Reset    3
    Read From Terminal Until    Unlock
    FOR    ${i}    IN RANGE    0    2
        Type In The Password    @{keys_password}
        Sleep    0.5s
    END
    Press Key N Times    1    ${SETUP_MENU_KEY}

Save Changes
    [Documentation]    Saves current UEFI settings
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y

Save Changes And Reset
    [Documentation]    Saves current UEFI settings and restarts. ${nesting_level}
    ...    is how deep user is currently in the settings.
    ...    ${main_menu_steps_to_reset} means how many times should
    ...    arrow down be pressed to get to the Reset option in main
    ...    settings menu
    # robocop: disable=unused-argument
    [Arguments]    ${nesting_level}=2    ${main_menu_steps_to_reset}=5
    # robocop: enable
    Save Changes
    Sleep    1s
    Reset System

Boot System Or From Connected Disk
    [Documentation]    Tries to boot ${system_name}. If it is not possible then it tries
    ...    to boot from connected disk set up in config
    [Arguments]    ${system_name}
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    ${menu_construction}=    Enter Boot Menu And Return Construction
    # When ESP scanning feature is there, boot entries are named differently than
    # they used to
    IF    ${ESP_SCANNING_SUPPORT} == ${TRUE}
        IF    "${system_name}" == "ubuntu"
            ${system_name}=    Set Variable    Ubuntu
        END
    END
    ${is_system_present}=    Evaluate    "${system_name}" in """${menu_construction}"""
    IF    not ${is_system_present}
        ${ssd_list}=    Get Current CONFIG List Param    Storage_SSD    boot_name
        ${ssd_list_length}=    Get Length    ${ssd_list}
        IF    ${ssd_list_length} == 0
            ${hdd_list}=    Get Current CONFIG List Param    HDD_Storage    boot_name
            ${hdd_list_length}=    Get Length    ${hdd_list}
            IF    ${hdd_list_length} == 0
                FAIL    "System was not found and there are no disk connected"
            END
            ${disk_name}=    Set Variable    ${hdd_list[0]}
        ELSE
            ${disk_name}=    Set Variable    ${ssd_list[0]}
        END
        ${system_index}=    Get Index From List    ${menu_construction}    ${disk_name}
        IF    ${system_index} == -1
            Fail    Disk: ${disk_name} not found in Boot Menu
        END
    ELSE
        ${system_index}=    Get Index Of Matching Option In Menu    ${menu_construction}    ${system_name}
    END
    Press Key N Times And Enter    ${system_index}    ${ARROW_DOWN}

Make Sure That Network Boot Is Enabled
    [Documentation]    This keywords checks that "Enable network boot" in
    ...    "Networking Options" is enabled when present, so the network
    ...    boot tests can be executed.
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${index}=    Get Index Of Matching Option In Menu    ${dasharo_menu}    Networking Options
    IF    ${index} != -1
        ${network_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
        ${index}=    Get Index Of Matching Option In Menu    ${network_menu}    Enable network boot
        IF    ${index} != -1
            Set Option State    ${network_menu}    Enable network boot    ${TRUE}
            Save Changes And Reset    2    4
            Sleep    10s
        END
    END

Make Sure That Flash Locks Are Disabled
    [Documentation]    Keyword makes sure firmware flashing is not prevented by
    ...    any Dasharo Security Options, if they are present.
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${index}=    Get Index Of Matching Option In Menu
    ...    ${dasharo_menu}    Dasharo Security Options
    IF    ${index} != -1
        ${security_menu}=    Enter Dasharo Submenu
        ...    ${dasharo_menu}    Dasharo Security Options
        ${index}=    Get Index Of Matching Option In Menu
        ...    ${security_menu}    Lock the BIOS boot medium
        IF    ${index} != -1
            Set Option State    ${security_menu}    Lock the BIOS boot medium    ${FALSE}
            Reenter Menu
        END
        ${index}=    Get Index Of Matching Option In Menu
        ...    ${security_menu}    Enable SMM BIOS write
        IF    ${index} != -1
            Set Option State    ${security_menu}    Enable SMM BIOS write    ${FALSE}
            Reenter Menu
        END
        Save Changes And Reset    2    4
    END

Get Firmware Version From Tianocore Setup Menu
    [Documentation]    Keyword allows to read firmware version from Tianocore
    ...    Setup menu header.
    Enter Setup Menu
    ${output}=    Read From Terminal Until    Select Entry
    ${firmware_line}=    Get Lines Containing String    ${output}    Dasharo (coreboot+UEFI)
    ${firmware_version}=    Get Regexp Matches    ${firmware_line}    v\\d{1,}\.\\d{1,}\.\\d{1,}
    RETURN    ${firmware_version}

Disable Firmware Flashing Prevention Options
    [Documentation]    Keyword makes sure firmware flashing is not prevented by
    ...    any Dasharo Security Options, if they are present.
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${index}=    Get Index Of Matching Option In Menu
    ...    ${dasharo_menu}    Dasharo Security Options
    IF    ${index} != -1
        ${security_menu}=    Enter Dasharo Submenu
        ...    ${dasharo_menu}    Dasharo Security Options
        ${index}=    Get Index Of Matching Option In Menu
        ...    ${security_menu}    Lock the BIOS boot medium
        IF    ${index} != -1
            Set Option State    ${security_menu}    Lock the BIOS boot medium    ${FALSE}
            Reenter Menu
        END
        ${index}=    Get Index Of Matching Option In Menu
        ...    ${security_menu}    Enable SMM BIOS write
        IF    ${index} != -1
            Set Option State    ${security_menu}    Enable SMM BIOS write    ${FALSE}
            Reenter Menu
        END
        Save Changes And Reset    2    4
    END
