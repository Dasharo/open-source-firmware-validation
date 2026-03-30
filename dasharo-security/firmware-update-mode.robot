*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${BIOS_LOCK_SUPPORT}    BIOS lock not supported
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
FUM001.101 Firmware Update Mode support (Ubuntu)
    [Documentation]    FUM support, verify by entering dts and checking output
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    BLS001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    BLS001.201 not supported
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
    # Stop iPXE from booting default option as it contains workaround for this
    # issue
    Read From Terminal Until    efi/FirmwareUpdateMode:hex = 01
    Press Key N Times    1    ${CTRL_C}
    Enter IPXE Shell Submenu
    Execute Command In Terminal    dhcp
    # Write Bare allows to set interval between each character which might be
    # needed on slower platforms/serial connection
    Write Bare Into Terminal    chain http://boot.dasharo.com/dts/dts-no-fum-fix.ipxe\n    interval=0.2
    # Boot into DTS shell
    Set DUT Response Timeout    5m
    Read From Terminal Until    .cpio.gz...
    Read From Terminal Until    ok
    Wait For DTS To Boot    fum=${TRUE}
    Write Into Terminal    ${DTS_FUM_MENU_OPT}
    Enter Shell In DTS

*** Keywords ***
Get Key To Press
    [Arguments]    ${text}
    ${matches}=    Get Regexp Matches    ${text}    [0-9]
    VAR    ${digit}=    ${matches[0]}
    Log    Found digit: ${digit}
    RETURN    ${digit}