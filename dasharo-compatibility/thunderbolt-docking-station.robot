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
TDS001.001 Thunderbolt laptop charging (Ubuntu 22.04)
    [Documentation]    Check whether the DUT can be charged using a PD power
    ...    supply connected to the docking station, which is connected to the
    ...    Thunderbolt port.
    Skip If    not ${thunderbolt_docking_station_support}    TDS001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    TDS001.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Check charging state in Linux
    Exit from root user

TDS001.002 Thunderbolt laptop charging (Windows 11)
    [Documentation]    Check whether the DUT can be charged using a PD power
    ...    supply connected to the docking station, which is connected to the
    ...    Thunderbolt port.
    Skip If    not ${thunderbolt_docking_station_support}    TDS001.002 not supported
    Skip If    not ${tests_in_windows_support}    TDS001.002 not supported
    Power On
    Login to Windows
    Check charging state in Windows
