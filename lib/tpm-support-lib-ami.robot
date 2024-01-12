*** Settings ***
Documentation       Collection of keywords related to AMI UEFI TPM support

Library             ./tpm-support-lib-ami.py
Resource            ./tpm-support-lib-common.robot


*** Keywords ***
Enter TCG2 Menu
    [Documentation]    This keyword enters TCG2 menu after the platform was
    ...    powered on.
    ${setup_menu}=    Enter Setup Menu And Return Construction
    # Main Menu has clock that changes every second.
    # To read correct menu we first move 2 menus to the right read everything
    # on serial and go back to Advanced Menu
    Press Key N Times    2    ${ARROW_RIGHT}
    Read From Terminal
    Press Key N Times    1    ${ARROW_LEFT}
    ${snapshot}=    Read From Terminal Until    ESC: Exit
    ${menu}=    Get Ami Submenu Construction    ${snapshot}
    ${index}=    Get Index Of Matching Option In Menu    ${menu}    Trusted Computing
    Press Key N Times    ${index}    ${ARROW_DOWN}
    Read From Terminal
    Press Enter

Get TCG2 Menu Construction
    [Documentation]    Get TCG2 Menu Construction.
    ${snapshot}=    Read From Terminal Until    ESC: Exit
    @{menu}=    Parse Menu Snapshot Into Construction    ${snapshot}    0    0
    @{merged_menu}=    Merge Empty Options Into Previous Line    ${menu}
    RETURN    ${merged_menu}
