*** Settings ***
Documentation       Collection of keywords related to UEFI Secure Boot

Resource            ../keywords.robot


*** Keywords ***
Check If Attempt Secure Boot Can Be Selected
    [Documentation]    The Attempt Secure Boot option may be unavailable if
    ...    Reset Secure Boot Keys was not selected before. This keyword checks
    ...    if the Attempt Secure Boot can already be selected. If the help text
    ...    matches this option, it means it can already be selected.
    ${menu_construction}=    Get Secure Boot Configuration Submenu Construction
    ${index}=    Get Index Of Matching Option In Menu    ${menu_construction}    Attempt Secure Boot

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
    [Arguments]    ${entry}
    ${attempt_sb_can_be_selected}=    Check If Attempt Secure Boot Can Be Selected
    Reenter Menu
    ${menu_construction}=    Get Secure Boot Configuration Submenu Construction
    ${index}=    Get Index Of Matching Option In Menu    ${menu_construction}    ${entry}
    IF    not ${attempt_sb_can_be_selected}
        ${index}=    Evaluate    ${index} - 1
    END
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}

Select Attempt Secure Boot Option
    [Documentation]    Selects the Attempt Secure Boot Option
    ...    in the Secure Boot Configuration Submenu
    ${sb_state}=    Get Option Value    Attempt Secure Boot    checkpoint=Save
    ${option_is_set}=    Run Keyword And Return Status
    ...    Should Contain    ${sb_state}    [X]
    IF    ${option_is_set}
        Log    Attempt Secure Boot option is already set, nothing to do.
    ELSE
        Reenter Menu
        Go To Secure Boot Menu Entry    Attempt Secure Boot
        Read From Terminal Until    reset the platform to take effect!
        Press Key N Times    1    ${ENTER}
    END

Clear Attempt Secure Boot Option
    [Documentation]    Deselects the Attempt Secure Boot Option
    ...    in the Secure Boot Configuration Submenu
    ${sb_state}=    Get Option Value    Attempt Secure Boot    checkpoint=Save
    ${option_is_cleared}=    Run Keyword And Return Status
    ...    Should Contain    ${sb_state}    [ ]
    IF    ${option_is_cleared}
        Log    Attempt Secure Boot option is already cleared, nothing to do.
    ELSE
        Reenter Menu
        Go To Secure Boot Menu Entry    Attempt Secure Boot
        Read From Terminal Until    reset the platform to take effect!
        Press Key N Times    1    ${ENTER}
    END

Reset Secure Boot Keys
    [Documentation]    This test aims to verify that Secure Boot state after
    ...    flashing the platform with the Dasharo firmware is
    ...    correct.
    Go To Secure Boot Menu Entry    Reset Secure Boot Keys
    Read From Terminal Until    Exit
    Press Key N Times    1    ${ENTER}

Enable Custom Mode And Enroll Certificate
    [Documentation]    This keyword enables the secure boot custom mode
    ...    and enrolls a certificate with the given name.
    ...    It can also take the fileformat parameter
    ...    indicating whether the file is of a valid format.
    ...    If not, it will look for the appropriate ERROR
    ...    message.
    [Arguments]    ${cert_filename}    ${fileformat}=GOOD
    Enter Setup Menu Tianocore
    Enter Device Manager Submenu
    Enter Secure Boot Configuration Submenu
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

Enter UEFI Shell And Boot .EFI File
    [Documentation]    Boots given .efi file from UEFI shell.
    ...    Assumes that it is located on FS0.
    [Arguments]    @{filename}
    Enter Boot Menu Tianocore
    Enter UEFI Shell Tianocore
    Read From Terminal Until    Shell>
    Boot .EFI File From UEFI Shell    @{filename}

Upload Required Images
    [Documentation]    Uploads the required images onto the PiKVM
    Upload Image    ${PIKVM_IP}    https://cloud.3mdeb.com/index.php/s/k9EcYGDTWQAwtGs/download/good_keys.img
    Upload Image    ${PIKVM_IP}    https://cloud.3mdeb.com/index.php/s/LaZQKGizg8gQRMZ/download/not_signed.img
    Upload Image    ${PIKVM_IP}    https://cloud.3mdeb.com/index.php/s/q7PfkFz7Bd2RTXz/download/bad_keys.img
    Upload Image    ${PIKVM_IP}    https://cloud.3mdeb.com/index.php/s/TnEWbqGZ83i6bHo/download/bad_format.img

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

Enable Secure Boot
    Enter Setup Menu Tianocore
    Enter Device Manager Submenu
    Enter Secure Boot Configuration Submenu
    Select Attempt Secure Boot Option
    Save Changes And Reset    2

Disable Secure Boot
    Enter Setup Menu Tianocore
    Enter Device Manager Submenu
    Enter Secure Boot Configuration Submenu
    Clear Attempt Secure Boot Option
    Save Changes And Reset    2
