*** Settings ***
Library             Collections
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Library             ../keys-and-keywords/totp.py
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../keys-and-keywords/heads-keywords.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${HEADS_PAYLOAD_SUPPORT}    heads payload not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Variables ***
${TOTP_URI}=    unset

# Notes on menu option keys:
# - check for them explicitly, so we won't go into wrong menu if they change
# - read until end of ASCII window before choosing option, but check for the
#    option explicitly for better error messages
# - 'Write Bare Into Terminal' letter and ${ENTER} as separate commands, a small
#    delay is required
# - cases don't matter, both select the same option
# - if multiple options use the same (case-insensitive) letter, they are
#    selected top to bottom and don't loop back to the top


*** Test Cases ***
HDS001.001 Install Heads
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    Heads bootloader
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    HDS001.001 not supported
    Power On
    # Factory reset. Additional window if /boot already has Heads stuff in it.
    ${output}=    Read From Terminal Until    ┘
    ${output}=    Get Lines Containing String    ${output}    F${SPACE}${SPACE}OEM Factory Reset / Re-Ownership
    IF    "${output}"!="${EMPTY}"
        Write Bare Into Terminal    F
        Write Bare Into Terminal    ${ENTER}
        Read From Terminal Until    ┘
    END
    # Select 'Continue' and choose default answer for 6 questions.
    Write Into Terminal    ${ARROW_RIGHT}${ENTER}${ENTER}${ENTER}${ENTER}${ENTER}${ENTER}
    Read From Terminal Until    Resetting GPG Key...
    # Time-consuming operations on keys, increase timeout.
    Set DUT Response Timeout    900s
    Read From Terminal Until    Provisioned secrets
    Set DUT Response Timeout    300s
    Write Bare Into Terminal    ${ENTER}
    ${output}=    Read From Terminal Until    Press Enter to reboot.
    Should Contain    ${output}    OEM Factory Reset / Re-Ownership has completed successfully
    # Reboot.
    Write Bare Into Terminal    ${ENTER}
    # Seal TOTP.
    Read From Terminal Until    g${SPACE}${SPACE}Generate new HOTP/TOTP secret
    Read From Terminal Until    ┘
    Write Bare Into Terminal    g
    Write Bare Into Terminal    ${ENTER}
    Read From Terminal Until    Do you want to proceed?
    Read From Terminal Until    ┘
    Write Bare Into Terminal    ${ENTER}
    ${output}=    Read From Terminal Until    Once you have scanned the QR code, hit Enter to continue
    Log    ${output}    console=yes
    ${totp_uri_local}=    Get Lines Containing String    ${output}    otpauth://totp
    VAR    ${TOTP_URI}=    ${totp_uri_local}    scope=SUITE
    Write Bare Into Terminal    ${ENTER}
    ${output}=    Read From Terminal Until    ┘
    ${totp_dut}=    Get Regexp Matches    ${output}    TOTP: (......)    1
    ${totp_real}=    Get Totp From Uri    ${TOTP_URI}
    Should Be Equal As Strings    ${totp_dut[0]}    ${totp_real}
    # TODO: store disk encryption key in TPM, requires OS installed on LVM:
    # Options, boot options, show OS boot menu. Select boot option. Make default.
    # Seal disk unlock key in TPM. Resign changes inside of boot. Boot default.
    # Enjoy.

HDS002.001 Boot into Heads
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    Heads bootloader
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    HDS001.001 not supported
    Power On
    ${output}=    Detect Heads Main Menu
    ${totp_dut}=    Get Regexp Matches    ${output}    TOTP: (......)    1
    ${totp_real}=    Get Totp From Uri    ${TOTP_URI}
    Should Be Equal As Strings    ${totp_dut[0]}    ${totp_real}

HDS003.001 Boot from USB option is available and works correctly
    [Documentation]    Check whether the Boot from USB option is available in Heads and works correctly.
    [Tags]    semiauto
    Execute Manual Step    [1/4] Power on the DUT and boot into Heads
    Execute Manual Step    [2/4] Navigate to the Boot from USB option in the Heads menu
    Execute Manual Step    [3/4] Insert a bootable USB drive and select it
    Execute Manual Step    [4/4] Confirm the DUT boots from the USB drive successfully

HDS004.001 Continue to the main menu option is available and works correctly
    [Documentation]    Check whether the Continue to main menu option is available and works correctly in Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/3] Power on the DUT and boot into Heads
    Execute Manual Step    [2/3] Navigate to any submenu and select the option to return to the main menu
    Execute Manual Step    [3/3] Confirm the DUT returns to the Heads main menu correctly

HDS005.001 Exit to recovery shell option is available and works correctly
    [Documentation]    Check whether the Exit to recovery shell option is available and works correctly in Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/3] Power on the DUT and boot into Heads
    Execute Manual Step    [2/3] Select the Exit to recovery shell option in the Heads menu
    Execute Manual Step    [3/3] Confirm the DUT enters the recovery shell and commands are executable

HDS006.001 Default boot option is available and works correctly
    [Documentation]    Check whether the Default boot option is available and works correctly in Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/3] Power on the DUT and boot into Heads
    Execute Manual Step    [2/3] Select the Default boot option in the Heads menu
    Execute Manual Step    [3/3] Confirm the DUT boots into the default OS correctly

HDS007.001 Options submenu is available and works correctly
    [Documentation]    Check whether the Options submenu is available and works correctly in Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/3] Power on the DUT and boot into Heads
    Execute Manual Step    [2/3] Navigate to the Options submenu in the Heads main menu
    Execute Manual Step    [3/3] Confirm the Options submenu is accessible and displays the expected options

HDS008.001 System info option is available and works correctly
    [Documentation]    Check whether the System info option is available and works correctly in Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/3] Power on the DUT and boot into Heads
    Execute Manual Step    [2/3] Navigate to the System info option in the Heads menu
    Execute Manual Step    [3/3] Confirm the system information is displayed correctly

HDS009.001 Power off option is available and works correctly
    [Documentation]    Check whether the Power off option is available and works correctly in Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/3] Power on the DUT and boot into Heads
    Execute Manual Step    [2/3] Select the Power off option in the Heads menu
    Execute Manual Step    [3/3] Confirm the DUT powers off cleanly

HDS010.001 OEM Factory Reset option is available and works correctly
    [Documentation]    Check whether the OEM Factory Reset option is available and works correctly in Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/3] Power on the DUT and boot into Heads
    Execute Manual Step    [2/3] Navigate to the OEM Factory Reset option in the Heads menu
    Execute Manual Step    [3/3] Confirm the factory reset option is accessible and can be initiated

HDS018.001 Reset TPM option is available and works correctly
    [Documentation]    Check whether the Reset TPM option is available and works correctly in Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/3] Power on the DUT and boot into Heads
    Execute Manual Step    [2/3] Navigate to the Reset TPM option in the Heads Options menu
    Execute Manual Step    [3/3] Confirm the TPM reset option is accessible and completes successfully

HDS019.001 Generate new TOTP/HOTP secret
    [Documentation]    Check whether a new TOTP/HOTP secret can be generated in Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/3] Power on the DUT and boot into Heads
    Execute Manual Step    [2/3] Navigate to the option to generate a new TOTP/HOTP secret in Heads Options
    Execute Manual Step    [3/3] Confirm a new TOTP/HOTP secret is generated and can be enrolled

HDS020.001 Boot DTS from USB
    [Documentation]    Check whether Dasharo Tools Suite (DTS) can be booted from USB via Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/4] Prepare a USB drive with DTS image
    Execute Manual Step    [2/4] Power on the DUT and boot into Heads
    Execute Manual Step    [3/4] Select the Boot from USB option and choose the DTS USB drive
    Execute Manual Step    [4/4] Confirm DTS boots successfully from the USB drive

HDS021.001 Update firmware via DTS (DES)
    [Documentation]    Check whether firmware can be updated via Dasharo Tools Suite using DES credentials.
    [Tags]    semiauto
    Execute Manual Step    [1/5] Boot DTS from USB via Heads
    Execute Manual Step    [2/5] Select the firmware update option in DTS
    Execute Manual Step    [3/5] Enter DES credentials when prompted
    Execute Manual Step    [4/5] Select the firmware image to flash and confirm
    Execute Manual Step    [5/5] Confirm the firmware update completes successfully and the DUT reboots

HDS022.001 Install Heads via DTS (DES)
    [Documentation]    Check whether Heads can be installed via Dasharo Tools Suite using DES credentials.
    [Tags]    semiauto
    Execute Manual Step    [1/5] Boot DTS from USB via Heads
    Execute Manual Step    [2/5] Select the Heads installation option in DTS
    Execute Manual Step    [3/5] Enter DES credentials when prompted
    Execute Manual Step    [4/5] Select the Heads firmware image and confirm installation
    Execute Manual Step    [5/5] Confirm Heads is installed successfully and the DUT boots into Heads

HDS023.203 Existing Qubes installation is bootable after transition from EDK2 (Qubes OS)
    [Documentation]    Check whether an existing Qubes OS installation remains bootable after transitioning from EDK2 to Heads.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    Execute Manual Step    [1/4] Ensure Qubes OS is installed and booting correctly under EDK2
    Execute Manual Step    [2/4] Install Heads firmware on the DUT
    Execute Manual Step    [3/4] Boot into Heads and select the default Qubes OS boot entry
    Execute Manual Step    [4/4] Confirm Qubes OS boots successfully after the transition from EDK2 to Heads

HDS024.001 Revert back to UEFI from Heads
    [Documentation]    Check whether the DUT can be reverted from Heads back to UEFI (EDK2) firmware.
    [Tags]    semiauto
    Execute Manual Step    [1/4] Power on the DUT running Heads firmware
    Execute Manual Step    [2/4] Boot DTS from USB and select the option to flash UEFI firmware
    Execute Manual Step    [3/4] Flash the EDK2/UEFI firmware image
    Execute Manual Step    [4/4] Confirm the DUT boots into UEFI firmware after the revert

HDS025.203 Existing Qubes installation is bootable after transition back to EDK2 (Qubes OS)
    [Documentation]    Check whether an existing Qubes OS installation remains bootable after transitioning back to EDK2.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    Execute Manual Step    [1/4] Revert from Heads to EDK2 firmware
    Execute Manual Step    [2/4] Power on the DUT and select the Qubes OS boot entry
    Execute Manual Step    [3/4] Wait for Qubes OS to boot
    Execute Manual Step    [4/4] Confirm Qubes OS boots successfully after the transition back to EDK2

HDS026.001 USB dongle reset
    [Documentation]    Check whether the USB dongle (security key) reset works correctly in Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/3] Power on the DUT and boot into Heads
    Execute Manual Step    [2/3] Connect a USB security dongle and navigate to the USB dongle reset option
    Execute Manual Step    [3/3] Confirm the USB dongle reset completes successfully

HDS027.001 Build Heads from source
    [Documentation]    Check whether Heads can be built from source code.
    [Tags]    semiauto
    Execute Manual Step    [1/4] Clone the Heads source repository on a build machine
    Execute Manual Step    [2/4] Configure the build for the target platform
    Execute Manual Step    [3/4] Run the build command and wait for completion
    Execute Manual Step    [4/4] Confirm the Heads firmware image is produced without errors

HDS028.001 Rebuild Heads with custom bootsplash
    [Documentation]    Check whether Heads can be rebuilt with a custom bootsplash image.
    [Tags]    semiauto
    Execute Manual Step    [1/4] Prepare a custom bootsplash image in the correct format
    Execute Manual Step    [2/4] Replace the default bootsplash in the Heads source tree with the custom image
    Execute Manual Step    [3/4] Rebuild Heads and flash the resulting firmware to the DUT
    Execute Manual Step    [4/4] Confirm the custom bootsplash is displayed when the DUT boots into Heads

HDS029.001 Reboot in Heads
    [Documentation]    Check whether the DUT can reboot correctly when running Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/3] Power on the DUT and boot into Heads
    Execute Manual Step    [2/3] Select the reboot option from the Heads menu (or trigger a reboot)
    Execute Manual Step    [3/3] Confirm the DUT reboots and returns to the Heads main menu correctly

HDS011.001 Add GPG key to running BIOS and reflash
    [Documentation]    Check whether a GPG key can be added to the running BIOS and reflashed.
    [Tags]    semiauto
    Execute Manual Step    [1/13] Plug the USB storage into DUT.
    Execute Manual Step    [2/13] Power on the DUT.
    Execute Manual Step    [3/13] Wait for the Default boot menu appears.
    Execute Manual Step    [4/13] Select the Continue to the main menu option using the arrow keys and Enter.
    Execute Manual Step    [5/13] Select the Options --> option in the Heads boot menu.
    Execute Manual Step    [6/13] Select the GPG Options --> option in the HEADS Options submenu.
    Execute Manual Step    [7/13] Select the Add GPG key to running BIOS and reflash option in the GPG Management Menu.
    Execute Manual Step
    ...    [8/13] Choose Yes in the displayed GPG public key required window using the arrow keys and Enter.
    Execute Manual Step    [9/13] Choose GPG public key from the USB storage and press Enter.
    Execute Manual Step    [10/13] Select the Options --> option in the Heads boot menu.
    Execute Manual Step    [11/13] Select the GPG Options --> option in the HEADS Options submenu.
    Execute Manual Step    [12/13] Select the List GPG keys in your keyring option in the GPG Management Menu.
    Execute Manual Step    [13/13] Note the results.
    Execute Manual Step    [Expected result] The GPG Keyring window should contain information about the given GPG key.

HDS012.001 Add GPG key to standalone BIOS image and flash
    [Documentation]    Check whether a GPG key can be added to a standalone BIOS image and flashed.
    [Tags]    semiauto
    Execute Manual Step    [1/15] Plug the USB storage into DUT.
    Execute Manual Step    [2/15] Power on the DUT.
    Execute Manual Step    [3/15] Wait for the Default boot menu appears.
    Execute Manual Step    [4/15] Select the Continue to the main menu option using the arrow keys and Enter.
    Execute Manual Step    [5/15] Select the Options --> option in the Heads boot menu.
    Execute Manual Step    [6/15] Select the GPG Options --> option in the HEADS Options submenu.
    Execute Manual Step
    ...    [7/15] Select the Add GPG key to standalone BIOS image and flash option in the GPG Management Menu.
    Execute Manual Step
    ...    [8/15] Choose Yes in the displayed GPG public key required window using the arrow keys and Enter.
    Execute Manual Step    [9/15] Choose GPG public key from the USB storage and press Enter.
    Execute Manual Step    [10/15] Choose BIOS image(*.rom) from the USB storage and press Enter.
    Execute Manual Step    [11/15] Choose Yes in the displayed Flash ROM? window using the arrow keys and Enter.
    Execute Manual Step    [12/15] Select the Options --> option in the Heads boot menu.
    Execute Manual Step    [13/15] Select the GPG Options --> option in the HEADS Options submenu.
    Execute Manual Step    [14/15] Select the List GPG keys in your keyring option in the GPG Management Menu.
    Execute Manual Step    [15/15] Note the results.
    Execute Manual Step    [Expected result] The GPG Keyring window should contain information about the given GPG key.

HDS013.001 Replace GPG key(s) in the current ROM and reflash
    [Documentation]    Check whether GPG key(s) in the current ROM can be replaced and reflashed.
    [Tags]    semiauto
    Execute Manual Step    [1/13] Plug the USB storage into DUT.
    Execute Manual Step    [2/13] Power on the DUT.
    Execute Manual Step    [3/13] Wait for the Default boot menu appears.
    Execute Manual Step    [4/13] Select the Continue to the main menu option using the arrow keys and Enter.
    Execute Manual Step    [5/13] Select the Options --> option in the Heads boot menu.
    Execute Manual Step    [6/13] Select the GPG Options --> option in the HEADS Options submenu.
    Execute Manual Step
    ...    [7/13] Select the Replace GPG key(s) in the current ROM and reflash option in the GPG Management Menu.
    Execute Manual Step
    ...    [8/13] Choose Yes in the displayed GPG public key required window using the arrow keys and Enter.
    Execute Manual Step    [9/13] Choose GPG public key from the USB storage and press Enter.
    Execute Manual Step    [10/13] Select the Options --> option in the Heads boot menu.
    Execute Manual Step    [11/13] Select the GPG Options --> option in the HEADS Options submenu.
    Execute Manual Step    [12/13] Select the List GPG keys in your keyring option in the GPG Management Menu.
    Execute Manual Step    [13/13] Note the results.
    Execute Manual Step    [Expected result] The GPG Keyring window should contain information about the given GPG key.

HDS014.001 List GPG keys in your keyring
    [Documentation]    Check whether GPG keys in the Heads keyring can be listed.
    [Tags]    semiauto
    Execute Manual Step    [1/7] Power on the DUT.
    Execute Manual Step    [2/7] Wait for the Default boot menu appears.
    Execute Manual Step    [3/7] Select the Continue to the main menu option using the arrow keys and Enter.
    Execute Manual Step    [4/7] Select the Options --> option in the Heads boot menu.
    Execute Manual Step    [5/7] Select the GPG Options --> option in the HEADS Options submenu.
    Execute Manual Step    [6/7] Select the List GPG keys in your keyring option in the GPG Management Menu.
    Execute Manual Step    [7/7] Note the results.
    Execute Manual Step
    ...    [Expected result] The GPG Keyring window should contain information about the GPG key if any was added. The GPG Keyring window should be empty if no key has been added.

HDS015.001 Export public GPG key to USB drive
    [Documentation]    Check whether a public GPG key can be exported to USB drive from Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/8] Power on the DUT.
    Execute Manual Step    [2/8] Wait for the Default boot menu appears.
    Execute Manual Step    [3/8] Select the Continue to the main menu option using the arrow keys and Enter.
    Execute Manual Step    [4/8] Select the Options --> option in the Heads boot menu.
    Execute Manual Step    [5/8] Select the GPG Options --> option in the HEADS Options submenu.
    Execute Manual Step    [6/8] Select the Export public GPG key to USB drive option in the GPG Management Menu.
    Execute Manual Step
    ...    [7/8] Choose Yes in the displayed Export Public Key(s) to USB drive? window using the arrow keys and Enter.
    Execute Manual Step    [8/8] Note the results.
    Execute Manual Step
    ...    [Expected result] The GPG Key Copied Successfully window should be displayed. The public-key.asc file should be on USB storage.

HDS016.001 Generate GPG keys manually on a USB security token
    [Documentation]    Check whether GPG keys can be generated manually on a USB security token from Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/13] Plug the USB Security Dongle into DUT.
    Execute Manual Step    [2/13] Power on the DUT.
    Execute Manual Step    [3/13] Wait for the Default boot menu appears.
    Execute Manual Step    [4/13] Select the Continue to the main menu option using the arrow keys and Enter.
    Execute Manual Step    [5/13] Select the Options --> option in the Heads boot menu.
    Execute Manual Step    [6/13] Select the GPG Options --> option in the HEADS Options submenu.
    Execute Manual Step
    ...    [7/13] Select the Generate GPG keys manually on a USB security token option in the GPG Management Menu.
    Execute Manual Step    [8/13] Confirm that the USB Security Dongle is inserted, type Y and press Enter.
    Execute Manual Step    [9/13] Wait for gpg/card> prompt is appeared.
    Execute Manual Step    [10/13] Type admin and press Enter.
    Execute Manual Step    [11/13] Type generate and press Enter.
    Execute Manual Step    [12/13] Answer y to question Replace existing keys?
    Execute Manual Step    [13/13] Note the results.
    Execute Manual Step
    ...    [Expected result] Information about the successful generation of GPG keys should be displayed. The new GPG keys are on the USB Security Dongle.

HDS017.001 Clear GPG key(s) and reset all user settings
    [Documentation]    Check whether GPG keys and user settings can be cleared in Heads.
    [Tags]    semiauto
    Execute Manual Step    [1/14] Power on the DUT.
    Execute Manual Step    [2/14] Wait for the Default boot menu appears.
    Execute Manual Step    [3/14] Select the Continue to the main menu option using the arrow keys and Enter.
    Execute Manual Step    [4/14] Select the Options --> option in the Heads boot menu.
    Execute Manual Step    [5/14] Select the Change configuration settings --> option in the HEADS Options submenu.
    Execute Manual Step
    ...    [6/14] Select the Clear GPG key(s) and reset all user settings option in the Config Management Menu.
    Execute Manual Step
    ...    [7/14] Choose Yes in the displayed Reset Configuration? window using the arrow keys and Enter.
    Execute Manual Step    [8/14] Reboot the DUT.
    Execute Manual Step    [9/14] Wait for the Default boot menu appears.
    Execute Manual Step    [10/14] Select the Continue to the main menu option using the arrow keys and Enter.
    Execute Manual Step    [11/14] Select the Options --> option in the Heads boot menu.
    Execute Manual Step    [12/14] Select the GPG Options --> option in the HEADS Options submenu.
    Execute Manual Step    [13/14] Select the List GPG keys in your keyring option in the GPG Management Menu.
    Execute Manual Step    [14/14] Note the results.
    Execute Manual Step    [Expected result] The GPG Keyring window should be empty.
