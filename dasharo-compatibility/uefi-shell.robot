*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
Library             ../../lib/TestingStands.py
Resource            ../keywords/setup-keywords.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot
Resource            ../sonoff-rest-api/sonoff-api.robot

Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
USH001.001 UEFI Shell
    [Documentation]    Check whether the DUT has the ability to boot into an
    ...    integrated UEFI Shell application.
    Skip If    not ${tests_in_firmware_support}    USH001.001 not supported
    Skip If    not ${uefi_shell_support}    USH001.001 not supported
    Power On
    Enter Boot Menu Tianocore
    Enter UEFI Shell Tianocore
    Read From Terminal Until    UEFI Interactive Shell v2.2
