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
TDN001.001 Ethernet connection (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on Ubuntu 22.04.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_NET_INTERFACE}    TDN001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TDN001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Check Internet Connection On Ubuntu
    Exit From Root User

TDN001.002 Ethernet connection (Windows 11)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on Windows 11.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_NET_INTERFACE}    TDN001.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TDN001.002 not supported
    Power On
    Login To Windows
    Check Internet Connection On Windows
