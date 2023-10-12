*** Settings ***
Documentation       Collection of keywords related to EDK2 menus

Library             Collections
Library             String
Library             ./menus.py
Resource            ../../keywords.robot


*** Keywords ***
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

Get Setup Menu Construction
    [Documentation]    Keyword allows to get and return setup menu construction.
    ...    Getting setup menu construction is carried out in the following basis:
    ...    1. Get serial output, which shows Boot menu with all elements,
    ...    headers and whitespaces.
    ...    2. Split serial output string and create list.
    ...    3. Create empty list for detected elements of menu.
    ...    4. Add to the new list only elements which are not whitespaces and
    ...    not menu frames.
    ...    5. Remove from new list menu header and footer (header always
    ...    occupies one line, footer - 3)
    [Arguments]    ${checkpoint}=Select Entry
    ${menu_construction}=    Get Setup Submenu Construction    ${checkpoint}    3
    RETURN    ${menu_construction}

Get Setup Submenu Construction
    [Documentation]    Keyword allows to get and return setup menu construction.
    ...    Getting setup menu construction is carried out in the following basis:
    ...    1. Get serial output, which shows Boot menu with all elements,
    ...    headers and whitespaces.
    ...    2. Split serial output string and create list.
    ...    3. Create empty list for detected elements of menu.
    ...    4. Add to the new list only elements which are not whitespaces and
    ...    not menu frames.
    ...    5. Remove from new list menu header and footer (header always
    ...    occupies one line, height of footer is customizable and is one by
    ...    default)
    [Arguments]    ${checkpoint}=Press ESC to exit.    ${description_lines}=1
    ${menu}=    Read From Terminal Until    ${checkpoint}
    ${menu_construction}=    Parse Menu Snapshot Into Construction    ${menu}    ${description_lines}
    RETURN    ${menu_construction}

Enter Dasharo System Features Submenu
    [Documentation]    Grabs current menu, finds specified ${submenu} and
    ...    returns its contents.
    [Arguments]    ${submenu}
    ${menu}=    Read From Terminal Until    <Enter>=Select Entry
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

Enter Dasharo Submenu
    [Documentation]    Grabs current menu, finds specified ${submenu} and
    ...    returns its contents.
    [Arguments]    ${submenu}
    ${menu}=    Read From Terminal Until    ${DASHARO_ENTER_PROMPT}
    ${menu_construction}=    Enter Dasharo Submenu Snapshot    ${menu}    ${submenu}
    RETURN    ${menu_construction}

Enter Dasharo Submenu Snapshot
    [Documentation]    Version of "Enter Dasharo Submenu" that processes menu
    ...    grabbed beforehand.
    [Arguments]    ${menu_construction}    ${submenu}
    ${menu_construction}=    Parse Menu Snapshot Into Construction    ${menu_construction}    3
    ${system_index}=    Get Index From List    ${menu_construction}    ${submenu}
    IF    ${system_index} == -1    Skip    msg=Menu option not found
    Press Key N Times And Enter    ${system_index}    ${ARROW_DOWN}
    ${menu_construction}=    Get Setup Submenu Construction    checkpoint=${DASHARO_EXIT_PROMPT}
    RETURN    ${menu_construction}

Parse Menu Snapshot Into Construction
    [Documentation]    Breaks grabbed menu data into lines.
    [Arguments]    ${menu}    ${description_lines}
    @{menu_lines}=    Split String    ${menu}    \n
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        ${line}=    Strip String    ${line}
        ${line}=    Remove String    ${line}    -    \\    \    /    |    <    >
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        IF    "${line}"!="${EMPTY}" and "${line}"!="${SPACE}"
            ${line}=    Get Substring    ${line}    1
            Append To List    ${menu_construction}    ${line}
        END
    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[${description_lines}:-1]
    RETURN    ${menu_construction}

Change Numeric Value Of Setting
    [Documentation]    Changes numeric value of ${setting} present in menu to
    ...    ${value}
    [Arguments]    ${setting}    ${value}
    Enter Submenu In Tianocore    ${setting}    checkpoint=${DASHARO_EXIT_PROMPT}    description_lines=2
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
