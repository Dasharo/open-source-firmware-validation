*** Settings ***
Documentation       This suite verifies the correct operation of keywords
...                 entering and parsing Boot Menu, Setup Menu, and top-level submenus
...                 of the Setup Menu.

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
    Enter Boot Menu
    ${out}=    Read From Terminal Until    exit
    Should Contain    ${out}    Please select boot device:

Enter Boot Menu Tianocore And Return Construction
    [Documentation]    Test Enter Boot Menu kwd
    Power On
    ${menu}=    Enter Boot Menu And Return Construction
    List Should Not Contain Value    ${menu}    Please select boot device:
    List Should Contain Value    ${menu}    Setup
    Menu Construction Should Not Contain Control Text    ${menu}

Enter Setup Menu
    [Documentation]    Test Enter Setup Menu Tianocore kwd
    Power On
    Enter Setup Menu
    ${out}=    Read From Terminal Until    Select Entry
    Should Contain    ${out}    Select Language

Enter Setup Menu And Return Construction
    [Documentation]    Test Get Setup Menu Construction kwd
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    # First entry should be always language selection
    Should Be Equal As Strings    ${setup_menu}[0]    Select Language <Standard English>
    # Two last entris should be: Continue, Reset
    Should Be Equal As Strings    ${setup_menu}[-2]    Continue
    # Last entry should be always: Reset
    Should Be Equal As Strings    ${setup_menu}[-1]    Reset
    # These should always be present, with no particular order
    List Should Contain Value    ${setup_menu}    > Device Manager
    List Should Contain Value    ${setup_menu}    > Dasharo System Features
    List Should Contain Value    ${setup_menu}    > One Time Boot
    List Should Contain Value    ${setup_menu}    > Boot Maintenance Manager
    Menu Construction Should Not Contain Control Text    ${setup_menu}

Enter User Password Management Menu
    [Documentation]    Test entering into User Password Management menu
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    Enter Submenu From Snapshot    ${setup_menu}    User Password Management
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    Password Management

Parse User Password Management Menu
    [Documentation]    Test entering into User Password Management menu
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${password_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    User Password Management
    Should Match Regexp    ${password_menu}[0]    ^Admin Password Status .*$
    Should Be Equal As Strings    ${password_menu}[1]    Change Admin Password
    ${password_menu_entries}=    Get Length    ${password_menu}
    Should Be Equal As Integers    ${password_menu_entries}    2
    Menu Construction Should Not Contain Control Text    ${password_menu}

Enter Device Manager Menu
    [Documentation]    Test entering into User Password Management menu
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    Enter Submenu From Snapshot    ${setup_menu}    Device Manager
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    Device Manager
    Should Contain    ${out}    Device Manager
    Should Contain    ${out}    Devices List
    Should Contain    ${out}    Press ESC to exit.

Parse Device Manager Menu
    [Documentation]    Test entering into User Password Management menu
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${device_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Should Not Contain    ${device_menu}[0]    Devices List
    List Should Contain Value    ${device_menu}    > Driver Health Manager
    List Should Contain Value    ${device_menu}    Press ESC to exit.
    Menu Construction Should Not Contain Control Text    ${device_menu}

Enter Secure Boot Menu
    [Documentation]    Test entering into User Password Management menu
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${device_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Enter Submenu From Snapshot    ${device_menu}    Secure Boot Configuration
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    Secure Boot Configuration
    Should Contain    ${out}    Current Secure Boot State

Enter One Time Boot Menu
    [Documentation]    Test entering into User Password Management menu
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    Enter Submenu From Snapshot    ${setup_menu}    One Time Boot
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    One Time Boot

Parse One Time Boot Menu
    [Documentation]    Test entering into User Password Management menu
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${otb_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    One Time Boot
    List Should Contain Value    ${otb_menu}    UEFI Shell
    Menu Construction Should Not Contain Control Text    ${otb_menu}

Enter Boot Maintenance Manager Menu
    [Documentation]    Test entering into User Password Management menu
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    Enter Submenu From Snapshot    ${setup_menu}    Boot Maintenance Manager
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    Boot Maintenance Manager

Parse Boot Maintenance Manager Menu
    [Documentation]    Test entering into User Password Management menu
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${boot_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Boot Maintenance Manager
    Should Be Equal As Strings    ${boot_mgr_menu}[0]    > Boot Options
    Should Be Equal As Strings    ${boot_mgr_menu}[1]    > Driver Options
    Should Be Equal As Strings    ${boot_mgr_menu}[2]    > Console Options
    Should Be Equal As Strings    ${boot_mgr_menu}[3]    > Boot From File
    Should Match Regexp    ${boot_mgr_menu}[4]    ^Boot Next Value <.*>$
    Should Match Regexp    ${boot_mgr_menu}[5]    ^Auto Boot Time-out \\[\\d+\\]$
    Menu Construction Should Not Contain Control Text    ${boot_mgr_menu}

Enter Invalid Option in Setup Menu
    [Documentation]    Test if keyword fails (rather than silently continuing) when
    ...    not existing submenu was given.
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    Run Keyword And Return Status
    ...    Enter Submenu From Snapshot And Return Construction    ${setup_menu}    Not Existing Submenu

Test TianoCore Reset System
    Power On
    Enter Setup Menu Tianocore And Return Construction
    Tianocore Reset System
    Enter Setup Menu Tianocore And Return Construction

Test Exit From Current Menu
    [Documentation]    Test Exit From Current Menu kwd
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${setup_menu}    Device Manager

    FOR    ${i}    IN RANGE    0    20
        Exit From Current Menu
        ${setup_menu}=    Get Setup Menu Construction
        Should Not Contain    ${setup_menu}    > Secure Boot Configuration
        Should Contain    ${setup_menu}    > Dasharo System Features
        Should Contain    ${setup_menu}    > One Time Boot
        Press Enter
    END
