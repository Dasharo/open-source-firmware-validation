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
BBB001.001 Boot blocking (charger disconnected) (Ubuntu 22.04)
    [Documentation]    Discharge the battery to below 5% and check if booting is
    ...    blocked.
    IF    not ${tests_in_ubuntu_support}    SKIP    BBB001.001 not supported
    IF    not ${boot_blocking_support}    SKIP    BBB001.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Sonoff Power Off
    Discharge the battery until target level in Linux    3
    Execute Command In Terminal    reboot

BBB001.002 Boot blocking (charger connected) (Ubuntu 22.04)
    [Documentation]    Discharge the battery to below 5% and check if booting is
    ...    blocked.
    IF    not ${tests_in_ubuntu_support}    SKIP    BBB001.001 not supported
    IF    not ${boot_blocking_support}    SKIP    BBB001.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Sonoff Power Off
    Discharge the battery until target level in Linux    3
    Sonoff Power On
    Execute Command In Terminal    reboot
