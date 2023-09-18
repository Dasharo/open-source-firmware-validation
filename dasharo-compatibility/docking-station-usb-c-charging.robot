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
# NOTE:
# - Novacustom laptops do not currently support charging via USB Type-C port
# - Novacustom laptops only support charging via Thunderbolt 4 and standard
#    barrel connector


*** Test Cases ***
DUC001.001 USB Type-C laptop charging (Ubuntu 22.04)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port.
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    DUC001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DUC001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Check Charging State In Linux
    Exit From Root User

DUC001.002 USB Type-C laptop charging (Windows 11)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port.
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    DUC001.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    DUC001.002 not supported
    Power On
    Login To Windows
    Check Charging State In Windows
