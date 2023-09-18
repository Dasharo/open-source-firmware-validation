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
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
DET001.001 Ethernet connection (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    Ubuntu 22.04.
    Skip If    not ${docking_station_net_interface}    DET001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DET001.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Check Internet Connection on Linux
    Exit from root user

DET001.001 Ethernet connection (Windows 11)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    Windows 11.
    Skip If    not ${docking_station_net_interface}    DET001.002 not supported
    Skip If    not ${tests_in_windows_support}    DET001.002 not supported
    Power On
    Login to Windows
    Check Internet Connection on Windows
