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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
DAU001.001 Audio recognition (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into the
    ...    docking station.
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    DUD001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DUD001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${EXTERNAL_HEADSET}
    Exit From Root User
