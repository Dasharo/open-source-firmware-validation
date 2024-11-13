*** Settings ***
Documentation       Collection of keywords related to SeaBIOS.

# Here is comparison of terms with lib/bios/menus.robot
# Tianocore -> SeaBIOS
# Setup Menu -> sortbootorder
#
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

Enter Sortbootorder
    [Documentation]    Enter sortbootorder with Boot Menu Construction.
    Enter Boot Menu SeaBIOS
    ${menu}=    Get Boot Menu Construction
    Enter Menu From Snapshot    ${menu}    \[setup\]

Get Sortbootorder Menu Construction
    [Documentation]    Keyword allows to get and return sortbootorder menu construction.
    [Arguments]    ${checkpoint}=Save configuration and exit
    # Lines to strip:
    ${out}=    Read From Terminal Until    ${checkpoint}
    ${menu}=    Parse Menu Snapshot Into Construction    ${out}    7    0
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
    ...    Select boot device:
    ...    , N for PXE boot
    RETURN    ${construction}

Enter Setup Menu SeaBIOS And Return Construction
    [Documentation]    Enters Setup Menu and returns Setup Menu construction
    Enter Setup Menu SeaBIOS
    ${menu}=    Get Setup Menu Construction
    RETURN    ${menu}

Get RTC Clock Submenu Construction
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

Get Option State
    [Documentation]    Gets menu construction and option name as arguments.
    ...    Returns option state, which can be: True or False.
    [Arguments]    ${menu}    ${option}
    ${index}=    Get Index Of Matching Option In Menu    ${menu}    ${option}
    ${value}=    Get Regexp Matches    ${menu}[${index}]    (Enabled|Disabled)

    RETURN    ${value}[0]

Set Option State And Return Construction
    [Documentation]    Sets option to desired state and return construction.
    [Arguments]    ${menu}    ${option}    ${desired_state}
    ${current_state}=    Get Option State    ${menu}    ${option}

    IF    '${current_state}' == '${desired_state}'
        RETURN    ${menu}
    ELSE
        ${menu}=    Enter Menu From Snapshot And Return Sortbootorder Construction    ${menu}    ${option}
    END
    RETURN    ${menu}

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

Get Hidden Security Register Submenu Construction
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

Get Hidden Flash Lockdown Submenu Construction
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

Enter Menu From Snapshot
    [Documentation]    Enter given Menu option
    [Arguments]    ${menu}    ${option}
    ${key}=    Extract Menu Key    ${menu}    ${option}
    Write Bare Into Terminal    ${key}

Enter Menu From Snapshot And Return Sortbootorder Construction
    [Documentation]    Enter given sortbootorder Menu option and return construction
    [Arguments]    ${menu}    ${option}
    ${key}=    Extract Sortbootorder Menu Key    ${menu}    ${option}
    Write Bare Into Terminal    ${key}
    ${menu}=    Get Sortbootorder Menu Construction
    RETURN    ${menu}

Extract Menu Key
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
    ${key}=    Set Variable    ${option.split('.')[0]}
    RETURN    ${key}

Extract Sortbootorder Menu Key
    [Documentation]    Extract key which should be hit to toggle given sortbootorder Menu option
    [Arguments]    ${menu}    ${option}
    FOR    ${item}    IN    @{menu}
        ${matches}=    Run Keyword And Return Status
        ...    Should Match    ${item}    *${option}*
        IF    ${matches}
            ${option}=    Set Variable    ${item}
            BREAK
        END
    END
    ${key}=    Set Variable    ${option.split()[0]}
    RETURN    ${key}

Save Sortbootorder Changes
    [Documentation]    This keyword saves introduced changes
    Write Bare Into Terminal    s

Get IPXE Boot Menu Construction
    [Documentation]    Keyword allows to get and return iPXE menu construction.
    [Arguments]    ${lines_top}=1    ${lines_bot}=0    ${checkpoint}=${EDK2_IPXE_CHECKPOINT}
    ${menu}=    Read From Terminal Until    ${checkpoint}
    ${construction}=    Parse Menu Snapshot Into Construction    ${menu}    ${lines_top}    ${lines_bot}
    RETURN    ${construction}

Enable Network/PXE Boot
    [Documentation]    Enable Network/PXE Boot and save.
    Enter Sortbootorder
    ${menu}=    Get Sortbootorder Menu Construction
    ${menu}=    Set Option State And Return Construction    ${menu}    Network/PXE boot    Enabled
    List Should Contain Value    ${menu}    n Network/PXE boot - Currently Enabled
    Save Sortbootorder Changes

Enter TPM Configuration
    [Documentation]    Enter TPM Configuration with Boot Menu Construction.
    Enter Boot Menu SeaBIOS
    ${menu}=    Get Boot Menu Construction
    Enter Menu From Snapshot    ${menu}    TPM Configuration

Enter IPXE
    [Documentation]    Enter iPXE with Boot Menu Construction.
    Enable Network/PXE Boot
    Enter Boot Menu SeaBIOS
    ${menu}=    Get Boot Menu Construction
    Enter Menu From Snapshot    ${menu}    iPXE
