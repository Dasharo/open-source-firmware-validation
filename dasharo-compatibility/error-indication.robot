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
ERR001.001 SATA LED and PC speaker error indication support (firmware)
    [Documentation]    Check whether the SATA LED and PC speaker error indication
    ...    works correctly during firmware execution.
    Execute Manual Step    [1/4] Power on the DUT
    Execute Manual Step    [2/4] Observe the SATA LED and listen for PC speaker beeps during POST
    Execute Manual Step    [3/4] If possible, trigger an error condition (e.g. remove RAM or storage device)
    Execute Manual Step    [4/4] Confirm that the SATA LED and/or PC speaker provides the expected error indication

ERR002.001 PC speaker beep during boot (firmware)
    [Documentation]    Check whether the PC speaker emits the expected beep during
    ...    normal firmware boot.
    Execute Manual Step    [1/3] Power on the DUT
    Execute Manual Step    [2/3] Listen for the PC speaker beep during POST
    Execute Manual Step    [3/3] Confirm that the PC speaker emits the expected beep code during normal boot

SPK001.001 SATA LED and PC speaker error indication support (firmware)
    [Documentation]    Check whether the SATA LED and PC speaker error indication
    ...    works correctly during firmware execution.
    Execute Manual Step    [1/4] Power on the DUT
    Execute Manual Step    [2/4] Observe the SATA LED and listen for PC speaker beeps during POST
    Execute Manual Step
    ...    [3/4] If possible, trigger an error condition (e.g. remove RAM or storage device) and observe
    Execute Manual Step    [4/4] Confirm that the SATA LED and/or PC speaker provides the expected error indication
