*** Keywords ***
Enable Custom Mode and Enroll certificate
    [Arguments]    ${cert_filename}    ${fileformat}=GOOD
    [Documentation]    This keyword enables the secure boot custom mode
    ...    and enrolls a certificate with the given name.
    ...    It can also take the fileformat parameter
    ...    indicating whether the file is of a valid format.
    ...    If not, it will look for the appropriate ERROR
    ...    message.
    Enter Setup Menu Tianocore
    Enter Device Manager Submenu
    Enter Secure Boot Configuration Submenu
    Enter Custom Secure Boot Options
    Enroll Certificate    ${cert_filename}    ${fileformat}

Enter UEFI Shell and Boot .EFI File
    [Arguments]    @{filename}
    [Documentation]    Boots given .efi file from UEFI shell.
    ...    Assumes that it is located on FS0.
    Enter Boot Menu Tianocore
    Enter UEFI Shell Tianocore
    Read From Terminal Until    Shell>
    Boot .EFI File From UEFI shell    @{filename}

Verify Reset Secure Boot Keys
    [Documentation]    Verifies that Reset Secure Boot Keys
    ...    option is available.
    Enter Setup Menu Tianocore
    Enter Device Manager Submenu
    Enter Secure Boot Configuration Submenu
    Read From Terminal Until    Reset Secure Boot Keys


Reset Secure Boot Keys Again
    [Documentation]    Performs Reset Secure Boot Keys if they've
    ...    been reset since flashing.
    Enter Setup Menu Tianocore
    Enter Device Manager Submenu
    Enter Secure Boot Configuration Submenu
    Press key n times and enter    3    ${ARROW_DOWN}
    Read From Terminal Until    INFO
    Press key n times    1    ${ENTER}
    Save changes and reset    2    5

Upload Required Images
    [Documentation]    Uploads the required images onto the PiKVM
    Upload Image    ${pikvm_ip}    https://cloud.3mdeb.com/index.php/s/k9EcYGDTWQAwtGs/download/good_keys.img
    Upload Image    ${pikvm_ip}    https://cloud.3mdeb.com/index.php/s/LaZQKGizg8gQRMZ/download/not_signed.img
    Upload Image    ${pikvm_ip}    https://cloud.3mdeb.com/index.php/s/q7PfkFz7Bd2RTXz/download/bad_keys.img
    Upload Image    ${pikvm_ip}    https://cloud.3mdeb.com/index.php/s/TnEWbqGZ83i6bHo/download/bad_format.img

Check If Attempt Secure Boot Can Be Selected
    [Documentation]    The Attempt Secure Boot option may be unavailable if
    ...    Reset Secure Boot Keys was not selected before. This keyword checks
    ...    if the Attempt Secure Boot can already be selected. If the help text
    ...    matches this option, it means it can already be selected.
    ${menu_construction}=    Get Secure Boot Configuration Submenu Construction
    ${index}=    Get Index Of Matching Option In Menu    ${menu_construction}    Attempt Secure Boot

    Press Key N Times    ${index} - 2    ${ARROW_DOWN}
    Read From Terminal
    Press Key N Times    2    ${ARROW_DOWN}
    ${out}=    Read From Terminal
    ${can_be_selected}=    Run Keyword And Return Status
    ...    Should Contain Any    ${out}    Enable/Disable the    Secure Boot feature    after platform reset
    RETURN    ${can_be_selected}

Reset Secure Boot Keys For The First Time
    [Documentation]    This test aims to verify that Secure Boot state after
    ...    flashing the platform with the Dasharo firmware is
    ...    correct.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO001.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Device Manager Submenu
    Enter Secure Boot Configuration Submenu
    ${attempt_sb_can_be_selected}=    Check If Attempt Secure Boot Can Be Selected
    IF    not ${attempt_sb_can_be_selected}
        Reenter Menu
        Press Key N Times And Enter    2    ${ARROW_DOWN}
        Press Key N Times    1    ${ENTER}
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
