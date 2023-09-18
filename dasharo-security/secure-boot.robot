*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords    Prepare Test Suite    AND    Reset Secure Boot Keys For The First Time
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
 SBO001.001 Check Secure Boot default state (firmware)
    [Documentation]    This test aims to verfiy that Secure Boot state after
    ...    flashing the platform with the Dasharo firmware is
    ...    correct.
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
    ...    boot menu and, after the DUT reset, it is seen from
    ...    the OS.
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
    ...    boot menu and, after the DUT reset, it is seen from
    ...    the OS.
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


*** Keywords ***
Check if Attempt Secure Boot can be Selected
    [Documentation]    The Attempt Secure Boot option may be unavailable if
    ...    Reset Secure Boot Keys was not selected before. This keyword checks
    ...    if the Attempt Secure Boot can already be selected. If the help text
    ...    matches this option, it means it can already be selected.
    ${menu_construction}=    Get Secure Boot Configuration Submenu Construction
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
    RETURN    ${can_be_selected}

Reset Secure Boot Keys For The First Time
    [Documentation]    This test aims to verfiy that Secure Boot state after
    ...    flashing the platform with the Dasharo firmware is
    ...    correct.
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
    ...    Returns True when Secure Boot is enabled
    ...    and False when disabled.
    ${out}=    Execute Linux command    dmesg | grep secureboot
    Should Contain Any    ${out}    disabled    enabled
    ${sb_status}=    Run Keyword And Return Status    Should Contain    ${out}    enabled
    RETURN    ${sb_status}

Check Secure Boot in Windows
    [Documentation]    Keyword checks Secure Boot state in Windows.
    ...    Returns True when Secure Boot is enabled
    ...    and False when disabled.
    ${out}=    ${out}=    Confirm-SecureBootUEFI
    Should Contain Any    ${out}    True    False
    ${sb_status}=    Run Keyword And Return Status    Should Contain    ${out}    True
    RETURN    ${sb_status}

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
