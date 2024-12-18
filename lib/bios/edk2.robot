*** Settings ***
Documentation       Collection of keywords related to EDK2 menus

Library             Collections
Library             String
Library             ./menus.py
Resource            common.robot


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

Enter Setup Menu Tianocore And Return Construction
    [Documentation]    Enters Setup Menu and returns Setup Menu construction
    Enter Setup Menu
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

Get Option State
    [Documentation]    Gets menu construction and option name as arguments.
    ...    Returns option state, which can be: True, False, or numeric value.
    [Arguments]    ${menu}    ${option}
    ${index}=    Get Index Of Matching Option In Menu    ${menu}    ${option}
    ${value}=    Get Value From Brackets    ${menu}[${index}]
    ${len}=    Get Length    ${value}

    ${state}=    Set Variable    ${value}
    IF    ${len} == 1
        IF    '${value}[0]' == 'X'
            ${state}=    Set Variable    ${TRUE}
        ELSE IF    '${value}[0]' == ' '
            ${state}=    Set Variable    ${FALSE}
        END
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
    Tianocore Reset System
    ${main_menu}=    Enter Setup Menu Tianocore And Return Construction
    Read From Terminal
    Press Key N Times    1    ${F9}
    Read From Terminal Until    ignore.
    Write Bare Into Terminal    y

    IF    ${DASHARO_SERIAL_PORT_MENU_SUPPORT}
        ${dasharo_menu}=    Enter Dasharo System Features    ${main_menu}
        ${serial_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Serial Port Configuration
        # The Serial Redirection option is called differently in some versions of Dasharo
        # MSI z690-ddr5 v1.1.3 has "Enable Serial Port", v1.1.4 has "Enable COM0 Serial"
        TRY
            Set Option State    ${serial_menu}    Enable COM0 Serial    ${TRUE}
        EXCEPT
            Set Option State    ${serial_menu}    Enable Serial Port    ${TRUE}
        END
    END

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

Get Firmware Version From Tianocore Setup Menu
    [Documentation]    Keyword allows to read firmware version from Tianocore
    ...    Setup menu header.
    Enter Setup Menu
    ${output}=    Read From Terminal Until    Select Entry
    ${firmware_line}=    Get Lines Containing String    ${output}    Dasharo (coreboot+UEFI)
    ${firmware_version}=    Get Regexp Matches    ${firmware_line}    v\\d{1,}\.\\d{1,}\.\\d{1,}
    RETURN    ${firmware_version}
