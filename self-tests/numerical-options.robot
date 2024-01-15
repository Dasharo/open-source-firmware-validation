*** Settings ***
Documentation       This suite verifies the correct operation of keywords
...                 getting and setting state of numerical options.

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
Set numerical option
    [Documentation]    Checks whether the numerical option can be set.
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${chipset_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Chipset Configuration
    Set Option State    ${chipset_menu}    Watchdog timeout value    600
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${chipset_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Chipset Configuration
    ${state}=    Get Option State    ${chipset_menu}    Watchdog timeout value
    Log    ${state}
    Should Be Equal As Integers    ${state}    600
