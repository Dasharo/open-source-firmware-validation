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
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
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
    Write Bare Into Terminal    fs2:
    Press Enter
    Read From Terminal Until    FS2:\\>
    Write Bare Into Terminal    ls
    Press Enter
    ${out}=    Read From Terminal Until    FS2:\\>
    Should Contain    ${out}    TxeInfo.efi
    Should Contain    ${out}    FPT.efi
    Should Contain    ${out}    fparts.txt
    Write Bare Into Terminal    TxeInfo.efi -VERBOSE    0.1
    Press Enter
    ${out}=    Read From Terminal Until    ManufacturingMode
    ${out}=    Read From Terminal Until    \n
    Should Contain    ${out}    Enabled
    ${out}=    Read From Terminal Until    Global Valid FPF:
    ${out}=    Read From Terminal Until    \n
    Should Contain    ${out}    Invalid
