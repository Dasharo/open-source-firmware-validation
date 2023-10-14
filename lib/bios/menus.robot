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
    ${index}=    Get Index Of Matching Option In Menu    ${menu}    ${option}
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}
    ${submenu}=    Get Submenu Construction
    RETURN    ${submenu}

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
    RETURN    ${index}

Get Option State
    [Documentation]    Gets menu construction and option name as arguments.
    ...    Returns option state, which can be: True, False, or numerical value.
    [Arguments]    ${menu}    ${option}
    ${index}=    Get Index Of Matching Option In Menu    ${menu}    ${option}
    ${value}=    Get Value From Brackets    ${menu}[${index}]
    IF    '${value}' == 'X'
        ${state}=    Set Variable    ${TRUE}
    ELSE IF    '${value}' == '${SPACE}'
        ${state}=    Set Variable    ${FALSE}
    ELSE
        ${state}=    Set Variable    ${value}
    END
    RETURN    ${state}

Set Option State
    [Documentation]    Gets menu construction option name, and desired state
    ...    as arguments.
    [Arguments]    ${menu}    ${option}    ${target_state}
    ${current_state}=    Get Option State    ${menu}    ${option}

    # This type of field can either be boolean ([X] or [ ]), or free entry
    # field. At first, find out which one is it.
    IF    '${current_state}' == '${TRUE}' or '${current_state}' == '${FALSE}'
        ${type}=    Set Variable    bool
    ELSE
        ${type}=    Set Variable    numerical
    END

    IF    '${current_state}' != '${target_state}'
        ${index}=    Get Index Of Matching Option In Menu    ${menu}    ${option}
        Press Key N Times And Enter    ${index}    ${ARROW_DOWN}
        IF    '${type}' == 'numerical'
            Write Bare Into Terminal    ${target_state}
            Press Key N Times    1    ${ENTER}
        END
    ELSE
        Log    Nothing to do. Desired state is already set.
    END

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
