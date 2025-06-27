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
Suite Teardown      Run Keywords
...                     Log Out And Close Connection
Test Setup          Run Keyword
...                     Restore Initial DUT Connection Method


*** Test Cases ***
OPN001.503 Install OPNsense (serial output) on disk
    [Documentation]    Install OPNsense (serial output) from preseeded
    ...    USB stick on disk. Make sure to use linux fatlabel command
    ...    to rename installer ESP to OPNBOOT. Next, please refer to
    ...    scripts/freebsd/preseed_opnsense.sh for OPNsense installer
    ...    modification.
    Power On
    Boot OPNsense Installer
    ${installer_message}=    Catenate    Click OK,    after test execution ends,
    ...    connect to DUT via serial and continue manual installation.
    Pause Execution    ${installer_message}

OPN002.503 Boot OPNsense CE (serial output) from disk
    [Documentation]    Boot OPNsense (serial output) from disk.
    Power On
    Boot OPNsense

OPN003.503 Boot OPNsense (serial output) from disk after cold-boot
    [Documentation]    Boot OPNsense (serial output) from disk after cold-boot
    @{supported_power_ctrls}=    Create List    RteCtrl    sonoff
    Skip If    '${POWER_CTRL}' not in ${supported_power_ctrls}
    Power On
    Set UEFI Option    PowerStateAfterPowerAcLoss    Powered On
    Sleep    2
    IF    '${POWER_CTRL}' == 'RteCtrl'
        Rte Psu Off
    ELSE IF    '${POWER_CTRL}' == 'sonoff'
        Sonoff Off
    END
    Sleep    12
    IF    '${POWER_CTRL}' == 'RteCtrl'
        Rte Psu On
    ELSE IF    '${POWER_CTRL}' == 'sonoff'
        Sonoff On
    END
    ${start_date}=    Get Current Date
    Boot OPNsense
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Cold boot duration in seconds: ${delta_time}

OPN004.503 Boot OPNsense (serial output) from disk after warm-boot
    [Documentation]    Boot OPNsense (serial output) from disk after warm-boot
    Power On
    Boot OPNsense
    Enter OPNsense Shell
    Write Into Terminal    poweroff
    Power On
    ${start_date}=    Get Current Date
    Boot OPNsense
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Warm boot duration in seconds: ${delta_time}

OPN005.503 Boot OPNsense (serial output) from disk after reboot
    [Documentation]    Boot OPNsense (serial output) from disk after reboot
    Power On
    Boot OPNsense
    Enter OPNsense Shell
    Write Into Terminal    reboot
    ${start_date}=    Get Current Date
    Boot OPNsense
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Reboot duration in seconds: ${delta_time}
