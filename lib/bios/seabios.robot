*** Settings ***
Documentation       Collection of keywords related to SeaBIOS

Library             Collections
Library             String

*** Keywords ***
Enter Boot Menu SeaBIOS
    [Documentation]    Enter Boot Menu with SeaBIOS boot menu key mapped in
    ...    keys list.
    Read From Terminal Until    ${SEABIOS_STRING}
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
    ${menu}=    Read From Terminal Until    TPM Configuration
    # Lines to strip:
    # Select boot device:
    #
    # 1. DVD/CD [AHCI/2: QEMU DVD-ROM ATAPI-4 DVD/CD]
    # 2. iPXE
    # 3. Payload [setup]
    # 4. Payload [memtest]
    # 
    # t. TPM Configuration
    ${construction}=    Parse Menu Snapshot Into Construction    ${menu}    1    0
    RETURN    ${construction}

Enter Boot Menu SeaBIOS And Return Construction
    [Documentation]    Enters boot menu, returning menu construction
    Enter Boot Menu SeaBIOS
    ${menu}=    Get Boot Menu Construction
    RETURN    ${menu}

Enter sortbootorder
    [Documentation]    Enter sortbootorder with Boot Menu Consruction.
    Enter Boot Menu SeaBIOS
    ${menu}=    Get Boot Menu Construction
    Enter Boot Menu From Snapshot    ${menu}    \[setup\]

Enter TPM Configuration
    [Documentation]    Enter TPM Configuration with Boot Menu Consruction.
    Enter Boot Menu SeaBIOS
    ${menu}=    Get Boot Menu Construction
    Enter Boot Menu From Snapshot    ${menu}    TPM Configuration

Enter iPXE
    [Documentation]    Enter iPXE with Boot Menu Consruction.
    Enter Boot Menu SeaBIOS
    ${menu}=    Get Boot Menu Construction
    Enter Boot Menu From Snapshot    ${menu}    iPXE

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

Enter Setup Menu SeaBIOS And Return Construction
    [Documentation]    Enters Setup Menu and returns Setup Menu construction
    Enter Setup Menu SeaBIOS
    ${menu}=    Get Setup Menu Construction
    RETURN    ${menu}

Enter Boot Menu From Snapshot
    [Documentation]    Enter given Boot Menu SeaBIOS option
    [Arguments]    ${menu}    ${option}
    ${key}=    Extract SeaBIOS Menu Key    ${menu}    ${option}
    Write Bare Into Terminal    ${key}

Extract SeaBIOS Menu Key
    [Documentation]    Extract key which should be hit to enter given Menu in SeaBIOS
    [Arguments]    ${menu}    ${option}
    FOR    ${item}    IN    @{menu}
        ${matches}=    Run Keyword And Return Status
        ...    Should Match    ${item}    *${option}*
        IF    ${matches}
            ${option}=    Set Variable    ${item}
            BREAK
        END
    END
    ${key}    Set Variable    ${option.split('.')[0]}
    RETURN    ${key}

Get IPXE Boot Menu Construction
    [Documentation]    Keyword allows to get and return iPXE menu construction.
    [Arguments]    ${lines_top}=1    ${lines_bot}=0    ${checkpoint}=${EDK2_IPXE_CHECKPOINT}
    ${menu}=    Read From Terminal Until    ${checkpoint}
    ${construction}=    Parse Menu Snapshot Into Construction    ${menu}    ${lines_top}    ${lines_bot}
    RETURN    ${construction}

