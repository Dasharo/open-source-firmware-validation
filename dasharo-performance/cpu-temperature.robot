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
CPT001.001 CPU temperature without load Ubuntu 22.04
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    Skip If    not ${cpu_temperature_measure}    CPT001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    CPT001.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Detect or Install Package    lm-sensors
    Execute Command In Terminal    sensors-detect --auto
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${temperature_test_duration} / ${temperature_test_measure_interval}) + 1
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        ${temperature}=    Get CPU Temperature CURRENT
        Log to Console    Current temperature: ${temperature}°C
        Should Be True    ${temperature} < ${max_cpu_temp}
        Sleep    ${temperature_test_measure_interval}m
        ${timer}=    Evaluate    ${timer} + ${temperature_test_measure_interval}
    END

CPT002.001 CPU temperature after stress test Ubuntu 22.04
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    Skip If    not ${cpu_temperature_measure}    CPT002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    CPT002.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Detect or Install Package    lm-sensors
    Execute Command In Terminal    sensors-detect --auto
    Stress Test    ${temperature_test_duration}m
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${temperature_test_duration} / ${temperature_test_measure_interval}) + 1
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        ${temperature}=    Get CPU Temperature CURRENT
        Log to Console    Current temperature: ${temperature}°C
        Should Be True    ${temperature} < ${max_cpu_temp}
        Sleep    ${temperature_test_measure_interval}m
        ${timer}=    Evaluate    ${timer} + ${temperature_test_measure_interval}
    END
