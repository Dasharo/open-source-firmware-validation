*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
UTC004.001 USB Type-C Display output (semi-automatic)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    Skip If    not ${usb_type_c_display_support}    UTC004.001 not supported
    Power On
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    usb
    Should Contain    ${out}    ${clevo_usb_c_hub}
    Exit from root user
