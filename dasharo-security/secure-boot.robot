*** Settings ***
Metadata            ORDER_SENSITIVE

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
SBO001.101 Check Secure Boot default state (EDK2 UEFI)
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

SBO003.101 Attempt to boot file with the correct key from Shell (EDK2 UEFI)
    [Documentation]    This test verifies that Secure Boot allows booting a
    ...    signed file with a correct key.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SBO003.101 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO003.101 not supported
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

SBO004.101 Attempt to boot file without the key from Shell (EDK2 UEFI)
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

SBO005.101 Attempt to boot file with the wrong-signed key from Shell (EDK2 UEFI)
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

SBO006.101 Reset Secure Boot Keys option availability (EDK2 UEFI)
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

SBO007.101 Attempt to boot the file after restoring keys to default (EDK2 UEFI)
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

SBO008.101 Attempt to enroll the key in the incorrect format (EDK2 UEFI)
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

SBO009.101 Attempt to boot file signed for intermediate certificate (EDK2 UEFI)
    [Documentation]    Check whether a file signed for an intermediate certificate can boot with Secure Boot enabled.
    [Tags]    semiauto
    Execute Manual Step    [1/18] Run sb-img-wrapper.sh script to generate keys and sign efi file.
    Execute Manual Step    [2/18] Flash generated INTERMEDIATE.img into USB storage.
    Execute Manual Step    [3/18] Plug the USB storage into DUT.
    Execute Manual Step    [4/18] Power on the DUT.
    Execute Manual Step    [5/18] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [6/18] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [7/18] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [8/18] Set the Current Secure Boot State field to Enabled.
    Execute Manual Step    [9/18] Set the Secure Boot Mode field to Custom Mode.
    Execute Manual Step
    ...    [10/18] Select options in the given order: Custom Secure Boot Options -> DB Options -> Enroll Signature -> Enroll Signature Using File.
    Execute Manual Step    [11/18] Select the certificate from the USB storage.
    Execute Manual Step    [12/18] Select the Commit Changes and Exit option.
    Execute Manual Step    [13/18] Press ESC until the setup menu.
    Execute Manual Step    [14/18] Select the Reset option.
    Execute Manual Step    [15/18] While the DUT is booting, hold the BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [16/18] Select the UEFI Shell option using the arrow keys and press Enter.
    Execute Manual Step    [17/18] In the shell open the USB storage by executing: FS0:
    Execute Manual Step    [18/18] Boot the previously prepared file by typing: signed-hello.efi
    VAR    ${result_msg}=
    ...    [Expected result] File boots correctly (no information: Command Error Status: Access Denied on the output)
    ...    and the output of the command shows file content. Example output: "Hello, world!"
    ...    separator=${SPACE}
    Execute Manual Step    ${result_msg}

SBO010.101 Check support for rsa2k signed certificates (EDK2 UEFI)
    [Documentation]    Check whether Secure Boot supports RSA 2048-bit signed certificates.
    [Tags]    semiauto
    Execute Manual Step    [1/18] Run sb-img-wrapper.sh script to generate keys and sign efi file.
    Execute Manual Step    [2/18] Flash generated RSA2048.img into USB storage.
    Execute Manual Step    [3/18] Plug the USB storage into DUT.
    Execute Manual Step    [4/18] Power on the DUT.
    Execute Manual Step    [5/18] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [6/18] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [7/18] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [8/18] Set the Current Secure Boot State field to Enabled.
    Execute Manual Step    [9/18] Set the Secure Boot Mode field to Custom Mode.
    Execute Manual Step
    ...    [10/18] Select options: Custom Secure Boot Options -> DB Options -> Enroll Signature -> Enroll Signature Using File.
    Execute Manual Step    [11/18] Select the certificate from the USB storage.
    Execute Manual Step    [12/18] Select the Commit Changes and Exit option.
    Execute Manual Step    [13/18] Press ESC until the setup menu.
    Execute Manual Step    [14/18] Select the Reset option.
    Execute Manual Step    [15/18] While the DUT is booting, hold the BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [16/18] Select the UEFI Shell option.
    Execute Manual Step    [17/18] In the shell open the USB storage: FS0:
    Execute Manual Step    [18/18] Boot the file: signed-hello.efi
    Execute Manual Step
    ...    [Expected result] File boots correctly and the output shows file content. Example output: "Hello, world!"

SBO011.101 Check support for rsa3k signed certificates (EDK2 UEFI)
    [Documentation]    Check whether Secure Boot supports RSA 3072-bit signed certificates.
    [Tags]    semiauto
    Execute Manual Step    [1/18] Run sb-img-wrapper.sh script to generate keys and sign efi file.
    Execute Manual Step    [2/18] Flash generated RSA3072.img into USB storage.
    Execute Manual Step    [3/18] Plug the USB storage into DUT.
    Execute Manual Step    [4/18] Power on the DUT.
    Execute Manual Step    [5/18] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [6/18] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [7/18] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [8/18] Set the Current Secure Boot State field to Enabled.
    Execute Manual Step    [9/18] Set the Secure Boot Mode field to Custom Mode.
    Execute Manual Step
    ...    [10/18] Select options: Custom Secure Boot Options -> DB Options -> Enroll Signature -> Enroll Signature Using File.
    Execute Manual Step    [11/18] Select the certificate from the USB storage.
    Execute Manual Step    [12/18] Select the Commit Changes and Exit option.
    Execute Manual Step    [13/18] Press ESC until the setup menu.
    Execute Manual Step    [14/18] Select the Reset option.
    Execute Manual Step    [15/18] While the DUT is booting, hold the BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [16/18] Select the UEFI Shell option.
    Execute Manual Step    [17/18] In the shell open the USB storage: FS0:
    Execute Manual Step    [18/18] Boot the file: signed-hello.efi
    Execute Manual Step
    ...    [Expected result] File boots correctly and the output shows file content. Example output: "Hello, world!"

SBO012.101 Check support for rsa4k signed certificates (EDK2 UEFI)
    [Documentation]    Check whether Secure Boot supports RSA 4096-bit signed certificates.
    [Tags]    semiauto
    Execute Manual Step    [1/18] Run sb-img-wrapper.sh script to generate keys and sign efi file.
    Execute Manual Step    [2/18] Flash generated RSA4096.img into USB storage.
    Execute Manual Step    [3/18] Plug the USB storage into DUT.
    Execute Manual Step    [4/18] Power on the DUT.
    Execute Manual Step    [5/18] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [6/18] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [7/18] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [8/18] Set the Current Secure Boot State field to Enabled.
    Execute Manual Step    [9/18] Set the Secure Boot Mode field to Custom Mode.
    Execute Manual Step
    ...    [10/18] Select options: Custom Secure Boot Options -> DB Options -> Enroll Signature -> Enroll Signature Using File.
    Execute Manual Step    [11/18] Select the certificate from the USB storage.
    Execute Manual Step    [12/18] Select the Commit Changes and Exit option.
    Execute Manual Step    [13/18] Press ESC until the setup menu.
    Execute Manual Step    [14/18] Select the Reset option.
    Execute Manual Step    [15/18] While the DUT is booting, hold the BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [16/18] Select the UEFI Shell option.
    Execute Manual Step    [17/18] In the shell open the USB storage: FS0:
    Execute Manual Step    [18/18] Boot the file: signed-hello.efi
    Execute Manual Step
    ...    [Expected result] File boots correctly and the output shows file content. Example output: "Hello, world!"

SBO013.101 Check support for ecdsa256 signed certificates (EDK2 UEFI)
    [Documentation]    Check whether Secure Boot supports ECDSA P-256 signed certificates.
    [Tags]    semiauto
    Execute Manual Step    [1/18] Run sb-img-wrapper.sh script to generate keys and sign efi file.
    Execute Manual Step    [2/18] Flash generated ECDSA256.img into USB storage.
    Execute Manual Step    [3/18] Plug the USB storage into DUT.
    Execute Manual Step    [4/18] Power on the DUT.
    Execute Manual Step    [5/18] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [6/18] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [7/18] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [8/18] Set the Current Secure Boot State field to Enabled.
    Execute Manual Step    [9/18] Set the Secure Boot Mode field to Custom Mode.
    Execute Manual Step
    ...    [10/18] Select options: Custom Secure Boot Options -> DB Options -> Enroll Signature -> Enroll Signature Using File.
    Execute Manual Step    [11/18] Select the certificate from the USB storage.
    Execute Manual Step    [12/18] Select the Commit Changes and Exit option.
    Execute Manual Step    [13/18] Press ESC until the setup menu.
    Execute Manual Step    [14/18] Select the Reset option.
    Execute Manual Step    [15/18] While the DUT is booting, hold the BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [16/18] Select the UEFI Shell option.
    Execute Manual Step    [17/18] In the shell open the USB storage: FS0:
    Execute Manual Step    [18/18] Boot the file: signed-hello.efi
    Execute Manual Step
    ...    [Expected result] File boots correctly and the output shows file content. Example output: "Hello, world!"

SBO014.101 Check support for ecdsa384 signed certificates (EDK2 UEFI)
    [Documentation]    Check whether Secure Boot supports ECDSA P-384 signed certificates.
    [Tags]    semiauto
    Execute Manual Step    [1/18] Run sb-img-wrapper.sh script to generate keys and sign efi file.
    Execute Manual Step    [2/18] Flash generated ECDSA384.img into USB storage.
    Execute Manual Step    [3/18] Plug the USB storage into DUT.
    Execute Manual Step    [4/18] Power on the DUT.
    Execute Manual Step    [5/18] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [6/18] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [7/18] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [8/18] Set the Current Secure Boot State field to Enabled.
    Execute Manual Step    [9/18] Set the Secure Boot Mode field to Custom Mode.
    Execute Manual Step
    ...    [10/18] Select options: Custom Secure Boot Options -> DB Options -> Enroll Signature -> Enroll Signature Using File.
    Execute Manual Step    [11/18] Select the certificate from the USB storage.
    Execute Manual Step    [12/18] Select the Commit Changes and Exit option.
    Execute Manual Step    [13/18] Press ESC until the setup menu.
    Execute Manual Step    [14/18] Select the Reset option.
    Execute Manual Step    [15/18] While the DUT is booting, hold the BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [16/18] Select the UEFI Shell option.
    Execute Manual Step    [17/18] In the shell open the USB storage: FS0:
    Execute Manual Step    [18/18] Boot the file: signed-hello.efi
    Execute Manual Step
    ...    [Expected result] File boots correctly and the output shows file content. Example output: "Hello, world!"

SBO015.101 Check support for ecdsa521 signed certificates (EDK2 UEFI)
    [Documentation]    Check whether Secure Boot supports ECDSA P-521 signed certificates.
    [Tags]    semiauto
    Execute Manual Step    [1/18] Run sb-img-wrapper.sh script to generate keys and sign efi file.
    Execute Manual Step    [2/18] Flash generated ECDSA521.img into USB storage.
    Execute Manual Step    [3/18] Plug the USB storage into DUT.
    Execute Manual Step    [4/18] Power on the DUT.
    Execute Manual Step    [5/18] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [6/18] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [7/18] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [8/18] Set the Current Secure Boot State field to Enabled.
    Execute Manual Step    [9/18] Set the Secure Boot Mode field to Custom Mode.
    Execute Manual Step
    ...    [10/18] Select options: Custom Secure Boot Options -> DB Options -> Enroll Signature -> Enroll Signature Using File.
    Execute Manual Step    [11/18] Select the certificate from the USB storage.
    Execute Manual Step    [12/18] Select the Commit Changes and Exit option.
    Execute Manual Step    [13/18] Press ESC until the setup menu.
    Execute Manual Step    [14/18] Select the Reset option.
    Execute Manual Step    [15/18] While the DUT is booting, hold the BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [16/18] Select the UEFI Shell option.
    Execute Manual Step    [17/18] In the shell open the USB storage: FS0:
    Execute Manual Step    [18/18] Boot the file: signed-hello.efi
    Execute Manual Step
    ...    [Expected result] File boots correctly and the output shows file content. Example output: "Hello, world!"

SBO016.101 Attempt to enroll expired certificate and boot signed image (EDK2 UEFI)
    [Documentation]    Check that a file signed with an expired certificate cannot boot with Secure Boot enabled.
    [Tags]    semiauto
    Execute Manual Step    [1/18] Run sb-img-wrapper.sh script to generate keys and sign efi file.
    Execute Manual Step    [2/18] Flash generated EXPIRED.img into USB storage.
    Execute Manual Step    [3/18] Plug the USB storage into DUT.
    Execute Manual Step    [4/18] Power on the DUT.
    Execute Manual Step    [5/18] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [6/18] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [7/18] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [8/18] Set the Current Secure Boot State field to Enabled.
    Execute Manual Step    [9/18] Set the Secure Boot Mode field to Custom Mode.
    Execute Manual Step
    ...    [10/18] Select options: Custom Secure Boot Options -> DB Options -> Enroll Signature -> Enroll Signature Using File.
    Execute Manual Step    [11/18] Select the certificate from the USB storage.
    Execute Manual Step    [12/18] Select the Commit Changes and Exit option.
    Execute Manual Step    [13/18] Press ESC until the setup menu.
    Execute Manual Step    [14/18] Select the Reset option.
    Execute Manual Step    [15/18] While the DUT is booting, hold the BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [16/18] Select the UEFI Shell option.
    Execute Manual Step    [17/18] In the shell open the USB storage: FS0:
    Execute Manual Step    [18/18] Boot the file: signed-hello.efi
    Execute Manual Step    [Expected result] File does not boot correctly: Command Error Status: Access Denied.

SBO018.101 Check automatic certificate provisioning (EDK2 UEFI)
    [Documentation]    Check whether Dasharo Tools Suite automatically provisions Secure Boot certificates.
    [Tags]    semiauto
    Execute Manual Step    [1/22] Power on the DUT.
    Execute Manual Step    [2/22] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [3/22] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [4/22] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [5/22] Set the Secure Boot Mode field to Custom Mode.
    Execute Manual Step
    ...    [6/22] Erase Secure Boot keys: Custom Secure Boot Options -> DB Options -> Enroll Signature -> Erase all Secure Boot Keys.
    Execute Manual Step    [7/22] Press F10 to save changes.
    Execute Manual Step    [8/22] Press ESC until the setup menu.
    Execute Manual Step    [9/22] Select the Reset option.
    Execute Manual Step    [10/22] While the DUT is booting, hold the BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [11/22] Boot Dasharo Tools Suite from USB Storage.
    Execute Manual Step    [12/22] Wait until Dasharo Tools Suite enrolls keys and resets the DUT.
    Execute Manual Step    [13/22] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [14/22] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [15/22] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [16/22] Set the Current Secure Boot State field to Enabled.
    Execute Manual Step    [17/22] Press F10 to save changes.
    Execute Manual Step    [18/22] Press ESC until the setup menu.
    Execute Manual Step    [19/22] Select the Reset option.
    Execute Manual Step    [20/22] Verify by booting signed Dasharo Tools Suite from USB Storage.
    Execute Manual Step    [21/22] Reboot the DUT.
    Execute Manual Step    [22/22] Verify by booting unsigned Ubuntu.
    Execute Manual Step
    ...    [Expected result] Dasharo Tools Suite system signed with custom keys should boot while Ubuntu should not boot as it is signed with Microsoft keys.

SBO019.101 Check automatic certificate provisioning KEK certificate (EDK2 UEFI)
    [Documentation]    Check whether the KEK certificate provisioned by Dasharo Tools Suite matches the expected certificate.
    [Tags]    semiauto
    VAR    ${step23_msg}=
    ...    [23/23] Compare the current KEK certificate with the certificate that should be enrolled:
    ...    wget https://cloud.3mdeb.com/index.php/s/FGdaGq2QqnGWQew/download/KEK.crt -O /tmp/first_certificate.crt
    ...    openssl x509 -in /tmp/first_certificate.crt -noout -text > /tmp/first_certificate.crt
    ...    mokutil --kek > /tmp/second_certificate.crt
    ...    diff /tpm/first_certificate.crt /tmp/second_certificate.crt
    ...    separator=\n
    Execute Manual Step    [1/23] Power on the DUT.
    Execute Manual Step    [2/23] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [3/23] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [4/23] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [5/23] Set the Secure Boot Mode field to Custom Mode.
    Execute Manual Step
    ...    [6/23] Erase Secure Boot keys: Custom Secure Boot Options -> DB Options -> Enroll Signature -> Erase all Secure Boot Keys.
    Execute Manual Step    [7/23] Press F10 to save changes.
    Execute Manual Step    [8/23] Press ESC until the setup menu.
    Execute Manual Step    [9/23] Select the Reset option.
    Execute Manual Step    [10/23] While the DUT is booting, hold the BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [11/23] Boot Dasharo Tools Suite from USB Storage.
    Execute Manual Step    [12/23] Wait until Dasharo Tools Suite enrolls keys and resets the DUT.
    Execute Manual Step    [13/23] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [14/23] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [15/23] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [16/23] Set the Current Secure Boot State field to Enabled.
    Execute Manual Step    [17/23] Press F10 to save changes.
    Execute Manual Step    [18/23] Press ESC until the setup menu.
    Execute Manual Step    [19/23] Select the Reset option.
    Execute Manual Step    [20/23] While the DUT is booting, hold the BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [21/23] Boot Dasharo Tools Suite from USB Storage.
    Execute Manual Step    [22/23] Enter shell in Dasharo Tools Suite by pressing 9.
    Execute Manual Step    ${step23_msg}
    Execute Manual Step
    ...    [Expected result] The data provided by both certificates should be equal, the form of the compared data might differ.

SBO020.101 Enroll certificates using sbctl (EDK2 UEFI)
    [Documentation]    Check whether certificates can be enrolled using sbctl and Secure Boot enabled thereafter.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO020.101 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SBO020.101 not supported
    Execute Manual Step    [1/22] Power on the DUT.
    Execute Manual Step    [2/22] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [3/22] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [4/22] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [5/22] Set the Secure Boot Mode field to Custom Mode.
    Execute Manual Step
    ...    [6/22] Erase Secure Boot keys: Custom Secure Boot Options -> DB Options -> Enroll Signature -> Erase all Secure Boot Keys.
    Execute Manual Step    [7/22] Press F10 to save changes.
    Execute Manual Step    [8/22] Press ESC until the setup menu.
    Execute Manual Step    [9/22] Select the Reset option.
    Execute Manual Step    [10/22] The DUT will now attempt to boot OPERATING_SYSTEM.
    Execute Manual Step    [11/22] Login to OPERATING_SYSTEM.
    Execute Manual Step    [12/22] Remove old Secure Boot keys: rm -rf /usr/share/secureboot
    Execute Manual Step    [13/22] Generate new Secure Boot keys: sbctl create-keys
    Execute Manual Step
    ...    [14/22] Enroll generated Secure Boot keys: sbctl enroll-keys --yes-this-might-brick-my-machine
    Execute Manual Step    [15/22] Restart the DUT.
    Execute Manual Step    [16/22] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [17/22] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [18/22] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [19/22] Set the Current Secure Boot State field to Enabled.
    Execute Manual Step    [20/22] Press F10 to save changes.
    Execute Manual Step    [21/22] Press ESC until the setup menu.
    Execute Manual Step    [22/22] Select the Reset option.
    Execute Manual Step
    ...    [Expected result] You should not be able to boot the system after enrolling the keys and enabling Secure Boot.

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

SBO017.201 Boot OS Signed And Enrolled From Inside System (Ubuntu)
    [Documentation]    Check whether an OS signed and enrolled from inside the system can boot with Secure Boot enabled.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO017.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SBO017.201 not supported
    Execute Manual Step    [1/26] Power on the DUT.
    Execute Manual Step    [2/26] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [3/26] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [4/26] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [5/26] Set the Secure Boot Mode field to Custom Mode.
    Execute Manual Step
    ...    [6/26] Erase Secure Boot keys: Custom Secure Boot Options -> DB Options -> Enroll Signature -> Erase all Secure Boot Keys.
    Execute Manual Step    [7/26] Press F10 to save changes.
    Execute Manual Step    [8/26] Press ESC until the setup menu.
    Execute Manual Step    [9/26] Select the Reset option.
    Execute Manual Step    [10/26] The DUT will now attempt to boot OPERATING_SYSTEM.
    Execute Manual Step    [11/26] Login to OPERATING_SYSTEM.
    Execute Manual Step    [12/26] Remove Old Secure Boot keys: rm -rf /usr/share/secureboot
    Execute Manual Step    [13/26] Generate new Secure Boot keys: sbctl create-keys
    Execute Manual Step
    ...    [14/26] Enroll generated Secure Boot keys: sbctl enroll-keys --yes-this-might-brick-my-machine
    Execute Manual Step
    ...    [15/26] Sign all components: sbctl verify | awk -F ' ' '{print $2}' | tail -n+2 | xargs -I "#" sbctl sign "#"
    Execute Manual Step    [16/26] Reboot OPERATING_SYSTEM.
    Execute Manual Step    [17/26] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [18/26] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [19/26] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [20/26] Set the Current Secure Boot State field to Enabled.
    Execute Manual Step    [21/26] Press F10 to save changes.
    Execute Manual Step    [22/26] Press ESC until the setup menu.
    Execute Manual Step    [23/26] Select the Reset option.
    Execute Manual Step    [24/26] The DUT will now attempt to boot OPERATING_SYSTEM.
    Execute Manual Step    [25/26] Login to OPERATING_SYSTEM.
    Execute Manual Step    [26/26] Check if Secure Boot is enabled: dmesg | grep secureboot
    Execute Manual Step    [Expected result] In dmesg output should be a line informing that Secure Boot is enabled.

SBO021.201 Attempt to enroll the key in the incorrect format (Ubuntu)
    [Documentation]    Check that sbctl fails when attempting to enroll keys in an incorrect format.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBO021.201 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SB021.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SBO021.201 not supported
    VAR    ${step14_msg}=
    ...    [14/15] Generate wrong format keys and move them to the appropriate locations:
    ...    openssl ecparam -genkey -name secp384r1 -out db.key && openssl req -new -x509 -key db.key -out db.pem -days 365 -subj "/CN=3mdeb_test"
    ...    openssl ecparam -genkey -name secp384r1 -out PK.key && openssl req -new -x509 -key PK.key -out PK.pem -days 365 -subj "/CN=3mdeb_test"
    ...    openssl ecparam -genkey -name secp384r1 -out KEK.key && openssl req -new -x509 -key KEK.key -out KEK.pem -days 365 -subj "/CN=3mdeb_test"
    ...    mv db.key /usr/share/secureboot/keys/db/
    ...    mv PK.key /usr/share/secureboot/keys/PK/
    ...    mv KEK.key /usr/share/secureboot/keys/KEK/
    ...    separator=\n
    Execute Manual Step    [1/15] Power on the DUT.
    Execute Manual Step    [2/15] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI setup menu.
    Execute Manual Step    [3/15] Enter the Device Manager menu using the arrow keys and Enter.
    Execute Manual Step    [4/15] Enter the Secure Boot Configuration submenu.
    Execute Manual Step    [5/15] Set the Secure Boot Mode field to Custom Mode.
    Execute Manual Step
    ...    [6/15] Erase Secure Boot keys: Custom Secure Boot Options -> DB Options -> Enroll Signature -> Erase all Secure Boot Keys.
    Execute Manual Step    [7/15] Press F10 to save changes.
    Execute Manual Step    [8/15] Press ESC until the setup menu.
    Execute Manual Step    [9/15] Select the Reset option.
    Execute Manual Step    [10/15] The DUT will now attempt to boot OPERATING_SYSTEM.
    Execute Manual Step    [11/15] Login to OPERATING_SYSTEM.
    Execute Manual Step    [12/15] Remove Old Secure Boot keys: rm -rf /usr/share/secureboot
    Execute Manual Step    [13/15] Generate new Secure Boot keys: sbctl create-keys
    Execute Manual Step    ${step14_msg}
    Execute Manual Step
    ...    [15/15] Attempt to enroll generated Secure Boot keys: sbctl enroll-keys --yes-this-might-brick-my-machine
    Execute Manual Step    [Expected result] Utility sbctl should fail while enrolling keys.

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
    Boot And Login To Windows
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
    Boot And Login To Windows
    ${sb_status}=    Check Secure Boot In Windows
    Should Not Be True    ${sb_status}


*** Keywords ***
Set Secure Boot State To Disabled
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Disable Secure Boot    ${sb_menu}
    # Changes to Secure Boot menu take action immediately, so we can just reset
    Tianocore Reset System
