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
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
TDP001.001 - Docking station HDMI display in OS (Ubuntu 20.04)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly recognized by the
    ...    OPERATING_SYSTEM.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_HDMI}    TDP001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TDP001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Check Docking Station HDMI In Linux
    Exit From Root User

TDP001.002 - Docking station HDMI display in OS (Windows 11)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly recognized by the
    ...    OPERATING_SYSTEM.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_HDMI}    TDP001.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TDP001.002 not supported
    Power On
    Login To Windows
    Check Docking Station HDMI Windows

TDP002.001 - Docking station DP display in OS (Ubuntu 20.04)
    [Documentation]    This test aims to verify that the display connected with
    ...    the DisplayPort cable to the docking station is correctly recognized
    ...    by the OPERATING_SYSTEM.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_DISPLAY_PORT}    TDP002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TDP002.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Check Docking Station DP In Linux
    Exit From Root User

TDP002.002 - Docking station DP display in OS (Windows 11)
    [Documentation]    This test aims to verify that the display connected with
    ...    the DisplayPort cable to the docking station is correctly recognized
    ...    by the OPERATING_SYSTEM.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_DISPLAY_PORT}    TDP002.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TDP002.002 not supported
    Power On
    Login To Windows
    Check Docking Station DP Windows
