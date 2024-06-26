*** Settings ***
Documentation       Collection of keywords related to EDK2 menus

Library             Collections
Library             String
Library             ./menus.py


*** Keywords ***
Enter Boot Menu Tianocore
    [Documentation]    Enter Boot Menu with tianocore boot menu key mapped in
    ...    keys list.
    Read From Terminal Until    ${TIANOCORE_STRING}
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Single Key PiKVM    ${BOOT_MENU_KEY}
    ELSE
        Write Bare Into Terminal    ${BOOT_MENU_KEY}
    END
    IF    ${LAPTOP_EC_SERIAL_WORKAROUND} == ${TRUE}
        # FIXME: Laptop EC serial workaround
        Press Key N Times    1    ${ARROW_DOWN}
        Press Key N Times    1    ${ARROW_UP}
    END

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
    # The maximum number of entries in boot menu is 11 right now. When we have
    # more, the list can be scrolled.
    # TODO: Is there a better way of checking if the list can be scrolled?
    # The UP/DOWN arrows are not drawn on serial on the first readout of
    # the menu, it seems.
    ${no_entries}=    Get Length    ${construction}
    IF    ${no_entries} == 11
        # 1. Remember first and last entries (last entry in the first screen)
        ${first_entry}=    Get From List    ${construction}    0

        # 2. Go down by 10 entries
        Press Key N Times    10    ${ARROW_DOWN}
        Sleep    1s
        Read From Terminal
        # 3. Keep going down one by one, until we reach the first_entry again
        FOR    ${iter}    IN RANGE    0    100
            Press Key N Times    1    ${ARROW_DOWN}
            ${out}=    Read From Terminal Until Regexp    > .*
            Log    ${out}
            ${lines}=    Split To Lines    ${out}
            ${entry}=    Get From List    ${lines}    -1
            ${entry}=    Strip String    ${entry}
            ${entry}=    Strip String    ${entry}    characters=>
            ${entry}=    Strip String    ${entry}
            IF    '${entry}' != '${first_entry}'
                Append To List    ${construction}    ${entry}
            ELSE
                BREAK
            END
        END
    END
    RETURN    ${construction}

Enter Boot Menu Tianocore And Return Construction
    [Documentation]    Enters boot menu, returning menu construction
    Enter Boot Menu Tianocore
    ${menu}=    Get Boot Menu Construction
    RETURN    ${menu}

Enter Setup Menu Tianocore
    [Documentation]    Enter Setup Menu with key specified in platform-configs.
    Read From Terminal Until    ${TIANOCORE_STRING}
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Single Key PiKVM    ${SETUP_MENU_KEY}
    ELSE
        Write Bare Into Terminal    ${SETUP_MENU_KEY}
    END

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
    [Arguments]    ${checkpoint}=ESC=exit    ${lines_top}=1    ${lines_bot}=0
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
    ...    one adjusts to change
    RETURN    ${construction}

Enter Setup Menu Tianocore And Return Construction
    [Documentation]    Enters Setup Menu and returns Setup Menu construction
    Enter Setup Menu Tianocore
    ${menu}=    Get Setup Menu Construction
    RETURN    ${menu}

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

Enter Submenu From Snapshot
    [Documentation]    Enter given Setup Menu Tianocore option after entering
    ...    Setup Menu Tianocore
    [Arguments]    ${menu}    ${option}
    ${index}=    Get Index Of Matching Option In Menu    ${menu}    ${option}
    Should Not Be Equal As Integers    ${index}    -1    msg=Option ${option} not found in menu
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}

Enter Submenu From Snapshot And Return Construction
    [Documentation]    Enter given Setup Menu Tianocore option after entering
    ...    Setup Menu Tianocore
    [Arguments]    ${menu}    ${option}    ${opt_only}=${FALSE}
    Enter Submenu From Snapshot    ${menu}    ${option}
    ${submenu}=    Get Submenu Construction    opt_only=${opt_only}
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

Enter Dasharo APU Configuration
    [Arguments]    ${setup_menu}
    ${apu_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Dasharo APU Configuration
    RETURN    ${apu_menu}

Enter Dasharo Submenu
    [Arguments]    ${dasharo_menu}    ${option}
    ${submenu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${dasharo_menu}
    ...    ${option}
    ...    opt_only=${TRUE}
    RETURN    ${submenu}

Get Index Of Matching Option In Menu
    [Documentation]    This keyword returns the index of element that matches
    ...    one in given menu
    [Arguments]    ${menu_construction}    ${option}    ${ignore_not_found_error}=${FALSE}
    FOR    ${element}    IN    @{menu_construction}
        ${matches}=    Run Keyword And Return Status
        ...    Should Match    ${element}    *${option}*
        IF    ${matches}
            ${option}=    Set Variable    ${element}
            BREAK
        END
    END
    ${index}=    Get Index From List    ${menu_construction}    ${option}
    IF    ${ignore_not_found_error} == ${FALSE}
        Should Be True    ${index} >= 0    Option ${option} not found in the list
    END
    RETURN    ${index}

Press Key N Times And Enter
    [Documentation]    Enter specified in the first argument times the specified
    ...    in the second argument key and then press Enter.
    [Arguments]    ${n}    ${key}
    Press Key N Times    ${n}    ${key}
    Press Enter

Press Enter
    # Before entering new menu, make sure we get rid of all leftovers
    Sleep    1s
    Read From Terminal
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Single Key PiKVM    Enter
    ELSE
        Press Key N Times    1    ${ENTER}
    END

Press Key N Times
    [Documentation]    Enter specified in the first argument times the specified
    ...    in the second argument key.
    [Arguments]    ${n}    ${key}
    FOR    ${index}    IN RANGE    0    ${n}
        IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
            Single Key PiKVM    ${key}
            # Key press time as defined in PiKVM library is 200ms. We need some
            # additional delay to make sure we can gather all input from terminal after
            # key press.
            Sleep    2s
        ELSE
            Write Bare Into Terminal    ${key}
            # Escape sequences in EDK2 have 2 seconds to complete on serial.
            # After 2 seconds if it is not completed, it is returned as a
            # keystroke. So we need at least 2 seconds interval for pressing
            # ESC for example.
            Sleep    2s
        END
    END

Get Option State
    [Documentation]    Gets menu construction and option name as arguments.
    ...    Returns option state, which can be: True, False, or numeric value.
    [Arguments]    ${menu}    ${option}
    ${index}=    Get Index Of Matching Option In Menu    ${menu}    ${option}
    ${value}=    Get Value From Brackets    ${menu}[${index}]
    IF    '${value}[0]' == 'X'
        ${state}=    Set Variable    ${TRUE}
    ELSE IF    '${value}[0]' == ' '
        ${state}=    Set Variable    ${FALSE}
    ELSE
        ${state}=    Set Variable    ${value}
    END
    RETURN    ${state}

Get Option Type
    [Documentation]    Accepts option state and returns option type. Option
    ...    type can be one of:    bool, numeric, list.
    [Arguments]    ${state}
    # This type of field can either be boolean ([X] or [ ]), or free entry
    # field. At first, find out which one is it.
    IF    '${state}' == '${TRUE}' or '${state}' == '${FALSE}'
        ${type}=    Set Variable    bool
    ELSE
        ${status}=    Run Keyword And Return Status
        ...    Convert To Integer    ${state}
        IF    ${status} == ${TRUE}
            ${type}=    Set Variable    numeric
        ELSE
            ${type}=    Set Variable    list
        END
    END
    RETURN    ${type}

Select State From List
    [Documentation]    Accepts a list of option and states (current and target).
    ...    Selects the target state.
    [Arguments]    ${list}    ${current_state}    ${target_state}
    # Calculate offset and direction
    ${current_index}=    Get Index Of Matching Option In Menu    ${list}    ${current_state}
    Should Not Be Equal As Integers    ${current_index}    -1
    ${target_index}=    Get Index Of Matching Option In Menu    ${list}    ${target_state}
    Should Not Be Equal As Integers    ${target_index}    -1
    ${diff_index}=    Evaluate    ${target_index} - ${current_index}
    IF    ${diff_index} > 0
        ${direction}=    Set Variable    ${ARROW_DOWN}
        ${offset}=    Set Variable    ${diff_index}
    ELSE
        ${direction}=    Set Variable    ${ARROW_UP}
        ${offset}=    Evaluate    -1 * ${diff_index}
    END
    # Select the target state
    Press Key N Times And Enter    ${offset}    ${direction}

Set Option State
    [Documentation]    Gets menu construction option name, and desired state
    ...    as arguments. Return TRUE if the option was changed and FALSE if
    ...    option was already in target state.
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
            IF    ${LAPTOP_EC_SERIAL_WORKAROUND} == ${TRUE}
                # FIXME: Laptop EC serial workaround
                Press Key N Times    1    ${ARROW_DOWN}
                Press Key N Times    1    ${ARROW_UP}
            END

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
        RETURN    ${TRUE}
    ELSE
        Log    Nothing to do. Desired state is already set.
        RETURN    ${FALSE}
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
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    ${IPXE_BOOT_ENTRY}
    IF    ${NETBOOT_UTILITIES_SUPPORT} == ${TRUE}
        ${ipxe_menu}=    Get IPXE Boot Menu Construction    lines_top=2
    ELSE
        ${ipxe_menu}=    Get IPXE Boot Menu Construction
    END
    Enter Submenu From Snapshot    ${ipxe_menu}    iPXE Shell
    Set Prompt For Terminal    iPXE>
    Read From Terminal Until Prompt

Exit From Current Menu
    [Documentation]    Exits from current menu, refreshing screen.
    # Before entering new menu, make sure we get rid of all leftovers
    Read From Terminal
    Press Key N Times    1    ${ESC}

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
    [Arguments]    ${keys_password}
    FOR    ${key}    IN    @{keys_password}
        Write Bare Into Terminal    ${key}
        Sleep    0.5s
    END
    Press Key N Times    1    ${ENTER}

# This should stay, maybe improved if needed

Type In New Disk Password
    [Documentation]    Types in new disk password when prompted. The actual
    ...    password is passed as list of keys.
    [Arguments]    ${keys_password}
    Read From Terminal Until    your new password
    Sleep    0.5s
    # FIXME: Often the TCG OPAL test fails to enter Setup Menu after typing
    # password, and the default boot path proceeds instead. Pressing Setup Key
    # at this point allows to enter Setup Menu much more reliably.
    Press Key N Times    1    ${SETUP_MENU_KEY}
    FOR    ${i}    IN RANGE    0    2
        Type In The Password    ${keys_password}
        Sleep    1s
    END

# This should stay, maybe improved if needed

Type In BIOS Password
    [Documentation]    Types in password in general BIOS prompt
    [Arguments]    ${keys_password}
    Read From Terminal Until    password
    Sleep    0.5s
    Type In The Password    ${keys_password}

# This should stay, maybe improved if needed

Type In Disk Password
    [Documentation]    Types in the disk password
    [Arguments]    ${keys_password}
    Read From Terminal Until    Unlock
    Sleep    0.5s
    # FIXME: See a comment in: Type in new disk password
    Press Key N Times    1    ${SETUP_MENU_KEY}
    Type In The Password    ${keys_password}
    Press Key N Times    1    ${ENTER}

# This should stay, maybe improved if needed

Remove Disk Password
    [Documentation]    Removes disk password
    [Arguments]    ${keys_password}
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
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
    Save Changes And Reset
    Read From Terminal Until    Unlock
    FOR    ${i}    IN RANGE    0    2
        Type In The Password    ${keys_password}
        Sleep    0.5s
    END
    Press Key N Times    1    ${SETUP_MENU_KEY}

Tianocore Reset System
    # EDK2 interprets Alt + Ctrl + Del on USB keyboards as reset combination.
    # On serial console it is ESC R ESC r ESC R.
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        FAIL    SSH not supported for interfacing with TianoCore
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Telnet.Write Bare    \x1bR\x1br\x1bR
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        FAIL    OpenBMC not yet supported for interfacing with TianoCore
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        @{reset_combo}=    Create List    AltRight    ControlRight    Delete
        Key Combination PiKVM    ${reset_combo}
    ELSE
        FAIL    Unknown connection method for config: ${CONFIG}
    END

Save Changes
    [Documentation]    Saves current UEFI settings
    Press Key N Times    1    ${F10}
    Read From Terminal Until    Save configuration changes?
    Sleep    1s
    Write Bare Into Terminal    y
    Sleep    2s

Save Changes And Reset
    [Documentation]    Saves current UEFI settings and restarts.
    Save Changes
    Tianocore Reset System

Boot System Or From Connected Disk
    [Documentation]    Tries to boot ${system_name}. If it is not possible then it tries
    ...    to boot from connected disk set up in config
    [Arguments]    ${system_name}
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    ${menu_construction}=    Enter Boot Menu Tianocore And Return Construction
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
                ${mmc_list}=    Get Current CONFIG List Param    MMC_Storage    boot_name
                ${mmc_list_length}=    Get Length    ${mmc_list}
                IF    ${mmc_list_length} == 0
                    FAIL    "System was not found and there are no disk connected"
                END
                ${disk_name}=    Set Variable    ${mmc_list[0]}
            ELSE
                ${disk_name}=    Set Variable    ${hdd_list[0]}
            END
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
    IF    not ${DASHARO_NETWORKING_MENU_SUPPORT}    RETURN
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${index}=    Get Index Of Matching Option In Menu    ${dasharo_menu}    Networking Options
    IF    ${index} != -1
        ${network_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
        ${index}=    Get Index Of Matching Option In Menu    ${network_menu}    Enable network boot
        IF    ${index} != -1
            Set Option State    ${network_menu}    Enable network boot    ${TRUE}
            Save Changes And Reset
            Sleep    10s
        END
    END

Make Sure That Flash Locks Are Disabled
    [Documentation]    Keyword makes sure firmware flashing is not prevented by
    ...    any Dasharo Security Options, if they are present.
    IF    not ${DASHARO_SECURITY_MENU_SUPPORT}    RETURN
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${index}=    Get Index Of Matching Option In Menu
    ...    ${dasharo_menu}    Dasharo Security Options
    IF    ${index} != -1
        ${security_menu}=    Enter Dasharo Submenu
        ...    ${dasharo_menu}    Dasharo Security Options
        ${index}=    Get Index Of Matching Option In Menu
        ...    ${security_menu}    Lock the BIOS boot medium    ${TRUE}
        IF    ${index} != -1
            Set Option State    ${security_menu}    Lock the BIOS boot medium    ${FALSE}
            Reenter Menu
        END
        ${index}=    Get Index Of Matching Option In Menu
        ...    ${security_menu}    Enable SMM BIOS write    ${TRUE}
        IF    ${index} != -1
            Set Option State    ${security_menu}    Enable SMM BIOS write    ${FALSE}
            Reenter Menu
        END
        Save Changes And Reset
    END

Get Firmware Version From Tianocore Setup Menu
    [Documentation]    Keyword allows to read firmware version from Tianocore
    ...    Setup menu header.
    Enter Setup Menu Tianocore
    ${output}=    Read From Terminal Until    Select Entry
    ${firmware_line}=    Get Lines Containing String    ${output}    Dasharo (coreboot+UEFI)
    ${firmware_version}=    Get Regexp Matches    ${firmware_line}    v\\d{1,}\.\\d{1,}\.\\d{1,}
    RETURN    ${firmware_version}

Get USB Boot Option
    [Documentation]    Returns the full name of the first boot option
    ...    containing "USB"
    ${menu}=    Enter Setup Menu Tianocore And Return Construction
    ${menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${menu}
    ...    One Time Boot
    Press Key N Times    1    ${ARROW_DOWN}
    Read From Terminal
    Press Key N Times    1    ${ARROW_UP}
    FOR    ${menu_option}    IN    @{menu}
        ${screen}=    Read From Terminal
        ${start}=    Call Method    ${screen}    index    Device Path :
        ${end}=    Call Method    ${screen}    index    F9\=Reset
        ${screen}=    Get Substring    ${screen}    ${start}    ${end}
        @{screen_lines}=    Split To Lines    ${screen}
        ${side_text}=    Set Variable    ${EMPTY}
        FOR    ${index}    ${line}    IN ENUMERATE    @{screen_lines}
            ${len}=    Get Length    ${line}
            IF    ${len} < 54    CONTINUE
            ${side_text}=    Catenate    ${side_text}    ${line}[-25:]
        END
        ${side_text}=    Remove String    ${side_text}    \n    ${SPACE}
        ${is_usb}=    Run Keyword And Return Status
        ...    Should Contain    ${side_text}    USB    ignore_case=${TRUE}
        IF    ${is_usb}    RETURN    ${menu_option}
        Press Key N Times    1    ${ARROW_DOWN}
    END
    FAIL    "No USB boot option found"
