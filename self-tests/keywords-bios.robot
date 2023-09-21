*** Settings ***
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
Enter Boot Menu
    [Documentation]    Test Enter Boot Menu kwd
    Power On
    Enter Boot Menu
    ${out}=    Read From Terminal Until    exit
    Should Contain    ${out}    Please select boot device:

Enter Setup Menu Tianocore
    [Documentation]    Test Enter Setup Menu Tianocore kwd
    Power On
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    Select Entry
    Should Contain    ${out}    Select Language

Get Setup Menu Construction
    [Documentation]    Test Get Setup Menu Construction kwd
    Power On
    Enter Setup Menu Tianocore
    ${menu_construction}=    Get Setup Menu Construction
    # TODO: Fix kwd so it does not unnecessarily remove 1st character in these
    # First entry should be always language selection
    Should Be Equal As Strings    ${menu_construction}[0]    elect Language Standard English
    # The next entries should not start with ">" (it should be stripped)
    Should Not Contain    ${menu_construction}[1]    >
    Should Not Contain    ${menu_construction}[2]    >
    # Two last entris should be: Continue, Reset
    Should Be Equal As Strings    ${menu_construction}[-2]    ontinue
    # Last entry should be always: Reset
    Should Be Equal As Strings    ${menu_construction}[-1]    eset

Enter Dasharo System Features
    [Documentation]    Test Enter Dasharo System Features Submenu kwd
    Power On
    Enter Dasharo System Features
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    Dasharo System Features

Enter Device Manager Submenu
    [Documentation]    Test Enter Device Manager Submenu kwd
    Power On
    Enter Setup Menu Tianocore
    Enter Device Manager Submenu
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    Device Manager

# TODO: fix this kwd
# Enter Secure Boot Configuration Submenu
#    [Documentation]    Test Enter Secure Boot Configuration Submenu kwd
#    Power On
#    Enter Setup Menu Tianocore
#    Enter Secure Boot Configuration Submenu
#    ${out}=    Read From Terminal Until    Esc=Exit
#    Should Contain    ${out}    Secure Boot Configuration
