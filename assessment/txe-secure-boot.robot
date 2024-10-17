*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# Resource    ../platform-configs/msi-pro-z690-a-ddr5.robot
# Required setup keywords:
# Prepare Test Suite - elementary setup keyword for all tests.
# Upload Required Images - uploads all required files onto the PiKVM.
# Required teardown keywords:
# Log Out And Close Connection - elementary teardown keyword for all tests.
Suite Setup         Run Keywords
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
Test Setup          Restore Initial DUT Connection Method


*** Test Cases ***
TXE001.001 Check if platform is not fused
    [Documentation]    This test aims to verify that the platform is not fused

    Power On
    Enter UEFI Shell
    Set Prompt For Terminal    FS2:\\>
    Execute UEFI Shell Command    fs2:
    ${out}=    Execute UEFI Shell Command    ls
    Should Contain    ${out}    TxeInfo.efi
    Should Contain    ${out}    FPT.efi
    Should Contain    ${out}    fparts.txt
    ${out}=    Execute UEFI Shell Command    TxeInfo.efi -VERBOSE    0.1
    ${man_mode}=    Get Lines Containing String    ${out}    ManufacturingMode:
    Should Contain    ${man_mode}    Enabled
    ${fpf}=    Get Lines Containing String    ${out}    Global Valid FPF:
    Should Contain    ${fpf}    Invalid
