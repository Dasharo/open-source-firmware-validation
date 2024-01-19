*** Settings ***
Documentation       Collection of Dasharo keywords related to UEFI Secure Boot

Library             ../lib/secure-boot-lib.py
Resource            ../lib/secure-boot-lib-common.robot
Resource            ../keywords.robot


*** Variables ***
${RESET_KEYS_OPTION}=           > Reset to default Secure Boot Keys
${INCORRECT_FORMAT_MESSAGE}=    ERROR: Unsupported file type!


*** Keywords ***
Get Secure Boot Menu Construction
    [Documentation]    Secure Boot menu is very different than all
    ...    of the others so we need a special keyword for parsing it.
    ...    Return only selectable entries. If some menu option is not
    ...    selectable (grayed out) it will not be in the menu construction
    ...    list.
    [Arguments]    ${checkpoint}=Esc=Exit    ${lines_top}=1    ${lines_bot}=1
    ${out}=    Read From Terminal Until    ${checkpoint}
    # At first, parse the menu as usual
    ${menu}=    Parse Menu Snapshot Into Construction    ${out}    ${lines_top}    ${lines_bot}
    ${enable_sb_can_be_selected}=    Run Keyword And Return Status
    ...    List Should Not Contain Value
    ...    ${menu}
    ...    To enable Secure Boot, set Secure Boot Mode to
    # If we have a help message indicating keys are not provisioned,
    # we drop this help message end Enable Secure Boot option (which is
    # not selectable) from the menu construction.
    IF    ${enable_sb_can_be_selected} == ${FALSE}
        Remove Values From List
        ...    ${menu}
        ...    To enable Secure Boot, set Secure Boot Mode to
        ...    Custom and enroll the keys/PK first.
        ...    Enable Secure Boot [ ]
        ...    Enable Secure Boot [X]
    END
    RETURN    ${menu}

Enter Secure Boot Menu
    [Documentation]    This keyword enters Secure Boot menu after the platform was powered on.
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${device_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Enter Submenu From Snapshot    ${device_mgr_menu}    Secure Boot Configuration

Enter Secure Boot Menu And Return Construction
    [Documentation]    This keyword enters Secure Boot menu after the platform was powered on. Returns Secure Boot menu construction.
    Enter Secure Boot Menu
    ${sb_menu}=    Get Secure Boot Menu Construction
    RETURN    ${sb_menu}

Enter Advanced Secure Boot Keys Management
    [Documentation]    Enables Secure Boot Custom Mode and enters Advanced Management menu.
    [Arguments]    ${sb_menu}
    Set Option State    ${sb_menu}    Secure Boot Mode    Custom Mode
    # After selecting Custom Mode, the Advanced Menu is one below
    Press Key N Times And Enter    1    ${ARROW_DOWN}

Enter Advanced Secure Boot Keys Management And Return Construction
    [Documentation]    Enables Secure Boot Custom Mode and enters Advanced Management menu.
    [Arguments]    ${sb_menu}
    Enter Advanced Secure Boot Keys Management    ${sb_menu}
    ${menu}=    Get Submenu Construction    opt_only=${TRUE}
    RETURN    ${menu}

Enter Key Management And Return Construction
    [Documentation]    Enters Advanced Key Management menu and returns constructions.
    ...    Should be called from secure boot menu
    [Arguments]    ${sb_menu}=${EMPTY}
    IF    ${sb_menu} == ${EMPTY}
        ${sb_menu}=    Get Secure Boot Menu Construction
    END
    ${key_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    RETURN    ${key_menu}

Reset To Default Secure Boot Keys
    [Documentation]    This keyword assumes that we are in the Advanced Secure
    ...    Boot menu already.
    [Arguments]    ${advanced_menu}
    Enter Submenu From Snapshot    ${advanced_menu}    Reset to default Secure Boot Keys
    Read From Terminal Until    Are you sure?
    Press Enter

Erase All Secure Boot Keys
    [Documentation]    This keyword assumes that we are in the Advanced Secure
    ...    Boot menu already.
    [Arguments]    ${advanced_menu}
    Enter Submenu From Snapshot    ${advanced_menu}    Erase all Secure Boot Keys
    Read From Terminal Until    Are you sure?
    Press Enter

Return Secure Boot State
    [Documentation]    Returns the state of Secure Boot as reported in the Secure Boot Configuration menu
    [Arguments]    ${sb_menu}
    ${index}=    Get Index Of Matching Option In Menu    ${sb_menu}    Secure Boot State
    ${sb_state}=    Get From List    ${sb_menu}    ${index}
    ${sb_state}=    Remove String    ${sb_state}    Secure Boot State
    ${sb_state}=    Strip String    ${sb_state}
    RETURN    ${sb_state}

Make Sure That Keys Are Provisioned
    [Documentation]    Expects to be executed when in Secure Boot configuration menu.
    [Arguments]    ${sb_menu}
    ${need_reset}=    Run Keyword And Return Status    Should Not Contain Match    ${sb_menu}    Enable Secure Boot *
    IF    ${need_reset} == ${TRUE}
        ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
        Reset To Default Secure Boot Keys    ${advanced_menu}
        Sleep    3s
        Exit From Current Menu
        ${sb_menu}=    Get Secure Boot Menu Construction
    END
    RETURN    ${sb_menu}

Enable Secure Boot
    [Documentation]    Expects to be executed when in Secure Boot configuration menu.
    [Arguments]    ${sb_menu}
    ${sb_menu}=    Make Sure That Keys Are Provisioned    ${sb_menu}
    Set Option State    ${sb_menu}    Enable Secure Boot    ${TRUE}
    Save Changes
    Reenter Menu

Disable Secure Boot
    [Documentation]    Expects to be executed when in Secure Boot configuration menu.
    [Arguments]    ${sb_menu}
    ${sb_menu}=    Make Sure That Keys Are Provisioned    ${sb_menu}
    Set Option State    ${sb_menu}    Enable Secure Boot    ${FALSE}

Enter Enroll DB Signature Using File In DB Options
    [Documentation]    Keyword checks Secure Boot state in Windows.
    [Arguments]    ${advanced_menu}
    ${db_opts_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${advanced_menu}
    ...    DB Options
    ...    opt_only=${TRUE}
    ${enroll_sig_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${db_opts_menu}
    ...    Enroll Signature
    ...    opt_only=${FALSE}
    Enter Submenu From Snapshot    ${enroll_sig_menu}    Enroll Signature Using File

Enroll DB Signature
    [Documentation]    Enroll new DB Signature. Should be called in Advanced
    ...    Secure Boot Keys Management or Key Management Menu
    [Arguments]    ${key_menu}    ${volume}    ${file}
    Enter Enroll DB Signature Using File In DB Options    ${key_menu}
    Enter Volume In File Explorer    ${volume}
    Select File In File Explorer    ${file}

Enter Volume In File Explorer
    [Documentation]    Enter the given volume
    [Arguments]    ${target_volume}
    # 1. Read out the whole File Explorer menu
    ${volumes}=    Get Submenu Construction    opt_only=${TRUE}
    Log    ${volumes}
    # 2. See if our label is within these entries
    ${index}=    Get Index Of Matching Option In Menu    ${volumes}    ${target_volume}    ${TRUE}
    # 3. If yes, go to the selected label
    IF    ${index} != -1
        Press Key N Times And Enter    ${index}    ${ARROW_DOWN}
        # 4. If no, get the number of entries and go that many times below
    ELSE
        ${volumes_no}=    Get Length    ${volumes}
        Press Key N Times    ${volumes_no}    ${ARROW_DOWN}
        #    - check if the label is what we need, if yes, select
        FOR    ${in}    IN RANGE    20
            ${new_entry}=    Read From Terminal
            ${status}=    Run Keyword And Return Status
            ...    Should Contain    ${new_entry}    ${target_volume}
            IF    ${status} == ${TRUE}    BREAK
            IF    ${in} == 19    Fail    Volume not found
            Press Key N Times    1    ${ARROW_DOWN}
        END
        Press Key N Times    1    ${ENTER}
    END

Select File In File Explorer
    [Documentation]    Select the given file
    [Arguments]    ${target_file}
    # 1. Select desired file
    ${files}=    Get Submenu Construction
    Log    ${files}
    ${index}=    Get Index Of Matching Option In Menu    ${files}    ${target_file}
    # FIXME: We must add 1 due to empty selecatble space in File Manager
    Press Key N Times And Enter    ${index}+1    ${ARROW_DOWN}
    # 2. Save Changes
    ${enroll_sig_menu}=    Get Submenu Construction
    # Unselectable filename appears between options after file was selected
    Remove Values From List    ${enroll_sig_menu}    ${target_file}
    ${index}=    Get Index Of Matching Option In Menu    ${enroll_sig_menu}    Commit Changes and Exit
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}

Enter UEFI Shell
    [Documentation]    Boots given .efi file from UEFI shell.
    ...    Assumes that it is located on FS0.
    ${boot_menu}=    Enter Boot Menu And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    UEFI Shell
    Read From Terminal Until    Shell>

Execute File In UEFI Shell
    # UEFI shell has different line ending than the one we have set for the
    # Telnet connection. We cannot change it while the connection is open.
    [Arguments]    ${file}
    Write Bare Into Terminal    fs0:
    Press Enter
    Read From Terminal Until    FS0:\\>
    Write Bare Into Terminal    ${file}
    Press Enter
    ${out}=    Read From Terminal Until    FS0:\\>
    RETURN    ${out}

Boot Efi File And Return Response
    [Documentation]    Boots EFI file and returns response.
    # robocop: disable=unused-argument
    [Arguments]    ${file}    ${volume}=${EMPTY}    ${read_only_first_line}=${EMPTY}
    # robocop: enable
    Enter UEFI Shell
    ${out}=    Execute File In UEFI Shell    ${file}
    RETURN    ${out}

Boot Efi File
    [Documentation]    Boots EFI file. Fails if after booting there is no
    ...    expected_output in terminal
    [Arguments]    ${file}    ${volume}    ${expected_output}
    ${out}=    Boot Efi File And Return Response    ${file}    ${volume}
    Should Contain    ${out}    ${expected_output}    ignore_case=${TRUE}

Boot Efi File Should Fail
    [Documentation]    Attempts to boot EFI file. Succeeds if attempt results in
    ...    Secure Boot error message
    [Arguments]    ${file}    ${volume}
    ${out}=    Boot Efi File And Return Response    ${file}    ${volume}
    Should Contain Any    ${out}    Access Denied

Get Secure Boot State
    [Documentation]    Returns current state of Secure Boot.
    [Arguments]    ${sb_menu}
    ${sb_state}=    Get Matches    ${sb_menu}    Current Secure Boot State*
    RETURN    ${sb_state}[0]
