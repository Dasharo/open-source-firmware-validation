*** Settings ***
Documentation       Collection of keywords related to UEFI Secure Boot

Resource            ../keywords.robot


*** Variables ***
${GOOD_KEYS_URL}=           https://cloud.3mdeb.com/index.php/s/SjM5dQGji4XDAni/download/good_keys.img
${GOOD_KEYS_NAME}=          good_keys.img
${GOOD_KEYS_SHA256}=        13de737ba50c8d14a88aaf5314a938fb6826e18ba8f337470ee490b17dd6bea8
${NOT_SIGNED_URL}=          https://cloud.3mdeb.com/index.php/s/zmJXxGG4piGB2Me/download/not_signed.img
${NOT_SIGNED_NAME}=         not_signed.img
${NOT_SIGNED_SHA256}=       15dc0a250b73c3132b1d7c5f8e81f00cc34d899c3ddecbb838a8cd0b66c4f608
${BAD_KEYS_URL}=            https://cloud.3mdeb.com/index.php/s/BJPbSqRH6NdbRym/download/bad_keys.img
${BAD_KEYS_NAME}=           bad_keys.img
${BAD_KEYS_SHA256}=         6da92bd97d4b4ca645fa98dcdfdc0c6876959e5b815a36f1f7759bc5463e7b19
${BAD_FORMAT_URL}=          https://cloud.3mdeb.com/index.php/s/AsBnATiHTZQ6jae/download/bad_format.img
${BAD_FORMAT_NAME}=         bad_format.img
${BAD_FORMAT_SHA256}=       59d17bc120dfd0f2e6948a2bfdbdf5fb06eddcb44f9a053a8e7b8f677e21858c


*** Keywords ***
Get Secure Boot Menu Construction
    [Documentation]    Secure Boot menu is very different than all
    ...    of the others so we need a special keyword for parsing it.
    ...    Return only selectable entries. If some menu option is not
    ...    selectable (grayed out) it will not be in the menu construction
    ...    list.
    [Arguments]    ${checkpoint}=Esc=Exit    ${lines_top}=1    ${lines_bot}=2
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
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
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

Reset To Default Secure Boot Keys
    [Documentation]    This keyword assumes that we are in the Advanced Secure
    ...    Boot menu already.
    [Arguments]    ${advanced_menu}
    Enter Submenu From Snapshot    ${advanced_menu}    Reset to default Secure Boot Keys
    Read From Terminal Until    Are you sure?
    Press Enter
    # QEMU needs a lot of time, why?
    Sleep    15s

Erase All Secure Boot Keys
    [Documentation]    This keyword assumes that we are in the Advanced Secure
    ...    Boot menu already.
    [Arguments]    ${advanced_menu}
    Enter Submenu From Snapshot    ${advanced_menu}    Erase all Secure Boot Keys
    Read From Terminal Until    Are you sure?
    Press Enter
    # QEMU needs a lot of time, why?
    Sleep    15s

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
        Exit From Current Menu
        ${sb_menu}=    Get Secure Boot Menu Construction
    END
    RETURN    ${sb_menu}

Enable Secure Boot
    [Documentation]    Expects to be executed when in Secure Boot configuration menu.
    [Arguments]    ${sb_menu}
    ${sb_menu}=    Make Sure That Keys Are Provisioned    ${sb_menu}
    ${changed}=    Set Option State    ${sb_menu}    Enable Secure Boot    ${TRUE}
    IF    ${changed} == ${TRUE}
        # Changing Secure Boot state issues a special popup
        Read From Terminal Until    Configuration changed, please reset the platform to take effect!
        # Dismiss the popup with any key
        Press Enter
    END

Disable Secure Boot
    [Documentation]    Expects to be executed when in Secure Boot configuration menu.
    [Arguments]    ${sb_menu}
    ${sb_menu}=    Make Sure That Keys Are Provisioned    ${sb_menu}
    ${changed}=    Set Option State    ${sb_menu}    Enable Secure Boot    ${FALSE}
    IF    ${changed} == ${TRUE}
        # Changing Secure Boot state issues a special popup
        Read From Terminal Until    Configuration changed, please reset the platform to take effect!
        # Dismiss the popup with any key
        Press Enter
    END

Check Secure Boot In Linux
    [Documentation]    Keyword checks Secure Boot state in Linux.
    ...    Returns True when Secure Boot is enabled
    ...    and False when disabled.
    # The string in dmesg may be in two forms:
    # secureboot: Secure boot disabled
    # or just:
    # Secure boot disabled
    # Lines containing "Bluetooth" are ignored as they are not the target of this check and may cause false result.
    ${out}=    Execute Command In Terminal    dmesg | grep "Secure boot" | grep -v "Bluetooth"
    Should Contain Any    ${out}    disabled    enabled
    ${sb_status}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    enabled
    RETURN    ${sb_status}

Check Secure Boot In Windows
    [Documentation]    Keyword checks Secure Boot state in Windows.
    ...    Returns True when Secure Boot is enabled
    ...    and False when disabled.
    ${out}=    Execute Command In Terminal    Confirm-SecureBootUEFI
    Should Contain Any    ${out}    True    False
    ${sb_status}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    True
    RETURN    ${sb_status}

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
    [Documentation]    Boots into UEFI Shell. Should be called after Power On or
    ...    reboot
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    UEFI Shell
    Read From Terminal Until    Shell>
    Sleep    1s

Execute File In UEFI Shell
    # UEFI shell has different line ending than the one we have set for the
    # Telnet connection. We cannot change it while the connection is open.
    [Arguments]    ${file}
    ${out}=    Execute UEFI Shell Command    fs0:
    Should Contain    ${out}    FS0:\\>
    ${out}=    Execute UEFI Shell Command    ${file}
    Should Contain    ${out}    FS0:\\>
    RETURN    ${out}

Restore Secure Boot Defaults
    [Documentation]    Restore SB settings to default, by resetting keys
    ...    and disabling SB, so it does not interfere with the followup tests.
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Reset To Default Secure Boot Keys    ${advanced_menu}
    # Changes to Secure Boot take action immediately, so we can just continue

    Exit From Current Menu
    ${sb_menu}=    Reenter Menu And Return Construction
    IF    '${SECURE_BOOT_DEFAULT_STATE}' == 'Disabled'
        Disable Secure Boot    ${sb_menu}
    ELSE
        Enable Secure Boot    ${sb_menu}
    END
    # Changes to Secure Boot take action immediately, so we can just continue
