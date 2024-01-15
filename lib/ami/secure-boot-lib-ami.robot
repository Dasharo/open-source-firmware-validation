*** Settings ***
Documentation       Collection of Dasharo keywords related to UEFI Secure Boot

Resource            ../secure-boot-lib-common.robot


*** Variables ***
${RESET_KEYS_OPTION}=           > Restore Factory Keys
${INCORRECT_FORMAT_MESSAGE}=    Load Error


*** Keywords ***
Get Secure Boot Menu Construction
    [Documentation]    Secure Boot menu is very different than all
    ...    of the others so we need a special keyword for parsing it.
    ...    Return only selectable entries. If some menu option is not
    ...    selectable (grayed out) it will not be in the menu construction
    ...    list.
    [Arguments]    ${checkpoint}=ESC: Exit    ${lines_top}=1    ${lines_bot}=1
    ${out}=    Read From Terminal Until    ${checkpoint}
    # At first, parse the menu as usual
    ${menu}=    Parse Menu Snapshot Into Construction    ${out}    ${lines_top}    ${lines_bot}
    Remove Values From List    ${menu}    Not Active    Active
    RETURN    ${menu}

Enter Secure Boot Menu
    [Documentation]    This keyword enters Secure Boot menu after the platform was powered on.
    Enter Setup Menu
    Read From Terminal Until    ---/
    Press Key N Times    1    ${ARROW_RIGHT}
    Press Key N Times    1    ${ARROW_RIGHT}
    Press Key N Times    1    ${ARROW_RIGHT}
    Press Key N Times    1    ${PAGEDOWN}
    Read From Terminal
    Press Enter

Enter Secure Boot Menu And Return Construction
    [Documentation]    This keyword enters Secure Boot menu after the platform was powered on. Returns Secure Boot menu construction.
    Enter Secure Boot Menu
    ${sb_menu}=    Get Secure Boot Menu Construction
    ${sb_menu}=    Get Slice From List    ${sb_menu}    1
    RETURN    ${sb_menu}

Enter Key Management And Return Construction
    [Documentation]    Enters (Advanced) Key Management menu and returns constructions.
    ...    Should be called from secure boot menu
    # robocop: disable=unused-argument
    [Arguments]    ${sb_menu}=${EMPTY}
    # robocop: enable
    Press Key N Times And Enter    1    ${END}
    ${terminal}=    Read From Terminal Until    ESC: Exit
    ${key_menu}=    Get Ami Submenu Construction    ${terminal}
    RETURN    ${key_menu}

Reset To Default Secure Boot Keys
    [Documentation]    This keyword works in Secure Boot and Key Management Menu
    [Arguments]    ${key_menu}
    Enter Submenu From Snapshot    ${key_menu}    Restore Factory Keys
    Press Enter

Erase All Secure Boot Keys
    [Documentation]    This keyword assumes that we are in the Key Management
    ...    menu already.
    [Arguments]    ${advanced_menu}
    Reset To Default Secure Boot Keys    ${advanced_menu}
    Press Key N Times    1    ${HOME}
    Read From Terminal
    Enter Submenu From Snapshot    ${advanced_menu}    > Reset To Setup Mode
    Select Ami Option    ${TRUE}    frame_name=Reset To Setup Mode

Make Sure That Keys Are Provisioned
    [Documentation]    Expects to be executed when in Secure Boot configuration menu.
    [Arguments]    ${sb_menu}
    ${standard_mode}=    Run Keyword And Return Status
    ...    Should Contain Match    ${sb_menu}    Secure Boot Mode *\[Standard*
    IF    ${standard_mode} == ${TRUE}
        Press Key N Times And Enter    1    ${ARROW_DOWN}
        Press Key N Times And Enter    1    ${ARROW_DOWN}
        Press Key N Times    1    ${HOME}
    END
    ${setup_mode}=    Run Keyword And Return Status
    ...    Should Contain Match    ${sb_menu}    System Mode *Setup*
    ${sb_menu}=    Get Slice From List    ${sb_menu}    1
    IF    ${setup_mode} == ${TRUE}
        Reset To Default Secure Boot Keys    ${sb_menu}
        Press Key N Times    1    ${ESC}
        Read From Terminal
        Press Enter
        ${sb_menu}=    Get Secure Boot Menu Construction    checkpoint=ESC: Exit
        ${sb_menu}=    Get Slice From List    ${sb_menu}    1
    END
    RETURN    ${sb_menu}

Enable Secure Boot
    [Documentation]    Expects to be executed when in Secure Boot configuration menu.
    [Arguments]    ${sb_menu}
    ${sb_menu}=    Make Sure That Keys Are Provisioned    ${sb_menu}
    ${remove_first}=    Run Keyword And Return Status    Should Contain
    ...    ${sb_menu}[0]    System Mode
    IF    ${remove_first} == ${TRUE}
        ${sb_menu}=    Get Slice From List    ${sb_menu}    1
    END
    Set Option State    ${sb_menu}    Secure Boot *\[    Enabled

Disable Secure Boot
    [Documentation]    Expects to be executed when in Secure Boot configuration menu.
    [Arguments]    ${sb_menu}
    # ${sb_menu}=    Make Sure That Keys Are Provisioned    ${sb_menu}
    ${sb_menu}=    Get Slice From List    ${sb_menu}    1
    Set Option State    ${sb_menu}    Secure Boot *\[    Disabled

Enroll DB Signature
    [Documentation]    Enroll new DB Signature. Should be called in
    ...    Key Management Menu
    # robocop: disable=unused-argument
    [Arguments]    ${key_menu}    ${volume}    ${file}
    # robocop: enable
    Enter Submenu From Snapshot    ${key_menu}    > Authorized Signatures
    Select Ami Option    Append
    Select Ami Option    ${FALSE}
    Select Ami Option    USB
    Select Ami Option    ${file}
    Select Ami Option    Public Key Certificate
    Press Key N Times    2    ${ENTER}

Enter UEFI Shell
    [Documentation]    Boots into efi shell
    Enter Setup Menu And Return Construction
    Press Key N Times    1    ${ARROW_LEFT}
    Boot Option    EFI Shell
    Read From Terminal Until    Shell>

Delete Boot Option Ami
    [Documentation]    Delete boot option. Should be called from Boot Menu.
    ...    At the end returns to the top of Boot menu
    [Arguments]    ${boot_option}    ${fail_if_doesnt_exist}=${FALSE}
    Press Key N Times And Enter    1    ${END}
    Read From Terminal
    Press Enter
    ${status}=    Run Keyword And Return Status    Select Ami Option    ${boot_option}
    Press Key N Times    2    ${ESC}
    IF    ${status} == ${FALSE}
        IF    ${fail_if_doesnt_exist} == ${TRUE}
            Fail    Couldn't delete boot menu
        END
    END

Add Boot Option Ami
    [Documentation]    Add new boot option. Should be called from Main Menu.
    ...    If disk is empty then chooses first disk in menu. At the end returns
    ...    to the top of Boot menu
    [Arguments]    ${file}    ${boot_option}    ${volume}=${EMPTY}
    Press Key N Times    2    ${ARROW_LEFT}
    Delete Boot Option Ami    ${boot_option}
    Press Key N Times    1    ${END}
    Read From Terminal
    Press Key N Times And Enter    1    ${ARROW_UP}
    Read From Terminal Until    Add New Boot Option
    Press Enter
    Write Bare Into Terminal    ${boot_option}
    Press Enter
    Press Key N Times And Enter    1    ${ARROW_DOWN}
    Read From Terminal
    IF    '${volume}' == '${EMPTY}'
        Press Enter
    ELSE
        Select Ami Option    ${volume}
    END
    Select Ami Option    ${file}
    Press Key N Times And Enter    1    ${ARROW_DOWN}
    Press Enter
    Press Key N Times    1    ${ESC}
    Press Key N Times    1    ${HOME}

Boot Efi File And Return Response
    [Documentation]    Boots EFI file and returns response.
    ...    If volume is empty then boots from first drive.
    ...    If read_only_first_line is true then reads only up to \r\n else
    ...    up to ---/ (end of Ami frame/menu)
    [Arguments]    ${file}    ${volume}=${EMPTY}    ${read_only_first_line}=${TRUE}
    Enter Setup Menu And Return Construction
    Add Boot Option Ami    ${file}    tmp_boot    ${volume}
    Press Key N Times    1    ${ARROW_RIGHT}
    Boot Option    tmp_boot    ${TRUE}
    IF    ${read_only_first_line} == ${TRUE}
        ${out}=    Read From Terminal Until    \r\n
    ELSE
        ${out}=    Read From Terminal Until    ---/
    END
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
    ${out}=    Boot Efi File And Return Response
    ...    ${file}    ${volume}    ${FALSE}
    Should Contain Any    ${out}    Security Violation    Secure Boot Violation

Get Secure Boot State
    [Documentation]    Returns current state of Secure Boot.
    [Arguments]    ${sb_menu}
    ${sb_state}=    Get Matches    ${sb_menu}    Secure Boot*
    RETURN    ${sb_state}[0]

Make Sure There Is Secure Boot Error
    [Documentation]    Makes sure there is secure boot error.
    Read From Terminal Until    Secure Boot Violation
