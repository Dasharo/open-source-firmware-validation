*** Settings ***
Library     Collections
Library     OperatingSystem
Library     Process
Library     String
Library     Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library     SSHLibrary    timeout=90 seconds
Library     RequestsLibrary
Library     DateTime
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource    ../variables.robot
Resource    ../keywords.robot
Resource    ../keys.robot
Resource    ../keys-and-keywords/heads-keywords.robot
Resource    ../lib/performance/cpu.robot
Resource    ../lib/sensors/sensors.robot
# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)

Suite Setup    Run Keywords
...    Prepare Test Suite    AND
...    Check Power Supply

*** Variables ***
&{TESTS_TO_RUN}=                &{EMPTY}
${CPU_FREQUENCY_MEASURE}=       ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=     ${TRUE}
@{TESTED_LINUX_DISTROS}=        202    201


*** Test Cases ***

# Tests that can be performed immediately
_CANARY_CPF001.201 CPU not stuck on initial frequency (Ubuntu)
    VAR    ${TEST_ID}=    CPF001.201
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    ${TEST_ID}
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    ${TEST_ID}
    ...    not ${TESTS_IN_UBUNTU_SUPPORT}
    ...    tests in Ubuntu not supported
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    ${TEST_ID}
    ...    '201' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros
    Skip If Not Supported    ${TEST_ID}    ${TESTS_TO_RUN}

_CANARY_CPF005.201 CPU runs on expected frequency (Ubuntu)
    VAR    ${TEST_ID}=    CPF005.201
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    ${TEST_ID}
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    ${TEST_ID}
    ...    not ${TESTS_IN_UBUNTU_SUPPORT}
    ...    tests in Ubuntu not supported
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    ${TEST_ID}
    ...    '201' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    ${TEST_ID}
    ...    ${LAPTOP_PLATFORM}
    ...    The Platform is a Laptop
    Skip If Not Supported    ${TEST_ID}    ${TESTS_TO_RUN}

_CANARY_CPT001.201 CPU temperature without load (Ubuntu)
    VAR    ${TEST_ID}=    CPT001.201
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    ${TEST_ID}
    ...    not ${TESTS_IN_UBUNTU_SUPPORT}
    ...    tests in Ubuntu not supported
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    ${TEST_ID}
    ...    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    ${TEST_ID}
    ...    ${LAPTOP_PLATFORM}
    ...    The Platform is a Laptop
    Skip If Not Supported    ${TEST_ID}    ${TESTS_TO_RUN}


############################################
#    Tests that can be done immediately    #
############################################
_GATHER_Background Measurements Data Init (no load) (Ubuntu)
    ${prepare_sensors}=    Will Test Be Run Regex   ${TESTS_TO_RUN}    CP[TF]
    IF    ${prepare_sensors}    Prepare Sensors
    ${check_psu}=    Will Test Be Run Regex    ${TESTS_TO_RUN}    CP[TF]
    IF    ${check_psu}    Check Power Supply

_GATHER_Background Measurements Immediate (no load) (Ubuntu)
    # immediately skip if no tests want these measurements
    ${will_any_be_run}=    Will Test Be Run Regex  ${TESTS_TO_RUN}    CPF001.201
    Skip If    not ${will_any_be_run}

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    # CPF001.201 steps
    VAR    ${test_id}=    CPF001.201
    ${check_frequency}=    Will Test Be Run  ${TESTS_TO_RUN}    ${test_id}
    IF    ${check_frequency}
        Sleep    10s
        @{frequencies}=    Get CPU Frequencies In Ubuntu
        Set Test Outputs    ${TESTS_TO_RUN}    ${test_id}    ${frequencies}
    END

CPF001.201 CPU not stuck on initial frequency (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.001
    VAR    ${test_id}=    CPF001.201
    Skip If Not Supported    ${test_id}    ${TESTS_TO_RUN}
    @{frequencies}=    Get Test Outputs    ${TESTS_TO_RUN}    ${test_id}
    ${first_frequency}=    Get From List    ${frequencies}    0
    FOR    ${frequency}    IN    @{frequencies}
        IF    ${frequency} != ${INITIAL_CPU_FREQUENCY}
            Pass Execution    CPU does not stuck on initial frequency
        END
    END
    Fail    CPU stuck on initial frequency: ${INITIAL_CPU_FREQUENCY}

#############################################################################
#    Tests that gather measurements on Ubuntu, no load, n/a power source    #
#############################################################################
_GATHER_Background Measurements (no load) (Ubuntu)
    ${will_any_be_run}=    Will Test Be Run Regex
    ...    ${TESTS_TO_RUN}
    ...    (CPF005)|(CPT001)|(STB001).201
    Skip If    not ${will_any_be_run}

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    # CPF001.201 steps
    ${gather_temps}=    Will Test Be Run Regex    ${TESTS_TO_RUN}    CPT
    ${gather_freqs}=    Will Test Be Run Regex    ${TESTS_TO_RUN}    CPF
    ${measure_stab}=    Will Test Be Run Regex    ${TESTS_TO_RUN}    STB

    VAR    @{temp_list}=    @{EMPTY}
    VAR    @{freq_list}=    @{EMPTY}
    VAR    @{stab_list}=    @{EMPTY}

    # TODO temporary debug values
    VAR    ${FREQUENCY_TEST_MEASURE_INTERVAL}=    1
    VAR    ${TEMPERATURE_TEST_MEASURE_INTERVAL}=    1
    VAR    ${TEMPERATURE_TEST_DURATION}=    5
    VAR    ${FREQUENCY_TEST_DURATION}=    5
    VAR    ${STABILITY_TEST_DURATION}=    0

    ${next_temp_time}=    Set Variable If    ${gather_temps}    ${TEMPERATURE_TEST_MEASURE_INTERVAL}    999999
    ${next_stab_time}=    Set Variable If    ${gather_temps}    ${STABILITY_TEST_MEASURE_INTERVAL}      999999
    ${next_freq_time}=    Set Variable If    ${gather_temps}    ${FREQUENCY_TEST_MEASURE_INTERVAL}      999999

    ${start}=    DateTime.Get Current Date
    ${timer}=    Evaluate    0
    VAR    ${longest_duration}=    max(${TEMPERATURE_TEST_DURATION}, ${FREQUENCY_TEST_DURATION}, ${STABILITY_TEST_DURATION})

    WHILE    ${timer} < ${longest_duration}
        ${now}=    Get Current Date
        ${timer}=    Subtract Date From Date    ${now}    ${start}

        IF    ${gather_temps} and ${TEMPERATURE_TEST_DURATION} >= ${timer} >= ${next_temp_time}
            ${temperature}=    Get CPU Temperature
            ${next_temp_time}=    Evaluate    ${timer} + ${TEMPERATURE_TEST_MEASURE_INTERVAL}
            Append To List    ${temp_list}    ${temperature}
            Log To Console    ${timer}s: Temperature: ${temperature}
        END

        IF    ${gather_freqs} and ${FREQUENCY_TEST_DURATION} >= ${timer} >= ${next_freq_time}
            ${freqs}=    Get CPU Frequencies In Ubuntu
            ${next_freq_time}=    Evaluate    ${timer} + ${FREQUENCY_TEST_MEASURE_INTERVAL}
            Append To List    ${freq_list}    ${freqs}
            Log To Console    ${timer}s: Frequencies: ${freqs}
        END
        # ...    Log To Console    Stability check at ${elapsed}s

        # Run Keyword If    ${elapsed} % ${FREQUENCY_TEST_MEASURE_INTERVAL} < 0.1 and ${elapsed} <= ${FREQUENCY_TEST_DURATION}
        # ...    Log To Console    Frequency check at ${elapsed}s

        ${time_to_next_interval}=    Evaluate    min(${next_temp_time}, ${next_stab_time}, ${next_freq_time})
        Sleep    ${time_to_next_interval}
    END

    Set Test Outputs    ${TESTS_TO_RUN}    CPT001.201    ${temp_list}
    Set Test Outputs    ${TESTS_TO_RUN}    CPF005.201    ${freq_list}

CPT001.201 CPU temperature without load (Ubuntu)
    VAR    ${test_id}=    CPT001.201
    ${temps}=    Get Test Outputs    ${TESTS_TO_RUN}    ${test_id}
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

CPF005.201 CPU runs on expected frequency (Ubuntu)
    VAR    ${test_id}=    CPF005.201
    ${freqs}=    Get Test Outputs    ${TESTS_TO_RUN}    ${test_id}
    ${cpu_max_frequency_tol}=    Evaluate    ${CPU_MAX_FREQUENCY} * 1.125
    ${cpu_min_frequency_tol}=    Evaluate    ${CPU_MIN_FREQUENCY} * 0.875
    FOR    ${freqs_cores}    IN    @{freqs}
        FOR    ${core}    IN    @{freqs_cores}
            ${in_range}=    Evaluate    ${cpu_min_frequency_tol} <= ${core} <= ${cpu_max_frequency_tol}
            Should Be True    ${in_range}    Encountered invalid frequency: ${in_range} MHz
        END
    END

*** Keywords ***
Wait Until Time
    [Arguments]    ${target}
    ${now}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S.%f
    ${diff}=    Subtract Date From Date    ${target}    ${now}    result_format=number
    ${sleep}=    Evaluate    max(min(${diff}, 0.1), 0.01)
    Sleep    ${sleep}

Add Test Case Skip Condition
    [Arguments]    ${tests_dict}    ${test_id}    ${condition}    ${skip_reason}
    ${current_details}=    Get From Dictionary    ${tests_dict}    ${test_id}    default=${FALSE}
    IF    not ${current_details}
        VAR    &{support_details}=    test=${test_id}    run=${TRUE}    reason=supported
    ELSE
        VAR    ${support_details}=    ${current_details}
    END
    ${run}=    Get From Dictionary    ${support_details}    run
    IF    ${run} and (${condition})
        Set To Dictionary    ${support_details}    run=${FALSE}    reason=${skip_reason}
    END
    Set To Dictionary    ${tests_dict}    ${test_id}=${support_details}

Skip If Not Supported
    [Arguments]    ${test_id}    ${tests_dict}
    ${will_be_run}=    Will Test Be Run    ${tests_dict}    ${test_id}
    Skip If    not $will_be_run

Will Test Be Run
    [Arguments]    ${tests_dict}    ${test_id}
    ${test}=    Get From Dictionary    ${tests_dict}    ${test_id}    ${None}
    IF    $test is ${None}
        Log    Test ${test_id} not found
        RETURN    ${FALSE}
    END
    ${value}=    Get From Dictionary    ${test}    run    ${FALSE}
    RETURN    ${value}


Get Test Value
    [Arguments]    ${tests_dict}    ${test}    ${key}
    ${test}=    Get From Dictionary    ${tests_dict}    ${test}
    ${value}=    Get From Dictionary    ${test}    ${key}
    RETURN    ${value}

Get Test Outputs
    [Arguments]    ${tests_dict}    ${test}
    ${outputs}=    Get Test Value    ${tests_dict}    ${test}    outputs
    RETURN    ${outputs}

Set Test Value
    [Arguments]    ${tests_dict}    ${test_id}    ${key}    ${value}
    ${test}=    Get From Dictionary    ${tests_dict}    ${test_id}
    Set To Dictionary    ${test}    ${key}=${value}
    Set To Dictionary    ${tests_dict}    ${test_id}=${test}

Set Test Outputs
    [Arguments]    ${tests_dict}    ${test}    ${value}
    Set Test Value    ${tests_dict}    ${test}    outputs    ${value}

*** Keywords ***
Will Test Be Run Regex
    [Arguments]    ${dict}    ${pattern}
    FOR    ${key}    IN    @{dict.keys()}
        ${match}=    Evaluate    re.search(r"""${pattern}""", """${key}""")    re
        IF    $match is not ${None}
            ${id}=    Evaluate    $match.string
            ${run}=    Will Test Be Run    ${TESTS_TO_RUN}    ${id}
            IF    ${run}    RETURN    ${TRUE}
        END
    END
    RETURN    ${FALSE}