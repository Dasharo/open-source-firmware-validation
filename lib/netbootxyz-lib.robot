*** Settings ***
Documentation       Collection of keywords related to netboot.xyz

Library             Collections
Library             String
Resource            ./bios/menus.robot

*** Keywords ***
Parse netboot.xyz Menu Snapshot Into Construction
    [Documentation]    Breaks grabbed netboot.xyz data into selectable lines.
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
    ...    Default:
    ...    Distributions:
    ...    Tools:
    ...    Signature Checks
    RETURN    ${construction}

Enter Netboot.xyz Menu
    [Documentation]    This keyword enters netboot.xyz menu after the platform was
    ...    powered on.
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    ${IPXE_BOOT_ENTRY}
    ${ipxe_menu}=    Get IPXE Boot Menu Construction
    Enter Submenu From Snapshot    ${ipxe_menu}    OS installation

