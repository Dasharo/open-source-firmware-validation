*** Settings ***
Library             Collections
Library             DateTime
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Library             CSVLibrary
Library             ../lib/fan_curve_tests/fan_curve_tests.py
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/sensors/sensors.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    '''${CUSTOM_FAN_CURVE_FILE}''' == '''${TBD}'''    CFC not supported - CUSTOM_FAN_CURVE_FILE not defined
...                     AND
...                     Import Variables    ${CURDIR}/../platform-configs/${CUSTOM_FAN_CURVE_FILE}
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
CFC001.001 Custom fan curve silent profile measure (Ubuntu)
    [Documentation]    Check whether the fan curve is configured correctly in
    ...    silent profile and the fan spins up and down according to
    ...    the defined values.
    Skip If    not ${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}    CFC001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CFC001.001 not supported

    Set UEFI Option    FanCurveOption    Silent
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Perform Custom Fan Curve Test    silent

CFC002.001 Custom fan curve performance profile measure (Ubuntu)
    [Documentation]    Check whether the fan curve is configured correctly in
    ...    silent profile and the fan spins up and down according to
    ...    the defined values.
    Skip If    not ${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}    CFC002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CFC002.001 not supported

    Set UEFI Option    FanCurveOption    Performance
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Perform Custom Fan Curve Test    performance

CFC003.001 Custom fan curve OFF profile measure (Ubuntu)
    [Documentation]    Check whether the fan curve is configured correctly in
    ...    silent profile and the fan spins up and down according to
    ...    the defined values.
    Skip If    not ${CUSTOM_FAN_CURVE_OFF_MODE_SUPPORT}    CFC003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CFC003.001 not supported

    Set UEFI Option    FanCurveOption    Fans Off
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Perform Custom Fan Curve Test    off


*** Keywords ***
Perform Custom Fan Curve Test
    [Documentation]    Performs a Custom Fan Curve test for a given profile
    [Arguments]    ${profile}
    Prepare Sensors
    ${measurements}=    Create List
    ${stress_len}=    Evaluate    ${CUSTOM_FAN_CURVE_TEST_DURATION}*5
    ${cpu_count}=    Execute Command In Terminal    nproc
    ${fan_mode}=    Get Fan Measurement Unit Name

    FOR    ${cpu_usage}    IN RANGE    100
        Stress Test    time=${stress_len}s    load_percent=${cpu_usage}
        Sleep    1s    Let the CPU temperature stabilize
        ${current_time}=    Evaluate    time.time()
        ${start_time}=    Set Variable    ${current_time}
        ${end_time}=    Evaluate    ${start_time} + ${CUSTOM_FAN_CURVE_TEST_DURATION}

        WHILE    ${current_time} < ${end_time}
            ${current_time}=    Evaluate    time.time()
            ${duration}=    Evaluate    ${current_time} - ${start_time}
            Log To Console    \n${duration} s.
            ${result}    ${measurement}=    Measure And Verify
            ...    ${profile}    ${fan_mode}
            Append To List    ${measurements}    ${measurement}
            IF    not ${result}    Log To Console    Invalid fan speed    WARN
        END
    END
    Stress Test Stop
    Sleep    ${CUSTOM_FAN_CURVE_COOLDOWN_SECONDS}s

    ${percentile_drop}=    Get From Dictionary    ${TEMPERATURE_CURVE_SETTINGS}    percentile_drop
    ${failed_count}=    Count Failed Fan Measurements    ${measurements}
    ${filtered}=    Filter Fan Measurements    ${measurements}    ${percentile_drop}
    ${failed_after_filtering}=    Count Failed Fan Measurements    ${filtered}
    ${image}=    Save Measurements    ${filtered}    ${profile}_filtered
    Log    <img src="../${image}">    html=true

    IF    ${failed_count} > 0
        ${total_measurements}=    Get Length    ${measurements}
        ${percent_failed}=    Evaluate    ${failed_count} / ${total_measurements}
        ${acceptable_invalid_percent}=    Get From Dictionary
        ...    ${TEMPERATURE_CURVE_SETTINGS}    acceptable_invalid_percent
        Should Be True    ${percent_failed} <= ${acceptable_invalid_percent}
        ...    Too many measurements were invalid (${percent_failed} > ${acceptable_invalid_percent})
    END

Measure And Verify
    [Arguments]    ${profile}    ${fan_mode}
    ${fan_speed}=    Get Fan Speed    ${fan_mode}
    ${cpu_temp}=    Get CPU Temperature
    ${range_data}=    Get Fan Curve Range    ${cpu_temp}    ${profile}
    ${result}    ${expected}=    Verify Fan Speeds
    ...    ${range_data}    ${fan_speed}    ${fan_mode}    ${cpu_temp}
    ${tolerance}=    Get From Dictionary    ${range_data}    tolerance_${fan_mode}
    ${measurement}=    Create Dictionary    temp=${cpu_temp}
    ...    speed=${fan_speed}    expected=${expected}
    ...    tolerance=${tolerance}
    Log To Console
    ...    ${cpu_temp}C - ${fan_speed} ${fan_mode} (expected: ${expected} ${fan_mode} +/- ${tolerance})
    RETURN    ${result}    ${measurement}

Save Measurements
    [Documentation]    Saves fan speed & temp measurements to csv file
    [Arguments]    ${measurements}    ${name}
    ${columns}=    Create List    temp    speed    expected    tolerance
    ${filename}=    Set Variable    fan_speeds_${name}
    ${file_path}=    Set Variable    ${LOGS_DIR}/${filename}
    CSVLibrary.Csv File From Associative    ${file_path}.csv    ${measurements}    ${columns}
    ${image}=    Plot Fan Curve    ${file_path}    Fan speeds ${name}
    RETURN    ${image}

Verify Fan Speeds
    [Documentation]    Compares RPM/PWM to target values depending
    ...    on CPU temperature and a fan curve.
    [Tags]    robot:private
    [Arguments]    ${range_data}    ${fan_speed}    ${fan_mode}    ${cpu_temp}

    ${expected_fan_speed}=    Calculate Expected Speed    ${cpu_temp}    ${fan_mode}    ${range_data}
    ${tolerance}=    Get From Dictionary    ${range_data}    tolerance_${fan_mode}

    IF    '${fan_mode}' == 'pwm'
        ${fan_speed}=    Evaluate    float(${fan_speed}/2.55)
    END

    # RPM Measurements are not as precise as PWM. The margin of error has to be much larger.
    IF    '${fan_mode}' == 'rpm'
        ${smoothing}=    Set Variable    ${tolerance}
    ELSE IF    '${fan_mode}' == 'pwm' and ${expected_fan_speed} < 35
        ${smoothing}=    Evaluate    1
    ELSE
        ${smoothing}=    Evaluate    ${tolerance}
    END

    ${high_limit}=    Evaluate    ${expected_fan_speed}+${smoothing}
    ${low_limit}=    Evaluate    ${expected_fan_speed}-${smoothing}
    ${speed_is_valid}=    Evaluate    ${low_limit} < ${fan_speed} < ${high_limit}

    RETURN    ${speed_is_valid}    ${expected_fan_speed}

Get Fan Curve Range
    [Documentation]    Returns the dictionary with settings for temperature
    ...    range where the current temperature fits for a given profile
    [Arguments]    ${temperature}    ${profile}
    IF    '${profile}' == 'silent'
        ${range_data}=    Get Fan Curve Range From Curve    ${temperature}    @{TEMPERATURE_CURVE_SILENT}
    ELSE IF    '${profile}' == 'performance'
        ${range_data}=    Get Fan Curve Range From Curve    ${temperature}    @{TEMPERATURE_CURVE_PERFORMANCE}
    ELSE IF    '${profile}' == 'off'
        ${range_data}=    Get Fan Curve Range From Curve    ${temperature}    @{TEMPERATURE_CURVE_OFF}
    END
    RETURN    ${range_data}

Get Fan Curve Range From Curve
    [Documentation]    Returns the dictionary with settings for temperature
    ...    range where the current temperature fits
    [Tags]    robot:private
    [Arguments]    ${temperature}    @{temperature_curve}

    ${expected_speed}=    Evaluate    -1
    FOR    ${range_data}    IN    @{temperature_curve}
        ${min_temp}    ${max_temp}=    Get From Dictionary    ${range_data}    range
        # Ranges are ordered and don't overlap allowing for searching like this
        IF    ${temperature} < ${max_temp}    RETURN    ${range_data}
    END

Calculate Expected Speed
    [Documentation]    Calculates the expected speed percentage by config file
    ...    for a given temperature based on an algorithm and a
    ...    defined curve. Speed unit should be defined as "pwm" or "rpm" to
    ...    choose the curve unit.
    [Tags]    robot:private
    [Arguments]    ${temperature}    ${speed_unit}    ${range_data}

    ${expected_speed}=    Evaluate    -1
    ${min_temp}    ${max_temp}=    Get From Dictionary    ${range_data}    range
    ${eval_min}    ${eval_max}=    Get From Dictionary    ${range_data}    evaluation_${speed_unit}

    IF    ${temperature} == ${min_temp}
        ${expected_speed}=    Evaluate    float(${eval_min})
        # if not check if the temperature is lower than maximum temperature in
        # this range and if so, then calculate pwm by finding a linear function
        # and its ordinate
    ELSE IF    ${temperature} < ${max_temp}
        ${expected_speed}=    Evaluate
        ...    float(((${eval_max}-${eval_min})/(${max_temp}-${min_temp}))*(${temperature}-${min_temp})+${eval_min})
    END

    IF    ${expected_speed} == -1    FAIL
    RETURN    ${expected_speed}
