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
SPM001.201 2x S0ix suspend cycle (Battery) (Ubuntu)
    [Documentation]    Check whether 2 consecutive S0ix suspend cycles work correctly on battery in Ubuntu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SPM001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SPM001.201 not supported
    Execute Manual Step    [1/4] Boot into Ubuntu with AC disconnected (battery only)
    Execute Manual Step    [2/4] Trigger S0ix suspend twice and resume each time
    Execute Manual Step    [3/4] Check dmesg for S0ix-related messages after each resume
    Execute Manual Step    [4/4] Confirm both S0ix suspend cycles complete successfully without errors

SPM001.301 2x S0ix suspend cycle (Battery) (Windows)
    [Documentation]    Check whether 2 consecutive S0ix suspend cycles work correctly on battery in Windows.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SPM001.301 not supported
    Execute Manual Step    [1/4] Boot into Windows with AC disconnected (battery only)
    Execute Manual Step    [2/4] Trigger sleep (S0ix) twice and resume each time
    Execute Manual Step    [3/4] Check the Event Viewer for sleep/resume events
    Execute Manual Step    [4/4] Confirm both S0ix suspend cycles complete successfully without errors

SPM002.201 2x S0ix suspend cycle (AC) (Ubuntu)
    [Documentation]    Check whether 2 consecutive S0ix suspend cycles work correctly on AC power in Ubuntu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SPM002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SPM002.201 not supported
    Execute Manual Step    [1/4] Boot into Ubuntu with AC power connected
    Execute Manual Step    [2/4] Trigger S0ix suspend twice and resume each time
    Execute Manual Step    [3/4] Check dmesg for S0ix-related messages after each resume
    Execute Manual Step    [4/4] Confirm both S0ix suspend cycles complete successfully without errors

SPM002.301 2x S0ix suspend cycle (AC) (Windows)
    [Documentation]    Check whether 2 consecutive S0ix suspend cycles work correctly on AC power in Windows.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SPM002.301 not supported
    Execute Manual Step    [1/4] Boot into Windows with AC power connected
    Execute Manual Step    [2/4] Trigger sleep (S0ix) twice and resume each time
    Execute Manual Step    [3/4] Check the Event Viewer for sleep/resume events
    Execute Manual Step    [4/4] Confirm both S0ix suspend cycles complete successfully without errors

SPM003.201 2x S3 suspend cycle (Battery) (Ubuntu)
    [Documentation]    Check whether 2 consecutive S3 suspend cycles work correctly on battery in Ubuntu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SPM003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SPM003.201 not supported
    Execute Manual Step    [1/4] Boot into Ubuntu with AC disconnected (battery only)
    Execute Manual Step    [2/4] Trigger S3 suspend twice and resume each time
    Execute Manual Step    [3/4] Check dmesg for S3-related messages after each resume
    Execute Manual Step    [4/4] Confirm both S3 suspend cycles complete successfully without errors

SPM003.301 2x S3 suspend cycle (Battery) (Windows)
    [Documentation]    Check whether 2 consecutive S3 suspend cycles work correctly on battery in Windows.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SPM003.301 not supported
    Execute Manual Step    [1/4] Boot into Windows with AC disconnected (battery only)
    Execute Manual Step    [2/4] Trigger S3 sleep twice and resume each time
    Execute Manual Step    [3/4] Check the Event Viewer for sleep/resume events
    Execute Manual Step    [4/4] Confirm both S3 suspend cycles complete successfully without errors

SPM003.203 2x S3 suspend cycle (Battery) (Qubes OS)
    [Documentation]    Check whether 2 consecutive S3 suspend cycles work correctly on battery in Qubes OS.
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SPM003.203 not supported
    Execute Manual Step    [1/4] Boot into Qubes OS with AC disconnected (battery only)
    Execute Manual Step    [2/4] Trigger S3 suspend twice and resume each time
    Execute Manual Step    [3/4] Check dmesg for S3-related messages after each resume
    Execute Manual Step    [4/4] Confirm both S3 suspend cycles complete successfully without errors

SPM004.201 2x S3 suspend cycle (AC) (Ubuntu)
    [Documentation]    Check whether 2 consecutive S3 suspend cycles work correctly on AC power in Ubuntu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SPM004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SPM004.201 not supported
    Execute Manual Step    [1/4] Boot into Ubuntu with AC power connected
    Execute Manual Step    [2/4] Trigger S3 suspend twice and resume each time
    Execute Manual Step    [3/4] Check dmesg for S3-related messages after each resume
    Execute Manual Step    [4/4] Confirm both S3 suspend cycles complete successfully without errors

SPM004.301 2x S3 suspend cycle (AC) (Windows)
    [Documentation]    Check whether 2 consecutive S3 suspend cycles work correctly on AC power in Windows.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SPM004.301 not supported
    Execute Manual Step    [1/4] Boot into Windows with AC power connected
    Execute Manual Step    [2/4] Trigger S3 sleep twice and resume each time
    Execute Manual Step    [3/4] Check the Event Viewer for sleep/resume events
    Execute Manual Step    [4/4] Confirm both S3 suspend cycles complete successfully without errors

SPM004.203 2x S3 suspend cycle (AC) (Qubes OS)
    [Documentation]    Check whether 2 consecutive S3 suspend cycles work correctly on AC power in Qubes OS.
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SPM004.203 not supported
    Execute Manual Step    [1/4] Boot into Qubes OS with AC power connected
    Execute Manual Step    [2/4] Trigger S3 suspend twice and resume each time
    Execute Manual Step    [3/4] Check dmesg for S3-related messages after each resume
    Execute Manual Step    [4/4] Confirm both S3 suspend cycles complete successfully without errors

SPM005.201 2x warmboot cycle (Battery) (Ubuntu)
    [Documentation]    Check whether 2 consecutive warm boot cycles work correctly on battery in Ubuntu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SPM005.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SPM005.201 not supported
    Execute Manual Step    [1/4] Boot into Ubuntu with AC disconnected (battery only)
    Execute Manual Step    [2/4] Perform 2 warm boot cycles (reboot) and verify the system comes back up each time
    Execute Manual Step    [3/4] Check system logs for any boot errors
    Execute Manual Step    [4/4] Confirm both warm boot cycles complete successfully without errors

SPM005.301 2x warmboot cycle (Battery) (Windows)
    [Documentation]    Check whether 2 consecutive warm boot cycles work correctly on battery in Windows.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SPM005.301 not supported
    Execute Manual Step    [1/4] Boot into Windows with AC disconnected (battery only)
    Execute Manual Step    [2/4] Perform 2 warm boot cycles (restart) and verify the system comes back up each time
    Execute Manual Step    [3/4] Check the Event Viewer for boot errors
    Execute Manual Step    [4/4] Confirm both warm boot cycles complete successfully without errors

SPM005.203 2x warmboot cycle (Battery) (Qubes OS)
    [Documentation]    Check whether 2 consecutive warm boot cycles work correctly on battery in Qubes OS.
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SPM005.203 not supported
    Execute Manual Step    [1/4] Boot into Qubes OS with AC disconnected (battery only)
    Execute Manual Step    [2/4] Perform 2 warm boot cycles (reboot) and verify the system comes back up each time
    Execute Manual Step    [3/4] Check dmesg for boot errors
    Execute Manual Step    [4/4] Confirm both warm boot cycles complete successfully without errors

SPM006.201 2x warmboot cycle (AC) (Ubuntu)
    [Documentation]    Check whether 2 consecutive warm boot cycles work correctly on AC power in Ubuntu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SPM006.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SPM006.201 not supported
    Execute Manual Step    [1/4] Boot into Ubuntu with AC power connected
    Execute Manual Step    [2/4] Perform 2 warm boot cycles (reboot) and verify the system comes back up each time
    Execute Manual Step    [3/4] Check system logs for any boot errors
    Execute Manual Step    [4/4] Confirm both warm boot cycles complete successfully without errors

SPM006.301 2x warmboot cycle (AC) (Windows)
    [Documentation]    Check whether 2 consecutive warm boot cycles work correctly on AC power in Windows.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SPM006.301 not supported
    Execute Manual Step    [1/4] Boot into Windows with AC power connected
    Execute Manual Step    [2/4] Perform 2 warm boot cycles (restart) and verify the system comes back up each time
    Execute Manual Step    [3/4] Check the Event Viewer for boot errors
    Execute Manual Step    [4/4] Confirm both warm boot cycles complete successfully without errors

SPM006.203 2x warmboot cycle (AC) (Qubes OS)
    [Documentation]    Check whether 2 consecutive warm boot cycles work correctly on AC power in Qubes OS.
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SPM006.203 not supported
    Execute Manual Step    [1/4] Boot into Qubes OS with AC power connected
    Execute Manual Step    [2/4] Perform 2 warm boot cycles (reboot) and verify the system comes back up each time
    Execute Manual Step    [3/4] Check dmesg for boot errors
    Execute Manual Step    [4/4] Confirm both warm boot cycles complete successfully without errors
