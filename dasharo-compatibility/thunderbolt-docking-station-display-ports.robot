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
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
TDP001.001 - Docking station HDMI display in OS (Ubuntu 20.04)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly recognized by the
    ...    OPERATING_SYSTEM.
    Skip If    not ${thunderbolt_docking_station_hdmi}    TDP001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    TDP001.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Check docking station HDMI in Linux
    Exit from root user

TDP001.002 - Docking station HDMI display in OS (Windows 11)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly recognized by the
    ...    OPERATING_SYSTEM.
    Skip If    not ${thunderbolt_docking_station_hdmi}    TDP001.002 not supported
    Skip If    not ${tests_in_windows_support}    TDP001.002 not supported
    Power On
    Login to Windows
    Check docking station HDMI Windows

TDP002.001 - Docking station DP display in OS (Ubuntu 20.04)
    [Documentation]    This test aims to verify that the display connected with
    ...    the DisplayPort cable to the docking station is correctly recognized
    ...    by the OPERATING_SYSTEM.
    Skip If    not ${thunderbolt_docking_station_display_port}    TDP002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    TDP002.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Check docking station DP in Linux
    Exit from root user

TDP002.002 - Docking station DP display in OS (Windows 11)
    [Documentation]    This test aims to verify that the display connected with
    ...    the DisplayPort cable to the docking station is correctly recognized
    ...    by the OPERATING_SYSTEM.
    Skip If    not ${thunderbolt_docking_station_display_port}    TDP002.002 not supported
    Skip If    not ${tests_in_windows_support}    TDP002.002 not supported
    Power On
    Login to Windows
    Check docking station DP Windows
