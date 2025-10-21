*** Settings ***
Library         Collections
Library         DateTime
Library         String
Library         Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library         SSHLibrary    timeout=90 seconds
Resource        ../variables.robot
Resource        ../keywords.robot
Resource        ../lib/performance/cpu.robot
Resource        ../lib/sensors/sensors.robot
Resource        ../lib/parallel-testing.robot

Suite Setup     Run Keywords
...                 Prepare Test Suite
...                 AND    Run Keyword If    "CPT" in " ".join($TEST_CASES) or "CPF" in " ".join($TEST_CASES)
...                 Check Power Supply
...                 AND    Init Parallel Testing
...                 AND    Prepare Parallel Test Suite


*** Test Cases ***
############################################
#    Tests that can be done immediately    #
############################################
_PARALLEL_Background Measurements Immediate (no load) (Ubuntu)
    # immediately skip if no tests want these measurements
    ${will_any_be_run}=    Will Parallel Test Be Run Regex
    ...    (CPF001).201
    Skip If    not ${will_any_be_run}

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    # CPF001.201 steps
    VAR    ${parallel_test_id}=    CPF001.201
    ${check_frequency}=    Will Parallel Test Be Run    ${parallel_test_id}
    IF    ${check_frequency}
        Sleep    10s
        @{frequencies}=    Get CPU Frequencies In Ubuntu
        Set Parallel Test Outputs    ${parallel_test_id}    ${frequencies}
    END

CPF001.201 CPU not stuck on initial frequency (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.001
    VAR    ${parallel_test_id}=    CPF001.201
    Skip If Parallel Test Not Supported    ${parallel_test_id}
    ${outs}=    Get Parallel Test Outputs    ${parallel_test_id}
    Check CPU Frequencies Not Stuck    ${outs}

#############################################################################
#    Tests that gather measurements on Ubuntu, no load, n/a power source    #
#############################################################################

_PARALLEL_Background Measurements (no load) (Ubuntu)
    ${will_any_be_run}=    Will Parallel Test Be Run Regex
    ...    (CPF005)|(CPT001).201
    Skip If    not ${will_any_be_run}

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    # TODO temporary debug values
    VAR    ${frequency_test_measure_interval}=    1
    VAR    ${temperature_test_measure_interval}=    1
    VAR    ${temperature_test_duration}=    5
    VAR    ${frequency_test_duration}=    5

    ${gather_temps}=    Will Parallel Test Be Run Regex    CPT
    ${gather_freqs}=    Will Parallel Test Be Run Regex    CPF
    ${gather_temps}=    Set Variable If    ${gather_temps}    CPT001.201    ${None}
    ${gather_freqs}=    Set Variable If    ${gather_freqs}    CPF005.201    ${None}
    Background Measurements
    ...    id_temp=${gather_temps}   id_freq=${gather_freqs}

CPT001.201 CPU temperature without load (Ubuntu)
    VAR    ${parallel_test_id}=    CPT001.201
    Skip If Parallel Test Not Supported    ${parallel_test_id}
    ${temps}=    Get Parallel Test Outputs    ${parallel_test_id}
    Check CPU Temps    ${temps}


CPF005.201 CPU runs on expected frequency (Ubuntu)
    VAR    ${parallel_test_id}=    CPF005.201
    Skip If Parallel Test Not Supported    ${parallel_test_id}
    ${freqs}=    Get Parallel Test Outputs    ${parallel_test_id}
    Check CPU Freqs    ${freqs}


*** Keywords ***
Background Measurements
    [Arguments]    ${id_temp}=${None}    ${id_freq}=${None}
    # Initialization
    VAR    @{temp_list}=    @{EMPTY}
    VAR    @{freq_list}=    @{EMPTY}
    IF    ${id_temp} is not ${None}
        VAR    ${next_temp_time}=    0
    ELSE
        VAR    ${next_temp_time}=    999999
    END
    IF    ${id_freq} is not ${None}
        VAR    ${next_freq_time}=    0
    ELSE
        VAR    ${next_freq_time}=    999999
    END

    VAR    ${longest_duration}=
    ...    max(${TEMPERATURE_TEST_DURATION}, ${FREQUENCY_TEST_DURATION})
    ${start}=    DateTime.Get Current Date
    ${timer}=    Evaluate    0

    # measurement loop
    WHILE    ${timer} < ${longest_duration}
        ${now}=    Get Current Date
        ${timer}=    Subtract Date From Date    ${now}    ${start}

        IF    ${TEMPERATURE_TEST_DURATION} >= ${timer} >= ${next_temp_time}
            ${temperature}=    Get CPU Temperature
            ${next_temp_time}=    Evaluate    ${timer} + ${TEMPERATURE_TEST_MEASURE_INTERVAL}
            Append To List    ${temp_list}    ${temperature}
            Log To Console    ${timer}s: Temperature: ${temperature}
        END

        IF    ${FREQUENCY_TEST_DURATION} >= ${timer} >= ${next_freq_time}
            ${freqs}=    Get CPU Frequencies In Ubuntu
            ${next_freq_time}=    Evaluate    ${timer} + ${FREQUENCY_TEST_MEASURE_INTERVAL}
            Append To List    ${freq_list}    ${freqs}
            Log To Console    ${timer}s: Frequencies: ${freqs}
        END

        ${time_to_next_interval}=    Evaluate    min(${next_temp_time}, ${next_freq_time})
        Sleep    ${time_to_next_interval}
    END

    Set Parallel Test Outputs    ${id_temp}    ${temp_list}
    Set Parallel Test Outputs    ${id_freq}    ${freq_list}

Prepare Parallel Test Suite
    # Preparing parallel test cases
    VAR    ${PARALLEL_TEST_ID}=    CPF001.201    scope=TEST
    Add Parallel Test Skip Condition    not ${CPU_FREQUENCY_MEASURE}    frequency measure not supported
    Add Parallel Test Skip Condition    not ${TESTS_IN_UBUNTU_SUPPORT}    tests in Ubuntu not supported
    Add Parallel Test Skip Condition    '201' not in ${TESTED_LINUX_DISTROS}    Ubuntu not in tested distros

    VAR    ${PARALLEL_TEST_ID}=    CPF005.201    scope=TEST
    Add Parallel Test Skip Condition    not ${CPU_FREQUENCY_MEASURE}    frequency measure not supported
    Add Parallel Test Skip Condition    not ${TESTS_IN_UBUNTU_SUPPORT}    tests in Ubuntu not supported
    Add Parallel Test Skip Condition    '201' not in ${TESTED_LINUX_DISTROS}    Ubuntu not in tested distros
    Add Parallel Test Skip Condition    ${LAPTOP_PLATFORM}    The Platform is a Laptop

    VAR    ${PARALLEL_TEST_ID}=    CPT001.201    scope=TEST
    Add Parallel Test Skip Condition    not ${TESTS_IN_UBUNTU_SUPPORT}    tests in Ubuntu not supported
    Add Parallel Test Skip Condition
    ...    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros
    Add Parallel Test Skip Condition    ${LAPTOP_PLATFORM}    The Platform is a Laptop

    Log To Console    Tests to run:
    ${tests}=    Get Parallel Tests To Run
    Log To Console    ${tests}

    ${prepare_sensors}=    Will Parallel Test Be Run Regex    CP[TF]
    IF    ${prepare_sensors}    Prepare Sensors
    ${check_psu}=    Will Parallel Test Be Run Regex    CP[TF]
    IF    ${check_psu}    Check Power Supply

Check CPU Frequencies Not Stuck
    [Arguments]    ${frequencies}
    ${first_frequency}=    Get From List    ${frequencies}    0
    FOR    ${frequency}    IN    @{frequencies}
        IF    ${frequency} != ${INITIAL_CPU_FREQUENCY}
            Pass Execution    CPU does not stuck on initial frequency
        END
    END
    Fail    CPU stuck on initial frequency: ${INITIAL_CPU_FREQUENCY}

Check CPU Temps
    [Arguments]    ${temps}
    ${sum}=    Evaluate    0
    ${len}=    Get Length    ${temps}
    FOR    ${temp}    IN    @{temps}
        ${sum}=    Evaluate    ${sum} + ${temp}
    END
    ${avg}=    Evaluate    ${sum} / ${len}
    ${min}=    Evaluate    min($temps)
    ${max}=    Evaluate    max($temps)
    Log To Console    Average temp: ${avg}
    Log To Console    Min temp: ${min}
    Log To Console    Max temp: ${max}
    Log To Console    Test threshold of CPU temp: ${MAX_CPU_TEMP}°C
    Should Be True    ${avg} < ${MAX_CPU_TEMP}    Average is higher than threshold

Check CPU Freqs
    [Arguments]    ${freqs}
    ${cpu_max_frequency_tol}=    Evaluate    ${CPU_MAX_FREQUENCY} * 1.125
    ${cpu_min_frequency_tol}=    Evaluate    ${CPU_MIN_FREQUENCY} * 0.875
    FOR    ${freqs_cores}    IN    @{freqs}
        FOR    ${core}    IN    @{freqs_cores}
            ${in_range}=    Evaluate    ${cpu_min_frequency_tol} <= ${core} <= ${cpu_max_frequency_tol}
            Should Be True    ${in_range}    Encountered invalid frequency: ${in_range} MHz
        END
    END