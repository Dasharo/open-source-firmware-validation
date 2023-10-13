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
Enter Boot Menu Tianocore
    [Documentation]    Test Enter Boot Menu kwd
    Power On
    Enter Boot Menu Tianocore
    ${out}=    Read From Terminal Until    exit
    Should Contain    ${out}    Please select boot device:

Enter Boot Menu Tianocore And Return Construction
    [Documentation]    Test Enter Boot Menu kwd
    Power On
    ${menu}=    Enter Boot Menu Tianocore And Return Construction
    List Should Not Contain Value    ${menu}    Please select boot device:
    List Should Contain Value    ${menu}    Setup

Enter Setup Menu Tianocore
    [Documentation]    Test Enter Setup Menu Tianocore kwd
    Power On
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    Select Entry
    Should Contain    ${out}    Select Language

Enter Setup Menu Tianocore And Return Construction
    [Documentation]    Test Get Setup Menu Construction kwd
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    # First entry should be always language selection
    Should Be Equal As Strings    ${setup_menu}[0]    Select Language <Standard English>
    # The next entries should not start with ">" (it should be stripped)
    Should Not Contain    ${setup_menu}[1]    >
    Should Not Contain    ${setup_menu}[2]    >
    # Two last entris should be: Continue, Reset
    Should Be Equal As Strings    ${setup_menu}[-2]    Continue
    # Last entry should be always: Reset
    Should Be Equal As Strings    ${setup_menu}[-1]    Reset
    # These should always be present, with no particular order
    List Should Contain Value    ${setup_menu}    Device Manager
    List Should Contain Value    ${setup_menu}    Dasharo System Features
    List Should Contain Value    ${setup_menu}    One Time Boot
    List Should Contain Value    ${setup_menu}    Boot Maintenance Manager

Enter User Password Management Menu
    [Documentation]    Test entering into User Password Management menu
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Enter Setup Menu Option From Snapshot    ${setup_menu}    User Password Management
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    Password Management

Parse User Password Management Menu
    [Documentation]    Test entering into User Password Management menu
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${password_menu}=    Enter Setup Menu Option From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    User Password Management
    Should Be Equal As Strings    ${password_menu}[0]    Admin Password Status Not Installed
    Should Be Equal As Strings    ${password_menu}[1]    Change Admin Password
    ${password_menu_entries}=    Get Length    ${password_menu}
    Should Be Equal As Integers    ${password_menu_entries}    2

# Enter Dasharo System Features
#    [Documentation]    Test Enter Dasharo System Features Submenu kwd
#    Power On
#    Enter Dasharo System Features
#    ${out}=    Read From Terminal Until    Esc=Exit
#    Should Contain    ${out}    Dasharo System Features
#
# Enter Device Manager Submenu
#    [Documentation]    Test Enter Device Manager Submenu kwd
#    Power On
#    Enter Setup Menu Tianocore
#    Enter Device Manager Submenu
#    ${out}=    Read From Terminal Until    Esc=Exit
#    Should Contain    ${out}    Device Manager
#
# # TODO: fix this kwd
# # Enter Secure Boot Configuration Submenu
# #    [Documentation]    Test Enter Secure Boot Configuration Submenu kwd
# #    Power On
# #    Enter Setup Menu Tianocore
# #    Enter Secure Boot Configuration Submenu
# #    ${out}=    Read From Terminal Until    Esc=Exit
# #    Should Contain    ${out}    Secure Boot Configuration
