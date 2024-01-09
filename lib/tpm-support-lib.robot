*** Settings ***
Documentation       Collection of keywords related to UEFI TPM support

Library             ./tpm-support-lib.py
Resource            ../keywords.robot
Resource            ../keys.robot


*** Keywords ***
Get TCG2 Menu Construction
    [Documentation]    Get TCG2 Menu Construction.
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
    ${menu_dict}=    Convert List Of Pairs Into Dictionary    ${menu}
    RETURN    ${menu_dict}

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

Convert List Of Pairs Into Dictionary
    [Documentation]    Converts list of (key, value) into OrderedDict
    [Arguments]    ${list}
    ${dict}=    Evaluate    collections.OrderedDict()    collections
    FOR    ${kvp}    IN    @{list}
        Set To Dictionary    ${dict}    ${kvp}[0]    ${kvp}[1]
    END
    RETURN    ${dict}
