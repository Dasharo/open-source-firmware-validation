*** Settings ***
Documentation       Collection of keywords related to UEFI TPM support

Resource            ../keywords.robot
Resource            ../keys.robot


*** Keywords ***
# TODO: Most options are split in 2 lines either because name is too long or
#    they have too many arguments. Get TCG2 Menu Construction currently
#    returns those as different list items
Get TCG2 Menu Construction
    [Documentation]    Get TCG2 Menu Construction.
    [Arguments]    ${checkpoint}=Esc=Exit    ${lines_top}=1    ${lines_bot}=1
    ${out}=    Read From Terminal Until    ${checkpoint}
    ${menu}=    Parse Menu Snapshot Into Construction    ${out}    ${lines_top}    ${lines_bot}
    ${last}=    Get From List    ${menu}    -1
    # read next pages
    WHILE    """${last}""" == "v"
        Press Key N Times    1    ${PAGEDOWN}
        ${out}=    Read From Terminal Until    ${checkpoint}
        ${menu2}=    Parse Menu Snapshot Into Construction    ${out}    ${lines_top}    ${lines_bot}
        ${last}=    Get From List    ${menu2}    -1
        ${menu}=    Combine Lists    ${menu}    ${menu2}
    END
    # strip list from arrows (^ and v)
    Remove Values From List
    ...    ${menu}
    ...    v
    ...    ^
    ...    \\------------------------------------------------------------------------------/^v=Move Highlight
    ${first}=    Set Variable    ^
    # Return to top
    WHILE    """${first}""" == "^"
        Press Key N Times    1    ${PAGEUP}
        ${out}=    Read From Terminal Until    ${checkpoint}
        ${menu2}=    Parse Menu Snapshot Into Construction    ${out}    ${lines_top}    ${lines_bot}
        ${first}=    Get From List    ${menu2}    0
    END
    RETURN    ${menu}

Enter TCG2 Menu
    [Documentation]    This keyword enters TCG2 menu after the platform was powered on.
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Enter Submenu From Snapshot    ${device_mgr_menu}    TCG2 Configuration

Enter TCG2 Menu And Return Construction
    [Documentation]    This keyword enters TCG2 menu after the platform was powered on. Returns TCG2 menu construction.
    Enter TCG2 Menu
    ${sb_menu}=    Get TCG2 Menu Construction
    RETURN    ${sb_menu}
