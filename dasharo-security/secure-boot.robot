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
Resource            ../lib/ansible.robot

# Resource    ../platform-configs/msi-pro-z690-a-ddr5.robot
# Required setup keywords:
# Prepare Test Suite - elementary setup keyword for all tests.
# Upload Required Images - uploads all required files onto the PiKVM.
# Required teardown keywords:
# Log Out And Close Connection - elementary teardown keyword for all tests.
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     Run Ansible Playbook On Supported Operating Systems
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
Test Setup          Run Keywords
...                     Restore Initial DUT Connection Method


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

SBO009.001 Attempt to boot file signed for intermediate certificate
    [Documentation]    This test verifies that a file signed with an
    ...    intermediate certificate can be executed.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO009.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO009.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO009.001 not supported
    Download ISO And Mount As USB
    ...    ${DL_CACHE_DIR}/${INTERMEDIATE_NAME}
    ...    ${INTERMEDIATE_URL}
    ...    ${INTERMEDIATE_SHA256}
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    Save Changes
    Reenter Menu
    ${sb_menu}=    Get Secure Boot Menu Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll DB Signature Using File In DB Options    ${advanced_menu}
    Enter Volume In File Explorer    NO VOLUME LABEL
    Select File In File Explorer    intermediate-db.der
    Save Changes And Reset    3    5
    Enter UEFI Shell
    ${out}=    Execute File In UEFI Shell    hello.efi
    Should Contain    ${out}    Access Denied
    ${out}=    Execute File In UEFI Shell    signed-hello.efi

SBO010.001 Check support for rsa2k signed certificates
    [Documentation]    PEM generated with `openssl req -new -x509 -newkey rsa:2048 -subj "/CN=DB-RSA2048/" -keyout DB-RSA2048.key -out DB-RSA2048.crt -days 3650 -nodes -sha256`
    ...    converted to DER using `openssl base64 -d -in DB-RSA2048.cer -out DB-RSA2048.der`
    Download ISO And Mount As USB    ${DL_CACHE_DIR}/${RSA2_K_TEST_NAME}    ${RSA2_K_TEST_URL}    ${RSA2_K_TEST_SHA256}
    Power On

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${sb_menu}=    Reenter Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll DB Signature Using File In DB Options    ${advanced_menu}
    Enter Volume In File Explorer    RSA2K_LABEL
    Select File In File Explorer    DB-RSA2048.der
    Save Changes And Reset    3    5

    Enter UEFI Shell
    ${out}=    Execute File In UEFI Shell    hello_rsa2k.efi
    Should Contain    ${out}    Hello, world!

SBO010.002 Check support for rsa3k signed certificates
    [Documentation]    PEM generated with `openssl req -new -x509 -newkey rsa:3072 -subj "/CN=DB-RSA3072/" -keyout DB-RSA3072.key -out DB-RSA3072.pem -days 3650 -nodes -sha256`
    ...    converted to DER using `openssl base64 -d -in DB-RSA3072.cer -out DB-RSA3072.der`
    Download ISO And Mount As USB    ${DL_CACHE_DIR}/${RSA3_K_TEST_NAME}    ${RSA3_K_TEST_URL}    ${RSA3_K_TEST_SHA256}
    Power On

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${sb_menu}=    Reenter Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll DB Signature Using File In DB Options    ${advanced_menu}
    Enter Volume In File Explorer    RSA3K_LABEL
    Select File In File Explorer    DB-RSA3072.der
    Save Changes And Reset    3    5

    Enter UEFI Shell
    ${out}=    Execute File In UEFI Shell    hello_rsa3k.efi
    Should Contain    ${out}    Hello, world!

SBO010.003 Check support for rsa4k signed certificates
    [Documentation]    PEM generated with `openssl req -new -x509 -newkey rsa:4096 -subj "/CN=DB-RSA4096/" -keyout DB-RSA4096.key -out DB-RSA4096.pem -days 3650 -nodes -sha256`
    ...    converted to DER using `openssl base64 -d -in DB-RSA4096.cer -out DB-RSA4096.der`
    Download ISO And Mount As USB    ${DL_CACHE_DIR}/${RSA4_K_TEST_NAME}    ${RSA4_K_TEST_URL}    ${RSA4_K_TEST_SHA256}
    Power On

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${sb_menu}=    Reenter Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll DB Signature Using File In DB Options    ${advanced_menu}
    Enter Volume In File Explorer    RSA4K_LABEL
    Select File In File Explorer    DB-RSA4096.der
    Save Changes And Reset    3    5

    Enter UEFI Shell
    ${out}=    Execute File In UEFI Shell    hello_rsa4k.efi
    Should Contain    ${out}    Hello, world!

SBO010.004 Check support for ecdsa256 signed certificates
    [Documentation]    PEM generated with `openssl req -new -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 -subj "/CN=DB-ECDSA256/" -keyout DB-ECDSA256.key
    ...    -out DB-ECDSA256.crt -days 3650 -nodes -sha256`
    ...    converted to DER using `openssl base64 -d -in DB-ECDSA256.cer -out DB-ECDSA256.der`
    Download ISO And Mount As USB
    ...    ${DL_CACHE_DIR}/${ECDSA256_TEST_NAME}
    ...    ${ECDSA256_TEST_URL}
    ...    ${ECDSA256_TEST_SHA256}
    Power On

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${sb_menu}=    Reenter Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll DB Signature Using File In DB Options    ${advanced_menu}
    Enter Volume In File Explorer    ECDSA256_L
    Select File In File Explorer    DB-ECDSA256.der
    Save Changes And Reset    3    5

    Enter UEFI Shell
    ${out}=    Execute File In UEFI Shell    hello_ecdsa256.efi
    Should Contain    ${out}    Hello, world!

SBO010.005 Check support for ecdsa384 signed certificates
    [Documentation]    PEM generated with `openssl req -new -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-384 -subj "/CN=DB-ECDSA384/" -keyout DB-ECDSA384.key
    ...    -out DB-ECDSA384.crt -days 3650 -nodes -sha256`
    ...    converted to DER using `openssl base64 -d -in DB-ECDSA384.cer -out DB-ECDSA384.der`
    Download ISO And Mount As USB
    ...    ${DL_CACHE_DIR}/${ECDSA384_TEST_NAME}
    ...    ${ECDSA384_TEST_URL}
    ...    ${ECDSA384_TEST_SHA256}
    Power On

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${sb_menu}=    Reenter Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll DB Signature Using File In DB Options    ${advanced_menu}
    Enter Volume In File Explorer    ECDSA384_L
    Select File In File Explorer    DB-ECDSA384.der
    Save Changes And Reset    3    5

    Enter UEFI Shell
    ${out}=    Execute File In UEFI Shell    hello_ecdsa384.efi
    Should Contain    ${out}    Hello, world!

SBO010.006 Check support for ecdsa521 signed certificates
    [Documentation]    PEM generated with `openssl req -new -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-521 -subj "/CN=DB-ECDSA521/" -keyout DB-ECDSA521.key
    ...    -out DB-ECDSA521.crt -days 3650 -nodes -sha256`
    ...    converted to DER using `openssl base64 -d -in DB-ECDSA521.cer -out DB-ECDSA521.der`
    Download ISO And Mount As USB
    ...    ${DL_CACHE_DIR}/${ECDSA521_TEST_NAME}
    ...    ${ECDSA521_TEST_URL}
    ...    ${ECDSA521_TEST_SHA256}
    Power On

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${sb_menu}=    Reenter Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll DB Signature Using File In DB Options    ${advanced_menu}
    Enter Volume In File Explorer    ECDSA521_L
    Select File In File Explorer    DB-ECDSA521.der
    Save Changes And Reset    3    5

    Enter UEFI Shell
    ${out}=    Execute File In UEFI Shell    hello_ecdsa521.efi
    Should Contain    ${out}    Hello, world!

SBO011.001 Attempt to enroll expired certificate and boot signed image
    [Documentation]    This test verifies that an expired certificate can be
    ...    used to verify booted image.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO011.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO011.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO011.001 not supported
    Download ISO And Mount As USB    ${DL_CACHE_DIR}/${EXPIRED_NAME}    ${EXPIRED_URL}    ${EXPIRED_SHA256}
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    Save Changes
    Reenter Menu
    ${sb_menu}=    Get Secure Boot Menu Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll DB Signature Using File In DB Options    ${advanced_menu}
    Enter Volume In File Explorer    NO VOLUME LABEL
    Select File In File Explorer    ExpiredCert.der
    Save Changes And Reset    3    5
    Enter UEFI Shell
    ${out}=    Execute File In UEFI Shell    hello.efi
    Should Contain    ${out}    Access Denied
    ${out}=    Execute File In UEFI Shell    hello-signed-with-expired-cert.efi
    Should Contain    ${out}    Access Denied

SBO012.001 Boot OS Signed And Enrolled From Inside System (Ubuntu 22.04)
    [Documentation]    This test verifies that OS boots after enrolling keys
    ...    and signing system from inside
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO012.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO012.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO012.001 not supported

    Power On
    # 1. Make sure we are in Setup Mode
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Erase All Secure Boot Keys    ${advanced_menu}
    Exit From Current Menu
    Save Changes And Reset    2

    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User

    # 2. Remove old keys then generate and enroll new keys
    Remove Old Secure Boot Keys In OS
    ${sb_status}=    Generate Secure Boot Keys In OS
    Should Be True    ${sb_status}
    ${sb_status}=    Enroll Secure Boot Keys In OS
    Should Be True    ${sb_status}

    # 3. Sign all components
    Sign All Boot Components In OS
    Execute Reboot Command

    # 4. Enable Secure Boot
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    Save Changes And Reset    2

    # 5. Check SB state in OS
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${sb_status}=    Check Secure Boot In Linux
    Should Be True    ${sb_status}


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
