*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../keywords.robot
Resource            ../lib/bios/menus.robot
Resource            ../variables.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../sonoff-rest-api/sonoff-api.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
SOR001.001 Check that all options in OptionROMs are available
    [Documentation]    This test checks if all OptionROM options are available
    Power On
    Enter Dasharo System Features
    ${menu_construction}=    Enter Submenu And Return Its Construction    PCIPCIe Configuration
    ${list_content}=    Read Option List Contents    ${menu_construction}    OptionROM Execution Policy
    Should Contain    ${list_content}    Disable all OptionROMs loading
    Should Contain    ${list_content}    Enable all OptionROMs loading
    Should Contain    ${list_content}    Enable OptionROM loading only on GPUs
