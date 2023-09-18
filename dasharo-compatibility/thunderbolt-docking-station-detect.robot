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
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
# semi-automatic test
TDD001.001 Docking station detection after coldboot (Ubuntu 22.04)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_DETECT_SUPPORT}    TDD001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TDD001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Docking Station In Linux
    Set Global Variable    ${FAILED_DETECTION}    0
    FOR    ${iteration}    IN RANGE    0    ${DOCKING_STATION_COLDBOOT_ITERATIONS}
        TRY
            Log To Console    Coldboot the DUT manually
            # coldboot - msi ./sonoff, protectli RteCtrl -rel, novacustom ???
            IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    Sleep    60s
            Login To Linux
            Switch To Root User
            Detect Docking Station In Linux
            Exit From Root User
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

# semi-automatic test

TDD002.001 Docking station detection after warmboot (Ubuntu 22.04)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_DETECT_SUPPORT}    TDD002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TDD002.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Docking Station In Linux
    Set Global Variable    ${FAILED_DETECTION}    0
    FOR    ${iteration}    IN RANGE    0    ${DOCKING_STATION_WARMBOOT_ITERATIONS}
        TRY
            Log To Console    Warmboot the DUT manually
            # warmboot - msi rte, protectli novacustom ???
            IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    Sleep    60s
            Login To Linux
            Switch To Root User
            Detect Docking Station In Linux
            Exit From Root User
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

TDD003.001 Docking station detection after reboot (Ubuntu 22.04)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${THUNDERBOLT_DOCKING_STATION_DETECT_SUPPORT}    TDD003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TDD003.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Docking Station In Linux
    Set Global Variable    ${FAILED_DETECTION}    0
    FOR    ${iteration}    IN RANGE    0    ${DOCKING_STATION_REBOOT_ITERATIONS}
        TRY
            Write Into Terminal    reboot
            IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    Sleep    45s
            Login To Linux
            Switch To Root User
            Detect Docking Station In Linux
            Exit From Root User
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
            Power On
            Login To Linux
            Switch To Root User
            Detect Docking Station In Linux
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.
