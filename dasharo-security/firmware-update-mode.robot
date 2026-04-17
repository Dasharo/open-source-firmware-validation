*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${FIRMWARE_UPDATE_MODE_SUPPORT}    Firmware Update Mode not supported
...                     AND
...                     Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    not supported
...                     AND
...                     Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}    Dasharo Security menu not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Variables ***
${FUM_DIALOG_TOP}=                          Update Mode. All firmware write protections are disabled in this mode.
${FUM_DIALOG_BOTTOM}=                       The platform will automatically reboot and disable Firmware Update Mode
${WRONG_KEYS_CAPSULE_STATUS}=               Capsule Status: Security Violation
${WRONG_GUID_CAPSULE_STATUS}=               Capsule Status: Not Ready
# Paths used by SSH-only capsule updates to stage files under the EFI shell workspace
${UEFI_SHELL_BOOT_DIR}=                     /boot/efi
${CAPSULE_UPDATE_SHELL_DIR}=                ${UEFI_SHELL_BOOT_DIR}/capsule_testing
${CAPSULE_UPDATE_SHELL_BOOTENTRY_NAME}=     UEFI Shell


*** Test Cases ***
FUM001.201 Firmware Update Mode support (Ubuntu)
    [Documentation]    FUM support, verify by entering dts and checking output
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    BLS001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    BLS001.201 not supported
    Set UEFI Option    LockBios    ${TRUE}
    Power On
    # Enable FUM
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Enter Submenu From Snapshot    ${security_menu}    Enter Firmware Update Mode
    Read From Terminal Until    Press ENTER to continue and reboot
    Press Enter
    ${out}=    Read From Terminal Until Regexp    (${TIANOCORE_STRING})|(${FUM_DIALOG_TOP})
    IF    '${FUM_DIALOG_TOP}' in $out
        ${fum_screen}=    Read From Terminal Until    ${FUM_DIALOG_BOTTOM}
        ${digit}=    Get Key To Press    ${fum_screen}
        Write Bare Into Terminal    ${digit}
    ELSE
        Log    FUM screen did not appear    WARN
    END
    Read From Terminal Until    efi/FirmwareUpdateMode:hex = 01
    Press Key N Times    2    ${CTRL_C}
    Load OS Credentials    ${ENV_ID_UBUNTU}
    # After exiting iPXE, the first boot entry is always loaded. In OSFV, this is usually the "OSFV Ubuntu" entry. If issues arise,
    # consider adding a keyword at the beginning that explicitly sets Ubuntu as the primary OS.
    Press Key N Times    1    ${ENTER}
    Login To Linux
    Switch To Root User
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    ${pr0}=    Get Lines Matching Regexp    ${out_flashrom}    ^PR0: Warning: 0x.{8}-0x.{8} is read-only.$
    Exit From Root User
    Should Be Empty    ${pr0}


*** Keywords ***
Get Key To Press
    [Arguments]    ${text}
    ${matches}=    Get Regexp Matches    ${text}    [0-9]
    VAR    ${digit}=    ${matches[0]}
    Log    Found digit: ${digit}
    RETURN    ${digit}
