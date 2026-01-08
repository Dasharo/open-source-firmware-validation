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

# Resource    ../platform-configs/msi-pro-z690-a-ddr5.robot
# Required setup keywords:
# Prepare Test Suite - elementary setup keyword for all tests.
# Upload Required Images - uploads all required files onto the PiKVM.
# Required teardown keywords:
# Log Out And Close Connection - elementary teardown keyword for all tests.
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Tests in Firmware not supported
...                     AND
...                     Skip If    not ${SECURE_BOOT_SUPPORT}    Secure Boot is not supported
...                     AND
...                     Mount USB Disk Image    ${TEST_DATA_DIR}/secure-boot/sb_test_data.img    file    TRUE
...                     AND
...                     Restore Secure Boot Defaults
Suite Teardown      Run Keywords
...                     Run Keyword If    ${SECURE_BOOT_SUPPORT} and ${TESTS_IN_FIRMWARE_SUPPORT}    Set Secure Boot State To Disabled
...                     AND
...                     Log Out And Close Connection
Test Setup          Run Keyword
...                     Restore Initial DUT Connection Method

Default Tags        automated


*** Test Cases ***
SBO001.101 Check Secure Boot default state (firmware)
    [Documentation]    This test aims to verify that Secure Boot state after
    ...    flashing the platform with the Dasharo firmware is
    ...    correct.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO001.101 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO001.101 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    ${sb_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${device_mgr_menu}
    ...    Secure Boot Configuration
    ${sb_state}=    Get Matches    ${sb_menu}    Current Secure Boot State*
    Should Contain    ${sb_state}[0]    ${SECURE_BOOT_DEFAULT_STATE}

SBO002.201 UEFI Secure Boot (Ubuntu)
    [Documentation]    This test verifies that Secure Boot can be enabled from
    ...    boot menu and, after the DUT reset, it is seen from
    ...    the OS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO002.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO002.201 not supported

    # 1. Make sure that SB is enabled
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    # Save Changes And Reset
    # Changes to Secure Boot menu takes action immediately, so we can just reset
    Tianocore Reset System

    # 2. Check SB state in OS
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${sb_status}=    Check Secure Boot In Linux
    Should Be True    ${sb_status}
    Execute Reboot Command

    # 3. Make sure that SB is disabled
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Disable Secure Boot    ${sb_menu}
    # Save Changes And Reset
    # Changes to Secure Boot menu takes action immediately, so we can just reset
    Tianocore Reset System

    # 4. Check SB state in OS
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${sb_status}=    Check Secure Boot In Linux
    Should Not Be True    ${sb_status}

SBO002.301 UEFI Secure Boot (Windows)
    [Documentation]    This test verifies that Secure Boot can be enabled from
    ...    boot menu and, after the DUT reset, it is seen from
    ...    the OS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO002.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SBO002.301 not supported

    # 1. Make sure that SB is enabled
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    # Save Changes And Reset
    # Changes to Secure Boot menu takes action immediately, so we can just reset
    Tianocore Reset System

    # 2. Check SB state in OS
    Login To Windows
    ${sb_status}=    Check Secure Boot In Windows
    Should Be True    ${sb_status}
    Execute Reboot Command    windows

    # 3. Make sure that SB is disabled
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Disable Secure Boot    ${sb_menu}
    # Save Changes And Reset
    # Changes to Secure Boot menu takes action immediately, so we can just reset
    Tianocore Reset System

    # 4. Check SB state in OS
    Login To Windows
    ${sb_status}=    Check Secure Boot In Windows
    Should Not Be True    ${sb_status}

# TODO: These must be improved (never worked reliably), and adjusted to both
# keywords and menu layout changes.
#

SBO003.101 Attempt to boot file with the correct key from Boot Maintenance Manager (firmware)
    [Documentation]    This test verifies that Secure Boot allows booting a
    ...    signed file with a correct key.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO004.101 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO004.101 not supported
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    # Save Changes
    # Changes to Secure Boot menu take action immediately, so we can just continue
    Reenter Menu
    ${sb_menu}=    Get Secure Boot Menu Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll DB Signature Using File In DB Options    ${advanced_menu}
    Enter Volume In File Explorer    BAD_INFLUE
    Select File In File Explorer    cert_good.der
    # Save Changes And Reset
    # Changes to Secure Boot menu take action immediately, so we can just reset
    Tianocore Reset System

    Enter Boot From File
    Enter Volume In File Explorer    BAD_INFLUE
    Execute File In File Explorer    hello-dasharo-signed-good.efi
    Read From Terminal Until    ${HELLO_EFI_STRING}

SBO004.101 Attempt to boot file without the key from Boot Maintenance Manager (firmware)
    [Documentation]    This test verifies that Secure Boot blocks booting a file
    ...    without a key.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO004.101 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO004.101 not supported
    # 1. Make sure that SB is enabled
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    # Save Changes And Reset
    # Changes to Secure Boot menu takes action immediately, so we can just reset
    Tianocore Reset System

    Enter Boot From File
    Enter Volume In File Explorer    BAD_INFLUE
    Execute File In File Explorer    hello-dasharo.efi
    Read From Terminal Until    ${SB_ERROR_STRING}

SBO005.101 Attempt to boot file with the wrong-signed key from Boot Maintenance Manager (firmware)
    [Documentation]    This test verifies that Secure Boot disallows booting
    ...    a signed file with a wrong-signed key.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO005.101 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO005.101 not supported
    # 1. Make sure that SB is enabled
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    # Save Changes And Reset
    # Changes to Secure Boot menu takes action immediately, so we can just reset
    Tianocore Reset System

    Enter Boot From File
    Enter Volume In File Explorer    BAD_INFLUE
    Execute File In File Explorer    hello-dasharo-signed-bad.efi
    Read From Terminal Until    ${SB_ERROR_STRING}

SBO006.101 Reset Secure Boot Keys option availability (firmware)
    [Documentation]    This test verifies that the Reset Secure Boot Keys
    ...    option is available
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO006.101 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO006.101 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    ${sb_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${device_mgr_menu}
    ...    Secure Boot Configuration
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Should Contain    ${advanced_menu}    > Reset to default Secure Boot Keys

SBO007.101 Attempt to boot the file after restoring keys to default (firmware)
    [Documentation]    This test verifies that restoring the keys to default
    ...    removes any custom added certificates.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO007.101 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO007.101 not supported
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    # Save Changes
    # Changes to Secure Boot menu take action immediately, so we can just continue

    Reenter Menu
    ${sb_menu}=    Get Secure Boot Menu Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll DB Signature Using File In DB Options    ${advanced_menu}
    Enter Volume In File Explorer    BAD_INFLUE
    Select File In File Explorer    cert_good.der
    # Save Changes And Reset
    # Changes to Secure Boot menu take action immediately, so we can just reset
    Tianocore Reset System

    Enter Boot From File
    Enter Volume In File Explorer    BAD_INFLUE
    Execute File In File Explorer    hello-dasharo-signed-good.efi
    Read From Terminal Until    ${HELLO_EFI_STRING}

    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Reset To Default Secure Boot Keys    ${advanced_menu}
    # Save Changes And Reset
    # Changes to Secure Boot menu take action immediately, so we can just reset
    Tianocore Reset System

    Enter Boot From File
    Enter Volume In File Explorer    BAD_INFLUE
    Execute File In File Explorer    hello-dasharo-signed-good.efi
    Read From Terminal Until    ${SB_ERROR_STRING}

SBO008.101 Attempt to enroll the key in the incorrect format (firmware)
    [Documentation]    This test verifies that it is impossible to load
    ...    a certificate in the wrong file format.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO008.101 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO008.101 not supported
    # 1. Make sure that SB is enabled
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    # Changes to Secure Boot take action immediately, so we can just continue
    Reenter Menu
    ${sb_menu}=    Get Secure Boot Menu Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll DB Signature Using File In DB Options    ${advanced_menu}
    Enter Volume In File Explorer    BAD_INFLUE
    Select File In File Explorer    cert_fake.der
    Read From Terminal Until    ERROR: Unsupported file type!


*** Keywords ***
Set Secure Boot State To Disabled
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Disable Secure Boot    ${sb_menu}
    # Changes to Secure Boot menu take action immediately, so we can just reset
    Tianocore Reset System
