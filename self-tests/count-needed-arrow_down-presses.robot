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
    ...    correctly. Make sure that "Attempt PPI Version" is set to 1.3
    ...    The best way to check this test is to observe bios in QEMU.
    Log To Console    Make sure that "Attempt PPI Version" is set to 1.3
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_manager_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Enter Submenu From Snapshot
    ...    ${device_manager_menu}
    ...    TCG2 Configuration
    ${target_option_index}=    Search For Option Not Visible After Entering Menu    Attempt PPI Version    re_enter=${FALSE}
    Reenter Menu
    Press Key N Times And Enter    ${target_option_index}    ${ARROW_DOWN}
    Press Key N Times And Enter    1    ${ARROW_UP}
    Reenter Menu
    ${target_option_index}=    Search For Option Not Visible After Entering Menu    Attempt PPI Version    re_enter=${TRUE}
    Reenter Menu
    Press Key N Times And Enter    ${target_option_index}    ${ARROW_DOWN}
    Press Key N Times And Enter    1    ${ARROW_DOWN}

Search For Option Visible At First Menu Entrance
    [Documentation]    Chcesks if the Key Word "Search For Option Not Visible After Entering Menu" returns
    ...   a proper message when the searched option is visible at first menu entrance.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_manager_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Enter Submenu From Snapshot
    ...    ${device_manager_menu}
    ...    TCG2 Configuration
    ${target_option_index}=    Run Keyword And Ignore Error
    ...    Search For Option Not Visible After Entering Menu    Attempt TPM Device    re_enter=${FALSE}
    ${wxpected_result}=    Evaluate    ('FAIL', 'This option is visible after entering the menu. Use another Key Word.')
    Should Be Equal    ${target_option_index}    ${wxpected_result}

Search Option In Menu Smaller Than 11 Entries
    [Documentation]    Chcesks if the Key Word "Search For Option Not Visible After Entering Menu" returns
    ...   a proper message when the searched option is visible at first menu entrance.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_manager_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    ${target_option_index}=    Search For Option Not Visible After Entering Menu    TCG2 Configuration    re_enter=${TRUE}
    Press Key N Times And Enter    ${target_option_index}    ${ARROW_DOWN}
    # ${TPMmenu}=    Get Boot Menu Construction
    ${TPMmenu}=    Get Menu Construction    checkpoint=Esc=Exit
    Should Contain    ${TPMmenu}    Current TPM Device TPM 2.0
