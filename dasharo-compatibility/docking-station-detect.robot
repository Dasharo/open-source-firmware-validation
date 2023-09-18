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
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
# semi-automatic test
DUD001.001 Docking station detection after coldboot (Ubuntu 22.04)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    not ${docking_station_detect_support}    DUD001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DUD001.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Detect Docking Station in Linux
    Set Global Variable    ${failed_detection}    0
    FOR    ${iteration}    IN RANGE    0    ${docking_station_coldboot_iterations}
        TRY
            Log To Console    Coldboot the DUT manually
            # coldboot - msi ./sonoff, protectli RteCtrl -rel, novacustom ???
            IF    '${dut_connection_method}' == 'SSH'    Sleep    60s
            Login to Linux
            Switch to root user
            Detect Docking Station in Linux
            Exit from root user
        EXCEPT
            ${failed_detection}=    Evaluate    ${failed_detection} + 1
        END
    END
    IF    '${failed_detection}' > '${allowed_docking_station_detect_fails}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

# semi-automatic test

DUD002.001 Docking station detection after warmboot (Ubuntu 22.04)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${docking_station_detect_support}    DUD002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DUD002.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Detect Docking Station in Linux
    Set Global Variable    ${failed_detection}    0
    FOR    ${iteration}    IN RANGE    0    ${docking_station_warmboot_iterations}
        TRY
            Log To Console    Warmboot the DUT manually
            # warmboot - msi rte, protectli novacustom ???
            IF    '${dut_connection_method}' == 'SSH'    Sleep    60s
            Login to Linux
            Switch to root user
            Detect Docking Station in Linux
            Exit from root user
        EXCEPT
            ${failed_detection}=    Evaluate    ${failed_detection} + 1
        END
    END
    IF    '${failed_detection}' > '${allowed_docking_station_detect_fails}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

DUD003.001 Docking station detection after reboot (Ubuntu 22.04)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${docking_station_detect_support}    DUD003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DUD003.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Detect Docking Station in Linux
    Set Global Variable    ${failed_detection}    0
    FOR    ${iteration}    IN RANGE    0    ${docking_station_reboot_iterations}
        TRY
            Write Into Terminal    reboot
            IF    '${dut_connection_method}' == 'SSH'    Sleep    45s
            Login to Linux
            Switch to root user
            Detect Docking Station in Linux
            Exit from root user
        EXCEPT
            ${failed_detection}=    Evaluate    ${failed_detection} + 1
            Power On
            Login to Linux
            Switch to root user
            Detect Docking Station in Linux
        END
    END
    IF    '${failed_detection}' > '${allowed_docking_station_detect_fails}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.
