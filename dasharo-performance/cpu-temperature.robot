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
CPT001.001 CPU temperature without load (Ubuntu)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT001.001 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Temperature Without Load (Ubuntu)

CPT001.002 CPU temperature without load (Ubuntu) (battery)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT001.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT001.002 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Temperature Without Load (Ubuntu)

CPT001.003 CPU temperature without load (Ubuntu) (AC)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT001.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT001.003 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Temperature Without Load (Ubuntu)

CPT001.004 CPU temperature without load (Ubuntu) (USB-PD)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT001.004 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT001.004 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB-PD_connected}    USB-PD not connected
    CPU Temperature Without Load (Ubuntu)

CPT002.001 CPU temperature after stress test (Ubuntu)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT002.001 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Temperature After Stress Test (Ubuntu)

CPT002.002 CPU temperature after stress test (Ubuntu) (battery)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT002.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT002.002 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Temperature After Stress Test (Ubuntu)

CPT002.003 CPU temperature after stress test (Ubuntu) (AC)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT002.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT002.003 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Temperature After Stress Test (Ubuntu)

CPT002.004 CPU temperature after stress test (Ubuntu) (USB-PD)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT002.004 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT002.004 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB-PD_connected}    USB-PD not connected
    CPU Temperature After Stress Test (Ubuntu)


*** Keywords ***
CPU Temperature Without Load (Ubuntu)
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    lm-sensors
    Execute Command In Terminal    sensors-detect --auto
    ${timer}=    Convert To Integer    0
    @{temperature_list}=    Create List
    ${max_temperature}=    Set Variable    0
    ${min_temperature}=    Set Variable    999
    ${sum}=    Convert To Integer    0
    ${sum_previous}=    Convert To Integer    0
    ${total_intervals}=    Evaluate    (${TEMPERATURE_TEST_DURATION} / ${TEMPERATURE_TEST_MEASURE_INTERVAL}) + 1
    ${minute_counter}=    Set Variable    0
    Log To Console    \nStarting Test...
    FOR    ${i}    IN RANGE    ${total_intervals}
        ${temperature}=    Get CPU Temperature CURRENT
        Append To List    ${temperature_list}    ${temperature}
        ${max_temperature}=    Evaluate    max(${max_temperature}, ${temperature})
        ${min_temperature}=    Evaluate    min(${min_temperature}, ${temperature})
        ${sum}=    Evaluate    ${sum} + ${temperature}
        Sleep    ${TEMPERATURE_TEST_MEASURE_INTERVAL}s
        ${timer}=    Evaluate    ${timer} + ${TEMPERATURE_TEST_MEASURE_INTERVAL}
        ${minute_counter}=    Evaluate    ${minute_counter} + ${TEMPERATURE_TEST_MEASURE_INTERVAL}
        IF    ${minute_counter} >= 60
            ${mean_last_minute_temperature}=    Evaluate    ((${sum} - ${sum_previous}) / 60)
            ${sum_previous}=    Set Variable    ${sum}
            Log To Console    \n----------------------------------------------------------------
            Log To Console    ${timer}/${TEMPERATURE_TEST_DURATION} seconds passed.
            Log To Console    Mean temperature over last minute: ${mean_last_minute_temperature}°C
            ${minute_counter}=    Set Variable    0
        END
    END
    ${average}=    Evaluate    ${sum} / ${total_intervals}
    Log To Console    \n----------------------------------------------------------------
    Log To Console    Mean temperature over test duration: ${average}°C
    Log To Console    Max temperature over test duration: ${max_temperature}°C
    Log To Console    Min temperature over test duration: ${min_temperature}°C
    Log To Console    Test threshold of CPU temp: ${MAX_CPU_TEMP}°C
    Should Be True    ${average} < ${MAX_CPU_TEMP}

CPU Temperature After Stress Test (Ubuntu)
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    lm-sensors
    Execute Command In Terminal    sensors-detect --auto
    Stress Test    ${TEMPERATURE_TEST_DURATION}s
    ${timer}=    Convert To Integer    0
    @{temperature_list}=    Create List
    ${max_temperature}=    Set Variable    0
    ${min_temperature}=    Set Variable    999
    ${sum}=    Convert To Integer    0
    ${sum_previous}=    Convert To Integer    0
    ${total_intervals}=    Evaluate    (${TEMPERATURE_TEST_DURATION} / ${TEMPERATURE_TEST_MEASURE_INTERVAL}) + 1
    ${minute_counter}=    Set Variable    0
    Log To Console    \nStarting Test...
    FOR    ${i}    IN RANGE    ${total_intervals}
        ${temperature}=    Get CPU Temperature CURRENT
        Append To List    ${temperature_list}    ${temperature}
        ${max_temperature}=    Evaluate    max(${max_temperature}, ${temperature})
        ${min_temperature}=    Evaluate    min(${min_temperature}, ${temperature})
        ${sum}=    Evaluate    ${sum} + ${temperature}
        Sleep    ${TEMPERATURE_TEST_MEASURE_INTERVAL}s
        ${timer}=    Evaluate    ${timer} + ${TEMPERATURE_TEST_MEASURE_INTERVAL}
        ${minute_counter}=    Evaluate    ${minute_counter} + ${TEMPERATURE_TEST_MEASURE_INTERVAL}
        IF    ${minute_counter} >= 60
            ${mean_last_minute_temperature}=    Evaluate    ((${sum} - ${sum_previous}) / 60)
            ${sum_previous}=    Set Variable    ${sum}
            Log To Console    \n----------------------------------------------------------------
            Log To Console    ${timer}/${TEMPERATURE_TEST_DURATION} seconds passed.
            Log To Console    Mean temperature over last minute: ${mean_last_minute_temperature}°C
            ${minute_counter}=    Set Variable    0
        END
    END
    ${average}=    Evaluate    ${sum} / ${total_intervals}
    Log To Console    \n----------------------------------------------------------------
    Log To Console    Mean temperature under stress over test duration: ${average}°C
    Log To Console    Max temperature under stress over test duration: ${max_temperature}°C
    Log To Console    Min temperature over test duration: ${min_temperature}°C
    Log To Console    Test threshold of CPU temp: ${MAX_CPU_TEMP}°C
    Should Be True    ${average} < ${MAX_CPU_TEMP}
