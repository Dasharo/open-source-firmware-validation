*** Settings ***
Documentation       Collection of common keywords related to EDK2 menus

Library             Collections
Library             String
Library             ./menus-common.py
Resource            ../terminal.robot


*** Keywords ***
Enter Boot Menu
    [Documentation]    Enter Boot Menu with tianocore boot menu key mapped in
    ...    keys list.
    Read From Terminal Until    ${TIANOCORE_STRING}
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

Enter Boot Menu And Return Construction
    [Documentation]    Enters boot menu, returning menu construction
    Enter Boot Menu
    ${menu}=    Get Boot Menu Construction
    RETURN    ${menu}

Enter Setup Menu
    [Documentation]    Enter Setup Menu with key specified in platform-configs.
    Read From Terminal Until    ${TIANOCORE_STRING}
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Single Key PiKVM    ${SETUP_MENU_KEY}
    ELSE
        Write Bare Into Terminal    ${SETUP_MENU_KEY}
    END

Enter Setup Menu And Return Construction
    [Documentation]    Enters Setup Menu and returns Setup Menu construction
    Enter Setup Menu
    ${menu}=    Get Setup Menu Construction
    RETURN    ${menu}

Exit From Current Menu
    [Documentation]    Exits from current menu, refreshing screen.
    # Before entering new menu, make sure we get rid of all leftovers
    Read From Terminal
    Press Key N Times    1    ${ESC}

Reset System
    # EDK2 interprets Alt + Ctrl + Del on USB keyboards as reset combination.
    # On serial console it is ESC R ESC r ESC R.
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        FAIL    SSH not supported for interfacing with TianoCore
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Telnet.Write Bare    \x1bR\x1br\x1bR
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        FAIL    OpenBMC not yet supported for interfacing with TianoCore
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        @{reset_combo}=    Create List    AltRight    ControlRight    Delete
        Key Combination PiKVM    ${reset_combo}
    ELSE
        FAIL    Unknown connection method for config: ${CONFIG}
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
            Sleep    2s
        ELSE
            Write Bare Into Terminal    ${key}
            # Escape sequences in EDK2 have 2 seconds to complete on serial.
            # After 2 seconds if it is not completed, it is returned as a
            # keystroke. So we need at least 2 seconds interval for pressing
            # ESC for example.
            Sleep    2s
        END
    END

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

Get Option State
    [Documentation]    Gets menu construction and option name as arguments.
    ...    Returns option state, which can be: True, False, or numeric value.
    [Arguments]    ${menu}    ${option}
    ${index}=    Get Index Of Matching Option In Menu    ${menu}    ${option}
    ${value}=    Get Value From Brackets    ${menu}[${index}]
    IF    '${value}[0]' == 'X'
        ${state}=    Set Variable    ${TRUE}
    ELSE IF    '${value}[0]' == ' '
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

Enter Submenu From Snapshot
    [Documentation]    Enter given Setup Menu Tianocore option after entering
    ...    Setup Menu Tianocore
    [Arguments]    ${menu}    ${option}
    ${index}=    Get Index Of Matching Option In Menu    ${menu}    ${option}
    Should Not Be Equal As Integers    ${index}    -1    msg=Option ${option} not found in menu
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}

Enter Submenu From Snapshot And Return Construction
    [Documentation]    Enter given Setup Menu Tianocore option after entering
    ...    Setup Menu Tianocore
    [Arguments]    ${menu}    ${option}    ${opt_only}=${FALSE}
    Enter Submenu From Snapshot    ${menu}    ${option}
    ${submenu}=    Get Submenu Construction    opt_only=${opt_only}
    RETURN    ${submenu}

Select State From List
    [Documentation]    Accepts a list of option and states (current and target).
    ...    Selects the target state.
    [Arguments]    ${list}    ${current_state}    ${target_state}
    # Calculate offset and direction
    ${current_index}=    Get Index Of Matching Option In Menu    ${list}    ${current_state}
    Should Not Be Equal As Integers    ${current_index}    -1
    ${target_index}=    Get Index Of Matching Option In Menu    ${list}    ${target_state}
    Should Not Be Equal As Integers    ${target_index}    -1
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
