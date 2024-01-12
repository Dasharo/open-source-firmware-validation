*** Settings ***
Documentation       Collection of keywords related to UEFI TPM support

Library             ./tpm-support-lib.py
Resource            ../keywords.robot
Resource            ../keys.robot


*** Keywords ***
Get TCG2 Menu Construction
    [Documentation]    Get TCG2 Menu Construction. Returns all 3 pages of menu
    ...    options. Merges multiline options into one string.
    # TODO: Keyword should probably work for many other menus with minimal
    #    changes. @{additional_remove} should be argument or contain all
    #    possible values to be removed for every menu (there are not that
    #    many). Number of pages could be determined by presence of down
    #    arrow.
    [Arguments]    ${checkpoint}=Esc=Exit
    @{menu}=    Create List
    @{additional_remove}=    Create List
    ...    TPM2 Physical Presence Operation
    ...    TCG2 Protocol Configuration
    # Read screen and go to next page
    FOR    ${i}    IN RANGE    3
        ${out}=    Read From Terminal Until    ${checkpoint}
        ${menu2}=    Parse TCG2 Menu Snapshot Into Construction
        ...    ${out}
        ...    ${additional_remove}
        ${menu}=    Combine Lists    ${menu}    ${menu2}
        Press Key N Times    1    ${PAGEDOWN}
    END
    # Go back to top
    FOR    ${i}    IN RANGE    3
        Sleep    0.1
        Press Key N Times    1    ${PAGEUP}
    END
    @{new_menu}=    Convert List Of Pairs Into List Of Strings    ${menu}
    RETURN    ${new_menu}

Enter TCG2 Menu
    [Documentation]    This keyword enters TCG2 menu after the platform was
    ...    powered on.
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Enter Submenu From Snapshot    ${device_mgr_menu}    TCG2 Configuration

Enter TCG2 Menu And Return Construction
    [Documentation]    This keyword enters TCG2 menu after the platform was
    ...    powered on. Returns TCG2 menu construction.
    Enter TCG2 Menu
    ${sb_menu}=    Get TCG2 Menu Construction
    RETURN    ${sb_menu}

Convert List Of Pairs Into List Of Strings
    [Documentation]    Converts list of (key, value) pairs into list of strings
    ...    made from concatenating key and value parts: "key value"
    [Arguments]    ${list}
    @{new_list}=    Create List
    FOR    ${kvp}    IN    @{list}
        ${one_string}=    Catenate    ${kvp}[0]    ${SPACE}    ${kvp}[1]
        Append To List    ${new_list}    ${one_string}
    END
    RETURN    ${new_list}
