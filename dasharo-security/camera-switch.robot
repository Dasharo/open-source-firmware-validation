*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${CAMERA_SWITCH_SUPPORT}    Camera switch not supported
...                     AND
...                     Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}    Dasharo Security menu not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
CHS001.001 Check camera enablement
    [Documentation]    This test makes sure that camera enable option
    ...    is set, hence the camera works properly
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${security_menu}    Enable Camera    ${TRUE}
    Save Changes And Reset
    Login To Linux
    ${webcam}=    Check The Presence Of Webcam
    Should Be True    ${webcam}

CHS002.001 Check camera disablement
    [Documentation]    This test makes sure that camera enable option
    ...    is not set, hence the camera is not detected by operating system
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${security_menu}    Enable Camera    ${FALSE}
    Save Changes And Reset
    Login To Linux
    ${webcam}=    Check The Presence Of Webcam
    Should Not Be True    ${webcam}


*** Keywords ***
Check The Presence Of Webcam
    [Documentation]    Checks if webcam is visible for operating system
    ...    Returns True if presence is detected
    ${terminal_result}=    Execute Command In Terminal    lsusb | grep '${WEBCAM_UBUNTU}'
    ${result}=    Run Keyword And Return Status
    ...    Should Not Be Empty    ${terminal_result}
    RETURN    ${result}
