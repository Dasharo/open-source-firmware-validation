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
Resource            ../lib/bios/menus.robot
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggests (not
#    exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keywords
...                     Log Out And Close Connection


*** Test Cases ***
APU001.001 Check if apu2 watchdog option is available
    [Documentation]    Check if the watchdog timer can be enabled in the apu2
    ...    configuration submenu.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    APU001.001 not supported
    Skip If    not ${APU_CONFIGURATION_MENU_SUPPORT}    APU configuration tests not supported.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${apu_menu}=    Enter Dasharo APU Configuration    ${setup_menu}
    ${index}=    Get Index Of Matching Option In Menu    ${apu_menu}    Enable watchdog
    Should Not Be Equal    '${index}'    -1    The option was not found in menu

APU002.001 Enable apu2 watchdog
    [Documentation]    Enable apu2 watchdog with the default timeout and verify
    ...    that it resets the platform.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    APU002.001 not supported
    Skip If    not ${APU_CONFIGURATION_MENU_SUPPORT}    APU configuration tests not supported.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${apu_menu}=    Enter Dasharo APU Configuration    ${setup_menu}
    ${current_profile}=    Set Option State    ${apu_menu}    Enable watchdog
    ...    ${TRUE}
    Save Changes And Reset
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    # We're in the setup menu. Now just wait until the platform resets.
    Set DUT Response Timeout    60s
    Read From Terminal Until    ${TIANOCORE_STRING}

APU003.001 Disable apu2 watchdog
    [Documentation]    Disable the watchdog after enabling it to verify it does
    ...    not reset the platform anymore.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    APU002.001 not supported
    Skip If    not ${APU_CONFIGURATION_MENU_SUPPORT}    APU configuration tests not supported.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${apu_menu}=    Enter Dasharo APU Configuration    ${setup_menu}
    ${current_profile}=    Set Option State    ${apu_menu}    Enable watchdog
    ...    ${FALSE}
    Save Changes And Reset
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    # We're in the setup menu. Now just wait more than the default timeout to
    # make sure the watchdog does not work.
    ${platform_has_reset}=    Set Variable    ${TRUE}
    Set DUT Response Timeout    70s
    TRY
        Read From Terminal Until    ${TIANOCORE_STRING}
    EXCEPT
        ${platform_has_reset}=    Set Variable    ${FALSE}
    END
    Should Be Equal    ${platform_has_reset}    ${FALSE}
