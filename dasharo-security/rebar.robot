*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../keywords.robot
Resource            ../lib/bios/menus.robot
Resource            ../variables.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
RBE001.001 Check if Resizeable BARs option is present
    [Documentation]    This test checks that Resizable BAR option is available
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RBE001.001 not supported
    Skip If    not ${DASHARO_PCI_PCIE_MENU_SUPPORT}    RBE001.001 not supported
    Skip If    not ${DASHARO_PCIE_REBAR_SUPPORT}    RBE001.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${pci_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    PCI/PCIe Configuration
    Should Contain Match    ${pci_menu}    Enable PCIe Resizeable*
