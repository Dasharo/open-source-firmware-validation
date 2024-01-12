*** Settings ***
Documentation       Collection of keywords related to AMI menus

Library             ./menus-ami.py
Resource            ./menus-common.robot


*** Keywords ***
Get Boot Menu Construction
    [Documentation]    Keyword allows to get and return boot menu construction.
    ${menu}=    Read From Terminal Until    ---/
    ${construction}=    Extract Strings From Ami Frame    ${menu}
    RETURN    ${construction}

Get Menu Construction
    [Documentation]    Returns menu construction. If menu is longer than one
    ...    screen then keyword scrolls down to construct whole menu.
    ${out}=    Read From Terminal Until    ---/
    ${up}    ${down}=    Can Snapshot Be Scrolled    ${out}
    IF    '${up}' == 'yes'
        Press Key N Times    1    ${HOME}
        ${out}=    Read From Terminal
        ${construction}=    Parse Menu Snapshot Into Construction
        ...    ${out}    0    0    full=${FALSE}
        ${down}=    Set Variable    yes
    END
    WHILE    '${down}' == 'yes'
        Press Key N Times    1    ${PAGEDOWN}
        ${out}=    Read From Terminal
        ${_}    ${new_down}=    Can Snapshot Be Scrolled    ${out}    full=${FALSE}
        IF    '${new_down}' == 'no'
            ${down}=    Set Variable    'no'
        END
        ${new_lines}=    Parse Menu Snapshot Into Construction
        ...    ${out}    0    0    full=${FALSE}
        Add New Lines To List    ${construction}    ${new_lines}
    END
    Press Key N Times    1    ${HOME}
    RETURN    ${construction}

Get Setup Menu Construction
    [Documentation]    Return Setup Menu
    ${snapshot}=    Read From Terminal Until    ---/
    ${menu}=    Parse Menu Snapshot Into Construction
    ...    ${snapshot}    0    0
    RETURN    ${menu}

Set Option State
    [Documentation]    Gets menu construction option name, and desired state
    ...    as arguments.
    [Arguments]    ${menu}    ${option}    ${target_state}
    ${current_state}=    Get Option State    ${menu}    ${option}
    IF    '${current_state}' != '${target_state}'
        ${type}=    Get Option Type    ${current_state}
        Enter Submenu From Snapshot    ${menu}    ${option}
        IF    '${type}' == 'numeric'
            Write Bare Into Terminal    ${target_state}
            Press Enter
        END
        IF    '${type}' == 'list'
            ${out}=    Read From Terminal Until    ---/
            ${list}=    Extract Strings From Ami Frame    ${out}
            # TODO: Temporarily disabled due to the complexity with
            # options spanning into multiple lines.
            # List Should Contain Value
            # ...    ${list}
            # ...    ${target_state}
            # ...    Target state ${target_state} not available in the list
            Select State From List    ${list}    ${current_state}    ${target_state}
        END
    ELSE
        Log    Nothing to do. Desired state is already set.
    END

Save Changes And Reset
    [Documentation]    Saves current UEFI settings and restarts. ${nesting_level}
    ...    is how deep user is currently in the settings.
    ...    ${main_menu_steps_to_reset} means how many times should
    ...    arrow down be pressed to get to the Reset option in main
    ...    settings menu
    # robocop: disable:unused-argument
    [Arguments]    ${nesting_level}=${EMPTY}    ${main_menu_steps_to_reset}=${EMPTY}
    # robocop: enable
    Press Key N Times And Enter    1    ${F4}
    Sleep    1s
    Reset System

Boot Option
    [Documentation]    Boots boot_option. Keyword assumes we are in
    ...    Save & Exit menu. Set expect_prompt to True if you have any unsaved
    ...    BIOS changes
    [Arguments]    ${boot_option}    ${expect_prompt}=${FALSE}
    # Make sure we are at the top
    Press Key N Times    1    ${HOME}
    Read From Terminal
    ${found}=    Set Variable    ${FALSE}
    # TODO: check if there are more options instead of setting max tries
    FOR    ${i}    IN RANGE    30
        Press Key N Times    1    ${ARROW_DOWN}
        # TODO: same line endings are skipped when scrolling down e.g.:
        # ECSD256_LABEL: hello_world.efi
        # ECSD512_LABEL: hello_world.efi
        # last line returned by Read From Serial will only have ECSD512 part.
        ${out}=    Read From Terminal
        ${found}=    Run Keyword And Return Status
        ...    Should Contain    ${out}    ${boot_option}    ignore_case=${TRUE}
        IF    ${found} == ${TRUE}
            Press Enter
            IF    ${expect_prompt} == ${TRUE}
                Read From Terminal Until    ---/
                Press Enter
                Read From Terminal Until    ---/
                ${found}=    Set Variable    ${TRUE}
                BREAK
            END
        END
    END
    IF    ${found} == ${FALSE}    Fail    Boot option not found

Boot Operating System
    [Documentation]    Keyword allows boot operating system installed on the
    ...    DUT. Takes as an argument operating system name.
    [Arguments]    ${operating_system}
    Enter Boot Menu
    Select Ami Option    ${operating_system}    boot_frame=${TRUE}

Boot System Or From Connected Disk
    [Documentation]    Tries to boot ${system_name}.
    [Arguments]    ${system_name}
    Boot Operating System    ${system_name}

Select Ami Option
    [Documentation]    Selects option from list of options in AMI frame.
    ...    Returns underlying submenu. Assumes first option is selected.
    ...    set boot_frame if you are in Boot frame. If frame_name is not empty
    ...    then make sure we are in correct frame by checking if top border or
    ...    header contains frame_name
    [Arguments]    ${option}    @{}    ${ignore_case}=${TRUE}
    ...    ${boot_frame}=${FALSE}    ${frame_name}=${EMPTY}
    ${out}=    Read From Terminal Until    ---/
    IF    '${frame_name}' != '${EMPTY}'
        ${header}=    Extract Ami Frame Name    ${out}
        Should Contain    ${header}    ${frame_name}
    END
    IF    '${option}' == '${TRUE}'
        Press Enter
    ELSE IF    '${option}' == '${FALSE}'
        Press Key N Times    1    ${ESC}
    ELSE
        ${list}=    Extract Strings From Ami Frame    ${out}
        ${target_index}=    Get Index Of Matching Option In Menu
        ...    ${list}
        ...    ${option}
        ...    ignore_case=${ignore_case}
        Should Not Be Equal As Integers    ${target_index}    -1
        Press Key N Times And Enter    ${target_index}    ${ARROW_DOWN}
    END
    IF    ${boot_frame} == ${FALSE}
        ${submenu}=    Read From Terminal Until    ---/
    END
    RETURN    ${EMPTY}
