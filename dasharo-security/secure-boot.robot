*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Library             ../lib/secure-boot-lib.py

# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
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
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
Test Setup          Restore Initial DUT Connection Method


*** Test Cases ***

SBO001.001 Check Secure Boot default state (firmware)
    [Documentation]    This test aims to verify that Secure Boot state after
    ...    flashing the platform with the Dasharo firmware is
    ...    correct.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO001.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    ${sb_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${device_mgr_menu}
    ...    Secure Boot Configuration
    ${sb_state}=    Get Matches    ${sb_menu}    Current Secure Boot State*
    Should Contain    ${sb_state}[0]    Disabled

SBO002.001 UEFI Secure Boot (Ubuntu 22.04)
    [Documentation]    This test verifies that Secure Boot can be enabled from
    ...    boot menu and, after the DUT reset, it is seen from
    ...    the OS.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO002.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO002.001 not supported

    # 1. Make sure that SB is enabled
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    Save Changes And Reset    2

    # 2. Check SB state in OS
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${sb_status}=    Check Secure Boot In Linux
    Should Be True    ${sb_status}
    Execute Reboot Command

    # 3. Make sure that SB is disabled
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Disable Secure Boot    ${sb_menu}
    Save Changes And Reset    2

    # 4. Check SB state in OS
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

    # 1. Make sure that SB is enabled
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    Save Changes And Reset    2

    # 2. Check SB state in OS
    Boot System Or From Connected Disk    ${OS_WINDOWS}
    Login To Windows
    ${sb_status}=    Check Secure Boot In Windows
    Should Be True    ${sb_status}
    Execute Reboot Command

    # 3. Make sure that SB is disabled
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Disable Secure Boot    ${sb_menu}
    Save Changes And Reset    2

    # 4. Check SB state in OS
    Boot System Or From Connected Disk    ${OS_WINDOWS}
    Login To Windows
    Switch To Root User
    ${sb_status}=    Check Secure Boot In Windows
    Should Not Be True    ${sb_status}

# TODO: These must be imrpoved (never worked reliably), and adjusted to both
# keywords and menu layout changes.
#

SBO003.001 Attempt to boot file with the correct key from Shell (firmware)
    [Documentation]    This test verifies that Secure Boot allows booting
    ...    a signed file with a correct key.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO003.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO003.001 not supported
    Download ISO And Mount As USB    ${DL_CACHE_DIR}/${GOOD_KEYS_NAME}    ${GOOD_KEYS_URL}    ${GOOD_KEYS_SHA256}
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    Save Changes
    Reenter Menu
    ${sb_menu}=    Get Secure Boot Menu Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll DB Signature Using File In DB Options    ${advanced_menu}
    Enter Volume In File Explorer    GOOD_KEYS
    Select File In File Explorer    DB.cer
    Save Changes And Reset    3    5

    Enter UEFI Shell
    ${out}=    Execute File In UEFI Shell    hello-valid-keys.efi
    Should Contain    ${out}    Hello, world!

SBO004.001 Attempt to boot file without the key from Shell (firmware)
    [Documentation]    This test verifies that Secure Boot blocks booting a file
    ...    without a key.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO004.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO004.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO004.001 not supported
    Download ISO And Mount As USB    ${DL_CACHE_DIR}/${NOT_SIGNED_NAME}    ${NOT_SIGNED_URL}    ${NOT_SIGNED_SHA256}
    Power On
    Enter UEFI Shell
    ${out}=    Execute File In UEFI Shell    hello.efi
    Should Contain    ${out}    Access Denied

SBO005.001 Attempt to boot file with the wrong-signed key from Shell (firmware)
    [Documentation]    This test verifies that Secure Boot disallows booting
    ...    a signed file with a wrong-signed key.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO005.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO005.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO005.001 not supported
    Download ISO And Mount As USB    ${DL_CACHE_DIR}/${BAD_KEYS_NAME}    ${BAD_KEYS_URL}    ${BAD_KEYS_SHA256}
    Power On
    Enter UEFI Shell
    ${out}=    Execute File In UEFI Shell    hello-bad-keys.efi
    Should Contain    ${out}    Access Denied

SBO006.001 Reset Secure Boot Keys option availability (firmware)
    [Documentation]    This test verifies that the Reset Secure Boot Keys
    ...    option is available
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO006.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO006.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO006.001 not supported
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

SBO007.001 Attempt to boot the file after restoring keys to default (firmware)
    [Documentation]    This test verifies that restoring the keys to default
    ...    removes any custom added certificates.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO007.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO007.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO007.001 not supported
    Download ISO And Mount As USB    ${DL_CACHE_DIR}/${GOOD_KEYS_NAME}    ${GOOD_KEYS_URL}    ${GOOD_KEYS_SHA256}
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    Save Changes
    Reenter Menu
    ${sb_menu}=    Get Secure Boot Menu Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll DB Signature Using File In DB Options    ${advanced_menu}
    Enter Volume In File Explorer    GOOD_KEYS
    Select File In File Explorer    DB.cer
    Save Changes And Reset    3    5

    Enter UEFI Shell
    ${out}=    Execute File In UEFI Shell    hello-valid-keys.efi
    Should Contain    ${out}    Hello, world!

    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Reset To Default Secure Boot Keys    ${advanced_menu}
    Save Changes And Reset    3    5

    Enter UEFI Shell
    ${out}=    Execute File In UEFI Shell    hello-valid-keys.efi
    Should Contain    ${out}    Access Denied

SBO008.001 Attempt to enroll the key in the incorrect format (firmware)
    [Documentation]    This test verifies that it is impossible to load
    ...    a certificate in the wrong file format.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO008.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO008.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO008.001 not supported
    Download ISO And Mount As USB    ${DL_CACHE_DIR}/${BAD_FORMAT_NAME}    ${BAD_FORMAT_URL}    ${BAD_FORMAT_SHA256}
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    Save Changes
    Reenter Menu
    ${sb_menu}=    Get Secure Boot Menu Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll DB Signature Using File In DB Options    ${advanced_menu}
    Enter Volume In File Explorer    BAD_FORMAT
    Select File In File Explorer    DB.txt
    Read From Terminal Until    ERROR: Unsupported file type!

SBO009.001 Check automatic certificate provisioning
    [Documentation]    This test verifies that the automatic certificate
    ...    provisioning will install custom keys which will make Ubuntu
    ...    unbootable.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO009.001 not supported
    Power On
    # Erase Secure Boot Keys
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    Save Changes
    Reenter Menu
    ${sb_menu}=    Get Secure Boot Menu Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Erase All Secure Boot Keys    ${advanced_menu}
    Save Changes And Reset    3    5
    # Reboot to Automatic provisioning
    Boot Dasharo Tools Suite    USB    True
    Boot System Or From Connected Disk      ubuntu
    Read From Terminal Until    Press any key to continue...

SBO009.002 Check automatic certificate provisioning KEK certificate
    [Documentation]    This test verifies that the automatic certificate
    ...    provisioning installs the expected KEK certificate.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO009.002 not supported
    Power On
    # TODO change name 
    Boot Dasharo Tools Suite    USB
    Enter Shell In DTS
    # Get the KEK certificates
    Execute Command In Terminal    mokutil --kek > mokutil-kek
    Execute Command In Terminal    wget https://raw.githubusercontent.com/Wind-River/meta-secure-core/master/meta-signing-key/files/uefi_sb_keys/KEK.crt
    Execute Command In Terminal    openssl x509 -in KEK.crt -noout -text -fingerprint > kek

   # mokutil and openssl-x509 have slightly different output formats. They are
   # therefore compared using a python keyword.
    ${mokutil-file}=    Execute Command In Terminal    cat mokutil-kek
    ${openssl-file}=    Execute Command In Terminal    cat kek
    ${out}=    Run Keyword And Return Status    Compare Mokutil And OpenSSL Outputs    ${mokutil-file}    ${openssl-file}
    Should Be True    ${out}

    # Clean up
    Execute Command In Terminal    rm mokutil-kek kek KEK.crt
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Reset To Default Secure Boot Keys    ${advanced_menu} 

*** Keywords ***
Prepare Test Files
    IF    "${MANUFACTURER}" == "QEMU"
        Download To Host Cache
        ...    ${GOOD_KEYS_NAME}
        ...    ${GOOD_KEYS_URL}
        ...    ${GOOD_KEYS_SHA256}
        Download To Host Cache
        ...    ${NOT_SIGNED_NAME}
        ...    ${NOT_SIGNED_URL}
        ...    ${NOT_SIGNED_SHA256}
        Download To Host Cache
        ...    ${BAD_KEYS_NAME}
        ...    ${BAD_KEYS_URL}
        ...    ${BAD_KEYS_SHA256}
        Download To Host Cache
        ...    ${BAD_FORMAT_NAME}
        ...    ${BAD_FORMAT_URL}
        ...    ${BAD_FORMAT_SHA256}
    END
