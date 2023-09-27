*** Settings ***
Library     Collections
Library     String
Library     ./menus.py
Resource    ../../keywords.robot


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

Select Option From List
    [Documentation]    Requires menu construction as input. Selects desired
    ...    element from the list of the option
    [Arguments]    ${menu_construction}    ${option}    ${list_element}
    ${option_index}=    Get Index From List    ${menu_construction}    ${option}
    Read From Terminal
    Press Key N Times And Enter    ${option_index}    ${ARROW_DOWN}
    Sleep    1s
    ${list}=    Read From Terminal
    ${list_options}=    Get List Options    ${list}
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
