*** Settings ***
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
MEM001.001 Memtest availability
    [Documentation]    Check whether the Memtest entry is available in the DUT boot menu.
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Wait until BOOT_MENU_STRING appears.
    Execute Manual Step    [3/4] Press BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [4/4] Check if Payload [memtest] is available in the boot menu.
    Execute Manual Step
    ...    [Expected result] The Payload [memtest] option should be visible as one of the boot menu options.

MEM002.001 Enter Memtest
    [Documentation]    Check whether the DUT enters Memtest from the boot menu.
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Wait for boot until BOOT_MENU_STRING appears.
    Execute Manual Step    [3/5] Press BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [4/5] Select the key with a proper number for Payload [memtest].
    Execute Manual Step    [5/5] Check if Memtest86+ is available.
    Execute Manual Step    [Expected result] The Memtest86+ is visible at the top of the output.

MEM003.001 Memtest stability
    [Documentation]    Check whether Memtest starts and does not hang on the DUT.
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Wait for boot until BOOT_MENU_STRING appears.
    Execute Manual Step    [3/5] Press BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [4/5] Select the key with a proper number for Payload [memtest].
    Execute Manual Step    [5/5] Check if State: - Running... is available.
    Execute Manual Step
    ...    [Expected result] The State: - Running... is visible after a few seconds and confirms that the test is in progress.

MEM004.001 Memtest refreshing by 'L' key
    [Documentation]    Check whether DUT refreshes Memtest properly using the L key.
    Execute Manual Step    [1/6] Power on the DUT.
    Execute Manual Step    [2/6] Wait for boot until BOOT_MENU_STRING appears.
    Execute Manual Step    [3/6] Press BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [4/6] Select the key with a proper number for BOOT_MENU_ENTRY.
    Execute Manual Step    [5/6] Press the L key.
    Execute Manual Step    [6/6] Check if L refreshes output.
    Execute Manual Step    [Expected result] The Memtest86+ is visible before and after pressing L.

MEM005.001 Memtest refreshing by 'l' key
    [Documentation]    Check whether DUT refreshes Memtest properly using the l key.
    Execute Manual Step    [1/6] Power on the DUT.
    Execute Manual Step    [2/6] Wait for boot until BOOT_MENU_STRING appears.
    Execute Manual Step    [3/6] Press BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [4/6] Select the key with a proper number for BOOT_MENU_ENTRY.
    Execute Manual Step    [5/6] Press the l key.
    Execute Manual Step    [6/6] Check if l refreshes output.
    Execute Manual Step    [Expected result] The Memtest86+ is visible before and after pressing l.

MEM006.001 Memtest completing
    [Documentation]    Check whether DUT completes Memtest without errors.
    Execute Manual Step    [1/6] Power on the DUT.
    Execute Manual Step    [2/6] Wait for boot until BOOT_MENU_STRING appears.
    Execute Manual Step    [3/6] Press BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [4/6] Select the key with a proper number for Payload [memtest].
    Execute Manual Step    [5/6] Make sure that State: - Running... is available.
    Execute Manual Step    [6/6] Wait until ** Pass complete, no errors, press Esc to exit ** appears.
    Execute Manual Step
    ...    [Expected result] After the test completes without any errors, ** Pass complete, no errors, press Esc to exit ** message is visible on the bottom of the screen.
