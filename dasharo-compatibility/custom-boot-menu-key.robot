*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
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
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
CBK001.001 Custom boot menu key
    [Documentation]    Check whether the DUT is configured properly to use
    ...    custom boot menu hotkey.
    Skip If    not ${CUSTOM_BOOT_MENU_KEY_SUPPORT}    CBK001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBK001.001 not supported
    Power On
    Enter Boot Menu
    Read From Terminal Until    ${BOOT_MENU_STRING}

CBK002.001 Custom setup menu key
    [Documentation]    Check whether the DUT is configured properly to use
    ...    custom setup menu hotkey.
    Skip If    not ${CUSTOM_SETUP_MENU_KEY_SUPPORT}    CBK002.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBK002.001 not supported
    Power On
    Enter Setup Menu
    Read From Terminal Until    ${SETUP_MENU_STRING}
