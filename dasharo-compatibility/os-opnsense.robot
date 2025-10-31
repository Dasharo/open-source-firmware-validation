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
...                     Skip If    '${ENV_ID_OPNSENSE}' not in ${TESTED_BSD_DISTROS}    OPNsense tests not supported
Suite Teardown      Run Keywords
...                     Log Out And Close Connection
Test Setup          Run Keyword
...                     Restore Initial DUT Connection Method


*** Test Cases ***
OPN001.503 Install operating system on disk (OPNsense)
    [Documentation]    Install OPNsense (serial output) from preseeded
    ...    USB stick on disk. Make sure to use linux fatlabel command
    ...    to rename installer ESP to OPNBOOT. Next, please refer to
    ...    scripts/freebsd/preseed_opnsense.sh for OPNsense installer
    ...    modification.
    ...
    ...    Previous IDs: OPN001.001
    [Tags]    semiauto
        Power On Ex    force_reboot=${TRUE}
    Boot OPNsense Installer
    VAR    ${installer_message}=
    ...    Click OK,
    ...    after test execution ends,
    ...    connect to DUT via serial and continue manual installation.
    ...    separator=${SPACE}
    Pause Execution    ${installer_message}

OPN002.503 Boot operating system from disk (OPNsense)
    [Documentation]    Boot OPNsense (serial output) from disk.
    ...
    ...    Previous IDs: OPN001.002
    Power On Ex    force_reboot=${TRUE}
    Boot OPNsense

OPN003.503 Boot operating system from disk after cold-boot (OPNsense)
    [Documentation]    Boot OPNsense (serial output) from disk after cold-boot
    ...
    ...    Previous IDs: BOS001.001
    VAR    @{supported_power_ctrls}=    RteCtrl    sonoff
    Skip If    '${POWER_CTRL}' not in ${supported_power_ctrls}
    Execute Cold Boot
    ${start_date}=    Get Current Date
    Boot OPNsense
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Cold boot duration in seconds: ${delta_time}

OPN004.503 Boot operating system from disk after warm-boot (OPNsense)
    [Documentation]    Boot OPNsense (serial output) from disk after warm-boot
    ...
    ...    Previous IDs: BOS002.001
    Power On Ex    force_reboot=${TRUE}
    Boot OPNsense
    Enter OPNsense Shell
    Write Into Terminal    poweroff
    Power On Ex    force_reboot=${TRUE}
    ${start_date}=    Get Current Date
    Boot OPNsense
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Warm boot duration in seconds: ${delta_time}

OPN005.503 Boot operating system from disk after reboot (OPNsense)
    [Documentation]    Boot OPNsense (serial output) from disk after reboot
    ...
    ...    Previous IDs: BOS003.001
    Power On Ex    force_reboot=${TRUE}
    Boot OPNsense
    Enter OPNsense Shell
    Write Into Terminal    reboot
    ${start_date}=    Get Current Date
    Boot OPNsense
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Reboot duration in seconds: ${delta_time}
