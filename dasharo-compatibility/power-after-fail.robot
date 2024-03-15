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
Resource            ../lib/bios/menus.robot
Resource            ../lib/power-after-fail-lib.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${DASHARO_POWER_MGMT_MENU_SUPPORT}    Power after fail tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
PSF001.001 Check Power State After Power Failure default state (firmware)
    [Documentation]    This test ensures that the option is present, and the
    ...    default state of this option after flashing is correct.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PSF001.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${pwr_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    ${state}=    Get Option State    ${pwr_menu}    Power state after power
    Should Be Equal    ${state}    ${DEFAULT_POWER_STATE_AFTER_FAIL}

PSF002.001 Powered Off State Restoration Test
    [Documentation]    This test ensures that the feature is able to
    ...    keep the DUT powered off after power failure.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PSF002.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${pwr_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    Set Option State    ${pwr_menu}    Power state after power    Powered Off
    Save Changes And Reset    2    4
    Enter Setup Menu
    Simulate Power Failure
    ${output}=    Run Keyword And Return Status
    ...    Enter Setup Menu And Return Construction
    Should Not Be True    ${output}

PSF003.001 Powered On State Restoration Test
    [Documentation]    This test ensures that the feature is able to correctly
    ...    power the DUT back on after failure.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PSF003.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${pwr_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    Set Option State    ${pwr_menu}    Power state after power    Powered On
    Save Changes And Reset    2    4
    Enter Setup Menu
    Simulate Power Failure
    Enter Setup Menu

PSF004.001 Previous Power State Restoration Test - Powered Off
    [Documentation]    This test ensures that the feature is able to correctly
    ...    restore the power state from the moment of failure, in this case to
    ...    keep the DUT powered off.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PSF004.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${pwr_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    Set Option State    ${pwr_menu}    Power state after power    The state at the moment of power failure
    Save Changes And Reset    2    4
    Enter Setup Menu
    # Power button press to power off the machine
    RteCtrl Power On
    Simulate Power Failure
    ${output}=    Run Keyword And Return Status
    ...    Enter Setup Menu
    Should Not Be True    ${output}

PSF004.002 Previous Power State Restoration Test - Powered On
    [Documentation]    This test ensures that the feature is able to correctly
    ...    restore the power state from the moment of failure, in this case to
    ...    power the DUT back on after power failure
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PSF004.002 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${pwr_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    Set Option State    ${pwr_menu}    Power state after power    The state at the moment of power failure
    Save Changes And Reset    2    4
    Enter Setup Menu
    Simulate Power Failure
    Enter Setup Menu
