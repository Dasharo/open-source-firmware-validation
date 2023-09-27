*** Settings ***

Library     Collections
Library     String

Resource    ../../keywords.robot

*** Keywords ***

Get submenu construction
    [Documentation]    Reads and returns the construction of any submenu
    ${menu}=    Read From Terminal Until    Press ESC to exit.
    @{menu_lines}=    Split String    ${menu}    \n
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        ${line}=    Remove String    ${line}    -    \\    \    /    |    <    >
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        IF    "${line}"!="${EMPTY}" and "${line}"!="${SPACE}"
            ${line}=    Get Substring    ${line}    1
            Append To List    ${menu_construction}    ${line}
        END
    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[3:-1]
    RETURN    ${menu_construction}

Enter submenu and return its construction
    [Documentation]    Enters given submenu and returns its construction
    [Arguments]    ${submenu}
    ${menu_construction}=    Get Setup Submenu Construction
    ${system_index}=    Get Index From List    ${menu_construction}    ${submenu}
    Press Key N Times And Enter    ${system_index}    ${ARROW_DOWN}
    ${submenu_construction}=    Get submenu construction
    RETURN    ${submenu_construction}

