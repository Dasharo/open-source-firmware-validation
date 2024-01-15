*** Settings ***
Documentation       Collection of keywords related to dasharo UEFI TPM support

Library             ./tpm-support-lib-dasharo.py
Resource            ../tpm-support-lib-common.robot


*** Keywords ***
Get TCG2 Menu Construction
    [Documentation]    Get TCG2 Menu Construction. Returns all 3 pages of menu
    ...    options. Merges multiline options into one string.
    ...    only_selectable argument is unused
    # TODO: Keyword should probably work for many other menus with minimal
    #    changes. @{additional_remove} should be argument or contain all
    #    possible values to be removed for every menu (there are not that
    #    many). Number of pages could be determined by presence of down
    #    arrow.
    # robocop: disable=unused-argument
    [Arguments]    ${checkpoint}=Esc=Exit    ${only_selectable}=${TRUE}
    # robocop: enable
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
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${device_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Enter Submenu From Snapshot    ${device_mgr_menu}    TCG2 Configuration

Search TCG2 Menu And Enter Option
    [Documentation]    This keyword enters TCG2 menu after the platform was
    ...    powered on and execute Enter on given option.
    [Arguments]    ${option}    ${checkpoint}=Esc=Exit
    @{additional_remove}=    Create List
    ...    TPM2 Physical Presence Operation
    ...    TCG2 Protocol Configuration
    Enter TCG2 Menu
    # Read screen and go to next page
    FOR    ${i}    IN RANGE    3
        ${out}=    Read From Terminal Until    ${checkpoint}
        ${menu}=    Parse TCG2 Menu Snapshot Into Construction
        ...    ${out}
        ...    ${additional_remove}
        @{new_menu}=    Convert List Of Pairs Into List Of Strings    ${menu}
        ${status}    ${index}=    Run Keyword And Ignore Error
        ...    Get Index Of Matching Option In Menu
        ...    ${new_menu}
        ...    ${option}
        IF    '${status}' == 'FAIL'
            Press Key N Times    1    ${PAGEDOWN}
        ELSE
            Run Keyword And Return    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}
        END
    END

Run TPM Clear Procedure
    [Documentation]    This keyword enters TCG2 menu after the platform was
    ...    powered on. Returns TCG2 menu construction.
    [Arguments]    ${checkpoint}=TCG2 Configuration
    Search TCG2 Menu And Enter Option    TPM2 Operation
    Press Key N Times And Enter    3    ${ARROW_DOWN}
    Read From Terminal Until    ${checkpoint}
    Save Changes And Reset
    Read From Terminal Until    Press F12 to clear the TPM
    Press Key N Times    1    ${F12}

TPM Version Should Be
    [Documentation]    Keyword makes sure that TPM version is either 2.0 or 1.2
    ...    depending on named arguments. If tpm2 and tpm1_2 are both false then
    ...    keyword won't fail as long as it finds Current TPM Device in menu.
    ...    If tpm2 and tpm1_2 are both true then keyword succeeds if version is
    ...    either 2.0 or 1.2
    [Arguments]    ${menu}    @{}    ${tpm2}=${TRUE}    ${tpm1_2}=${TRUE}
    ${version}=    Get Matches    ${menu}    Current TPM Device*
    IF    ${tpm2} == ${TRUE} and ${tpm1_2} == ${TRUE}
        Should Contain Any    ${version}[0]    TPM 2.0    TPM 1.0
    ELSE IF    ${tpm2} == ${TRUE}
        Should Contain    ${version}[0]    TPM 2.0
    ELSE IF    ${tpm1_2} == ${TRUE}
        Should Contain    ${version}[0]    TPM 1.2
    END
