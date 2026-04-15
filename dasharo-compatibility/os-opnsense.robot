*** Settings ***
Library             Collections
Library             DateTime
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# Log Out And Close Connection - elementary teardown keyword for all tests.
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    '${ENV_ID_OPNSENSE}' not in ${TESTED_BSD_DISTROS}    OPNSense tests not supported
Suite Teardown      Run Keywords
...                     Log Out And Close Connection
Test Setup          Run Keyword
...                     Restore Initial DUT Connection Method


*** Test Cases ***
OPN002.001 OPNSense stable (VGA output) installation on Hard Disk
    [Documentation]    Check whether OPNSense stable with VGA output can be installed on the hard disk.
    [Tags]    semiauto
    Execute Manual Step    [1/5] Prepare an OPNSense stable installation medium (USB)
    Execute Manual Step    [2/5] Power on the DUT and boot from the OPNSense installation medium
    Execute Manual Step    [3/5] Follow the OPNSense installer steps to complete the installation on the hard disk
    Execute Manual Step    [4/5] Reboot after installation completes
    Execute Manual Step    [5/5] Confirm OPNSense boots successfully from the hard disk via VGA output

OPN002.002 Boot OPNSense stable (VGA output) from Hard Disk
    [Documentation]    Check whether OPNSense stable with VGA output boots correctly from the hard disk.
    [Tags]    semiauto
    Execute Manual Step    [1/3] Power on the DUT with OPNSense installed on the hard disk
    Execute Manual Step    [2/3] Wait for OPNSense to boot
    Execute Manual Step    [3/3] Confirm OPNSense boots to the console/login screen via VGA output

OPN001.503 Install operating system on disk (OPNSense)
    [Documentation]    Install OPNSense (serial output) from preseeded
    ...    USB stick on disk. Make sure to use linux fatlabel command
    ...    to rename installer ESP to OPNBOOT. Next, please refer to
    ...    scripts/freebsd/preseed_opnsense.sh for OPNSense installer
    ...    modification.
    ...
    [Tags]    semiauto
    Power On
    Boot OPNSense Installer
    VAR    ${installer_message}=
    ...    Click OK,
    ...    after test execution ends,
    ...    connect to DUT via serial and continue manual installation.
    ...    separator=${SPACE}
    Pause Execution    ${installer_message}

OPN002.503 Boot operating system from disk (OPNSense)
    [Documentation]    Boot OPNSense (serial output) from disk.
    ...
    Power On
    Boot OPNSense

OPN003.503 Boot operating system from disk after cold-boot (OPNSense)
    [Documentation]    Boot OPNSense (serial output) from disk after cold-boot
    ...
    VAR    @{supported_power_ctrls}=    RteCtrl    sonoff
    Skip If    '${POWER_CTRL}' not in ${supported_power_ctrls}
    Execute Cold Boot
    ${start_date}=    Get Current Date
    Boot OPNSense
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Cold boot duration in seconds: ${delta_time}

OPN004.503 Boot operating system from disk after warm-boot (OPNSense)
    [Documentation]    Boot OPNSense (serial output) from disk after warm-boot
    ...
    Power On
    Boot OPNSense
    Enter OPNSense Shell
    Write Into Terminal    poweroff
    Power On
    ${start_date}=    Get Current Date
    Boot OPNSense
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Warm boot duration in seconds: ${delta_time}

OPN005.503 Boot operating system from disk after reboot (OPNSense)
    [Documentation]    Boot OPNSense (serial output) from disk after reboot
    ...
    Power On
    Boot OPNSense
    Enter OPNSense Shell
    Write Into Terminal    reboot
    ${start_date}=    Get Current Date
    Boot OPNSense
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Reboot duration in seconds: ${delta_time}
