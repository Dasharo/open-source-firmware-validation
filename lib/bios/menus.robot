*** Settings ***
Documentation       Collection of keywords related to EDK2 menus

Resource            ../../keywords.robot


*** Keywords ***
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
