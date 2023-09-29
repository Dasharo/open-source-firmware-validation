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
RBE001.001 Check if Resizeable BARs option is present
    [Documentation]    This test checks that Resizable BAR option is available
    Power On
    Enter Dasharo System Features
    ${menu_construction}=    Enter Submenu And Return Its Construction    PCIPCIe Configuration
    Should Contain    ${menu_construction}    Enable PCIe Resizeable
