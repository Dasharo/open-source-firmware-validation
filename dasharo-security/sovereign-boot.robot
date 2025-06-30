*** Settings ***
Library             Collections
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../variables.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${SOVEREIGN_BOOT_SUPPORT}    Sovereign Boot tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
# This must be in Test Setup, not Suite Setup, because of a known problem
# with QEMU: https://github.com/Dasharo/open-source-firmware-validation/issues/132
Test Setup          Run Keyword If    ${TESTS_IN_FIRMWARE_SUPPORT}
...                     Restore Initial DUT Connection Method


*** Variables ***
${SET_SV_BOOT_PROVISIONED_CMD}=     setvar SvBootConfig -guid B57031B9-1ABB-45F8-A9CB-AC5AAD72AD31 -bs -nv \=0101


*** Test Cases ***
SVB001.001 Sovereign Boot Wizard shows up on first boot
    [Documentation]    This test aims to verify that wizard is launched on
    ...    first boot.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SVB001.001 not supported
    Power On
    ${out}=    Read From Terminal Until    Sovereign Boot Provisioning Wizard
    Should Not Contain    ${out}    ${TIANOCORE_STRING}

SVB001.002 Sovereign Boot Wizard shows up after settings reset
    [Documentation]    This test aims to verify that wizard is launched after
    ...    settings reset.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SVB001.002 not supported
    Power On
    Read From Terminal Until    Sovereign Boot Provisioning Wizard
    Read From Terminal Until    restored default system settings.
    ${menu}=    Get Menu Construction    Esc=Exit    0    1
    # Read the remaining part of the menu
    Read From Terminal
    # We should check if [Exit] exists, but the menu is so small, that it has to be scrolled
    Press Key N Times    1    ${ESC}
    # Pressing ESC will get us to setup
    ${menu}=    Get Setup Menu Construction
    # Boot to Shell and emulate provisioned state. Will be removed in later phases of the project
    Enter UEFI Shell From Setup    ${menu}
    Execute UEFI Shell Command    ${SET_SV_BOOT_PROVISIONED_CMD}
    # Reset the system
    Tianocore Reset System
    # From now on we can use generic keywords
    Enter Setup Menu Tianocore
    Reset To Defaults Tianocore
    Save Changes And Reset
    ${out}=    Read From Terminal Until    Sovereign Boot Provisioning Wizard

SVB001.003 Sovereign Boot Wizard shows up after first boot option verification fails
    [Documentation]    This test aims to verify that wizard is launched after
    ...    settings reset.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SVB001.002 not supported
    # FIXME: doesn't work on QEMU, start QEMU with DTS already mounted!
    # Mount USB Disk Image    ${TEST_DATA_DIR}/dts/dts-base-image-v2.1.3.wic
    Power On
    Read From Terminal Until    Sovereign Boot Provisioning Wizard
    Read From Terminal Until    restored default system settings.
    ${menu}=    Get Menu Construction    Esc=Exit    0    1
    # Read the remaining part of the menu
    Read From Terminal
    # We should check if [Exit] exists, but the menu is so small, that it has to be scrolled
    Press Key N Times    1    ${ESC}
    # Pressing ESC will get us to setup
    ${menu}=    Get Setup Menu Construction
    # Boot to Shell and emulate provisioned state. Will be removed in later phases of the project
    Enter UEFI Shell From Setup    ${menu}
    Execute UEFI Shell Command    ${SET_SV_BOOT_PROVISIONED_CMD}
    # Reset the system
    Tianocore Reset System
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    # Save Changes And Reset
    # Changes to Secure Boot menu takes action immediately, so we can just reset
    Tianocore Reset System
    # Now the DTS should fail to boot
    # TODO: Ensure the veri first boot option is really unsigned. On real HW it may need to set
    # DTS as first boot option beforehand.
    Read From Terminal Until    Sovereign Boot Provisioning Wizard
    Read From Terminal Until    boot an untrusted image.
    ${menu}=    Get Menu Construction    Esc=Exit    0    1
    # Read the remaining part of the menu
    Read From Terminal
    Press Key N Times    1    ${ESC}
    # UEFI Boot Manager should print information about Secure Boot status and image verification status
    Read From Terminal Until    Secure Boot is enabled.
    Read From Terminal Until    The image signature is invalid or missing!

SVB002.001 Sovereign Boot Wizard disable option works
    [Documentation]    This test aims to verify that wizard disable option works.
    Power On
    # Sovereign Boot should be provisioend at this point, use generic keyword.
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    # Remove line that is not an option
    ${sv_index}=    Get Index From List    ${sb_menu}    *** Sovereign Boot Options ***
    Remove From List    ${sb_menu}    ${sv_index}
    ${changed}=    Set Option State    ${sb_menu}    Enable Sovereign Boot    ${FALSE}
    IF    ${changed} == ${TRUE}
        # Changing Sovereign Boot state to disabled issues a special popup
        Read From Terminal Until    Disabling Sovereign Boot will restore default Secure Boot Keys & databases.
        Read From Terminal Until    Are you sure?
        # Confirm the choice
        Press Enter
        # Wait until the popup disappears
        Get Secure Boot Menu Construction
    ELSE
        Fail    "Sovereign Boot should be enabled at this point"
    END
    Tianocore Reset System
    # We should be able to boot straight to setup with prompts when wizard is disabled
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${sv_index}=    Get Index From List    ${sb_menu}    *** Sovereign Boot Options ***
    Remove From List    ${sb_menu}    ${sv_index}
    List Should Not Contain Value    ${sb_menu}    > Launch Sovereign Boot Wizard
    ${changed}=    Set Option State    ${sb_menu}    Enable Sovereign Boot    ${FALSE}
    Should Not Be True    ${changed}

SVB002.002 Sovereign Boot Wizard enable option works
    [Documentation]    This test aims to verify that wizard enable option works.
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    # Remove line that is not an option
    ${sv_index}=    Get Index From List    ${sb_menu}    *** Sovereign Boot Options ***
    Remove From List    ${sb_menu}    ${sv_index}
    ${changed}=    Set Option State    ${sb_menu}    Enable Sovereign Boot    ${TRUE}
    IF    ${changed} == ${TRUE}
        # Changing Sovereign Boot state to enabled takes action immediately
        Tianocore Reset System
    ELSE
        Fail    "Sovereign Boot should be disabled at this point"
    END
    # Sovereign boot welcome string should appear again
    Read From Terminal Until    Sovereign Boot Provisioning Wizard
    Read From Terminal Until    restored default system settings.
    ${menu}=    Get Menu Construction    Esc=Exit    0    1
    # Read the remaining part of the menu
    Read From Terminal
    # We should check if [Exit] exists, but the menu is so small, that it has to be scrolled
    Press Key N Times    1    ${ESC}
    # Pressing ESC will get us to setup
    ${menu}=    Get Setup Menu Construction
    ${sb_menu}=    Enter Secure Boot Menu From Setup    ${menu}
    List Should Contain Value    ${sb_menu}    > Launch Sovereign Boot Wizard

SVB003.001 Sovereign Boot Wizard parses boot options correctly
    Power On
    Read From Terminal Until    Sovereign Boot Provisioning Wizard
    Read From Terminal Until    scheme you would like to use:
    ${menu}=    Get Menu Construction    Esc=Exit    0    1
    # No default selection here, just one press to go to SOvereign Boot configuration view
    Press Key N Times And Enter    1    ${ARROW_DOWN}
    Read From Terminal Until    A new bootloader/key has been detected.
    ${out}=    Read From Terminal Until    Esc=Exit
    # TODO: check the Bootorder and Boot#### variables to get a list of expected boot options
    Should Contain    ${out}    Description: Dasharo Tools Suite (on QEMU HARDDISK)
    Should Contain    ${out}    File path: \\EFI\\DTS\\grubx64.efi
    # Press Enter to do not trust the key and move to the next bootloader
    Press Enter
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    Description: QEMU HARDDISK
    Should Contain    ${out}    File path: \\EFI\\BOOT\\BOOTX64.EFI
    # Now there should be no more bootloaders found
    Press Enter
    Read From Terminal Until    No more bootloaders found.
    Read From Terminal Until    Press ENTER to continue ...
    Press Enter
    # Remove it later once the proper flow is implemented
    Read From Terminal Until    Sovereign Boot is already provisioned.


*** Keywords ***
Enter UEFI Shell From Setup
    [Arguments]    ${setup_menu}
    ${boot_menu}=    Enter Submenu From Snapshot And Return Construction    ${setup_menu}    One Time Boot
    Set Prompt For Terminal    Shell>
    Enter Submenu From Snapshot    ${boot_menu}    UEFI Shell
    Read From Terminal Until Prompt
    Sleep    1s

Enter Secure Boot Menu From Setup
    [Arguments]    ${setup_menu}
    ${device_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Enter Submenu From Snapshot    ${device_mgr_menu}    Secure Boot Configuration
    ${sb_menu}=    Get Secure Boot Menu Construction
    RETURN    ${sb_menu}
