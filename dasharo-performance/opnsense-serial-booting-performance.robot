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
...                     AND    Skip If    '${ENV_ID_OPNSENSE}' not in ${TESTED_BSD_DISTROS}
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
BOS001.503 Boot OPNSense (serial output) from disk after cold-boot (OPNSense)
    [Documentation]    This test aims to verify that OPNSense (serial output)
    ...    could be booted from the disk on the DUT after cold-boot. The test
    ...    is performed in multiple iterations.
    Execute Manual Step    [1/5] Cut the power off while DUT is turned on.
    Execute Manual Step    [2/5] Restore power and power on the DUT.
    Execute Manual Step    [3/5] Press BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step
    ...    [4/5] In the Boot Menu, select the disk on which OPNSense serial was previously installed or boot entry with the name of OPNSense.
    Execute Manual Step    [5/5] Confirm that the OPNSense login screen is displayed via serial output.

BOS002.503 Boot OPNSense (serial output) from disk after warm-boot (OPNSense)
    [Documentation]    This test aims to verify that OPNSense (serial output)
    ...    could be booted from the disk on the DUT after warm-boot. The test
    ...    is performed in multiple iterations.
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Press BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step
    ...    [3/4] In the Boot Menu, select the disk on which OPNSense serial was previously installed or boot entry with the name of OPNSense.
    Execute Manual Step    [4/4] Confirm that the OPNSense login screen is displayed via serial output.

BOS003.503 Boot OPNSense (serial output) from disk after reboot (OPNSense)
    [Documentation]    This test aims to verify that OPNSense (serial output)
    ...    could be booted from the disk on the DUT after reboot. The test is
    ...    performed in multiple iterations.
    Execute Manual Step    [1/6] Power on the DUT.
    Execute Manual Step    [2/6] Boot into the system.
    Execute Manual Step    [3/6] Log into the system by using the proper login and password.
    Execute Manual Step    [4/6] Open a terminal window and run: sudo reboot
    Execute Manual Step
    ...    [5/6] In the Boot Menu, select the disk on which OPNSense serial was previously installed or boot entry with the name of OPNSense.
    Execute Manual Step    [6/6] Confirm that the OPNSense login screen is displayed via serial output.
