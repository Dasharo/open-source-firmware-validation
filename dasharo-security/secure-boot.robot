*** Settings ***
Library     SSHLibrary    timeout=90 seconds
Library     Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library     Process
Library     OperatingSystem
Library     String
Library     RequestsLibrary
Library     Collections

#Required setup keywords:
#Prepare Test Suite - elementary setup keyword for all tests.

#Reset Secure Boot Keys For The First Time - resets secure boot keys
#        for the first time since flashing. Otherwise enabling secure boot
#        is not possible.

#Upload Required Images - uploads all required files onto the PiKVM.

#Required teardown keywords:
#Log Out And Close Connection - elementary teardown keyword for all tests.

Suite Setup       Run Keywords    Prepare Test Suite    AND    Upload Required Images    AND    Reset Secure Boot Keys For The First Time
Suite Teardown    Run Keyword    Log Out And Close Connection

# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource    ../sonoff-rest-api/sonoff-api.robot
Resource    ../rtectrl-rest-api/rtectrl.robot
Resource    ../variables.robot
Resource    ../keys-and-keywords/firmware-keywords.robot
Resource    ../keys-and-keywords/setup-keywords.robot
Resource    ../keys-and-keywords/ubuntu-keywords.robot
Resource    ../keys-and-keywords/keys.robot
Resource    ../openbmc-test-automation/lib/xcat/xcat_utils.robot

*** Keywords ***
Upload Required Images
    [Documentation]    Uploads the required images onto the PiKVM
    Upload Image    ${pikvm_ip}    https://cloud.3mdeb.com/index.php/s/k9EcYGDTWQAwtGs/download/good_keys.img
    Upload Image    ${pikvm_ip}    https://cloud.3mdeb.com/index.php/s/LaZQKGizg8gQRMZ/download/not_signed.img
    Upload Image    ${pikvm_ip}    https://cloud.3mdeb.com/index.php/s/q7PfkFz7Bd2RTXz/download/bad_keys.img
    Upload Image    ${pikvm_ip}    https://cloud.3mdeb.com/index.php/s/TnEWbqGZ83i6bHo/download/bad_format.img

Check if Attempt Secure Boot can be Selected
    [Documentation]    The Attempt Secure Boot option may be unavailable if
    ...    Reset Secure Boot Keys was not selected before. This keyword checks
    ...    if the Attempt Secure Boot can already be selected. If the help text
    ...    matches this option, it means it can already be selected.
    ${menu_construction}=     Get Secure Boot Configuration Submenu Construction
    ${index}=    Get Index of Matching Option in Menu    ${menu_construction}    Attempt Secure Boot

    Press key n times    ${index} - 2    ${ARROW_DOWN}
    Read From Terminal
    Press key n times    2    ${ARROW_DOWN}
    ${out}=    Read From Terminal
    ${can_be_selected}=    Run Keyword And Return Status
    ...    Should Contain Any    ${out}
    ...    Enable/Disable the
    ...    Secure Boot feature
    ...    after platform reset
    [Return]    ${can_be_selected}

Reset Secure Boot Keys For The First Time
    [Documentation]    This test aims to verfiy that Secure Boot state after
    ...        flashing the platform with the Dasharo firmware is
    ...        correct.
    Skip If    not ${secure_boot_support}    SBO001.001 not supported
    Skip If    not ${tests_in_firmware_support}    SBO001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SBO001.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Device Manager Submenu
    Enter Secure Boot Configuration Submenu
    ${attempt_sb_can_be_selected}=    Check if Attempt Secure Boot can be Selected
    IF    not ${attempt_sb_can_be_selected}
        Reenter menu
        Press key n times and enter    2    ${ARROW_DOWN}
        Press key n times    1    ${ENTER}
    END

Check Secure Boot in Linux
    [Documentation]    Keyword checks Secure Boot state in Linux.
    ...        Returns True when Secure Boot is enabled
    ...        and False when disabled.
    ${out}=    Execute Linux command    dmesg | grep secureboot
    Should Contain Any    ${out}    disabled    enabled
    ${sb_status}=    Run Keyword And Return Status    Should Contain    ${out}    enabled
    [Return]    ${sb_status}

Check Secure Boot in Windows
    [Documentation]    Keyword checks Secure Boot state in Windows.
    ...        Returns True when Secure Boot is enabled
    ...        and False when disabled.
    ${out}=    ${out}=    Confirm-SecureBootUEFI
    Should Contain Any    ${out}    True    False
    ${sb_status}=    Run Keyword And Return Status    Should Contain    ${out}    True
    [Return]    ${sb_status}

Enable Secure Boot
    Enter Setup Menu Tianocore
    Enter Device Manager Submenu
    Enter Secure Boot Configuration Submenu
    Select Attempt Secure Boot Option
    Save changes and reset    2

Disable Secure Boot
    Enter Setup Menu Tianocore
    Enter Device Manager Submenu
    Enter Secure Boot Configuration Submenu
    Clear Attempt Secure Boot Option
    Save changes and reset    2

Enable Custom Mode and Enroll certificate
    [Arguments]    ${cert_filename}    ${fileformat}=GOOD
    [Documentation]    This keyword enables the secure boot custom mode
    ...        and enrolls a certificate with the given name.
    ...        It can also take the fileformat parameter
    ...        indicating whether the file is of a valid format.
    ...        If not, it will look for the appropriate ERROR
    ...        message.
    Enter Setup Menu Tianocore
    Enter Device Manager Submenu
    Enter Secure Boot Configuration Submenu
    Enter Custom Secure Boot Options
    Enroll Certificate    ${cert_filename}    ${fileformat}

Enter UEFI Shell and Boot .EFI File
    [Arguments]    @{filename}
    [Documentation]    Boots given .efi file from UEFI shell.
    ...        Assumes that it is located on FS0.
    Enter Boot Menu Tianocore
    Enter UEFI Shell Tianocore
    Read From Terminal Until    Shell>
    Boot .EFI File From UEFI shell    @{filename}

Verify Reset Secure Boot Keys
    [Documentation]    Verifies that Reset Secure Boot Keys
    ...        option is available.
    Enter Setup Menu Tianocore
    Enter Device Manager Submenu
    Enter Secure Boot Configuration Submenu
    Read From Terminal Until    Reset Secure Boot Keys


Reset Secure Boot Keys Again
    [Documentation]    Performs Reset Secure Boot Keys if they've
    ...        been reset since flashing.
    Enter Setup Menu Tianocore
    Enter Device Manager Submenu
    Enter Secure Boot Configuration Submenu
    Press key n times and enter    3    ${ARROW_DOWN}
    Read From Terminal Until    INFO
    Press key n times    1    ${ENTER}
    Save changes and reset    2    5


*** Test Cases ***

SBO001.001 Check Secure Boot default state (firmware)
     [Documentation]    This test aims to verfiy that Secure Boot state after
     ...        flashing the platform with the Dasharo firmware is
     ...        correct.
     Skip If    not ${secure_boot_support}    SBO001.001 not supported
     Skip If    not ${tests_in_firmware_support}    SBO001.001 not supported
     Skip If    not ${tests_in_ubuntu_support}    SBO001.001 not supported
     Power On
     Enter Setup Menu Tianocore
     Enter Device Manager Submenu
     Enter Secure Boot Configuration Submenu
     ${sb_state}=    Get Option Value    Attempt Secure Boot    checkpoint=Save
     Should Contain    ${sb_state}    [ ]

SBO002.001 UEFI Secure Boot (Ubuntu 22.04)
    [Documentation]    This test verifies that Secure Boot can be enabled from
    ...        boot menu and, after the DUT reset, it is seen from
    ...        the OS.
    Skip If    not ${secure_boot_support}    SBO002.001 not supported
    Skip If    not ${tests_in_firmware_support}    SBO002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SBO002.001 not supported

    Power On
    Enable Secure Boot

    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${sb_status}=    Check Secure Boot in Linux
    Should Be True    ${sb_status}

    Power On
    Disable Secure Boot

    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${sb_status}=    Check Secure Boot in Linux
    Should Not Be True    ${sb_status}

SBO002.002 UEFI Secure Boot (Windows 11)
    [Documentation]    This test verifies that Secure Boot can be enabled from
    ...        boot menu and, after the DUT reset, it is seen from
    ...        the OS.
    Skip If    not ${secure_boot_support}    SBO002.002 not supported
    Skip If    not ${tests_in_firmware_support}    SBO002.002 not supported
    Skip If    not ${tests_in_windows_support}    SBO002.002 not supported

    Power On
    Enable Secure Boot
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    ${sb_status}=    Check Secure Boot in Windows
    Should Be True    ${sb_status}
    Power On
    Disable Secure Boot

    Boot system or from connected disk    ${os_windows}
    Login to Windows
   ${sb_status}=    Check Secure Boot in Windows
    Should Not Be True    ${sb_status}

SBO003.001 Attempt to boot file with the correct key from Shell (firmware)
    [Documentation]    This test verifies that Secure Boot allows booting
    ...        a signed file with a correct key.
    Skip If    not ${secure_boot_support}    SBO003.001 not supported
    Skip If    not ${tests_in_firmware_support}    SBO003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SBO003.001 not supported
    Mount Image    ${pikvm_ip}    good_keys.img
    Power On
    Enable Secure Boot
    Enable Custom Mode and Enroll certificate    DB.cer
    Enter UEFI Shell and Boot .EFI File    hello-valid-keys.efi    Hello, world!


SBO004.001 Attempt to boot file without the key from Shell (firmware)
    [Documentation]    This test verifies that Secure Boot blocks booting a file
    ...        without a key.
    Skip If    not ${secure_boot_support}    SBO004.001 not supported
    Skip If    not ${tests_in_firmware_support}    SBO004.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SBO004.001 not supported
    Mount Image    ${pikvm_ip}    not_signed.img
    Power On
    Enter UEFI Shell and Boot .EFI File    hello.efi    Access Denied


SBO005.001 Attempt to boot file with the wrong-signed key from Shell (firmware)
    [Documentation]    This test verifies that Secure Boot disallows booting
    ...        a signed file with a wrong-signed key.
    Skip If    not ${secure_boot_support}    SBO005.001 not supported
    Skip If    not ${tests_in_firmware_support}    SBO005.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SBO005.001 not supported
    Mount Image    ${pikvm_ip}    bad_keys.img
    Power On
    Enter UEFI Shell and Boot .EFI File    hello-bad-keys.efi    Access Denied

SBO006.001 Reset Secure Boot Keys option availability (firmware)
    [Documentation]    This test verifies that the Reset Secure Boot Keys
    ...        option is available
    Skip If    not ${secure_boot_support}    SBO006.001 not supported
    Skip If    not ${tests_in_firmware_support}    SBO006.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SBO006.001 not supported

    Power On
    Verify Reset Secure Boot Keys

SBO007.001 Attempt to boot the file after restoring keys to default (firmware)
    [Documentation]    This test verifies that restoring the keys to default
    ...        removes any custom added certificates.
    Skip If    not ${secure_boot_support}    SBO007.001 not supported
    Skip If    not ${tests_in_firmware_support}    SBO007.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SBO007.001 not supported
    Mount Image    ${pikvm_ip}    good_keys.img
    Power On
    Enable Custom Mode and Enroll certificate    DB.cer
    Enter UEFI Shell and Boot .EFI File    hello-valid-keys.efi    Hello, world!
    Power On
    Reset Secure Boot Keys Again
    Enter UEFI Shell and Boot .EFI File    hello-valid-keys.efi    Access Denied

SBO008.001 Attempt to enroll the key in the incorrect format (firmware)
    [Documentation]    This test verifies that it is impossible to load
    ...        a certificate in the wrong file format.
    Skip If    not ${secure_boot_support}    SBO008.001 not supported
    Skip If    not ${tests_in_firmware_support}    SBO008.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SBO008.001 not supported
    Mount Image    ${pikvm_ip}    bad_format.img
    Power On
    Enable Custom Mode and Enroll certificate    DB.txt    BAD
