*** Settings ***
Documentation       This suite verifies the correct operation of keywords
...                 getting and setting state of boolean options.

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
Set boolean option to true
    [Documentation]    Checks whether the boolean option can be set to TRUE.
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${networking_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
    Set Option State    ${networking_menu}    Enable network boot    ${TRUE}
    Save Changes And Reset    2    4

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${networking_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
    ${state}=    Get Option State    ${networking_menu}    Enable network boot
    Log    ${state}
    Should Be True    ${state}

Set boolean option to false
    [Documentation]    Checks whether the boolean option can be set to FALSE.
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${networking_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
    Set Option State    ${networking_menu}    Enable network boot    ${FALSE}
    Save Changes And Reset    2    4

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${networking_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
    ${state}=    Get Option State    ${networking_menu}    Enable network boot
    Log    ${state}
    Should Not Be True    ${state}

Toggle boolean option 3 times
    [Documentation]    Checks whether the boolean option can be toggled
    ...    FALSE/TRUE 3 times in a rew.
    Power On

    FOR    ${iterations}    IN RANGE    0    2
        ${setup_menu}=    Enter Setup Menu And Return Construction
        ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
        ${networking_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
        Set Option State    ${networking_menu}    Enable network boot    ${FALSE}
        Save Changes And Reset    2    4

        ${setup_menu}=    Enter Setup Menu And Return Construction
        ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
        ${networking_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
        ${state}=    Get Option State    ${networking_menu}    Enable network boot
        Log    ${state}
        Should Not Be True    ${state}

        Set Option State    ${networking_menu}    Enable network boot    ${TRUE}
        Save Changes And Reset    2    4

        ${setup_menu}=    Enter Setup Menu And Return Construction
        ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
        ${networking_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
        ${state}=    Get Option State    ${networking_menu}    Enable network boot
        Log    ${state}
        Should Be True    ${state}

        Set Option State    ${networking_menu}    Enable network boot    ${FALSE}
        Save Changes And Reset    2    4
    END
