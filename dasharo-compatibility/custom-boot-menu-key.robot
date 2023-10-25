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
<<<<<<< HEAD
    Enter Boot Menu Tianocore
=======
    Enter Boot Menu
    Read From Terminal Until    Please select boot device:
>>>>>>> 960df35b38fa (fix: dasharo-compatibility/custom-boot-menu-key.robot)

CBK002.001 Custom setup menu key
    [Documentation]    Check whether the DUT is configured properly to use
    ...    custom setup menu hotkey.
    Skip If    not ${CUSTOM_SETUP_MENU_KEY_SUPPORT}    CBK002.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBK002.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Read From Terminal Until    <Enter>=Select Entry
