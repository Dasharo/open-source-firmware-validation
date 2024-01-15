*** Settings ***
Documentation       Collection of keywords related to AMI UEFI TPM support

Library             ./tpm-support-lib-ami.py
Resource            ../tpm-support-lib-common.robot


*** Keywords ***
Enter TCG2 Menu
    [Documentation]    This keyword enters TCG2 menu after the platform was
    ...    powered on.
    ${menu}=    Enter Advanced Menu And Return Construction
    ${index}=    Get Index Of Matching Option In Menu    ${menu}    Trusted Computing
    Press Key N Times    ${index}    ${ARROW_DOWN}
    Read From Terminal
    Press Enter

Get TCG2 Menu Construction
    [Documentation]    Get TCG2 Menu Construction. If only_selectable is False
    ...    then keyword will also return non selectable lines.
    [Arguments]    ${checkpoint}=ESC: Exit    ${only_selectable}=${TRUE}
    ${snapshot}=    Read From Terminal Until    ${checkpoint}
    @{menu}=    Parse Menu Snapshot Into Construction    ${snapshot}    0    0
    @{merged_menu}=    Merge Empty Options Into Previous Line    ${menu}
    IF    ${only_selectable} == ${TRUE}
        @{to_remove}=    Get Matches    ${merged_menu}
        ...    regexp=Advanced TPM.* Device.*|Firmware Version.*|Vendor.*
        Remove Values From List    ${merged_menu}    @{to_remove}
    END
    RETURN    ${merged_menu}

TPM Version Should Be
    [Documentation]    Keyword makes sure that TPM version is either 2.0 or 1.2
    ...    depending on named arguments. If tpm2 and tpm1_2 are both false then
    ...    keyword won't fail as long as it finds UEFI Spec Version in menu.
    ...    If tpm2 and tpm1_2 are both true then keyword succeeds if version is
    ...    either 2.0 or 1.2
    [Arguments]    ${menu}    @{}    ${tpm2}=${TRUE}    ${tpm1_2}=${TRUE}
    ${version}=    Get Matches    ${menu}    *UEFI Spec Version*
    IF    ${tpm2} == ${TRUE} and ${tpm1_2} == ${TRUE}
        Should Contain Any    ${version}[0]    TCG_2    TCT_1_2
    ELSE IF    ${tpm2} == ${TRUE}
        Should Contain    ${version}[0]    TCG_2
    ELSE IF    ${tpm1_2} == ${TRUE}
        Should Contain    ${version}[0]    TCG_1_2
    END

Run TPM Clear Procedure
    [Documentation]    This keyword clears TPM
    ${menu}=    Enter TCG2 Menu And Return Construction
    Enter Submenu From Snapshot    ${menu}    Pending operation
    Select Ami Option    TPM Clear
    Save Changes And Reset
