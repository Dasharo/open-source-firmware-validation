*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
CBK001.001 Custom boot menu key
    [Documentation]    Check whether the DUT is configured properly to use
    ...    custom boot menu hotkey.
    Skip If    not ${custom_boot_menu_key_support}    CBK001.001 not supported
    Skip If    not ${tests_in_firmware_support}    CBK001.001 not supported
    Power On
    Enter Boot Menu

CBK002.001 Custom setup menu key
    [Documentation]    Check whether the DUT is configured properly to use
    ...    custom setup menu hotkey.
    Skip If    not ${custom_setup_menu_key_support}    CBK002.001 not supported
    Skip If    not ${tests_in_firmware_support}    CBK002.001 not supported
    Power On
    Enter Setup Menu Tianocore
