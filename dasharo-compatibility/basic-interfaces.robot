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
BI001.001 Check serial output
    [Documentation]    Check if the device can be booted and anything can be
    ...    read from serial.
    Skip If    not ${CUSTOM_BOOT_MENU_KEY_SUPPORT}    CBK001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBK001.001 not supported
    Power On
    Sleep    3s
    ${out}=    Read From Terminal
    Should Not Be Empty    ${out}
    RteCtrl Relay
    # Clear the output
    Read From Terminal
    # Make sure that nothing is being printed after the DUT is turned off
    ${out}=    Read From Terminal
    Should Be Empty    ${out}
