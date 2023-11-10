*** Settings ***
Documentation       Collection of keywords related to UEFI Secure Boot

Resource            ../keywords.robot


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

Reset To Default Secure Boot Keys
    [Documentation]    This keyword assumes that we are in the Advanced Secure
    ...    Boot menu already. We assume here it will not change too often and
    ...    that the menu layout is fixed. Reset to Default Secure Boot Keys is
    ...    the first entry.
    Press Enter
    Read From Terminal Until    Are you sure?
    Press Enter

Erase All Secure Boot Keys
    [Documentation]    This keyword assumes that we are in the Advanced Secure
    ...    Boot menu already. We assume here it will not change too often and
    ...    that the menu layout is fixed. Erase All Secure Boot Keys is the
    ...    second entry.
    Press Key N Times And Enter    1    ${ARROW_DOWN}
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

### Kwds below still needs review / rework after SB menu layout changes

Enable Custom Mode And Enroll Certificate
    [Documentation]    This keyword enables the secure boot custom mode
    ...    and enrolls a certificate with the given name.
    ...    It can also take the fileformat parameter
    ...    indicating whether the file is of a valid format.
    ...    If not, it will look for the appropriate ERROR
    ...    message.
    [Arguments]    ${cert_filename}    ${fileformat}=GOOD
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    ${secure_boot_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${device_mgr_menu}
    ...    Secure Boot Configuration
    Enter Custom Secure Boot Options
    Enroll Certificate    ${cert_filename}    ${fileformat}

Enroll Certificate
    [Documentation]    Enrolls the certificate with given filename
    ...    from a USB stick. If fileformat is not set
    ...    to GOOD, checks for Unsupported file type
    ...    error.
    ...
    [Arguments]    ${cert_filename}    ${fileformat}=GOOD

    Read From Terminal Until    PK Options
    Press Key N Times And Enter    2    ${ARROW_DOWN}
    Read From Terminal Until    Enroll Signature
    Press Key N Times    1    ${ENTER}
    Read From Terminal Until    Enroll Signature Using File
    Press Key N Times    1    ${ENTER}
    Read From Terminal Until    NO FILE SYSTEM INFO

    Press Key N Times And Enter    1    ${ARROW_UP}

    Read From Terminal
    ${out}=    Get File Explorer Submenu Construction
    Should Contain Match    ${out}    *${cert_filename}*
    ${index}=    Get Index From List    ${out}    ${cert_filename}
    Press Key N Times And Enter    ${index}+2    ${ARROW_DOWN}
    Read From Terminal
    Read From Terminal Until    Enroll
    ${enroll_menuconstr}=    Get Enroll Signature Submenu Construction
    ${index}=    Get Index From List    ${enroll_menuconstr}    Commit Changes and Exit
    Press Key N Times And Enter    ${index}-1    ${ARROW_DOWN}
    ${format_eval}=    Run Keyword And Return Status
    ...    Should Be Equal As Strings    ${fileformat}    GOOD
    IF    ${format_eval}
        Save Changes And Reset    3    5
    ELSE
        Read From Terminal Until    ERROR
    END

Get Custom Secureboot Submenu Construction
    [Documentation]    Keyword allows to get and return File Explorer menu construction.
    ${menu}=    Read From Terminal Until    DBT Options
    @{menu_lines}=    Split To Lines    ${menu}
    @{menu_lines}=    Remove Entry From List    ${menu_lines}    .*Move Highlight.*
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        ${line}=    Remove String    ${line}    -    \\    \    /    |    <    >
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        IF    "${line}"!="${EMPTY}" and "${line}"!=" "
            ${line}=    Strip String    ${line}
            Append To List    ${menu_construction}    ${line}
        END
    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[1:]
    RETURN    ${menu_construction}

Get Enroll Signature Submenu Construction
    [Documentation]    Keyword allows to get and return File Explorer menu construction.
    ${menu}=    Read From Terminal Until    Discard Changes and Exit
    @{menu_lines}=    Split To Lines    ${menu}
    @{menu_lines}=    Remove Entry From List    ${menu_lines}    .*Move Highlight.*
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        ${line}=    Remove String    ${line}    -    \\    \    /    |    <    >
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        IF    "${line}"!="${EMPTY}" and "${line}"!=" "
            ${line}=    Strip String    ${line}
            Append To List    ${menu_construction}    ${line}
        END
    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[1:]
    RETURN    ${menu_construction}

Upload Image
    [Documentation]    Mounts the image from the given URL on the PiKVM.
    [Arguments]    ${ip}    ${img_url}
    Upload Image To PiKVM    ${ip}    ${img_url}

Mount Image
    [Documentation]    Mounts the image with the given name on the PiKVM.
    [Arguments]    ${ip}    ${img_name}
    Mount Image On PiKVM    ${ip}    ${img_name}

Get File Explorer Submenu Construction
    [Documentation]    Keyword allows to get and return File Explorer menu construction.
    # Read From Terminal Until    NEW FILE
    ${menu}=    Read From Terminal Until    Move Highlight
    @{menu_lines}=    Split To Lines    ${menu}
    @{menu_lines}=    Remove Entry From List    ${menu_lines}    .*Move Highlight.*
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        ${line}=    Remove String    ${line}    -    \\    \    /    |    <    >
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        IF    "${line}"!="${EMPTY}" and "${line}"!=" "
            ${line}=    Strip String    ${line}
            Append To List    ${menu_construction}    ${line}
        END
    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[1:]
    RETURN    ${menu_construction}

Enter UEFI Shell And Boot .EFI File
    [Documentation]    Boots given .efi file from UEFI shell.
    ...    Assumes that it is located on FS0.
    [Arguments]    @{filename}
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    UEFI Shell
    Read From Terminal Until    Shell>
    Boot .EFI File From UEFI Shell    @{filename}

Boot .EFI File From UEFI Shell
    [Documentation]    Boots given efi file in UEFI shell using PiKVM,
    ...    and checks the result
    [Arguments]    ${filename}    ${expected_result}
    Sleep    3s
    Write Bare Into Terminal    fs0:
    Write Bare Into Terminal    \n
    Sleep    1s
    Write Bare Into Terminal    ${filename}
    Write Bare Into Terminal    \n
    Read From Terminal Until    ${expected_result}

Reset Secure Boot Keys
    [Documentation]    This keyword resets the Secure Boot Keys.
    [Arguments]    ${sb_menu}
    Go To Secure Boot Menu Entry    ${sb_menu}    Reset Secure Boot Keys
    Read From Terminal Until    Are you sure?
    Press Key N Times    1    ${ENTER}

Upload Required Images
    [Documentation]    Uploads the required images onto the PiKVM
    ${pikvm_ip}=    Get Variable Value    ${PIKVM_IP}
    IF    ${pikvm_ip}
        Upload Image    ${pikvm_ip}    https://cloud.3mdeb.com/index.php/s/k9EcYGDTWQAwtGs/download/good_keys.img
        Upload Image    ${pikvm_ip}    https://cloud.3mdeb.com/index.php/s/LaZQKGizg8gQRMZ/download/not_signed.img
        Upload Image    ${pikvm_ip}    https://cloud.3mdeb.com/index.php/s/DpmnoBK8HBJDTY4/download/bad_keys.img
        Upload Image    ${pikvm_ip}    https://cloud.3mdeb.com/index.php/s/TnEWbqGZ83i6bHo/download/bad_format.img
    ELSE
        Log    No PIKV_IP defined. Images for Secure Boot tests must be shipped via other backend.
    END

Check Secure Boot In Linux
    [Documentation]    Keyword checks Secure Boot state in Linux.
    ...    Returns True when Secure Boot is enabled
    ...    and False when disabled.
    ${out}=    Execute Linux Command    dmesg | grep secureboot
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

Check Gf Attempt Secure Boot Can Be Selected
    [Documentation]    The Attempt Secure Boot option may be unavailable if
    ...    Reset Secure Boot Keys was not selected before. This keyword checks
    ...    if the Attempt Secure Boot can already be selected. If the help text
    ...    matches this option, it means it can already be selected.
    [Arguments]    ${sb_menu}
    ${index}=    Get Index Of Matching Option In Menu    ${sb_menu}    Attempt Secure Boot

    # Go to one option before the target option and clear serial output
    Press Key N Times    ${index} - 1    ${ARROW_DOWN}
    Read From Terminal
    # Go to the target option and check if the help text matches the expected
    # option
    Press Key N Times    1    ${ARROW_DOWN}
    ${out}=    Read From Terminal
    ${can_be_selected}=    Run Keyword And Return Status
    ...    Should Contain All    ${out}    Enable/Disable the    Secure Boot feature    after platform reset
    RETURN    ${can_be_selected}

Go To Secure Boot Menu Entry
    [Documentation]    This keywords workarounds the fact the the Attempt Secure
    ...    Boot option might be not active and menu position might be off-by-one
    ...    with the actual key presses needed.
    [Arguments]    ${sb_menu}    ${entry}
    ${attempt_sb_can_be_selected}=    Check If Attempt Secure Boot Can Be Selected    ${sb_menu}
    ${index}=    Get Index Of Matching Option In Menu    ${sb_menu}    ${entry}
    IF    not ${attempt_sb_can_be_selected}
        ${index}=    Evaluate    ${index} - 1
    END
    ${sb_menu}=    Reenter Menu And Return Construction
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}

Select Attempt Secure Boot Option
    [Documentation]    Selects the Attempt Secure Boot Option
    ...    in the Secure Boot Configuration Submenu
    [Arguments]    ${sb_menu}

    ${can_be_selected}=    Check If Attempt Secure Boot Can Be Selected    ${sb_menu}
    IF    not ${can_be_selected}
        ${sb_menu}=    Reenter Menu And Return Construction
        Reset Secure Boot Keys    ${sb_menu}
    END
    ${sb_menu}=    Reenter Menu And Return Construction
    Set Option State    ${sb_menu}    Attempt Secure Boot    ${TRUE}
    Fail

Clear Attempt Secure Boot Option
    [Documentation]    Deselects the Attempt Secure Boot Option
    ...    in the Secure Boot Configuration Submenu
    ${sb_state}=    Get Option Value    Attempt Secure Boot    checkpoint=Save
    ${option_is_cleared}=    Run Keyword And Return Status
    ...    Should Contain    ${sb_state}    [ ]
    IF    ${option_is_cleared}
        Log    Attempt Secure Boot option is already cleared, nothing to do.
    ELSE
        ${sb_menu}=    Reenter Menu And Return Construction
        Go To Secure Boot Menu Entry    Attempt Secure Boot
        Read From Terminal Until    reset the platform to take effect!
        Press Key N Times    1    ${ENTER}
    END
