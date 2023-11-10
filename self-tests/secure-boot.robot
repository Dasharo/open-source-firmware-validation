*** Settings ***
Documentation       This suite verifies the correct operation of keywords parsing Secure Boot menus from the lib/secure-boot-lib.robot.

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
Enter Secure Boot Menu
    [Documentation]    Test Enter Secure Boot Menu kwd
    Power On
    Enter Secure Boot Menu
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    Secure Boot Configuration
    Should Contain    ${out}    Current Secure Boot State

Enter Secure Boot Menu And Return Construction
    [Documentation]    Test Enter Secure Boot Menu And Return Construction kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Should Not Contain    ${sb_menu}    Secure Boot Configuration
    Should Match Regexp    ${sb_menu}[0]    ^Current Secure Boot State.*$
    Should Match Regexp    ${sb_menu}[-1]    ^Secure Boot Mode \\<.*\\>.*$
    Should Not Contain    ${sb_menu}    To enable Secure Boot, set Secure Boot Mode to
    Should Not Contain    ${sb_menu}    Custom and enroll the keys/PK first.

Enter Advanced Secure Boot Keys Management
    [Documentation]    Test Enter Advanced Secure Boot Keys Management kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enter Advanced Secure Boot Keys Management    ${sb_menu}
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    Advanced Secure Boot Keys Management
    Should Contain    ${out}    Reset to default Secure Boot Keys
    Should Contain    ${out}    Erase all Secure Boot Keys

Reset To Default Secure Boot Keys
    [Documentation]    Test Reset To Default Secure Boot Keys kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enter Advanced Secure Boot Keys Management    ${sb_menu}
    Reset To Default Secure Boot Keys
    Save Changes And Reset    3

    Enter Secure Boot Menu
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Not Contain    ${out}    To enable Secure Boot, set Secure Boot Mode to
    Should Not Contain    ${out}    Custom and enroll the keys/PK first.

Erase All Secure Boot Keys
    [Documentation]    Test Erase All Secure Boot Keys kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enter Advanced Secure Boot Keys Management    ${sb_menu}
    Erase All Secure Boot Keys
    Save Changes And Reset    3

    Enter Secure Boot Menu
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    To enable Secure Boot, set Secure Boot Mode to
    Should Contain    ${out}    Custom and enroll the keys/PK first.

Secure Boot Menu Parsing With Default Keys
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enter Advanced Secure Boot Keys Management    ${sb_menu}
    Reset To Default Secure Boot Keys
    Save Changes And Reset    3

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Should Not Contain    ${sb_menu}    Secure Boot Configuration
    Should Match Regexp    ${sb_menu}[0]    ^Current Secure Boot State.*$
    Should Match Regexp    ${sb_menu}[1]    ^Enable Secure Boot \\[.\\].*$
    Should Match Regexp    ${sb_menu}[2]    ^Secure Boot Mode \\<.*\\>.*$
    Should Not Contain    ${sb_menu}    To enable Secure Boot, set Secure Boot Mode to
    Should Not Contain    ${sb_menu}    Custom and enroll the keys/PK first.

Secure Boot Menu Parsing With Erased Keys
    [Documentation]    Test Enter Secure Boot Menu And Return Construction kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enter Advanced Secure Boot Keys Management    ${sb_menu}
    Erase All Secure Boot Keys
    Reset To Default Secure Boot Keys
    Save Changes And Reset    3

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Should Not Contain    ${sb_menu}    Secure Boot Configuration
    Should Match Regexp    ${sb_menu}[0]    ^Current Secure Boot State.*$
    Should Match Regexp    ${sb_menu}[1]    ^Secure Boot Mode \\<.*\\>.*$
    Should Not Contain    ${sb_menu}    To enable Secure Boot, set Secure Boot Mode to
    Should Not Contain    ${sb_menu}    Custom and enroll the keys/PK first.

Return Secure Boot State
    [Documentation]    Test Return Secure Boot State kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${sb_state}=    Return Secure Boot State    ${sb_menu}
    Should Contain Any    ${sb_state}    Enabled    Disabled

# TODO: This fails with: Option Enable Secure Boot not found in the list
# if the keys were not provisioned first. The question is, should we "hide"
# restoring keys to default in the keywords like enable/disable SB, or the
# test scenarios should rather take care of this?

Enable Secure Boot
    [Documentation]    Test Enable Secure Boot kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Set Option State    ${sb_menu}    Enable Secure Boot    ${TRUE}
    Save Changes And Reset    2

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${sb_state}=    Return Secure Boot State    ${sb_menu}
    Should Contain    ${sb_state}    Enabled

Disable Secure Boot
    [Documentation]    Test Disable Secure Boot kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Set Option State    ${sb_menu}    Enable Secure Boot    ${FALSE}
    Save Changes And Reset    2

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${sb_state}=    Return Secure Boot State    ${sb_menu}
    Should Contain    ${sb_state}    Disabled

Enable and Disable Secure Boot Multiple Times
    [Documentation]    Test Enabling and Disabling Secure Boot 5 times
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    FOR    ${index}    IN RANGE    5
        Set Option State    ${sb_menu}    Enable Secure Boot    ${TRUE}
        Save Changes And Reset    2

        ${sb_menu}=    Enter Secure Boot Menu And Return Construction
        ${sb_state}=    Return Secure Boot State    ${sb_menu}
        Should Contain    ${sb_state}    Enabled

        Set Option State    ${sb_menu}    Enable Secure Boot    ${FALSE}
        Save Changes And Reset    2

        ${sb_menu}=    Enter Secure Boot Menu And Return Construction
        ${sb_state}=    Return Secure Boot State    ${sb_menu}
        Should Contain    ${sb_state}    Disabled
    END
