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
SHT001.001 SATA hot plug (firmware)
    [Documentation]    Check whether SATA hot plug works correctly during firmware execution.
    Execute Manual Step    [1/4] Power on the DUT and enter the firmware setup menu or observe POST
    Execute Manual Step    [2/4] Hot-plug a SATA device while the firmware is running
    Execute Manual Step    [3/4] Navigate to the boot device list or storage configuration
    Execute Manual Step    [4/4] Confirm the hot-plugged SATA device is detected in the firmware

SHT001.201 SATA hot plug (Ubuntu)
    [Documentation]    Check whether SATA hot plug works correctly in Ubuntu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SHT001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SHT001.201 not supported
    Execute Manual Step    [1/4] Boot into Ubuntu
    Execute Manual Step    [2/4] Hot-plug a SATA device while Ubuntu is running
    Execute Manual Step    [3/4] Run: lsblk or dmesg | tail to verify the SATA device is detected
    Execute Manual Step    [4/4] Confirm the hot-plugged SATA device is visible and accessible in Ubuntu

SHT001.301 SATA hot plug (Windows)
    [Documentation]    Check whether SATA hot plug works correctly in Windows.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SHT001.301 not supported
    Execute Manual Step    [1/4] Boot into Windows
    Execute Manual Step    [2/4] Hot-plug a SATA device while Windows is running
    Execute Manual Step    [3/4] Open Disk Management or File Explorer to check for the new device
    Execute Manual Step    [4/4] Confirm the hot-plugged SATA device is detected and accessible in Windows
