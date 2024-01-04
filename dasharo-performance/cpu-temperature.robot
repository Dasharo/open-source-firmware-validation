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
...                     Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPU temperature measurement tests not supported
...                     AND
...                     Check Power Supply
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
CPT001.001 CPU temperature without load (Ubuntu 22.04)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT001.001 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Temperature Without Load (Ubuntu 22.04)

CPT001.002 CPU temperature without load (Ubuntu 22.04) (battery)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT001.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT001.002 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Temperature Without Load (Ubuntu 22.04)

CPT001.003 CPU temperature without load (Ubuntu 22.04) (AC)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT001.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT001.003 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Temperature Without Load (Ubuntu 22.04)

CPT001.004 CPU temperature without load (Ubuntu 22.04) (USB-PD)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT001.004 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT001.004 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB-PD_connected}    USB-PD not connected
    CPU Temperature Without Load (Ubuntu 22.04)

CPT002.001 CPU temperature after stress test (Ubuntu 22.04)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT002.001 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Temperature After Stress Test (Ubuntu 22.04)

CPT002.002 CPU temperature after stress test (Ubuntu 22.04) (battery)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT002.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT002.002 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Temperature After Stress Test (Ubuntu 22.04)

CPT002.003 CPU temperature after stress test (Ubuntu 22.04) (AC)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT002.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT002.003 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Temperature After Stress Test (Ubuntu 22.04)

CPT002.004 CPU temperature after stress test (Ubuntu 22.04) (USB-PD)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT002.004 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT002.004 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB-PD_connected}    USB-PD not connected
    CPU Temperature After Stress Test (Ubuntu 22.04)


*** Keywords ***
CPU Temperature Without Load (Ubuntu 22.04)
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    lm-sensors
    Execute Command In Terminal    sensors-detect --auto
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${TEMPERATURE_TEST_DURATION} / ${TEMPERATURE_TEST_MEASURE_INTERVAL}) + 1
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        ${temperature}=    Get CPU Temperature CURRENT
        Log To Console    Current temperature: ${temperature}°C
        Should Be True    ${temperature} < ${MAX_CPU_TEMP}
        Sleep    ${TEMPERATURE_TEST_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${TEMPERATURE_TEST_MEASURE_INTERVAL}
    END

CPU Temperature After Stress Test (Ubuntu 22.04)
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    lm-sensors
    Execute Command In Terminal    sensors-detect --auto
    Stress Test    ${TEMPERATURE_TEST_DURATION}m
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${TEMPERATURE_TEST_DURATION} / ${TEMPERATURE_TEST_MEASURE_INTERVAL}) + 1
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        ${temperature}=    Get CPU Temperature CURRENT
        Log To Console    Current temperature: ${temperature}°C
        Should Be True    ${temperature} < ${MAX_CPU_TEMP}
        Sleep    ${TEMPERATURE_TEST_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${TEMPERATURE_TEST_MEASURE_INTERVAL}
    END
