*** Settings ***
Documentation       This suite verifies the correct operation of keywords
...                 reading out the boot manager when populated with multiple
...                 entries and must be scroleld through

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
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
Enter Boot Menu
    [Documentation]    Test Enter Boot Menu kwd
    Prepare EFI Partition With System Files
    Power On
    ${boot_menu}=    Enter Boot Menu And Return Construction
    ${no_entries}=    Get Length    ${boot_menu}
    Should Be True    ${no_entries} > 11
