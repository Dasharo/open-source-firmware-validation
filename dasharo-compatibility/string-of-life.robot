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
SOL001.001 SOL string shows Dasharo firmware and EC version
    [Documentation]    Check whether the String of Life (SOL) shows the correct
    ...    Dasharo firmware version and EC version.
    Execute Manual Step    [1/3] Power on the DUT and observe the firmware boot messages
    Execute Manual Step
    ...    [2/3] Look for the String of Life output (firmware version string) in the boot log or UEFI setup
    Execute Manual Step    [3/3] Confirm the SOL string displays the correct Dasharo firmware version and EC version

SOL002.001 SOL string shows information about proprietary EC
    [Documentation]    Check whether the String of Life (SOL) shows the correct
    ...    information about the proprietary EC.
    Execute Manual Step    [1/3] Power on the DUT and observe the firmware boot messages
    Execute Manual Step
    ...    [2/3] Look for the String of Life output (firmware version string) in the boot log or UEFI setup
    Execute Manual Step    [3/3] Confirm the SOL string displays the correct information about the proprietary EC
