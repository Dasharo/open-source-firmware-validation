*** Settings ***
Documentation       Collection of keywords related to UEFI TPM support

Resource            ../keywords.robot
Resource            ../keys.robot


*** Keywords ***
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

Take Ownership Over TPM2 Module
    [Documentation]    This keyword run set of commands to take ownership over
    ...    TPM2 module.
    Execute Linux Tpm2 Tools Command    tpm2_changeauth --quiet -c owner pass
    Execute Linux Tpm2 Tools Command    tpm2_changeauth --quiet -c lockout pass
    Execute Linux Command    tpm2_createprimary -Q --hierarchy=o --key-context=/tmp/test --key-auth=pass2 -P pass
    Execute Linux Tpm2 Tools Command    tpm2_evictcontrol -Q -C o -P pass -c /tmp/test 0x81000001
    Execute Linux Command    rm /tmp/test

Check Ownership Of TPM2 Module
    [Documentation]    This keyword run set of commands to check ownership of
    ...    TPM2 module. ${state} is a status of ownership, 0 means that it is
    ...    taken, 1 means that there is no ownership.
    [Arguments]    ${state}
    Execute Linux Command    ! tpm2_changeauth --quiet -c owner 2>/dev/null
    ${out}=    Execute Linux Command    echo $?
    ${out}=    Strip String    ${out}    mode=right    characters=\n
    Should Be Equal    ${out}    ${state}
