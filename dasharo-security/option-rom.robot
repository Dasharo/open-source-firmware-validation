# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../keywords.robot
Resource            ../lib/bios/menus.robot
Resource            ../variables.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
SOR001.001 Check that all options in OptionROMs are available
    [Documentation]    This test checks if all OptionROM options are available
    Skip If    not ${DASHARO_PCI_PCIE_MENU_SUPPORT}    SOR001.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${menu_construction}=    Enter Dasharo Submenu    ${dasharo_menu}    PCI/PCIe Configuration
    Enter Submenu From Snapshot    ${menu_construction}    OptionROM Execution Policy
    ${out}=    Read From Terminal Until    ---/
    Log    ${out}
    ${opts}=    Extract Strings From Frame    ${out}
    Log    ${opts}
    Should Be Equal As Strings    ${opts}[0]    Disable all OptionROMs loading
    Should Be Equal As Strings    ${opts}[1]    Enable all OptionROMs loading
    Should Be Equal As Strings    ${opts}[2]    Enable OptionROM loading only on GPUs
