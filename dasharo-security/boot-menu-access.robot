*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
BMA001.001 Boot menu enable
    [Documentation]    This test aims to verify that the boot menu can be
    ...    enabled in the firmware setup so that the user can select a boot
    ...    device at startup.
    Pause Execution    This is a manual test.
    Execute Manual Step    [1/4] Power on the DUT and enter UEFI setup.
    Execute Manual Step    [2/4] Navigate to the boot menu access settings.
    Execute Manual Step    [3/4] Enable the boot menu option and save changes.
    Execute Manual Step    [4/4] Reboot the DUT and verify the boot menu is accessible.

BMA002.001 Boot menu disable
    [Documentation]    This test aims to verify that the boot menu can be
    ...    disabled in the firmware setup so that the user cannot select a
    ...    boot device at startup.
    Pause Execution    This is a manual test.
    Execute Manual Step    [1/4] Power on the DUT and enter UEFI setup.
    Execute Manual Step    [2/4] Navigate to the boot menu access settings.
    Execute Manual Step    [3/4] Disable the boot menu option and save changes.
    Execute Manual Step    [4/4] Reboot the DUT and verify the boot menu is no longer accessible.
