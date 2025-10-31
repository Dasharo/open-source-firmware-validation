*** Settings ***
Documentation       This suite verifies the correct operation of the keyword
...                 "Search For Option Not Visible After Entering Menu"

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

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
Search For Option Not Visible After Entering Menu - Test
    [Documentation]    Chcesks if the Key Word "Search For Option Not Visible After Entering Menu" works
    ...    correctly.
    Power On Ex    force_reboot=${TRUE}
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_manager_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Enter Submenu From Snapshot
    ...    ${device_manager_menu}
    ...    TCG2 Configuration
    ${target_option_index}=    Search For Option Not Visible After Entering Menu
    ...    Attempt PPI Version
    ...    re_enter=${FALSE}
    ${second_target_option_index}=    Search For Option Not Visible After Entering Menu
    ...    Attempt PPI Version
    ...    re_enter=${TRUE}
    Should Be Equal    ${target_option_index}    ${second_target_option_index}

Search For Option Visible At First Menu Entrance
    [Documentation]    Chcesks if the Key Word "Search For Option Not Visible After Entering Menu" returns
    ...    a proper message when the searched option is visible at first menu entrance.
    Power On Ex    force_reboot=${TRUE}
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_manager_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Enter Submenu From Snapshot
    ...    ${device_manager_menu}
    ...    TCG2 Configuration
    ${target_option_index}=    Run Keyword And Ignore Error
    ...    Search For Option Not Visible After Entering Menu    Attempt TPM Device    re_enter=${FALSE}
    ${expected_result}=    Evaluate
    ...    ('FAIL', 'This option is visible after entering the menu. Use another keyword.')
    Should Be Equal    ${target_option_index}    ${expected_result}

Search Option In Menu Smaller Than 11 Entries
    [Documentation]    Chcesks if the Key Word "Search For Option Not Visible After Entering Menu" returns
    ...    a proper message when the searched option is visible at first menu entrance.
    Power On Ex    force_reboot=${TRUE}
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_manager_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    ${target_option_index}=    Search For Option Not Visible After Entering Menu
    ...    TCG2 Configuration
    ...    re_enter=${TRUE}
    Press Key N Times And Enter    ${target_option_index}    ${ARROW_DOWN}
    ${tpm_menu}=    Get Menu Construction    checkpoint=Esc=Exit
    Should Contain    ${tpm_menu}    Current TPM Device TPM 2.0
