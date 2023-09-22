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
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/secure-boot-lib.robot

# Required setup keywords:
# Prepare Test Suite - elementary setup keyword for all tests.
# Reset Secure Boot Keys For The First Time - resets secure boot keys
#    for the first time since flashing. Otherwise enabling secure boot
#    is not possible.
# Upload Required Images - uploads all required files onto the PiKVM.
# Required teardown keywords:
# Log Out And Close Connection - elementary teardown keyword for all tests.
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Reset Secure Boot Keys For The First Time
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
SBO001.001 Check Secure Boot default state (firmware)
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
    ${sb_state}=    Get Option Value    Attempt Secure Boot    checkpoint=Save
    Should Contain    ${sb_state}    [ ]

SBO002.001 UEFI Secure Boot (Ubuntu 22.04)
    [Documentation]    This test verifies that Secure Boot can be enabled from
    ...    boot menu and, after the DUT reset, it is seen from
    ...    the OS.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO002.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO002.001 not supported

    Power On
    Enable Secure Boot

    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${sb_status}=    Check Secure Boot In Linux
    Should Be True    ${sb_status}

    Power On
    Disable Secure Boot

    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${sb_status}=    Check Secure Boot In Linux
    Should Not Be True    ${sb_status}

SBO002.002 UEFI Secure Boot (Windows 11)
    [Documentation]    This test verifies that Secure Boot can be enabled from
    ...    boot menu and, after the DUT reset, it is seen from
    ...    the OS.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO002.002 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO002.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SBO002.002 not supported

    Power On
    Enable Secure Boot
    Boot System Or From Connected Disk    ${OS_WINDOWS}
    Login To Windows
    ${sb_status}=    Check Secure Boot In Windows
    Should Be True    ${sb_status}
    Power On
    Disable Secure Boot

    Boot System Or From Connected Disk    ${OS_WINDOWS}
    Login To Windows
    ${sb_status}=    Check Secure Boot In Windows
    Should Not Be True    ${sb_status}

SBO003.001 Attempt to boot file with the correct key from Shell (firmware)
    [Documentation]    This test verifies that Secure Boot allows booting
    ...    a signed file with a correct key.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO003.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO003.001 not supported
    Mount Image    ${PIKVM_IP}    good_keys.img
    Power On
    Enable Secure Boot
    Enable Custom Mode And Enroll Certificate    DB.cer
    Enter UEFI Shell And Boot .EFI File    hello-valid-keys.efi    Hello, world!

SBO004.001 Attempt to boot file without the key from Shell (firmware)
    [Documentation]    This test verifies that Secure Boot blocks booting a file
    ...    without a key.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO004.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO004.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO004.001 not supported
    Mount Image    ${PIKVM_IP}    not_signed.img
    Power On
    Enter UEFI Shell And Boot .EFI File    hello.efi    Access Denied

SBO005.001 Attempt to boot file with the wrong-signed key from Shell (firmware)
    [Documentation]    This test verifies that Secure Boot disallows booting
    ...    a signed file with a wrong-signed key.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO005.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO005.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO005.001 not supported
    Mount Image    ${PIKVM_IP}    bad_keys.img
    Power On
    Enter UEFI Shell And Boot .EFI File    hello-bad-keys.efi    Access Denied

SBO006.001 Reset Secure Boot Keys option availability (firmware)
    [Documentation]    This test verifies that the Reset Secure Boot Keys
    ...    option is available
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO006.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO006.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO006.001 not supported

    Power On
    Verify Reset Secure Boot Keys

SBO007.001 Attempt to boot the file after restoring keys to default (firmware)
    [Documentation]    This test verifies that restoring the keys to default
    ...    removes any custom added certificates.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO007.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO007.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO007.001 not supported
    Mount Image    ${PIKVM_IP}    good_keys.img
    Power On
    Enable Custom Mode And Enroll Certificate    DB.cer
    Enter UEFI Shell And Boot .EFI File    hello-valid-keys.efi    Hello, world!
    Power On
    Reset Secure Boot Keys Again
    Enter UEFI Shell And Boot .EFI File    hello-valid-keys.efi    Access Denied

SBO008.001 Attempt to enroll the key in the incorrect format (firmware)
    [Documentation]    This test verifies that it is impossible to load
    ...    a certificate in the wrong file format.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO008.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO008.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO008.001 not supported
    Mount Image    ${PIKVM_IP}    bad_format.img
    Power On
    Enable Custom Mode And Enroll Certificate    DB.txt    BAD
