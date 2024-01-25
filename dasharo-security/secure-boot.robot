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
...                     AND
...                     Check If Certificate Images For Tests Exists
...                     AND
...                     Run Ansible Playbook On Supported Operating Systems    secure-boot
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
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${sb_state}=    Get Secure Boot State    ${sb_menu}
    Should Contain    ${sb_state}    Disabled

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
    Mount ISO As USB    ${CURDIR}/../scripts/secure-boot/images/GOOD_KEYS.img
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${key_menu}=    Enter Key Management And Return Construction
    Enroll DB Signature    ${key_menu}    GOOD_KEYS    cert.der
    Save Changes And Reset    3    5
    Boot Efi File    signed-hello.efi    GOOD_KEYS    Hello, World!

SBO004.001 Attempt to boot file without the key from Shell (firmware)
    [Documentation]    This test verifies that Secure Boot blocks booting a file
    ...    without a key.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO004.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO004.001 not supported
    Mount ISO As USB    ${CURDIR}/../scripts/secure-boot/images/NOT_SIGNED.img
    Power On
    Boot Efi File Should Fail    hello.efi    NOT_SIGNED

SBO005.001 Attempt to boot file with the wrong-signed key from Shell (firmware)
    [Documentation]    This test verifies that Secure Boot disallows booting
    ...    a signed file with a wrong-signed key.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO005.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO005.001 not supported
    Mount ISO As USB    ${CURDIR}/../scripts/secure-boot/images/BAD_KEYS.img
    Power On
    Boot Efi File Should Fail    signed-hello.efi    BAD_KEYS

SBO006.001 Reset Secure Boot Keys option availability (firmware)
    [Documentation]    This test verifies that the Reset Secure Boot Keys
    ...    option is available
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO006.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO006.001 not supported
    Power On
    Enter Secure Boot Menu
    ${key_menu}=    Enter Key Management And Return Construction
    Should Contain    ${key_menu}    ${RESET_KEYS_OPTION}

SBO007.001 Attempt to boot the file after restoring keys to default (firmware)
    [Documentation]    This test verifies that restoring the keys to default
    ...    removes any custom added certificates.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO007.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO007.001 not supported
    Mount ISO As USB    ${CURDIR}/../scripts/secure-boot/images/GOOD_KEYS.img
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${key_menu}=    Enter Key Management And Return Construction
    Enroll DB Signature    ${key_menu}    GOOD_KEYS    cert.der
    Save Changes And Reset    3    5

    Boot Efi File    signed-hello.efi    GOOD_KEYS    Hello, World!

    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${key_menu}=    Enter Key Management And Return Construction
    Reset To Default Secure Boot Keys    ${key_menu}
    Save Changes And Reset    3    5

    Boot Efi File Should Fail    signed-hello.efi    GOOD_KEYS

SBO008.001 Attempt to enroll the key in the incorrect format (firmware)
    [Documentation]    This test verifies that it is impossible to load
    ...    a certificate in the wrong file format.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO008.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO008.001 not supported
    Mount ISO As USB    ${CURDIR}/../scripts/secure-boot/images/BAD_FORMAT.img
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${key_menu}=    Enter Key Management And Return Construction
    Enroll DB Signature    ${key_menu}    BAD_FORMAT    cert.der
    Read From Terminal Until    ${INCORRECT_FORMAT_MESSAGE}

SBO009.001 Attempt to boot file signed for intermediate certificate
    [Documentation]    This test verifies that a file signed with an
    ...    intermediate certificate can be executed.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO009.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO009.001 not supported
    Mount ISO As USB    ${CURDIR}/../scripts/secure-boot/images/INTERMEDIATE.img
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${key_menu}=    Enter Key Management And Return Construction
    Enroll DB Signature    ${key_menu}    INTERMED    cert.der
    Save Changes And Reset    3    5
    Boot Efi File Should Fail    hello.efi    GOOD_KEYS
    Reset System
    Boot Efi File    signed-hello.efi    GOOD_KEYS    Hello, World!

SBO010.001 Check support for rsa2k signed certificates
    [Documentation]    PEM generated with `openssl req -new -x509 -newkey rsa:2048 -subj "/CN=DB-RSA2048/" -keyout DB-RSA2048.key -out DB-RSA2048.crt -days 3650 -nodes -sha256`
    ...    converted to DER using `openssl base64 -d -in DB-RSA2048.cer -out DB-RSA2048.der`
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO010.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO010.001 not supported
    Mount ISO As USB    ${CURDIR}/../scripts/secure-boot/images/RSA2048.img
    Power On

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${key_menu}=    Enter Key Management And Return Construction
    Enroll DB Signature    ${key_menu}    RSA2048    cert.der
    Save Changes And Reset    3    5

    Boot Efi File    signed-hello.efi    RSA2048    Hello, world!

SBO010.002 Check support for rsa3k signed certificates
    [Documentation]    PEM generated with `openssl req -new -x509 -newkey rsa:3072 -subj "/CN=DB-RSA3072/" -keyout DB-RSA3072.key -out DB-RSA3072.pem -days 3650 -nodes -sha256`
    ...    converted to DER using `openssl base64 -d -in DB-RSA3072.cer -out DB-RSA3072.der`
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO010.002 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO010.002 not supported
    Mount ISO As USB    ${CURDIR}/../scripts/secure-boot/images/RSA3072.img
    Power On

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${key_menu}=    Enter Key Management And Return Construction
    Enroll DB Signature    ${key_menu}    RSA3072    cert.der
    Save Changes And Reset    3    5

    Boot Efi File    signed-hello.efi    RSA3072    Hello, world!

SBO010.003 Check support for rsa4k signed certificates
    [Documentation]    PEM generated with `openssl req -new -x509 -newkey rsa:4096 -subj "/CN=DB-RSA4096/" -keyout DB-RSA4096.key -out DB-RSA4096.pem -days 3650 -nodes -sha256`
    ...    converted to DER using `openssl base64 -d -in DB-RSA4096.cer -out DB-RSA4096.der`
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO010.003 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO010.003 not supported
    Mount ISO As USB    ${CURDIR}/../scripts/secure-boot/images/RSA4096.img
    Power On

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${key_menu}=    Enter Key Management And Return Construction
    Enroll DB Signature    ${key_menu}    RSA4096    cert.der
    Save Changes And Reset    3    5

    Boot Efi File    signed-hello.efi    RSA4096    Hello, world!

SBO010.004 Check support for ecdsa256 signed certificates
    [Documentation]    PEM generated with `openssl req -new -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 -subj "/CN=DB-ECDSA256/" -keyout DB-ECDSA256.key
    ...    -out DB-ECDSA256.crt -days 3650 -nodes -sha256`
    ...    converted to DER using `openssl base64 -d -in DB-ECDSA256.cer -out DB-ECDSA256.der`
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO010.004 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO010.004 not supported
    Mount ISO As USB    ${CURDIR}/../scripts/secure-boot/images/ECDSA256.img
    Power On

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${key_menu}=    Enter Key Management And Return Construction
    Enroll DB Signature    ${key_menu}    ECDSA256    cert.der
    Save Changes And Reset    3    5

    Boot Efi File    signed-hello.efi    ECDSA256    Hello, world!

SBO010.005 Check support for ecdsa384 signed certificates
    [Documentation]    PEM generated with `openssl req -new -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-384 -subj "/CN=DB-ECDSA384/" -keyout DB-ECDSA384.key
    ...    -out DB-ECDSA384.crt -days 3650 -nodes -sha256`
    ...    converted to DER using `openssl base64 -d -in DB-ECDSA384.cer -out DB-ECDSA384.der`
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO010.005 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO010.005 not supported
    Mount ISO As USB    ${CURDIR}/../scripts/secure-boot/images/ECDSA384.img
    Power On

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${key_menu}=    Enter Key Management And Return Construction
    Enroll DB Signature    ${key_menu}    ECDSA384    cert.der
    Save Changes And Reset    3    5

    Boot Efi File    signed-hello.efi    ECDSA384    Hello, world!

SBO010.006 Check support for ecdsa521 signed certificates
    [Documentation]    PEM generated with `openssl req -new -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-521 -subj "/CN=DB-ECDSA521/" -keyout DB-ECDSA521.key
    ...    -out DB-ECDSA521.crt -days 3650 -nodes -sha256`
    ...    converted to DER using `openssl base64 -d -in DB-ECDSA521.cer -out DB-ECDSA521.der`
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO010.006 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO010.006 not supported
    Mount ISO As USB    ${CURDIR}/../scripts/secure-boot/images/ECDSA521.img
    Power On

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${key_menu}=    Enter Key Management And Return Construction
    Enroll DB Signature    ${key_menu}    ECDSA521    cert.der
    Save Changes And Reset    3    5

    Boot Efi File    signed-hello.efi    ECDSA521    Hello, world!

SBO011.001 Attempt to enroll expired certificate and boot signed image
    [Documentation]    This test verifies that an expired certificate can be
    ...    used to verify booted image.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO011.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO011.001 not supported
    Mount ISO As USB    ${CURDIR}/../scripts/secure-boot/images/EXPIRED.img
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    ${key_menu}=    Enter Key Management And Return Construction
    Enroll DB Signature    ${key_menu}    EXPIRED    cert.der
    Save Changes And Reset    3    5

    Boot Efi File Should Fail    hello.efi    EXPIRED
    Reset System
    Boot Efi File Should Fail    signed-hello.efi    EXPIRED

SBO012.001 Boot OS Signed And Enrolled From Inside System (Ubuntu 22.04)
    [Documentation]    This test verifies that OS boots after enrolling keys
    ...    and signing system from inside
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO012.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO012.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO012.001 not supported
    Skip If    not ${SECURE_BOOT_CAN_REMOVE_EXTERNAL_CERT}    SBO012.001 not supported

    Power On
    # 1. Make sure we are in Setup Mode
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${key_menu}=    Enter Key Management And Return Construction    ${sb_menu}
    Erase All Secure Boot Keys    ${key_menu}
    Exit From Current Menu
    Save Changes And Reset    2

    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User

    # 2. Remove old keys then generate and enroll new keys
    Remove Old Secure Boot Keys In OS
    ${sb_status}=    Generate Secure Boot Keys In OS
    Should Be True    ${sb_status}
    ${sb_status}=    Enroll Secure Boot Keys In OS    True
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

SBO013.001 Check automatic certificate provisioning
    [Documentation]    This test verifies that the automatic certificate
    ...    provisioning will install custom keys which will make Ubuntu
    ...    unbootable. Before launching test, make sure that DTS with automatic
    ...    certificate provisioning is attached and can be booted on DUT.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO013.001 not supported
    Skip If    not ${DTS_UEFI_SB_SUPPORT}    SBO013.001 not supported
    Skip If    not ${SECURE_BOOT_CAN_REMOVE_EXTERNAL_CERT}    SBO013.001 not supported
    Power On

    # 1. Enroll certificate using automatic provisioning tool
    Autoenroll Secure Boot Certificates

    # 2. Verify by booting signed DTS:
    Boot Dasharo Tools Suite    USB
    Power On

    # 3. Verify by booting unsigned Ubuntu:
    Boot System Or From Connected Disk    ubuntu
    Make Sure There Is Secure Boot Error
    Power On

    # 4. Clean up
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${key_menu}=    Enter Key Management And Return Construction    ${sb_menu}
    Reset To Default Secure Boot Keys    ${key_menu}

SBO013.002 Check automatic certificate provisioning KEK certificate
    [Documentation]    This test verifies that the automatic certificate
    ...    provisioning installs the expected KEK certificate. Before launching
    ...    test, make sure that DTS with automatic certificate provisioning is
    ...    attached and can be booted on DUT.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO013.002 not supported
    Skip If    not ${DTS_UEFI_SB_SUPPORT}    SBO013.002 not supported
    Skip If    not ${SECURE_BOOT_CAN_REMOVE_EXTERNAL_CERT}    SBO013.002 not supported
    Power On

    # 1. Enroll certificate using automatic provisioning tool
    Autoenroll Secure Boot Certificates

    # 2. Boot DTS
    Boot Dasharo Tools Suite    USB
    Enter Shell In DTS

    # 3. Compare the certificates
    Compare KEK Certificate Using Mokutil In DTS
    ...    https://cloud.3mdeb.com/index.php/s/FGdaGq2QqnGWQew/download/KEK.crt

    # 4. Clean up
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${key_menu}=    Enter Key Management And Return Construction    ${sb_menu}
    Reset To Default Secure Boot Keys    ${key_menu}

SBO014.001 Enroll certificates using sbctl
    [Documentation]    This test erases Secure Boot keys from the BIOS menu and
    ...    verifies if new keys can be enrolled from operating system using
    ...    sbctl.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO014.001 not supported
    Skip If    not ${SECURE_BOOT_CAN_REMOVE_EXTERNAL_CERT}    SBO014.001 not supported
    Power On

    # 1. Erase Secure Boot Keys
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${key_menu}=    Enter Key Management And Return Construction    ${sb_menu}
    Erase All Secure Boot Keys    ${key_menu}
    Save Changes And Reset    3    5

    # 2. Boot to Ubuntu
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User

    # 3. Remove old keys then generate and enroll new keys
    Remove Old Secure Boot Keys In OS
    ${out}=    Generate Secure Boot Keys In Os
    Should Be True    ${out}
    ${out}=    Enroll Secure Boot Keys In Os    True
    Should Be True    ${out}

    # 4. Verify that it is impossible to boot Ubuntu with the keys
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    Save Changes And Reset    2
    Boot System Or From Connected Disk    ubuntu
    Make Sure There Is Secure Boot Error

    # 5. Clean up
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${key_menu}=    Enter Key Management And Return Construction    ${sb_menu}
    Reset To Default Secure Boot Keys    ${key_menu}
    Save Changes And Reset    3    5
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    rm -rf /usr/share/secureboot
    Log To Console    ${out}\n

SBO015.001 Attempt to enroll the key in the incorrect format (OS)
    [Documentation]    This test verifies that it is impossible to load
    ...    a certificate in the wrong file format from the operating system
    ...    while using sbctl.
    Skip If    not ${SECURE_BOOT_SUPPORT}    SBO015.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO015.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO015.001 not supported
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${key_menu}=    Enter Key Management And Return Construction    ${sb_menu}
    Erase All Secure Boot Keys    ${key_menu}
    Save Changes And Reset    3    5
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    # Remove old keys then generate new to prepare keys directory layout
    Remove Old Secure Boot Keys In OS
    ${out}=    Generate Secure Boot Keys In Os
    Should Be True    ${out}
    Generate Wrong Format Keys And Move Them    db    /usr/share/secureboot/keys/db/
    Generate Wrong Format Keys And Move Them    PK    /usr/share/secureboot/keys/PK/
    Generate Wrong Format Keys And Move Them    KEK    /usr/share/secureboot/keys/KEK/
    Enroll Secure Boot Keys In OS    False
    Should Be True    ${out}
