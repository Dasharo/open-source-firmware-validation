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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
FAN001.001 CPU fan speed measure
    [Documentation]    Check whether there's a possibility to measure CPU fan
    ...    current speed.
    Skip If    not ${FAN_SPEED_MEASURE_SUPPORT}    FAN001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FAN001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Prepare Sensors
    ${output}=    Get Fan RPM
    Should Not Be Empty    ${output}
    Should Not Be Equal    ${output}    0
