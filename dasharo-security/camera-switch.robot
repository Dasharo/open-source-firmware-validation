*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
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
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
CHS001.001 Check camera enablement
    [Documentation]    This test makes sure that camera enable option
    ...    is set, hence the camera works properly
    IF    not ${camera_switch_support}    Skip

    # changing settings in UEFI is only possible using serial connection
    IF    '${dut_connection_method}' == 'Telnet'
        Power On
        Enter Dasharo System Features
        Enter submenu in Tianocore    Dasharo Security Options
        ${camera_enabled}=    Check if Tianocore setting is enabled in current menu    Enable Camera
        Press key n times    1    ${F10}
        Press key n times    1    ${ESC}
        IF    not ${camera_enabled}
            Enter submenu in Tianocore    Enable Camera    ESC to exit    3
            Save changes and reset    2    4
        ELSE
            Log    Reboot
            Press key n times    2    ${ESC}
            Press key n times and enter    4    ${ARROW_DOWN}
        END
    ELSE
        Log    DUT connection method is different from Telnet!
        Log    Cannot change UEFI options, skipping to testing switch results...
    END

    Login to Linux
    ${webcam}=    Check the presence of webcam
    Should Be True    ${webcam}

CHS002.001 Check camera disablement
    [Documentation]    This test makes sure that camera enable option
    ...    is not set, hence the camera is not detected by operating system
    IF    not ${camera_switch_support}    Skip

    # changing settings in UEFI is only possible using serial connection
    IF    '${dut_connection_method}' == 'Telnet'
        Power On
        Enter Dasharo System Features
        Enter submenu in Tianocore    Dasharo Security Options
        ${camera_enabled}=    Check if Tianocore setting is enabled in current menu    Enable Camera
        Press key n times    1    ${F10}
        Press key n times    1    ${ESC}
        IF    ${camera_enabled}
            Enter submenu in Tianocore    Enable Camera    ESC to exit    3
            Save changes and reset    2    4
        ELSE
            Log    Reboot
            Press key n times    2    ${ESC}
            Press key n times and enter    4    ${ARROW_DOWN}
        END
    ELSE
        Log    DUT connection method is different from Telnet!
        Log    Cannot change UEFI options, skipping to testing switch results...
    END

    Login to Linux
    ${webcam}=    Check the presence of webcam
    Should Not Be True    ${webcam}


*** Keywords ***
Check the presence of webcam
    [Documentation]    Checks if webcam is visible for operating system
    ...    Returns True if presence is detected
    ${terminal_result}=    Execute Command In Terminal    lsusb | grep '${webcam_ubuntu}'
    ${result}=    Run Keyword And Return Status    Should Not Be Empty    ${terminal_result}
    RETURN    ${result}
