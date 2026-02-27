*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Variables ***
${FUM_DIALOG_TOP}=          Update Mode. All firmware write protections are disabled in this mode.
${FUM_DIALOG_BOTTOM}=       The platform will automatically reboot and disable Firmware Update Mode


*** Test Cases ***
FUM000.101 Firmware Update Mode works
    [Documentation]    Check if Firmware Update Mode works
    Skip If    "${OPTIONS_LIB}" == "options-lib_dcu"
    Power On
    # Enable FUM
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Enter Submenu From Snapshot    ${security_menu}    Enter Firmware Update Mode
    Read From Terminal Until    Press ENTER to continue and reboot
    Press Enter
    Wait For FUM Dialog And Confirm


*** Keywords ***
Wait For FUM Dialog And Confirm
    [Documentation]    Wait for FUM dialog to show and then confirm by pressing
    ...    expected key
    Read From Terminal Until    ${FUM_DIALOG_TOP}
    ${out}=    Read From Terminal Until    ${FUM_DIALOG_BOTTOM}
    ${digit}=    Get Key To Press    ${out}
    Write Bare Into Terminal    ${digit}

Get Key To Press
    [Arguments]    ${text}
    ${matches}=    Get Regexp Matches    ${text}    [0-9]
    VAR    ${digit}=    ${matches[0]}
    Log    Found digit: ${digit}
    RETURN    ${digit}
