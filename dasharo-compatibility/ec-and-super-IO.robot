*** Settings ***
Library             Collections
Library             Dialogs
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
...                     Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    EC and SuperI/O tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
# ==============================================================================
# FIRMWARE
# ==============================================================================

ECR004.001 Keyboard (standard keypad) in firmware
    [Documentation]    Check whether the standard keypad works correctly during
    ...    firmware execution (UEFI Setup Menu).
    [Tags]    semiauto
    Execute Manual Step    [1/2] Power on the DUT and press the `BIOS_SETUP_KEY` to enter the setup menu.
    Execute Manual Step    [2/2] Use the arrow keys and the Enter key to navigate the menus.
    Execute Manual Step    [Expected result] All menus can be entered using the internal keyboard.

ECR023.001 EC sync update with power adapter connected works correctly
    [Documentation]    This test aims to verify whether coreboot update
    ...    will also update EC firmware when power adapter is connected.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ECR023.001 not supported
    Skip If    not ${DTS_FIRMWARE_FLASHING_SUPPORT}    ECR023.001 not supported
    Skip If    not ${DTS_EC_FLASHING_SUPPORT}    ECR023.001 not supported
    # Flash old fw version without ec sync
    Make Sure That Flash Locks Are Disabled
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Set DUT Response Timeout    320s
    Execute Command In Terminal    wget -O /tmp/coreboot.rom ${FW_NO_EC_SYNC_DOWNLOAD_LINK}
    Flash Via Internal Programmer    /tmp/coreboot.rom
    Flash EC Firmware
    ...    ${EC_NO_SYNC_DOWNLOAD_LINK}    TOOL=dasharo_ectool
    Sleep    15s
    Power On
    Execute Manual Step    Enable console redirection

    # Make sure both coreboot and EC was flashed
    Make Sure That Flash Locks Are Disabled
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check Firmware Version    ${FW_NO_EC_SYNC_VERSION}
    Check EC Firmware Version
    ...    EXPECTED_VERSION=${EC_NO_SYNC_VERSION}    TOOL=dasharo_ectool
    # Flash new fw with ec sync
    Put File    ${FW_FILE}    /tmp/coreboot_with_ec.rom    scp=ALL
    ${flash_result}=    Execute Command In Terminal
    ...    flashrom -p internal --ifd -i bios -w /tmp/coreboot_with_ec.rom
    Should Contain    ${flash_result}    VERIFIED
    Write Into Terminal    reboot
    Sleep    20s
    Power On
    Execute Manual Step    Enable console redirection
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Run Keyword And Expect Error    *    Check Firmware Version
    ...    ${FW_NO_EC_SYNC_VERSION}
    Run Keyword And Expect Error    *    Check EC Firmware Version
    ...    EXPECTED_VERSION=${EC_NO_SYNC_VERSION}    TOOL=dasharo_ectool

    # Make sure EC isn't flashed second time after restart
    Write Into Terminal    reboot
    ${out}=    Read From Terminal Until    ${TIANOCORE_STRING}

ECR024.001 EC sync doesn't update with power adapter disconnected
    [Documentation]    This test aims to verify whether coreboot update
    ...    will display information to connect power adapter when it's
    ...    disconnected
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ECR024.001 not supported
    Skip If    not ${DTS_FIRMWARE_FLASHING_SUPPORT}    ECR024.001 not supported
    Skip If    not ${DTS_EC_FLASHING_SUPPORT}    ECR024.001 not supported

    # Flash old fw version without ec sync
    # Connect Laptop to power adapter
    Make Sure That Flash Locks Are Disabled
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Set DUT Response Timeout    320spre
    Execute Command In Terminal    wget -O /tmp/coreboot.rom ${FW_NO_EC_SYNC_DOWNLOAD_LINK}
    Flash Via Internal Programmer    /tmp/coreboot.rom
    Flash EC Firmware
    ...    ${EC_NO_SYNC_DOWNLOAD_LINK}    TOOL=dasharo_ectool
    Sleep    15s
    Power On
    Execute Manual Step    Enable console redirection
    Make Sure That Flash Locks Are Disabled
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check Firmware Version    ${FW_NO_EC_SYNC_VERSION}
    Check EC Firmware Version
    ...    EXPECTED_VERSION=${EC_NO_SYNC_VERSION}    TOOL=dasharo_ectool

    # Flash new fw with ec sync
    Put File    ${FW_FILE}    /tmp/coreboot_with_ec.rom    scp=ALL
    ${flash_result}=    Execute Command In Terminal
    ...    flashrom -p internal --ifd -i bios -w /tmp/coreboot_with_ec.rom
    Should Contain    ${flash_result}    VERIFIED
    # Disconnect power adapter
    Sonoff Off
    Write Into Terminal    reboot
    Sleep    20
    Power On
    Execute Manual Step    Enable console redirection
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Run Keyword And Expect Error    *    Check Firmware Version
    ...    ${FW_NO_EC_SYNC_VERSION}
    Check EC Firmware Version
    ...    EXPECTED_VERSION=${EC_NO_SYNC_VERSION}    TOOL=dasharo_ectool

ECR035.001 EC power button watchdog
    [Documentation]    Check whether the EC power button watchdog functionality works correctly.
    [Tags]    semiauto
    Execute Manual Step    [1/3] Power on the DUT.
    Execute Manual Step    [2/3] Hold the power button pressed for at least 10 seconds
    Execute Manual Step    [3/3] Note the DUT behavior
    Execute Manual Step
    ...    [Expected result] The DUT should power off and on all within the 10 seconds of power button being pressed down

PPS001.001 PS/2 keyboard detection
    [Documentation]    Check whether the external PS/2 keyboard is detected in OS and all keys work correctly.
    [Tags]    semiauto
    Execute Manual Step    [1/8] Power on the DUT.
    Execute Manual Step    [2/8] Boot into the system.
    Execute Manual Step    [3/8] Log into the system by using the proper login and password.
    Execute Manual Step
    ...    [4/8] Open a terminal window in dom0 and run the following command: sudo dmesg | grep -i PS/2
    Execute Manual Step    [5/8] Run the following command in the terminal: libinput debug-events --show-keycodes
    Execute Manual Step    [6/8] Test the alphanumeric keys and note the generated keycodes.
    Execute Manual Step    [7/8] Test non-alphanumeric keys and verify that they generate the correct keycodes.
    Execute Manual Step    [8/8] Test key combinations with the Shift, Ctrl and Alt modifier keys.
    VAR    ${result_msg}=
    ...    [Expected result] The external PS/2 keyboard is detected in OS.
    ...    All standard keyboard keys generate the correct keycodes and events as per their labels.
    ...    Key combinations are detected correctly.
    ...    separator=${SPACE}
    Execute Manual Step    ${result_msg}

SIO002.001 PS/2 keyboard in firmware
    [Documentation]    Check whether the PS/2 keyboard works correctly in firmware (UEFI/BIOS menus).
    [Tags]    semiauto
    Execute Manual Step    [1/2] Power on the DUT and press the BIOS_SETUP_KEY to enter the setup menu.
    Execute Manual Step    [2/2] Use the arrow keys and the Enter key to navigate the menus.
    Execute Manual Step    [Expected result] All menus can be entered using the PS/2 keyboard.

SIO004.001 Serial port in firmware
    [Documentation]    Check whether the serial port works correctly in firmware (UEFI/BIOS menus).
    [Tags]    semiauto
    Execute Manual Step    [1/3] Open the terminal emulator, e.g. minicom, on the RS232/USB adapter.
    Execute Manual Step    [2/3] Power on the DUT and press the BIOS_SETUP_KEY to enter the setup menu.
    Execute Manual Step    [3/3] Use the arrow keys and the Enter key to navigate the menus.
    Execute Manual Step    [Expected result] All menus can be entered using the serial console.

# ==============================================================================
# 203 UBUNTU
# ==============================================================================

ECR001.201 Battery monitoring - charge level in OS (Ubuntu)
    [Documentation]    Check whether the battery charge level can be read
    ...    (in mAh) in Linux OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR001.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in ${TESTED_LINUX_DISTROS}    ECR001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Turn On ACPI CALL Module In Linux
    Check Charge Level In Linux
    Exit From Root User

ECR002.201 Battery monitoring - charging state in OS (Ubuntu)
    [Documentation]    Check whether the battery state can be read in Linux OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR002.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in ${TESTED_LINUX_DISTROS}    ECR002.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Turn On ACPI CALL Module In Linux
    Check Charging State In Linux
    Exit From Root User

ECR003.201 Touchpad in OS - (Ubuntu)
    [Documentation]    Check whether touchpad is visible in Linux OS.
    ...    Touchpad steering and effect detection must be checked
    ...    manually.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR003.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in ${TESTED_LINUX_DISTROS}    ECR003.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Turn On ACPI CALL Module In Linux
    Device Detection In Linux    Touchpad
    Exit From Root User

ECR004.201 Keyboard (standard keypad) in OS (Ubuntu)
    [Documentation]    Check whether the standard keypad works correctly in Ubuntu OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR004.201 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Run `sudo libinput debug-events --show-keycodes` in the terminal.
    Execute Manual Step    [5/5] Press each keyboard key and check the generated keycode.
    VAR    ${result_msg}=
    ...    All standard keyboard keys generate the correct keycodes and events as per their labels.
    ...    Key combinations are detected correctly.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR005.201 Keyboard (function key: play/pause) in OS (Ubuntu)
    [Documentation]    Check whether the play/pause function key works correctly in Ubuntu OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR005.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR005.201 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Run `sudo libinput debug-events --show-keycodes` in the terminal.
    Execute Manual Step    [5/5] Verify that pressing the play/pause key generates a `KEY_PLAYPAUSE` event.
    Execute Manual Step    [Expected result] Pressing the play/pause hotkey generates a `KEY_PLAYPAUSE` event.

ECR006.201 Keyboard (function key: cooling mode) in OS (Ubuntu)
    [Documentation]    Check whether the cooling mode function key works correctly in Ubuntu OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR006.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR006.201 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Press the cooling mode hotkey (Fn + 1) once and note the effect.
    Execute Manual Step    [5/5] Press the cooling mode hotkey once again and note the effect.
    VAR    ${result_msg}=
    ...    Pressing the hotkey once should activate the cooling mode (fans should spin up to their maximum speed).
    ...    Pressing the hotkey again should deactivate the cooling mode (fans should return to normal).
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR007.201 Keyboard (function key: touchpad on/off) in OS (Ubuntu)
    [Documentation]    Check whether the touchpad on/off function key works correctly in Ubuntu OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR007.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR007.201 not supported
    Execute Manual Step    [1/2] Press the touchpad on/off key and try to use the touchpad.
    Execute Manual Step    [2/2] Press the touchpad on/off key once again and try to use the touchpad again.
    VAR    ${result_msg}=
    ...    Pressing the hotkey once should deactivate the touchpad (touchpad should be completely inoperable).
    ...    Pressing the hotkey again should reactivate the touchpad.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR008.201 Keyboard (function key: display on/off) in OS (Ubuntu)
    [Documentation]    Check whether the display on/off function key works correctly in Ubuntu OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR008.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR008.201 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Press the display on/off hotkey once and note the effect.
    Execute Manual Step    [5/5] Press any key on the keyboard and note the effect.
    VAR    ${result_msg}=
    ...    Pressing the hotkey once should turn the internal LCD panel off.
    ...    Pressing any key on the keyboard should power the internal LCD panel back on.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR009.201 Keyboard (function key: mute) in OS (Ubuntu)
    [Documentation]    Check whether the mute function key works correctly in Ubuntu OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR009.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR009.201 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the volume mute hotkey twice and note the effect each keypress has.
    VAR    ${result_msg}=
    ...    Pressing the hotkey should mute or unmute the currently enabled audio output.
    ...    Each keypress should cause a mute/unmute notification to appear in the middle of the screen.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR010.201 Keyboard (function key: keyboard backlight) in OS (Ubuntu)
    [Documentation]    Check whether the keyboard backlight function key works correctly in Ubuntu OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR010.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR010.201 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    VAR    ${step4_msg}=
    ...    Press the keyboard backlight hotkey 6 times and note the effect on the
    ...    keyboard backlight after each keypress.
    ...    separator=${SPACE}
    Execute Manual Step    [4/4] ${step4_msg}
    VAR    ${result_msg}=
    ...    The keyboard has 6 backlight settings from 0% to 100% Each keypress should
    ...    set the keyboard to the next mode, with the last mode wrapping back around to the first.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR011.201 Keyboard (function key: volume down) in OS (Ubuntu)
    [Documentation]    Check whether the volume down function key works correctly in Ubuntu OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR011.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR011.201 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the volume down hotkey once and note the effects.
    VAR    ${result_msg}=
    ...    Pressing the hotkey should decrease the volume of the currently enabled audio output.
    ...    Each key press should cause a volume down notification to appear in the middle of the screen.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR012.201 Keyboard (function key: volume up) in OS (Ubuntu)
    [Documentation]    Check whether the volume up function key works correctly in Ubuntu OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR012.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR012.201 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the volume up hotkey once and note the effects.
    VAR    ${result_msg}=
    ...    Pressing the hotkey should increase the volume of the currently enabled audio output.
    ...    Each key press should cause a volume up notification to appear in the middle of the screen.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR013.201 Keyboard (function key: display switch) in OS (Ubuntu)
    [Documentation]    Check whether the display switch function key works correctly in Ubuntu OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR013.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR013.201 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Run `sudo libinput debug-events --show-keycodes` in the terminal.
    Execute Manual Step    [5/5] Press the display switch hotkey once and note the effect.
    VAR    ${result_msg}=
    ...    Pressing the hotkey should yield the following output in the terminal:
    ...    -event3 KEYBOARD_KEY +0.000s KEY_LEFTMETA (125) pressed
    ...    event3 KEYBOARD_KEY +0.004s KEY_P (25) pressed
    ...    event3 KEYBOARD_KEY +0.010s KEY_P (25) released
    ...    event3 KEYBOARD_KEY +0.015s KEY_LEFTMETA (125) released
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR014.201 Keyboard (function key: brightness down) in OS (Ubuntu)
    [Documentation]    Check whether function key: brightness down works in
    ...    Linux OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR014.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in ${TESTED_LINUX_DISTROS}    ECR014.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Keyboard Function Key Brightness Down In Linux
    Exit From Root User

ECR015.201 Keyboard (function key: brightness up) in OS (Ubuntu)
    [Documentation]    Check whether function key: brightness up works in
    ...    Linux OS.
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR015.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR015.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in ${TESTED_LINUX_DISTROS}    ECR015.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Keyboard Function Key Brightness Up In Linux
    Exit From Root User

ECR016.201 Keyboard (function key: camera on/off) in OS (Ubuntu)
    [Documentation]    Check whether the camera on/off hotkey works correctly.
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR016.201 not supported
    Skip If    not ${USB_CAMERA_DETECTION_SUPPORT}    ECR016.201 not supported
    Skip If    not ${ACPI_CAMERA_SWITCH_SUPPORT}    ECR016.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR016.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in ${TESTED_LINUX_DISTROS}    ECR016.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Keyboard Function Key Camera OnOff In Linux
    Exit From Root User

ECR017.201 Keyboard (function key: flight mode) in OS (Ubuntu)
    [Documentation]    Check whether function key: flight mode works in
    ...    Linux OS.
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR017.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR017.201 not supported
    Skip If    not ${WIRELESS_CARD_SUPPORT}    ECR017.201 not supported
    Skip If    '${DUT_CONNECTION_METHOD}' == 'SSH'    ECR017.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in ${TESTED_LINUX_DISTROS}    ECR017.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Keyboard Function Key Flight Mode In Linux
    Exit From Root User

ECR018.201 Keyboard (function key: sleep) in OS (Ubuntu)
    [Documentation]    Check whether the sleep function key works correctly in Ubuntu OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR018.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR018.201 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the sleep hotkey once and note the result.
    VAR    ${result_msg}=
    ...    The laptop should go to sleep within seconds of the hotkey being pressed.
    ...    The power LED should be blinking green, indicating the laptop is sleeping.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR019.201 Buttons (button: power) in OS (Ubuntu)
    [Documentation]    Check whether button: power is detected in Linux OS.
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR019.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR019.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in ${TESTED_LINUX_DISTROS}    ECR019.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Turn On ACPI CALL Module In Linux
    Device Detection In Linux    Power
    Exit From Root User

ECR020.201 Buttons (button: lid switch) in OS (Ubuntu)
    [Documentation]    Check whether the lid switch works correctly in Ubuntu OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR020.201 not supported
    Execute Manual Step    [1/8] Power on the DUT.
    Execute Manual Step    [2/8] Boot into the system.
    Execute Manual Step    [3/8] Log into the system by using the proper login and password.
    VAR    ${step4_msg}=
    ...    Open one terminal window and run the following command:
    ...    sudo systemd-inhibit --what handle-lid-switch --mode block watch echo "Inhibiting lid switch"
    ...    separator=${SPACE}
    Execute Manual Step    [4/8] ${step4_msg}
    VAR    ${step5_msg}=
    ...    Open another terminal and run the command
    ...    `sleep 5 && cat /proc/acpi/button/lid/LID0/state` to read the state of the lid while it is closed.
    ...    separator=${SPACE}
    Execute Manual Step    [5/8] ${step5_msg}
    Execute Manual Step    [6/8] Close the lid and wait 5 seconds.
    Execute Manual Step    [7/8] Open the lid and note the output of the command.
    VAR    ${step8_msg}=
    ...    Run the command `cat /proc/acpi/button/lid/LID0/state` while the lid is
    ...    open and note the output.
    ...    separator=${SPACE}
    Execute Manual Step    [8/8] ${step8_msg}
    VAR    ${result_msg}=
    ...    The output of the second command should report that the lid is closed.
    ...    The output of the third command should report that the lid is open.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR021.201 Charging until 98% level in OS (Ubuntu)
    [Documentation]    Check whether the DUT stops charging the battery when the
    ...    98% threshold is reached.
    Skip If    '${POWER_CTRL}' != 'sonoff'    ECR021.201 not supported
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR021.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR021.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in ${TESTED_LINUX_DISTROS}    ECR021.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Charging Until 98% Level In Linux
    Check Charging State Not Charging In Linux

ECR022.201 Not charging between 95% and 98% in OS (Ubuntu)
    [Documentation]    Check whether the DUT does not charge the battery when
    ...    the charge level is between 95% and 98%.
    Skip If    '${POWER_CTRL}' != 'sonoff'    ECR022.201 not supported
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR022.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR022.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in ${TESTED_LINUX_DISTROS}    ECR022.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Not Charging Between 95% And 98% In Linux
    Exit From Root User

ECR025.201 Permanent keyboard illumination after cold boot (Ubuntu)
    [Documentation]    Check whether keyboard illumination persists at the same level after a cold boot in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR025.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR025.201 not supported
    Execute Manual Step    [1/9] Power on the DUT.
    Execute Manual Step    [2/9] Boot into the `OPERATING_SYSTEM`.
    Execute Manual Step    [3/9] Log into the `OPERATING_SYSTEM` by using the proper login and password.
    Execute Manual Step    [4/9] Set keyboard brightness and color to arbitrary settings.
    Execute Manual Step    [5/9] Disconnect power source, and remove battery if present.
    Execute Manual Step    [6/9] Connect power and battery again.
    Execute Manual Step    [7/9] Power on the DUT.
    Execute Manual Step    [8/9] Boot into the `OPERATING_SYSTEM`.
    Execute Manual Step    [9/9] Log into the `OPERATING_SYSTEM` by using the proper login and password.
    Execute Manual Step    [Expected result] After cold-boot keyboard brightness and colors settings remain the same.

ECR026.201 Permanent keyboard illumination after warm boot (Ubuntu)
    [Documentation]    Check whether keyboard illumination persists at the same level after a warm boot in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR026.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR026.201 not supported
    Execute Manual Step    [1/8] Power on the DUT.
    Execute Manual Step    [2/8] Boot into the `OPERATING_SYSTEM`.
    Execute Manual Step    [3/8] Log into the `OPERATING_SYSTEM` by using the proper login and password.
    Execute Manual Step    [4/8] Set keyboard brightness and color to arbitrary settings.
    Execute Manual Step    [5/8] Power off the DUT using power button.
    Execute Manual Step    [6/8] Power on the DUT.
    Execute Manual Step    [7/8] Boot into the `OPERATING_SYSTEM`.
    Execute Manual Step    [8/8] Log into the `OPERATING_SYSTEM` by using the proper login and password.
    Execute Manual Step    [Expected result] After warm-boot keyboard brightness and colors settings remain the same.

ECR027.201 Permanent keyboard illumination after reboot (Ubuntu)
    [Documentation]    Check whether keyboard illumination persists at the same level after a system reboot in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR027.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR027.201 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Set keyboard brightness and color to arbitrary settings.
    Execute Manual Step    [5/5] Reboot the device using: `sudo reboot now`
    Execute Manual Step    [Expected result] After reboot keyboard brightness and colors settings remain the same.

ECR028.201 Permanent keyboard illumination after suspension (Ubuntu)
    [Documentation]    Check whether keyboard illumination persists at the same level after suspension in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR028.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR028.201 not supported
    Execute Manual Step    [1/6] Power on the DUT.
    Execute Manual Step    [2/6] Boot into the system.
    Execute Manual Step    [3/6] Log into the system by using the proper login and password.
    Execute Manual Step    [4/6] Set keyboard brightness and color to arbitrary settings.
    Execute Manual Step    [5/6] Suspend the DUT using `SUSPEND_KEY`.
    Execute Manual Step    [6/6] Wake the device from suspend pressing any key on keyboard.
    Execute Manual Step    [Expected result] After suspend keyboard brightness and colors settings remain the same.

ECR029.201 FnLock Hotkey (Ubuntu)
    [Documentation]    Check whether the FnLock hotkey works correctly in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR029.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR029.201 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Use `FN_LOCK_KEY` to activate Fn lock functionality.
    Execute Manual Step    [5/5] Test function keys `F1` - `F12` and note the results.
    Execute Manual Step    [Expected result] The function keys `F1` - `F12` behave as if `Fn` key is pressed.

ECR030.201 Soft Switch Microphone Key (Ubuntu)
    [Documentation]    Check whether the soft switch microphone key works correctly in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR030.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR030.201 not supported
    Execute Manual Step    [1/6] Power on the DUT.
    Execute Manual Step    [2/6] Boot into the system.
    Execute Manual Step    [3/6] Log into the system by using the proper login and password.
    Execute Manual Step    [4/6] Go to `Settings` -> `Sound`
    Execute Manual Step    [5/6] Observe the bar above the Input Device option
    Execute Manual Step    [6/6] Press the `Fn+4` combination at will
    VAR    ${result_msg}=
    ...    The Fn+4 should toggle the mic ON and OFF and it should be seen on the
    ...    aforementioned bar which state is currently active as noise made will
    ...    make the bar go back and forth if ON and completely still if OFF
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR031.201 Keyboard (function key: RGB keyboard toggle) in OS (Ubuntu)
    [Documentation]    Check whether the RGB keyboard toggle hotkey works correctly in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR031.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR031.201 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the RGB keyboard toggle hotkey twice and note the result each time.
    Execute Manual Step
    ...    [Expected result] Pressing the button once should disable the keyboard backlight. Pressing the button again should re-enable the keyboard backlight.

ECR032.201 RGB keyboard next color FN key in OS (Ubuntu)
    [Documentation]    Check whether the RGB keyboard next color FN key works correctly in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR032.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR032.201 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step
    ...    [4/4] Press the RGB keyboard color hotkey repeatedly until the keyboard cycles through all color modes.
    Execute Manual Step
    ...    [Expected result] Pressing the button once should switch the keyboard color. All color modes according to product documentation should be accessible.

ECR033.201 RGB keyboard brightness down FN key in OS (Ubuntu)
    [Documentation]    Check whether the RGB keyboard brightness down FN key works correctly in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR033.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR033.201 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the RGB keyboard brightness down hotkey and note the result.
    Execute Manual Step    [Expected result] Pressing the button once should lower the keyboard backlight

ECR034.201 RGB keyboard brightness up FN key in OS (Ubuntu)
    [Documentation]    Check whether the RGB keyboard brightness up FN key works correctly in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR034.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ECR034.201 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the RGB keyboard brightness up hotkey and note the result.
    Execute Manual Step    [Expected result] Pressing the button once should increase the keyboard backlight.

SIO001.201 PS/2 mouse in OS - (Ubuntu)
    [Documentation]    Check whether the PS/2 mouse works correctly in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SIO001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SIO001.201 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Verify that the cursor can be moved with the PS/2 mouse and that clicking works.
    Execute Manual Step    [Expected result] Moving the cursor and clicking working correctly in the operating system.

SIO002.201 PS/2 keyboard in OS (Ubuntu)
    [Documentation]    Check whether the PS/2 keyboard works correctly in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SIO002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SIO002.201 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Run "sudo libinput debug-events --show-keycodes" in the terminal.
    Execute Manual Step    [5/5] Press keyboard keys and check the generated keycode.
    Execute Manual Step
    ...    [Expected result] All standard keyboard keys generate the correct keycodes and events as per their labels. Key combinations are detected correctly.

SIO003.201 PS/2 keyboard wake in OS (Ubuntu)
    [Documentation]    Check whether the PS/2 keyboard can wake the platform from sleep in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SIO003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SIO003.201 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Suspend the system to RAM.
    Execute Manual Step    [5/5] Press a keyboard key to wake the platform.
    Execute Manual Step    [Expected result] Platform is resuming to the OS from sleep after pressing the key.

SIO004.201 Serial port in OS (Ubuntu)
    [Documentation]    Check whether the serial port works correctly as Linux console in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SIO004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SIO004.201 not supported
    Execute Manual Step    [1/4] Open the terminal emulator, e.g. minicom, on the RS232/USB adapter.
    Execute Manual Step    [2/4] Power on the DUT.
    Execute Manual Step    [3/4] Boot into the system.
    Execute Manual Step    [4/4] Log into the system by using the proper login and password through serial console.
    Execute Manual Step
    ...    [Expected result] Serial port can be used as Linux console to log in. Serial port can be used to execute commands in bash/shell.

# ==============================================================================
# 203 FEDORA
# ==============================================================================

ECR001.202 Battery monitoring - charge level in OS (Fedora)
    [Documentation]    Check whether the battery charge level can be read
    ...    (in mAh) in Linux OS.
    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    ECR001.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Turn On ACPI CALL Module In Linux
    Check Charge Level In Linux
    Exit From Root User

ECR002.202 Battery monitoring - charging state in OS (Fedora)
    [Documentation]    Check whether the battery state can be read in Linux OS.
    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    ECR002.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Turn On ACPI CALL Module In Linux
    Check Charging State In Linux
    Exit From Root User

ECR003.202 Touchpad in OS - (Fedora)
    [Documentation]    Check whether touchpad is visible in Linux OS.
    ...    Touchpad steering and effect detection must be checked
    ...    manually.
    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    ECR003.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Turn On ACPI CALL Module In Linux
    Device Detection In Linux    Touchpad
    Exit From Root User

ECR014.202 Keyboard (function key: brightness down) in OS (Fedora)
    [Documentation]    Check whether function key: brightness down works in
    ...    Linux OS.
    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    ECR0014.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Keyboard Function Key Brightness Down In Linux
    Exit From Root User

ECR015.202 Keyboard (function key: brightness up) in OS (Fedora)
    [Documentation]    Check whether function key: brightness up works in
    ...    Linux OS.
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR015.202 not supported
    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    ECR0015.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Keyboard Function Key Brightness Up In Linux
    Exit From Root User

ECR016.202 Keyboard (function key: camera on/off) in OS (Fedora)
    [Documentation]    Check whether the camera on/off hotkey works correctly.
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR016.202 not supported
    Skip If    not ${USB_CAMERA_DETECTION_SUPPORT}    ECR016.202 not supported
    Skip If    not ${ACPI_CAMERA_SWITCH_SUPPORT}    ECR016.202 not supported
    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    ECR016.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Keyboard Function Key Camera OnOff In Linux
    Exit From Root User

ECR017.202 Keyboard (function key: flight mode) in OS (Fedora)
    [Documentation]    Check whether function key: flight mode works in
    ...    Linux OS.
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR017.202 not supported
    Skip If    not ${WIRELESS_CARD_SUPPORT}    ECR017.202 not supported
    Skip If    '${DUT_CONNECTION_METHOD}' == 'SSH'    ECR017.202 not supported
    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    ECR0017.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Keyboard Function Key Flight Mode In Linux
    Exit From Root User

ECR019.202 Buttons (button: power) in OS (Fedora)
    [Documentation]    Check whether button: power is detected in Linux OS.
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR019.202 not supported
    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    ECR0019.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Turn On ACPI CALL Module In Linux
    Device Detection In Linux    Power
    Exit From Root User

ECR020.202 Buttons (button: lid switch) in OS (Fedora)
    [Documentation]    Check whether the lid switch works correctly in Fedora OS.
    [Tags]    semiauto
    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    ECR020.202 not supported
    Execute Manual Step    [1/8] Power on the DUT.
    Execute Manual Step    [2/8] Boot into the system.
    Execute Manual Step    [3/8] Log into the system by using the proper login and password.
    VAR    ${step4_msg}=
    ...    Open one terminal window and run the following command:
    ...    sudo systemd-inhibit --what handle-lid-switch --mode block watch echo "Inhibiting lid switch"
    ...    separator=${SPACE}
    Execute Manual Step    [4/8] ${step4_msg}
    VAR    ${step5_msg}=
    ...    Open another terminal and run the command
    ...    `sleep 5 && cat /proc/acpi/button/lid/LID0/state` to read the state of the lid while it is closed.
    ...    separator=${SPACE}
    Execute Manual Step    [5/8] ${step5_msg}
    Execute Manual Step    [6/8] Close the lid and wait 5 seconds.
    Execute Manual Step    [7/8] Open the lid and note the output of the command.
    VAR    ${step8_msg}=
    ...    Run the command `cat /proc/acpi/button/lid/LID0/state` while the lid is
    ...    open and note the output.
    ...    separator=${SPACE}
    Execute Manual Step    [8/8] ${step8_msg}
    VAR    ${result_msg}=
    ...    The output of the second command should report that the lid is closed.
    ...    The output of the third command should report that the lid is open.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR021.202 Charging until 98% level in OS (Fedora)
    [Documentation]    Check whether the DUT stops charging the battery when the
    ...    98% threshold is reached.
    Skip If    '${POWER_CTRL}' != 'sonoff'    ECR021.202 not supported
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR021.202 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR021.202 not supported
    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    ECR021.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Charging Until 98% Level In Linux
    Check Charging State Not Charging In Linux

ECR022.202 Not charging between 95% and 98% in OS (Fedora)
    [Documentation]    Check whether the DUT does not charge the battery when
    ...    the charge level is between 95% and 98%.
    Skip If    '${POWER_CTRL}' != 'sonoff'    ECR022.202 not supported
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR022.202 not supported
    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    ECR022.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Not Charging Between 95% And 98% In Linux
    Exit From Root User

# ==============================================================================
# 203 QUBES OS
# ==============================================================================

ECR001.203 Battery monitoring - charge level in OS (Qubes OS)
    [Documentation]    Check whether the battery charge level can be read
    ...    (in mAh) in Linux OS.
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ECR001.203 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    Turn On ACPI CALL Module In Linux
    Check Charge Level In Linux

ECR002.203 Battery monitoring - charging state in OS (Qubes OS)
    [Documentation]    Check whether the battery state can be read in Linux OS.
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ECR002.203 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    Check Charging State In Linux

ECR003.203 Touchpad in OS (Qubes OS)
    [Documentation]    Check whether touchpad is visible in Linux OS.
    ...    Touchpad steering and effect detection must be checked
    ...    manually.
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ECR003.203 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    ${out}=    Execute Linux Command    sudo libinput list-devices | grep Touchpad
    Should Contain    ${out}    Touchpad

ECR004.203 Keyboard (standard keypad) in OS (Qubes OS)
    [Documentation]    Check whether keyboard is sending correct symbols in OS.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/3] Make sure Qubes OS is booted.
    Execute Manual Step    [2/3] Open Dom0 Xfce Terminal (or any text editor).
    Execute Manual Step
    ...    [3/3] Test at least 20 different keys (letters both small and capital, numpad, special symbols like ,./":->; etc.).

ECR005.203 Keyboard (function key: play/pause) in OS (Qubes OS)
    [Documentation]    Check whether function key works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/3] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal.
    Execute Manual Step    [3/4] Type `libinput debug-events` to track pressed keys.
    Execute Manual Step
    ...    [4/4] Press play/pause combination on DUT's keyboard (Fn+`) and observe actions listed by libinput.

ECR006.203 Keyboard (function key: cooling mode) in OS (Qubes OS)
    [Documentation]    Check whether function key works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal.
    Execute Manual Step    [3/4] Type `libinput debug-events` to track pressed keys
    Execute Manual Step
    ...    [4/4] Press the combination on DUT's keyboard (Fn+1) and observe actions listed by libinput

ECR007.203 Keyboard (function key: touchpad on/off) in OS (Qubes OS)
    [Documentation]    Check whether function key works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal
    Execute Manual Step    [3/4] Type `libinput debug-events` to track pressed keys
    Execute Manual Step
    ...    [4/4] Press the combination on DUT's keyboard (Fn+F1) and observe actions listed by libinput

ECR008.203 Keyboard (function key: display on/off) in OS (Qubes OS)
    [Documentation]    Check whether the display on/off function key works correctly in Qubes OS.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Press the combination on DUT's keyboard (Fn+F2) and observe the screen turn on/off
    Execute Manual Step    [3/4] Observe the internal display
    Execute Manual Step    [4/4] Confirm the display turns off, then press the key again to verify it turns back on

ECR009.203 Keyboard (function key: mute) in OS (Qubes OS)
    [Documentation]    Check whether function key works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal.
    Execute Manual Step    [3/4] Type `libinput debug-events` to track pressed keys
    Execute Manual Step
    ...    [4/4] Press the combination on DUT's keyboard (Fn+4) and observe actions listed by libinput

ECR010.203 Keyboard (function key: keyboard backlight) in OS (Qubes OS)
    [Documentation]    Check whether function key works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Press the keyboard backlight function key (Fn+F key)
    Execute Manual Step    [3/4] Observe the keyboard backlight
    Execute Manual Step    [4/4] Confirm the keyboard backlight changes brightness level or toggles on/off

ECR011.203 Keyboard (function key: volume down) in OS (Qubes OS)
    [Documentation]    Check whether function key works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal.
    Execute Manual Step    [3/4] Type `libinput debug-events` to track pressed keys
    Execute Manual Step
    ...    [4/4] Press the combination on DUT's keyboard (Fn+F5) and observe actions listed by libinput

ECR012.203 Keyboard (function key: volume up) in OS (Qubes OS)
    [Documentation]    Check whether function key works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal.
    Execute Manual Step    [3/4] Type `libinput debug-events` to track pressed keys
    Execute Manual Step
    ...    [4/4] Press the combination on DUT's keyboard (Fn+F6) and observe actions listed by libinput

ECR013.203 Keyboard (function key: display switch) in OS (Qubes OS)
    [Documentation]    Check whether function key works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal.
    Execute Manual Step    [3/4] Type `libinput debug-events` to track pressed keys
    Execute Manual Step
    ...    [4/4] Press the combination on DUT's keyboard (Fn+F7) and observe actions listed by libinput

ECR014.203 Keyboard (function key: brightness down) in OS (Qubes OS)
    [Documentation]    Check whether function key works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal.
    Execute Manual Step    [3/4] Type `libinput debug-events` to track pressed keys
    Execute Manual Step
    ...    [4/4] Press the combination on DUT's keyboard (Fn+F8) and observe actions listed by libinput

ECR015.203 Keyboard (function key: brightness up) in OS (Qubes OS)
    [Documentation]    Check whether function key works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal.
    Execute Manual Step    [3/4] Type `libinput debug-events` to track pressed keys
    Execute Manual Step
    ...    [4/4] Press the combination on DUT's keyboard (Fn+F9) and observe actions listed by libinput

ECR016.203 Keyboard (function key: camera on/off) in OS (Qubes OS)
    [Documentation]    Check whether function key works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal.
    Execute Manual Step    [3/4] Type `libinput debug-events` to track pressed keys
    Execute Manual Step
    ...    [4/4] Press the combination on DUT's keyboard (Fn+F10) and observe actions listed by libinput

ECR017.203 Keyboard (function key: flight mode on/off) in OS (Qubes OS)
    [Documentation]    Check whether function key works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal.
    Execute Manual Step    [3/4] Type `libinput debug-events` to track pressed keys.
    Execute Manual Step
    ...    [4/4] Press the combination on DUT's keyboard (Fn+F11) and observe actions listed by libinput.

ECR018.203 Keyboard (function key: sleep) in OS (Qubes OS)
    [Documentation]    Check whether function key works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal .
    Execute Manual Step    [3/4] Type `libinput debug-events` to track pressed keys.
    Execute Manual Step
    ...    [4/4] Press the combination on DUT's keyboard (Fn+F12) and observe actions listed by libinput.

ECR019.203 Buttons (button: power) in OS (Qubes OS)
    [Documentation]    Check whether power button works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Press the power button (do not hold).
    Execute Manual Step    [3/4] "Log out qubesos" window should appear in the middle of the screen.
    Execute Manual Step
    ...    [4/4] Press and hold the power button to shut down the DUT.

ECR020.203 Buttons (button: lid switch) in OS (Qubes OS)
    [Documentation]    Check whether lid switch works.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Close the laptop lid and wait 5s.
    Execute Manual Step    [3/4] Open the laptop lid, the DUT should be in sleep.
    Execute Manual Step
    ...    [4/4] Wake the DUT with any key or power button.

ECR021.203 Charging until 98% level in OS (Qubes OS)
    [Documentation]    Check whether the DUT charges the battery up to 98% level in Qubes OS.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ECR021.203 not supported
    Execute Manual Step    [1/4] Boot into Qubes OS with AC power connected
    Execute Manual Step    [2/4] Monitor the battery charge level in a terminal
    Execute Manual Step    [3/4] Wait until the battery reaches 98% charge
    Execute Manual Step    [4/4] Confirm the battery charges up to 98% and does not exceed that level significantly

ECR022.203 Not charging between 95% and 98% in OS (Qubes OS)
    [Documentation]    Check whether the DUT does not charge the battery when it is between 95% and 98% in Qubes OS.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ECR022.203 not supported
    Execute Manual Step    [1/4] Boot into Qubes OS with battery level between 95% and 98%
    Execute Manual Step    [2/4] Connect AC power to the DUT
    Execute Manual Step    [3/4] Monitor the battery charge status in a terminal
    Execute Manual Step    [4/4] Confirm the battery is not actively charging while between 95% and 98%

ECR025.203 Permanent keyboard illumination after cold boot (Qubes OS)
    [Documentation]    Check whether keyboard illumination persists at the same level after a cold boot.
    [Tags]    semiauto
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Choose any keyboard brightness (Fn+F4) as a means to test this feature
    ...    (for example, the last level before black for easier tracking).
    Execute Manual Step    [3/4] Perform a cold boot and boot into Qubes OS once again.
    Execute Manual Step
    ...    [4/4] Verify if the keyboard brightness is set to the level used before the cold boot.

ECR026.203 Permanent keyboard illumination after warm boot (Qubes OS)
    [Documentation]    Check whether keyboard backlight level persists after warm boot.
    [Tags]    semiauto
    Depends On    ${TESTS_IN_QUBESOS_SUPPORT}    ${TEST_NAME} not supported
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/5] Make sure Qubes OS is booted.
    Execute Manual Step    [2/5] Set keyboard backlight to a visible, non-default level (Fn+F4).
    Execute Manual Step    [3/5] Perform a warm boot (reboot from OS).
    Execute Manual Step    [4/5] Boot into Qubes OS again.
    Execute Manual Step    [5/5] Verify the keyboard backlight level is the same as before reboot.

ECR027.203 Permanent keyboard illumination after reboot (Qubes OS)
    [Documentation]    Check whether keyboard backlight level persists after cold reboot.
    [Tags]    semiauto
    Depends On    ${TESTS_IN_QUBESOS_SUPPORT}    ${TEST_NAME} not supported
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/5] Make sure Qubes OS is booted.
    Execute Manual Step    [2/5] Set keyboard backlight to a visible, non-default level (Fn+F4).
    Execute Manual Step    [3/5] Shut down the DUT completely.
    Execute Manual Step    [4/5] Power on and boot into Qubes OS.
    Execute Manual Step    [5/5] Verify the keyboard backlight level is preserved.

ECR028.203 Permanent keyboard illumination after suspension (Qubes OS)
    [Documentation]    Check whether keyboard backlight level persists after suspend/resume.
    [Tags]    semiauto
    Depends On    ${TESTS_IN_QUBESOS_SUPPORT}    ${TEST_NAME} not supported
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/5] Make sure Qubes OS is booted.
    Execute Manual Step    [2/5] Set keyboard backlight to a visible, non-default level (Fn+F4).
    Execute Manual Step    [3/5] Suspend the system (close lid or use suspend option).
    Execute Manual Step    [4/5] Resume the system.
    Execute Manual Step    [5/5] Verify the keyboard backlight level is unchanged.

ECR029.203 FnLock Hotkey (Qubes OS)
    [Documentation]    Check whether FnLock hotkey toggles function key behavior.
    ...    Without Fn Lock: FX keys send standard F1-F12 keycodes.
    ...    With Fn Lock active: FX keys act as if Fn is held, triggering special functions.
    [Tags]    semiauto
    Depends On    ${TESTS_IN_QUBESOS_SUPPORT}    ${TEST_NAME} not supported
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step
    ...    [1/4] Make sure Qubes OS is booted.
    ...    Execute Manual Step
    ...    [2/4] Verify that without Fn Lock, pressing FX keys sends standard F1-F12 keycodes (it should send FX, not trigger a special function).
    Execute Manual Step
    ...    [3/4] Enable Fn Lock and test a few function keys freely - they should now trigger their special functions without holding Fn.
    Execute Manual Step
    ...    [3/4] Disable Fn Lock and verify FX keys return to sending standard keycodes.

ECR030.203 Charging until 98% level in OS (Qubes OS)
    [Documentation]    Check whether the DUT stops charging the battery when 98% level is reached.
    [Tags]    semiauto
    Depends On    ${TESTS_IN_QUBESOS_SUPPORT}    ${TEST_NAME} not supported
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/5] Make sure Qubes OS is booted.
    Execute Manual Step    [2/5] Connect the power adapter.
    Execute Manual Step    [3/5] Monitor battery level until it reaches 98%.
    Execute Manual Step    [4/5] Verify charging stops at or before 98%.
    Execute Manual Step    [5/5] Disconnect the power adapter.

ECR031.203 Not charging between 95% and 98% in OS (Qubes OS)
    [Documentation]    Check whether the DUT does not charge battery between 95% and 98%.
    [Tags]    semiauto
    Depends On    ${TESTS_IN_QUBESOS_SUPPORT}    ${TEST_NAME} not supported
    Skip IF    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Execute Manual Step    [1/5] Make sure Qubes OS is booted.
    Execute Manual Step    [2/5] Ensure battery level is between 95% and 98%.
    Execute Manual Step    [3/5] Connect the power adapter.
    Execute Manual Step    [4/5] Observe battery charging state for several minutes.
    Execute Manual Step    [5/5] Verify battery does not start charging.

# ==============================================================================
# 203 WINDOWS
# ==============================================================================

ECR001.301 Battery monitoring - charge level in OS (Windows)
    [Documentation]    Check whether battery charge level can be read in
    ...    Windows OS.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR001.301 not supported
    Power On
    Boot And Login To Windows
    ${out}=    Get Battery Power Level Windows
    Should Be True    ${out} > 0 and ${out} < 101
    Execute Shutdown Command

ECR002.301 Battery monitoring - charging state in OS (Windows)
    [Documentation]    Check whether the battery state can be read in Windows
    ...    OS.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR002.301 not supported
    Power On
    Boot And Login To Windows
    Check If Battery Is Charging Windows
    Execute Shutdown Command

ECR003.301 Touchpad in OS - (Windows)
    [Documentation]    Check whether touchpad is visible in Windows OS.
    ...    Touchpad steering and effect detection must be checked
    ...    manually.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR003.301 not supported
    Power On
    Boot And Login To Windows
    ${out}=    Get Pointing Devices Windows
    Should Contain    ${out}    HID-compliant mouse
    Execute Shutdown Command

ECR004.301 Keyboard (standard keypad) in OS (Windows)
    [Documentation]    Check whether the standard keypad works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR004.301 not supported
    Execute Manual Step    [1/6] Power on the DUT.
    Execute Manual Step    [2/6] Boot into the system.
    Execute Manual Step    [3/6] Log into the system by using the proper login and password.
    VAR    ${step4_msg}=
    ...    Open `notepad`
    ...    Test the alphanumeric keys and note the generated characters
    ...    Test non-alphanumeric keys and verify that they generate the signs
    ...    Test key combinations with the `Shift`, and `Alt` modifier keys
    ...    separator=${SPACE}
    Execute Manual Step    [4/6] ${step4_msg}
    VAR    ${step5_msg}=
    ...    Open `On-Screen Keyboard` and press `Ctrl` key on the hardware keyboard.
    ...    Check if `On-Screen Keyboard` correctly highlights it.
    ...    separator=${SPACE}
    Execute Manual Step    [5/6] ${step5_msg}
    Execute Manual Step    [6/6] Open `Start menu` and press `Esc`. Check if `Start menu` is properly closed.
    VAR    ${result_msg}=
    ...    All standard keyboard keys generate correct characters or actions when pressed.
    ...    Key combinations are detected correctly.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR005.301 Keyboard (function key: play/pause) in OS (Windows)
    [Documentation]    Check whether the play/pause function key works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR005.301 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Start `Groove Music`
    VAR    ${step5_msg}=
    ...    Verify that when pressing the `play/pause` button, player menu appears
    ...    in the upper left part of the screen for a few seconds.
    ...    separator=${SPACE}
    Execute Manual Step    [5/5] ${step5_msg}
    Execute Manual Step    [Expected result] Pressing the play/pause hotkey is properly detected by the OS

ECR006.301 Keyboard (function key: cooling mode) in OS (Windows)
    [Documentation]    Check whether the cooling mode function key works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR006.301 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Press the cooling mode hotkey (Fn + 1) once and note the effect.
    Execute Manual Step    [5/5] Press the cooling mode hotkey once again and note the effect.
    VAR    ${result_msg}=
    ...    Pressing the hotkey once should activate the cooling mode (fans should spin up to their maximum speed).
    ...    Pressing the hotkey again should deactivate the cooling mode (fans should return to normal).
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR007.301 Keyboard (function key: touchpad on/off) in OS (Windows)
    [Documentation]    Check whether the touchpad on/off function key works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR007.301 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Press the touchpad on/off key and try to use the touchpad.
    Execute Manual Step    [5/5] Press the touchpad on/off key once again and try to use the touchpad again.
    VAR    ${result_msg}=
    ...    Pressing the hotkey once should deactivate the touchpad (touchpad should be completely inoperable).
    ...    Pressing the hotkey again should reactivate the touchpad.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR008.301 Keyboard (function key: display on/off) in OS (Windows)
    [Documentation]    Check whether the display on/off function key works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR008.301 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Press the display on/off hotkey once and note the effect.
    Execute Manual Step    [5/5] Press any key on the keyboard and note the effect.
    VAR    ${result_msg}=
    ...    Pressing the hotkey once should turn the internal LCD panel off.
    ...    Pressing any key on the keyboard should power the internal LCD panel back on.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR009.301 Keyboard (function key: mute) in OS (Windows)
    [Documentation]    Check whether the mute function key works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR009.301 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    VAR    ${step4_msg}=
    ...    Press the mute hotkey once and check the volume indicator in the bottom right
    ...    part of the screen.
    ...    separator=${SPACE}
    Execute Manual Step    [4/5] ${step4_msg}
    Execute Manual Step    [5/5] Press the mute hotkey once and check the volume indicator again.
    VAR    ${result_msg}=
    ...    Pressing the hotkey once should mute the device
    ...    Pressing the hotkey again should re-enable the sound
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR010.301 Keyboard (function key: keyboard backlight) in OS (Windows)
    [Documentation]    Check whether the keyboard backlight function key works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR010.301 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    VAR    ${step4_msg}=
    ...    Press the keyboard backlight hotkey 6 times and note the effect on the
    ...    keyboard backlight after each keypress.
    ...    separator=${SPACE}
    Execute Manual Step    [4/4] ${step4_msg}
    VAR    ${result_msg}=
    ...    The keyboard has 6 backlight settings from 0% to 100% Each keypress should
    ...    set the keyboard to the next mode, with the last mode wrapping back around to the first.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR011.301 Keyboard (function key: volume down) in OS (Windows)
    [Documentation]    Check whether the volume down function key works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR011.301 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the volume down hotkey once and note the effects.
    VAR    ${result_msg}=
    ...    Pressing the hotkey should decrease the volume of the currently enabled audio output.
    ...    Each key press should cause a volume down notification to appear in the upper left part of the screen.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR012.301 Keyboard (function key: volume up) in OS (Windows)
    [Documentation]    Check whether the volume up function key works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR012.301 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the volume down hotkey once and note the effects.
    VAR    ${result_msg}=
    ...    Pressing the hotkey should increase the volume of the currently enabled audio output.
    ...    Each key press should cause a volume up notification to appear in the upper left part of the screen.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR013.301 Keyboard (function key: display switch) in OS (Windows)
    [Documentation]    Check whether the display switch function key works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR013.301 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the display switch hotkey once and note the effect.
    VAR    ${result_msg}=
    ...    Pressing the hotkey should cause the display settings bar to appear
    ...    on the right part of the screen.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR014.301 Keyboard (function key: brightness down) in OS (Windows)
    [Documentation]    Check whether the brightness down function key works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR014.301 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the brightness down hotkey once and note the effects.
    VAR    ${result_msg}=
    ...    Pressing the hotkey should decrease the brightness of the internal LCD display.
    ...    Each key press should cause a brightness down notification to appear in the top left of the screen.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR015.301 Keyboard (function key: brightness up) in OS (Windows)
    [Documentation]    Check whether the brightness up function key works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR015.301 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the brightness up hotkey once and note the effects.
    VAR    ${result_msg}=
    ...    Pressing the hotkey should increase the brightness of the internal LCD display.
    ...    Each key press should cause a brightness up notification to appear in the top left of the screen.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR016.301 Keyboard (function key: camera on/off) in OS (Windows)
    [Documentation]    Check whether the camera on/off function key works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR016.301 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Open the `Camera` app.
    VAR    ${step5_msg}=
    ...    Press the camera on/off hotkey twice and note the effect after
    ...    a few seconds after the keypress.
    ...    separator=${SPACE}
    Execute Manual Step    [5/5] ${step5_msg}
    VAR    ${result_msg}=
    ...    Pressing the hotkey once should make the camera image disappear.
    ...    Pressing the hotkey again should make the camera image appear again after a few seconds.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR017.301 Keyboard (function key: flight mode) in OS (Windows)
    [Documentation]    Check whether the flight mode function key works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR017.301 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the camera on/off hotkey twice and note the effect after the key press.
    VAR    ${result_msg}=
    ...    Pressing the hotkey once should enable airplane mode and cause
    ...    `airplane mode on` notification to appear in the top right part of the screen.
    ...    Pressing the hotkey again should disable airplane mode and cause
    ...    `airplane mode off` notification to appear in the top right part of the screen.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR018.301 Keyboard (function key: sleep) in OS (Windows)
    [Documentation]    Check whether the sleep function key works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR018.301 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Wait 30 seconds for the system to load fully.
    Execute Manual Step    [5/5] Press the sleep hotkey once and note the result.
    VAR    ${result_msg}=
    ...    The laptop should go to sleep within seconds of the hotkey being pressed.
    ...    The power LED should be blinking green, indicating the laptop is sleeping.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR019.301 Buttons (button: power) in OS (Windows)
    [Documentation]    Check whether the power button works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR019.301 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Wait 30 seconds for the system to load fully.
    Execute Manual Step    [5/5] Press the power button once and note the result.
    VAR    ${result_msg}=
    ...    Pressing the button once should make laptop enter sleep mode.
    ...    The power LED should be blinking green, indicating the laptop is sleeping.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR020.301 Buttons (button: lid switch) in OS (Windows)
    [Documentation]    Check whether the lid switch works correctly in Windows OS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR020.301 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Wait 30 seconds for the system to load fully.
    Execute Manual Step    [5/5] Close the lid and note the effect on the power LED.
    VAR    ${result_msg}=
    ...    Pressing the button once should make laptop enter sleep mode.
    ...    The power LED should be blinking green, indicating the laptop is sleeping.
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR025.301 Permanent keyboard illumination after cold boot (Windows)
    [Documentation]    Check whether keyboard illumination persists at the same level after a cold boot in Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR025.301 not supported
    Execute Manual Step    [1/9] Power on the DUT.
    Execute Manual Step    [2/9] Boot into the `OPERATING_SYSTEM`.
    Execute Manual Step    [3/9] Log into the `OPERATING_SYSTEM` by using the proper login and password.
    Execute Manual Step    [4/9] Set keyboard brightness and color to arbitrary settings.
    Execute Manual Step    [5/9] Disconnect power source, and remove battery if present.
    Execute Manual Step    [6/9] Connect power and battery again.
    Execute Manual Step    [7/9] Power on the DUT.
    Execute Manual Step    [8/9] Boot into the `OPERATING_SYSTEM`.
    Execute Manual Step    [9/9] Log into the `OPERATING_SYSTEM` by using the proper login and password.
    Execute Manual Step    [Expected result] After cold-boot keyboard brightness and colors settings remain the same.

ECR026.301 Permanent keyboard illumination after warm boot (Windows)
    [Documentation]    Check whether keyboard illumination persists at the same level after a warm boot in Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR026.301 not supported
    Execute Manual Step    [1/8] Power on the DUT.
    Execute Manual Step    [2/8] Boot into the `OPERATING_SYSTEM`.
    Execute Manual Step    [3/8] Log into the `OPERATING_SYSTEM` by using the proper login and password.
    Execute Manual Step    [4/8] Set keyboard brightness and color to arbitrary settings.
    Execute Manual Step    [5/8] Power off the DUT using power button.
    Execute Manual Step    [6/8] Power on the DUT.
    Execute Manual Step    [7/8] Boot into the `OPERATING_SYSTEM`.
    Execute Manual Step    [8/8] Log into the `OPERATING_SYSTEM` by using the proper login and password.
    Execute Manual Step    [Expected result] After warm-boot keyboard brightness and colors settings remain the same.

ECR027.301 Permanent keyboard illumination after reboot (Windows)
    [Documentation]    Check whether keyboard illumination persists at the same level after a system reboot in Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR027.301 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Set keyboard brightness and color to arbitrary settings.
    Execute Manual Step    [5/5] Reboot the device executing in PowerShell: `Restart-Computer`
    Execute Manual Step    [Expected result] After reboot keyboard brightness and colors settings remain the same.

ECR028.301 Permanent keyboard illumination after suspension (Windows)
    [Documentation]    Check whether keyboard illumination persists at the same level after suspension in Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR028.301 not supported
    Execute Manual Step    [1/6] Power on the DUT.
    Execute Manual Step    [2/6] Boot into the system.
    Execute Manual Step    [3/6] Log into the system by using the proper login and password.
    Execute Manual Step    [4/6] Set keyboard brightness and color to arbitrary settings.
    Execute Manual Step    [5/6] Suspend the DUT using `SUSPEND_KEY`.
    Execute Manual Step    [6/6] Wake the device from suspend pressing any key on keyboard.
    Execute Manual Step    [Expected result] After suspend keyboard brightness and colors settings remain the same.

ECR029.301 FnLock Hotkey (Windows)
    [Documentation]    Check whether the FnLock hotkey works correctly in Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR029.301 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Use `FN_LOCK_KEY` to activate Fn lock functionality.
    Execute Manual Step    [5/5] Test function keys `F1` - `F12` and note the results.
    Execute Manual Step    [Expected result] The function keys `F1` - `F12` behave as if `Fn` key is pressed.

ECR030.301 Soft Switch Microphone Key (Windows)
    [Documentation]    Check whether the soft switch microphone key works correctly in Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR030.301 not supported
    Execute Manual Step    [1/6] Power on the DUT.
    Execute Manual Step    [2/6] Boot into the system.
    Execute Manual Step    [3/6] Log into the system by using the proper login and password.
    Execute Manual Step    [4/6] Go to `Settings` -> `System` -> `Sound`
    Execute Manual Step    [5/6] Observe the bar located on the mic volume slider
    Execute Manual Step    [6/6] Press the `Fn+4` combination at will
    VAR    ${result_msg}=
    ...    The Fn+4 should toggle the mic ON and OFF and it should be seen on the
    ...    aforementioned bar which state is currently active as the noise made will
    ...    make the bar go back and forth if ON and completely still if OFF
    ...    separator=${SPACE}
    Execute Manual Step    [Expected result] ${result_msg}

ECR031.301 Keyboard (function key: RGB keyboard toggle) in OS (Windows)
    [Documentation]    Check whether the RGB keyboard toggle hotkey works correctly in Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR031.301 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the RGB keyboard toggle hotkey twice and note the result each time.

ECR032.301 RGB keyboard next color FN key in OS (Windows)
    [Documentation]    Check whether the RGB keyboard next color FN key works correctly in Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR032.301 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step
    ...    [4/4] Press the RGB keyboard color hotkey repeatedly until the keyboard cycles through all color modes.
    Execute Manual Step
    ...    [Expected result] Pressing the button once should switch the keyboard color. All color modes according to product documentation should be accessible.

ECR033.301 RGB keyboard brightness down FN key in OS (Windows)
    [Documentation]    Check whether the RGB keyboard brightness down FN key works correctly in Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR033.301 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the RGB keyboard brightness down hotkey and note the result.
    Execute Manual Step    [Expected result] Pressing the button once should lower the keyboard backlight.

ECR034.201 RGB keyboard brightness up FN key in OS (Windows)
    [Documentation]    Check whether the RGB keyboard brightness up FN key works correctly in Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR034.301 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Press the RGB keyboard brightness up hotkey and note the result.
    Execute Manual Step    [Expected result] Pressing the button once should increase the keyboard backlight.

SIO001.301 PS/2 mouse in OS - (Windows)
    [Documentation]    Check whether the PS/2 mouse works correctly in Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SIO001.301 not supported
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Verify that the cursor can be moved with the PS/2 mouse and that clicking works.
    Execute Manual Step    [Expected result] Moving the cursor and clicking working correctly in the operating system.

SIO002.301 PS/2 keyboard in OS (Windows)
    [Documentation]    Check whether the PS/2 keyboard works correctly in Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SIO002.301 not supported
    Execute Manual Step    [1/8] Power on the DUT.
    Execute Manual Step    [2/8] Boot into the system.
    Execute Manual Step    [3/8] Log into the system by using the proper login and password.
    Execute Manual Step    [4/8] Open notepad and test the alphanumeric keys and note the generated characters.
    Execute Manual Step    [5/8] Test non-alphanumeric keys and verify that they generate the signs.
    Execute Manual Step    [6/8] Test key combinations with the Shift, and Alt modifier keys.
    Execute Manual Step
    ...    [7/8] Open On-Screen Keyboard and press Ctrl key on the hardware keyboard. Check if On-Screen Keyboard correctly highlights it.
    Execute Manual Step    [8/8] Open Start menu and press Esc. Check if Start menu is properly closed.
    Execute Manual Step
    ...    [Expected result] All standard keyboard keys generate correct characters or actions when pressed. Key combinations are detected correctly.

SIO003.301 PS/2 keyboard wake in OS (Windows)
    [Documentation]    Check whether the PS/2 keyboard can wake the platform from sleep in Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SIO003.301 not supported
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Suspend the system to RAM.
    Execute Manual Step    [5/5] Press a keyboard key to wake the platform.
    Execute Manual Step    [Expected result] Platform is resuming to the OS from sleep after pressing the key.


*** Keywords ***
Keyboard Function Key Brightness Down In Linux
    [Documentation]    Check whether function key: brightness down works in
    ...    Linux OS.
    Turn On ACPI CALL Module In Linux
    ${max_brightness}=    Get Maximum Brightness In Linux
    Set Brightness In Linux    ${max_brightness}
    ${brightness1}=    Get Current Brightness In Linux
    Brightness Down Button In Linux
    ${brightness2}=    Get Current Brightness In Linux
    Should Be True    ${brightness2} < ${brightness1}

Keyboard Function Key Brightness Up In Linux
    [Documentation]    Check whether function key: brightness up works in
    ...    Linux OS.
    Turn On ACPI CALL Module In Linux
    Set Brightness In Linux    0
    ${brightness1}=    Get Current Brightness In Linux
    Brightness Up Button In Linux
    ${brightness2}=    Get Current Brightness In Linux
    Should Be True    ${brightness2} > ${brightness1}

Keyboard Function Key Camera OnOff In Linux
    [Documentation]    Check whether the camera on/off hotkey works correctly.
    Turn On ACPI CALL Module In Linux
    ${out}=    List Devices In Linux    usb
    Should Contain Any    ${out}    Camera    BisonCam
    Toggle Camera In Linux
    ${out}=    List Devices In Linux    usb
    Should Not Contain Any    ${out}    Camera    BisonCam
    Toggle Camera In Linux
    ${out}=    List Devices In Linux    usb
    Should Contain Any    ${out}    Camera    BisonCam

Keyboard Function Key Flight Mode In Linux
    [Documentation]    Check whether function key: flight mode works in
    ...    Linux OS.
    Turn On ACPI CALL Module In Linux
    ${wifi_status}=    Get WiFi Block Status
    ${bt_status}=    Get Bluetooth Block Status
    Should Be True    ${wifi_status} == False
    Should Be True    ${bt_status} == False
    Toggle Flight Mode In Linux
    ${wifi_status}=    Get WiFi Block Status
    ${bt_status}=    Get Bluetooth Block Status
    Should Be True    ${wifi_status} == True
    Should Be True    ${bt_status} == True
    Toggle Flight Mode In Linux
    ${wifi_status}=    Get WiFi Block Status
    ${bt_status}=    Get Bluetooth Block Status
    Should Be True    ${wifi_status} == False
    Should Be True    ${bt_status} == False

Charging Until 98% Level In Linux
    [Documentation]    Check whether the DUT stops charging the battery when the
    ...    98% threshold is reached.
    Sonoff On
    Charge Battery Until Target Level In Linux    98
    Sonoff Off
    Check Charging State Not Charging In Linux

Not Charging Between 95% And 98% In Linux
    [Documentation]    Check whether the DUT does not charge the battery when
    ...    the charge level is between 95% and 98%.
    ${percentage}=    Check Battery Percentage In Linux
    IF    ${percentage} < 95
        Sonoff On
        Charge Battery Until Target Level In Linux    96
        Sonoff Off
        Sleep    5
        Sonoff On
        Check Charging State Not Charging In Linux
    ELSE
        Sonoff Off
        Sleep    5
        Sonoff On
        Check Charging State Not Charging In Linux
    END
