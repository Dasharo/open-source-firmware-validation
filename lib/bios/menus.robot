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
    ${construction}=    Get Menu Construction    ${checkpoint}    3    1
    RETURN    ${construction}

Get Menu Construction
    [Documentation]    Keyword allows to get and return setup menu construction.
    [Arguments]    ${checkpoint}=Press ESC to exit.    ${lines_top}=1    ${lines_bot}=0
    ${menu}=    Read From Terminal Until    ${checkpoint}
    ${construction}=    Parse Menu Snapshot Into Construction    ${menu}    ${lines_top}    ${lines_bot}
    RETURN    ${construction}

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
    RETURN    ${construction}

Enter Setup Menu Tianocore And Return Construction
    [Documentation]    Enters Setup Menu and returns Setup Menu construction
    Enter Setup Menu Tianocore
    ${menu}=    Get Setup Menu Construction
    RETURN    ${menu}

Get Submenu Construction
    [Arguments]    ${checkpoint}=Esc=Exit    ${lines_top}=1    ${lines_bot}=1
    # In most cases, we need to strip two lines:
    #    TOP:
    #    Title line, such as:    Dasharo System Features
    #    BOTTOM:
    #    Help line, such as:    F9=Reset to Defaults    Esc=Exit
    ${submenu}=    Get Menu Construction    ${checkpoint}    ${lines_top}    ${lines_bot}
    # Handling of additional exceptions appearing in submenus:
    #    1. Drop unselectable strings from Device Manager
    Remove Values From List    ${submenu}    Devices List
    RETURN    ${submenu}

Enter Submenu From Snapshot
    [Documentation]    Enter given Setup Menu Tianocore option after entering
    ...    Setup Menu Tianocore
    [Arguments]    ${menu}    ${option}
    ${index}=    Get Index Of Matching Option In Menu    ${menu}    ${option}
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}

Enter Submenu From Snapshot And Return Construction
    [Documentation]    Enter given Setup Menu Tianocore option after entering
    ...    Setup Menu Tianocore
    [Arguments]    ${menu}    ${option}
    Enter Submenu From Snapshot    ${menu}    ${option}
    ${submenu}=    Get Submenu Construction
    RETURN    ${submenu}

Save BIOS Changes
    [Documentation]    This keyword saves introduced changes
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y

Enter Dasharo System Features Submenu
    [Documentation]    Grabs current menu, finds specified ${submenu} and
    ...    returns its contents.
    [Arguments]    ${submenu}
    ${menu}=    Read From Terminal Until    Esc=Exit
    ${menu_construction}=    Enter Dasharo System Features Submenu Snapshot    ${menu}    ${submenu}
    RETURN    ${menu_construction}

Enter Dasharo System Features Submenu Snapshot
    [Documentation]    Version of "Enter Dasharo System Features Submenu" that
    ...    processes menu grabbed beforehand.
    [Arguments]    ${menu_construction}    ${submenu}
    ${menu_construction}=    Parse Menu Snapshot Into Construction    ${menu_construction}    3
    ${system_index}=    Get Index From List    ${menu_construction}    Dasharo System Features
    Press Key N Times And Enter    ${system_index}    ${ARROW_DOWN}
    ${menu_construction}=    Get Setup SubMenu Construction
    ${system_index}=    Get Index From List    ${menu_construction}    ${submenu}
    IF    ${system_index} == -1    Skip    msg=Menu option not found
    Press Key N Times And Enter    ${system_index}    ${ARROW_DOWN}
    ${menu_construction}=    Get Setup Submenu Construction
    RETURN    ${menu_construction}

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
    # Handling exceptions caused by some options splitting into multiple lines.
    # For Dasharo System Features options, we can assume that each entry has
    # either ">", or "[ ]", or "< >". For other edk2 menus, this is not always
    # the case.
    FOR    ${entry}    IN    @{submenu}
        ${status}=    Check If Menu Line Is An Option    ${entry}
        IF    ${status} != ${TRUE}
            Remove Values From List    ${submenu}    ${entry}
        END
    END
    RETURN    ${submenu}

Get Index Of Matching Option In Menu
    [Documentation]    This keyword returns the index of element that matches
    ...    one in given menu
    [Arguments]    ${menu_construction}    ${option}
    FOR    ${element}    IN    @{menu_construction}
        ${matches}=    Run Keyword And Return Status
        ...    Should Match    ${element}    *${option}*
        IF    ${matches}
            ${option}=    Set Variable    ${element}
            BREAK
        END
    END
    ${index}=    Get Index From List    ${menu_construction}    ${option}
    Should Be True    ${index} >= 0    Option ${option} not found in the list
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
            Sleep    1s
        ELSE
            Write Bare Into Terminal    ${key}
        END
    END

Get Option State
    [Documentation]    Gets menu construction and option name as arguments.
    ...    Returns option state, which can be: True, False, or numeric value.
    [Arguments]    ${menu}    ${option}
    ${index}=    Get Index Of Matching Option In Menu    ${menu}    ${option}
    ${value}=    Get Value From Brackets    ${menu}[${index}]
    IF    '${value}' == 'X'
        ${state}=    Set Variable    ${TRUE}
    ELSE IF    '${value}' == ' '
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
    ${current_index}=    Get Index From List    ${list}    ${current_state}
    ${target_index}=    Get Index From List    ${list}    ${target_state}
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
            List Should Contain Value
            ...    ${list}
            ...    ${target_state}
            ...    Target state ${target_state} not available in the list
            Select State From List    ${list}    ${current_state}    ${target_state}
        END
    ELSE
        Log    Nothing to do. Desired state is already set.
    END

############################################################################
### Below keywords still must be reviewed and reworked. We should reuse the
### keywords from above, and remove as much as possible the ones below.
############################################################################

Enter Dasharo Submenu Snapshot
    [Documentation]    Version of "Enter Dasharo Submenu" that processes menu
    ...    grabbed beforehand.
    [Arguments]    ${menu_construction}    ${submenu}
    ${menu_construction}=    Parse Menu Snapshot Into Construction    ${menu_construction}    3
    ${system_index}=    Get Index From List    ${menu_construction}    ${submenu}
    IF    ${system_index} == -1    Skip    msg=Menu option not found
    Press Key N Times And Enter    ${system_index}    ${ARROW_DOWN}
    ${menu_construction}=    Get Setup Submenu Construction    checkpoint=Esc=Exit
    RETURN    ${menu_construction}

Change Numeric Value Of Setting
    [Documentation]    Changes numeric value of ${setting} present in menu to
    ...    ${value}
    [Arguments]    ${setting}    ${value}    ${checkpoint}=ESC to exit
    Enter Submenu In Tianocore    ${setting}    ${checkpoint}    description_lines=2
    Write Bare Into Terminal    ${value}
    Press Key N Times    1    ${ENTER}

Reset To Defaults Tianocore
    [Documentation]    Resets all Tianocore options to defaults. It is invoked
    ...    by pressing F9 and confirming with 'y' when in option
    ...    setting menu.
    Read From Terminal
    Press Key N Times    1    ${F9}
    Read From Terminal Until    ignore.
    Write Bare Into Terminal    y

Enter Secure Boot Configuration Submenu
    [Documentation]    Enter to the Secure Boot Configuration submenu which
    ...    should be located in the Setup Menu.

    ${menu_construction}=    Get Setup Menu Construction
    ${index}=    Get Index From List    ${menu_construction}    Secure Boot Configuration
    Press Key N Times And Enter    2    ${ARROW_DOWN}

Enter IPXE
    [Documentation]    Enter iPXE after device power cutoff.
    # TODO:    2 methods for entering iPXE (Ctrl-B and SeaBIOS)
    # TODO2:    problem with iPXE string (e.g. when 3 network interfaces are available)

    IF    '${PAYLOAD}' == 'seabios'
        Enter SeaBIOS
        Sleep    0.5s
        ${setup}=    Telnet.Read
        ${lines}=    Get Lines Matching Pattern    ${setup}    ${IPXE_BOOT_ENTRY}
        Telnet.Write Bare    ${lines[0]}
        Telnet.Read Until    ${IPXE_STRING}
        Telnet.Write Bare    ${IPXE_KEY}
        IPXE Wait For Prompt
    ELSE IF    '${PAYLOAD}' == 'tianocore'
        Enter Boot Menu Tianocore
        Enter Submenu In Tianocore    option=${IPXE_BOOT_ENTRY}
        Enter Submenu In Tianocore
        ...    option=iPXE Shell
        ...    checkpoint=${EDK2_IPXE_CHECKPOINT}
        ...    description_lines=${EDK2_IPXE_START_POS}
        Set Prompt For Terminal    iPXE>
        Read From Terminal Until Prompt
    END

Enter Submenu In Tianocore
    [Documentation]    Enter chosen option. Generic keyword.
    [Arguments]    ${option}    ${checkpoint}=ESC to exit    ${description_lines}=1
    ${rel_pos}=    Get Relative Menu Position    ${option}    ${checkpoint}    ${description_lines}
    Press Key N Times And Enter    ${rel_pos}    ${ARROW_DOWN}

Enter UEFI Shell Tianocore
    [Documentation]    Enter UEFI Shell in Tianocore by specifying its position
    ...    in the list.
    Set Local Variable    ${IS_SHELL_AVAILABLE}    ${FALSE}
    ${menu_construction}=    Get Boot Menu Construction
    ${is_shell_available}=    Evaluate    "UEFI Shell" in """${menu_construction}"""
    IF    not ${is_shell_available}
        FAIL    Test case marked as Failed\nBoot menu does not contain position for entering UEFI Shell
    END
    ${system_index}=    Get Index From List    ${menu_construction}    UEFI Shell
    Press Key N Times And Enter    ${system_index}    ${ARROW_DOWN}

Get Menu Reference Tianocore
    [Documentation]    Get first entry from Tianocore Boot Manager menu.
    [Arguments]    ${raw_menu}    ${bias}
    ${lines}=    Get Lines Matching Pattern    ${raw_menu}    *[qwertyuiopasdfghjklzxcvbnm]*
    ${lines}=    Split To Lines    ${lines}
    ${bias}=    Convert To Integer    ${bias}
    ${first_entry}=    Get From List    ${lines}    ${bias}
    ${first_entry}=    Strip String    ${first_entry}    characters=1234567890()
    ${first_entry}=    Strip String    ${first_entry}
    RETURN    ${first_entry}

Tianocore One Time Boot
    [Arguments]    ${option}
    Enter Boot Menu Tianocore
    Enter Submenu In Tianocore    ${option}

Check If Submenu Exists Tianocore
    [Documentation]    Checks if given submenu exists
    [Arguments]    ${submenu}
    ${out}=    Telnet.Read Until    exit.
    ${result}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    ${submenu}
    RETURN    ${result}

Reenter Menu
    [Documentation]    Returns to the previous menu and enters the same one
    ...    again
    [Arguments]    ${forward}=${FALSE}
    IF    ${forward} == True
        Press Key N Times    1    ${ENTER}
        Sleep    1s
        Press Key N Times    1    ${ESC}
    ELSE
        Press Key N Times    1    ${ESC}
        Sleep    1s
        Press Key N Times    1    ${ENTER}
    END

Type In The Password
    [Documentation]    Operation for typing in the password
    [Arguments]    @{keys_password}
    FOR    ${key}    IN    @{keys_password}
        Write Bare Into Terminal    ${key}
        Sleep    0.5s
    END
    Press Key N Times    1    ${ENTER}

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

Type In BIOS Password
    [Documentation]    Types in password in general BIOS prompt
    [Arguments]    @{keys_password}
    Read From Terminal Until    password
    Sleep    0.5s
    Type In The Password    @{keys_password}

Type In Disk Password
    [Documentation]    Types in the disk password
    [Arguments]    @{keys_password}
    Read From Terminal Until    Unlock
    Sleep    0.5s
    # FIXME: See a comment in: Type in new disk password
    Press Key N Times    1    ${SETUP_MENU_KEY}
    Type In The Password    @{keys_password}
    Press Key N Times    1    ${ENTER}

Remove Disk Password
    [Documentation]    Removes disk password
    [Arguments]    @{keys_password}
    Enter Device Manager Submenu
    Enter TCG Drive Management Submenu
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

Change To Next Option In Setting
    [Documentation]    Changes given setting option to next in the list of
    ...    possible options.
    [Arguments]    ${setting}
    Enter Submenu In Tianocore    ${setting}
    Press Key N Times And Enter    1    ${ARROW_DOWN}

Skip If Menu Option Not Available
    [Documentation]    Skips the test if given submenu is not available in the
    ...    menu
    [Arguments]    ${submenu}
    ${res}=    Check If Submenu Exists Tianocore    ${submenu}
    Skip If    not ${res}
    Reenter Menu
    Sleep    1s
    Telnet.Read Until    Esc=Exit

Save Changes And Boot To OS
    [Documentation]    Saves current UEFI settings and continues booting to OS.
    ...    ${nesting_level} is crucial, because it depicts where
    ...    Continue button is located.
    [Arguments]    ${nesting_level}=2
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Press Key N Times    ${nesting_level}    ${ESC}
    Enter Submenu In Tianocore    Continue    checkpoint=Continue    description_lines=6

# TODO: calculate steps_to_reset based on menu construction

Save Changes And Reset
    [Documentation]    Saves current UEFI settings and restarts. ${nesting_level}
    ...    is how deep user is currently in the settings.
    ...    ${main_menu_steps_to_reset} means how many times should
    ...    arrow down be pressed to get to the Reset option in main
    ...    settings menu
    [Arguments]    ${nesting_level}=2    ${main_menu_steps_to_reset}=5
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Press Key N Times    ${nesting_level}    ${ESC}
    Press Key N Times And Enter    ${main_menu_steps_to_reset}    ${ARROW_DOWN}

Check If Tianocore Setting Is Enabled In Current Menu
    [Documentation]    Checks if option ${option} is enabled, returns True/False
    [Arguments]    ${option}
    ${option_value}=    Get Option Value    ${option}
    ${enabled}=    Run Keyword And Return Status
    ...    Should Be Equal    ${option_value}    [X]
    RETURN    ${enabled}

Get Relative Menu Position
    [Documentation]    Evaluate and return relative menu entry position
    ...    described in the argument.
    [Arguments]    ${entry}    ${checkpoint}    ${bias}=1
    ${output}=    Read From Terminal Until    ${checkpoint}
    ${output}=    Strip String    ${output}
    ${reference}=    Get Menu Reference Tianocore    ${output}    ${bias}
    @{lines}=    Split To Lines    ${output}
    ${iterations}=    Set Variable    0
    FOR    ${line}    IN    @{lines}
        IF    '${reference}' in '${line}\\n'
            ${start}=    Set Variable    ${iterations}
            BREAK
        END
        ${iterations}=    Evaluate    ${iterations} + 1
    END
    ${iterations}=    Set Variable    0
    FOR    ${line}    IN    @{lines}
        IF    '${entry}' in '${line}\\n'
            ${end}=    Set Variable    ${iterations}
        END
        ${iterations}=    Evaluate    ${iterations} + 1
    END
    ${rel_pos}=    Evaluate    ${end} - ${start}
    RETURN    ${rel_pos}

Enter Device Manager Submenu
    [Arguments]    ${setup_menu}
    ${device_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Should Not Contain    ${device_menu}[0]    Devices List
    List Should Contain Value    ${device_menu}    Driver Health Manager
    RETURN    ${device_menu}

Read Option List Contents
    [Documentation]    This keywords enters the option and returns the content
    ...    of the list
    [Arguments]    ${menu_construction}    ${option}
    ${option_index}=    Get Index Of Matching Option In Menu    ${menu_construction}    ${option}
    Read From Terminal
    Press Key N Times And Enter    ${option_index}    ${ARROW_DOWN}
    Sleep    1s
    ${list}=    Read From Terminal
    ${list_options}=    Get List Options    ${list}
    RETURN    ${list_options}

Select Option From List
    [Documentation]    Requires menu construction as input. Selects desired
    ...    element from the list of the option
    [Arguments]    ${menu_construction}    ${option}    ${list_element}
    ${list_options}=    Read Option List Contents    ${menu_construction}    ${option}
    # It turns out that if you go to the beginning of the list and you press
    # 'up' you won't get to the last option - this is good and we can make sure
    # that we are at the start of the list
    ${list_length}=    Get Length    ${list_options}
    Press Key N Times    ${list_length}    ${ARROW_UP}
    ${option_index}=    Get Index Of Matching Option In Menu    ${list_options}    ${list_element}
    Press Key N Times And Enter    ${option_index}    ${ARROW_DOWN}
