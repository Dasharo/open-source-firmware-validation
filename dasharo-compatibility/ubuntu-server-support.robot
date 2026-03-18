*** Settings ***
Library             Dialogs
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
USS001.002 Boot Ubuntu Server stable from Hard Disk
    [Documentation]    Check whether Ubuntu Server stable can be booted from the hard disk on the DUT.
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Press BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [3/4] In the Boot Menu, select the device on which the system was previously installed.
    Execute Manual Step    [4/4] Wait for the OPERATING_SYSTEM to boot and note the result.
    Execute Manual Step    [Expected result] The OPERATING_SYSTEM login screen should be displayed.
