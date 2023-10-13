*** Settings ***
Documentation       Collection of keywords related to EDK2 menus

Library             Collections
Library             String
Library             ./menus.py
Resource            ../../keywords.robot


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
    ${construction}=    Parse Menu Snapshot Into Construction    ${menu}    3    4
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
    [Arguments]    ${checkpoint}=Save screenshot
    ${construction}=    Get Menu Construction    ${checkpoint}    3    1
    RETURN    ${construction}

Get Menu Construction
    [Documentation]    Keyword allows to get and return setup menu construction.
    [Arguments]    ${checkpoint}=Press ESC to exit.    ${leading_lines}=1    ${trailing_lines}=0
    ${menu}=    Read From Terminal Until    ${checkpoint}
    ${construction}=    Parse Menu Snapshot Into Construction    ${menu}    ${leading_lines}    ${trailing_lines}
    RETURN    ${construction}

Parse Menu Snapshot Into Construction
    [Documentation]    Breaks grabbed menu data into lines.
    [Arguments]    ${menu}    ${leading_lines}    ${trailing_lines}
    ${slice_start}=    Set Variable    ${leading_lines}
    IF    ${trailing_lines} == 0
        ${slice_end}=    Set Variable    None
    ELSE
        ${slice_end}=    Evaluate    ${trailing_lines} * -1
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
        # Drop leading arrows (e.g. preceding options)
        ${line}=    Strip String    ${line}    characters=>    mode=left
        # Remove leading and trailing spaces
        ${line}=    Strip String    ${line}
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

Enter Setup Menu Option From Snapshot
    [Documentation]    Enter given Setup Menu Tianocore option after entering
    ...    Setup Menu Tianocore
    [Arguments]    ${menu}    ${option}
    ${index}=    Get Index From List    ${menu}    ${option}
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}

Enter Setup Menu Option From Snapshot And Return Construction
    [Documentation]    Enter given Setup Menu Tianocore option after entering
    ...    Setup Menu Tianocore
    [Arguments]    ${menu}    ${option}
    ${index}=    Get Index From List    ${menu}    ${option}
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}
    ${submenu}=    Get Menu Construction    Esc=Exit    3    2
    RETURN    ${submenu}

Enter Setup Menu Option
    [Documentation]    Enter given Setup Menu Tianocore option after entering
    ...    Setup Menu Tianocore
    [Arguments]    ${option}
    ${menu_construction}=    Get Setup Menu Construction
    ${index}=    Get Index From List    ${menu_construction}    ${option}
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}

Get Submenu Construction
    [Documentation]    Reads and returns the construction of any submenu
    ${menu}=    Read From Terminal Until    Press ESC to exit.
    @{menu_lines}=    Split String    ${menu}    \n
    @{menu_construction}=    Create List

    FOR    ${line}    IN    @{menu_lines}
        ${line}=    Remove String    ${line}    -    \\    \    /    |
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        ${is_menu_option}=    Check If Menu Line Is An Option    ${line}
        IF    ${is_menu_option}
            ${line}=    Get Substring    ${line}    0    30
            ${line}=    Strip String    ${line}
            Append To List    ${menu_construction}    ${line}
        END
    END
    RETURN    ${menu_construction}

Enter Submenu And Return Its Construction
    [Documentation]    Enters given submenu and returns its construction
    [Arguments]    ${submenu}
    ${menu_construction}=    Get Setup Submenu Construction
    ${system_index}=    Get Index From List    ${menu_construction}    ${submenu}
    Press Key N Times And Enter    ${system_index}    ${ARROW_DOWN}
    Read From Terminal Until    <Enter>
    ${submenu_construction}=    Get Submenu Construction
    RETURN    ${submenu_construction}

Read Option List Contents
    [Documentation]    This keywords enters the option and returns the content
    ...    of the list
    [Arguments]    ${menu_construction}    ${option}
    ${option_index}=    Get Index From List    ${menu_construction}    ${option}
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
    ${option_index}=    Get Index From List    ${list_options}    ${list_element}
    Press Key N Times And Enter    ${option_index}    ${ARROW_DOWN}

Save BIOS Changes
    [Documentation]    This keyword saves introduced changes
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y

Enter Dasharo System Features Submenu
    [Documentation]    Grabs current menu, finds specified ${submenu} and
    ...    returns its contents.
    [Arguments]    ${submenu}
    ${menu}=    Read From Terminal Until    Save screenshot
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

### TO REMOVE

Enter Dasharo Submenu
    [Documentation]    Grabs current menu, finds specified ${submenu} and
    ...    returns its contents.
    [Arguments]    ${submenu}    ${checkpoint}=<Enter>=Select Entry
    ${menu}=    Read From Terminal Until    ${checkpoint}
    ${menu_construction}=    Enter Dasharo Submenu Snapshot    ${menu}    ${submenu}
    RETURN    ${menu_construction}

### TO REMOVE

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
    [Arguments]    ${checkpoint}=exit.
    Telnet.Read Until    ${checkpoint}
    Press Key N Times    1    ${F9}
    Telnet.Read Until    ignore.
    Write Bare Into Terminal    y
