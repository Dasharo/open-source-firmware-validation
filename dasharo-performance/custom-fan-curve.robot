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
Library             ../lib/sensors/fan_curve_plots.py
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
    Login To Linux
    Switch To Root User
    Perform Custom Fan Curve Test    off


*** Keywords ***
Perform Custom Fan Curve Test
    [Documentation]    Performs a Custom Fan Curve test for a given profile
    [Arguments]    ${profile}
    Prepare Sensors

    ${result}=    Set Variable    ${TRUE}
    ${fails_in_a_row}=    Set Variable    0
    ${max_fails_in_a_row}=    Set Variable    0
    ${measurements}=    Create List

    ${stress_len}=    Evaluate    ${CUSTOM_FAN_CURVE_TEST_DURATION}*5
    ${cpu_count}=    Execute Command In Terminal    nproc
    ${fan_mode}=    Get Fan Measurement Unit Name

    FOR    ${i}    IN RANGE    100
        ${current_time}=    Evaluate    time.time()
        ${start_time}=    Set Variable    ${current_time}
        ${end_time}=    Evaluate    ${start_time} + ${CUSTOM_FAN_CURVE_TEST_DURATION}
        Stress Test    time=${stress_len}s    load_percent=${i}
        WHILE    ${current_time} < ${end_time}
            ${current_time}=    Evaluate    time.time()
            ${duration}=    Evaluate    ${current_time} - ${start_time}
            Log To Console    \n${duration} s.

            ${new_result}    ${measurement}=    Measure And Verify
            ...    ${profile}    ${fan_mode}

            IF    not ${result} and not ${new_result}
                Log To Console    Invalid speed    WARN
                ${fails_in_a_row}=    Evaluate    ${fails_in_a_row}+1
                IF    ${fails_in_a_row} > ${max_fails_in_a_row}
                    ${max_fails_in_a_row}=    Set Variable    ${fails_in_a_row}
                END
            ELSE
                ${fails_in_a_row}=    Set Variable    0
            END
            ${result}=    Set Variable    ${new_result}
        END
    END
    Stress Test Stop

    ${image}=    Save Measurements    ${measurements}    ${profile}
    IF    ${max_fails_in_a_row} > 1
        Log To Console    Invalid fan speeds detected. Needs manual verification    WARN
        Fail    Invalid fan speeds detected. Needs manual verification
    END
    # Add a graph of measurements to the logs
    Log    <img src="../${image}">    html=true
    Sleep    ${CUSTOM_FAN_CURVE_COOLDOWN_SECONDS}s

Measure And Verify
    [Arguments]    ${profile}    ${fan_mode}
    ${fan_speed}=    Get Fan Speed    ${fan_mode}
    ${cpu_temp}=    Get CPU Temperature

    ${result}    ${expected}    ${tolerance}=    Verify Fan Speeds
    ...    ${profile}    ${fan_speed}    ${fan_mode}    ${cpu_temp}

    ${measurement}=    Create Dictionary    temp=${cpu_temp}
    ...    speed=${fan_speed}    expected=${expected}
    ...    tolerance=${tolerance}
    Log To Console
    ...    ${cpu_temp}C - ${fan_speed} ${fan_mode} (expected: ${expected} ${fan_mode} +/- ${tolerance})
    RETURN    ${result}    ${measurement}

Save Measurements
    [Documentation]    Saves fan speed & temp measurements to csv file
    [Arguments]    ${measurements}    ${profile}
    ${columns}=    Create List    temp    speed    expected    tolerance
    ${file}=    Set Variable    fan_speeds_${profile}
    CSVLibrary.Csv File From Associative    ${file}.csv    ${measurements}    ${columns}
    ${image}=    Plot Fan Curve    ${file}
    RETURN    ${image}

Verify Fan Speeds
    [Documentation]    Compares RPM/PWM to target values depending
    ...    on CPU temperature and a fan curve.
    ...    - profile is a string and can be
    ...    \ either "performance", "silent" or "off" depending on the fan curve[Tags]    robot:private
    ...    \ to compare against.
    ...    - fan_speed - measured fan speed value
    ...    - fan_mode - fan measurement unit - rpm or pwm,
    ...    - cpu_temp - cpu temperature in C
    ...    returns:
    ...    - boolean result
    ...    - expected speed
    ...    - tolerance
    [Tags]    robot:private
    [Arguments]    ${profile}    ${fan_speed}    ${fan_mode}    ${cpu_temp}

    IF    '${profile}' == 'silent'
        ${expected_fan_speed}    ${tolerance}=    Calculate Speed Percentage Based On Temperature In Silent Mode
        ...    ${cpu_temp}    ${fan_mode}
    ELSE IF    '${profile}' == 'performance'
        ${expected_fan_speed}    ${tolerance}=    Calculate Speed Percentage Based On Temperature In Performance Mode
        ...    ${cpu_temp}    ${fan_mode}
    ELSE IF    '${profile}' == 'off'
        ${expected_fan_speed}    ${tolerance}=    Calculate Speed Percentage Based On Temperature In Off Mode
        ...    ${cpu_temp}    ${fan_mode}
    END

    ${speed_is_valid}=    Verify With Tolerance
    ...    ${fan_speed}
    ...    ${expected_fan_speed}
    ...    ${fan_mode}
    ...    ${tolerance}

    RETURN    ${speed_is_valid}    ${expected_fan_speed}    ${tolerance}

Verify With Tolerance
    [Documentation]    Compares the actual and expected value of the fan speed,
    ...    taking tolerance into account.
    [Tags]    robot:private
    [Arguments]    ${fan_speed}    ${expected_speed}    ${fan_speed_unit}    ${tolerance}

    IF    '${fan_speed_unit}' == 'pwm'
        ${fan_speed}=    Evaluate    float(${fan_speed}/2.55)
    END

    # RPM Measurements are not as precise as PWM. The margin of error has to be much larger.
    IF    '${fan_speed_unit}' == 'rpm'
        ${smoothing}=    Set Variable    ${tolerance}
    ELSE IF    '${fan_speed_unit}' == 'pwm' and ${expected_speed} < 35
        ${smoothing}=    Evaluate    1
    ELSE
        ${smoothing}=    Evaluate    ${tolerance}
    END

    ${high_limit}=    Evaluate    ${expected_speed}+${smoothing}
    ${low_limit}=    Evaluate    ${expected_speed}-${smoothing}
    ${result}=    Evaluate    ${low_limit} < ${fan_speed} < ${high_limit}
    RETURN    ${result}

Calculate Speed Percentage Based On Temperature
    [Documentation]    Calculates the expected speed percentage by config file
    ...    for a given temperature based on an algorithm and a
    ...    defined curve. Speed unit should be defined as "pwm" or "rpm" to
    ...    choose the curve unit.
    [Tags]    robot:private
    [Arguments]    ${temperature}    ${speed_unit}    @{temperature_curve}

    ${fan_speed}=    Evaluate    -1
    FOR    ${range_data}    IN    @{temperature_curve}
        ${min_temp}    ${max_temp}=    Get From Dictionary    ${range_data}    range
        ${eval_min}    ${eval_max}=    Get From Dictionary    ${range_data}    evaluation_${speed_unit}
        ${tolerance}=    Get From Dictionary    ${range_data}    tolerance_${speed_unit}
        # if temperature is equal to start of the range then pwm value will be
        # equal to minimal pwm for this range
        IF    ${temperature} == ${min_temp}
            ${fan_speed}=    Evaluate    float(${eval_min})
            BREAK
            # if not check if the temperature is lower than maximum temperature in
            # this range and if so, then calculate pwm by finding a linear function
            # and its ordinate
        ELSE IF    ${temperature} < ${max_temp}
            ${fan_speed}=    Evaluate
            ...    float(((${eval_max}-${eval_min})/(${max_temp}-${min_temp}))*(${temperature}-${min_temp})+${eval_min})
            BREAK
        END
    END

    IF    ${fan_speed} == -1    FAIL
    RETURN    ${fan_speed}    ${tolerance}

Calculate Speed Percentage Based On Temperature In Performance Mode
    [Documentation]    Calculates the expected speed in performance
    ...    mode for a given temperature based on an algorithm and a
    ...    defined curve.
    [Tags]    robot:private
    [Arguments]    ${temperature}    ${speed_unit}
    ${fan_speed}    ${tolerance}=    Calculate Speed Percentage Based On Temperature
    ...    ${temperature}
    ...    ${speed_unit}
    ...    @{TEMPERATURE_CURVE_PERFORMANCE}
    RETURN    ${fan_speed}    ${tolerance}

Calculate Speed Percentage Based On Temperature In Silent Mode
    [Documentation]    Calculates the expected speed in silent
    ...    mode for a given temperature based on an algorithm and a
    ...    defined curve.
    [Tags]    robot:private
    [Arguments]    ${temperature}    ${speed_unit}
    ${fan_speed}    ${tolerance}=    Calculate Speed Percentage Based On Temperature
    ...    ${temperature}
    ...    ${speed_unit}
    ...    @{TEMPERATURE_CURVE_SILENT}
    RETURN    ${fan_speed}    ${tolerance}

Calculate Speed Percentage Based On Temperature In Off Mode
    [Documentation]    Calculates the expected speed in off
    ...    mode for a given temperature based on an algorithm and a
    ...    defined curve.
    [Tags]    robot:private
    [Arguments]    ${temperature}    ${speed_unit}
    ${fan_speed}    ${tolerance}=    Calculate Speed Percentage Based On Temperature
    ...    ${temperature}
    ...    ${speed_unit}
    ...    @{TEMPERATURE_CURVE_OFF}
    RETURN    ${fan_speed}    ${tolerance}
