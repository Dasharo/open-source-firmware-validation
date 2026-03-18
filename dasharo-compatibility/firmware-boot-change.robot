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

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
FBC101.001 Switch from Legacy to UEFI
    [Documentation]    Check whether the firmware can be switched from Legacy boot mode to UEFI boot mode.
    Execute Manual Step    [1/4] Power on the DUT and enter the firmware setup menu
    Execute Manual Step    [2/4] Navigate to the boot settings and switch from Legacy to UEFI mode
    Execute Manual Step    [3/4] Save the settings and reboot the DUT
    Execute Manual Step    [4/4] Confirm the DUT boots successfully in UEFI mode

FBC102.001 Switch from UEFI to Legacy
    [Documentation]    Check whether the firmware can be switched from UEFI boot mode to Legacy boot mode.
    Execute Manual Step    [1/4] Power on the DUT and enter the firmware setup menu
    Execute Manual Step    [2/4] Navigate to the boot settings and switch from UEFI to Legacy mode
    Execute Manual Step    [3/4] Save the settings and reboot the DUT
    Execute Manual Step    [4/4] Confirm the DUT boots successfully in Legacy mode

FBC001.201 Ubuntu stays bootable (Legacy to UEFI) (Ubuntu)
    [Documentation]    Check whether Ubuntu remains bootable after switching from Legacy to UEFI boot mode.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Execute Manual Step    [1/5] Boot into Ubuntu in Legacy mode and verify it works
    Execute Manual Step    [2/5] Enter the firmware setup menu and switch from Legacy to UEFI mode
    Execute Manual Step    [3/5] Save the settings and reboot the DUT
    Execute Manual Step    [4/5] Attempt to boot into Ubuntu in UEFI mode
    Execute Manual Step    [5/5] Confirm that Ubuntu boots successfully after the Legacy to UEFI switch

FBC002.503 OPNSense stays bootable (Legacy to UEFI) (OPNSense)
    [Documentation]    Check whether OPNSense remains bootable after switching from Legacy to UEFI boot mode.
    Skip If    '${ENV_ID_OPNSENSE}' not in ${TESTED_BSD_DISTROS}
    Execute Manual Step    [1/5] Boot into OPNSense in Legacy mode and verify it works
    Execute Manual Step    [2/5] Enter the firmware setup menu and switch from Legacy to UEFI mode
    Execute Manual Step    [3/5] Save the settings and reboot the DUT
    Execute Manual Step    [4/5] Attempt to boot into OPNSense in UEFI mode
    Execute Manual Step    [5/5] Confirm that OPNSense boots successfully after the Legacy to UEFI switch

FBC003.502 pfSense stays bootable (Legacy to UEFI) (pfSense)
    [Documentation]    Check whether pfSense remains bootable after switching from Legacy to UEFI boot mode.
    Skip If    '${ENV_ID_PFSENSE}' not in ${TESTED_BSD_DISTROS}
    Execute Manual Step    [1/5] Boot into pfSense in Legacy mode and verify it works
    Execute Manual Step    [2/5] Enter the firmware setup menu and switch from Legacy to UEFI mode
    Execute Manual Step    [3/5] Save the settings and reboot the DUT
    Execute Manual Step    [4/5] Attempt to boot into pfSense in UEFI mode
    Execute Manual Step    [5/5] Confirm that pfSense boots successfully after the Legacy to UEFI switch

FBC004.207 OpenWrt stays bootable (Legacy to UEFI) (OpenWrt)
    [Documentation]    Check whether OpenWrt remains bootable after switching from Legacy to UEFI boot mode.
    Skip If    '${ENV_ID_OPENWRT}' not in ${TESTED_LINUX_DISTROS}
    Execute Manual Step    [1/5] Boot into OpenWrt in Legacy mode and verify it works
    Execute Manual Step    [2/5] Enter the firmware setup menu and switch from Legacy to UEFI mode
    Execute Manual Step    [3/5] Save the settings and reboot the DUT
    Execute Manual Step    [4/5] Attempt to boot into OpenWrt in UEFI mode
    Execute Manual Step    [5/5] Confirm that OpenWrt boots successfully after the Legacy to UEFI switch
