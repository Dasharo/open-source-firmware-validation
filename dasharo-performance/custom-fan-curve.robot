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
Resource            ../lib/sensors.robot

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
    ${stress_len}=    Evaluate    ${CUSTOM_FAN_CURVE_TEST_DURATION}*2
    Stress Test    ${stress_len}m
    ${timer}=    Convert To Integer    0
    Sleep    5s
    ${result}=    Set Variable    ${TRUE}
    ${fails_in_a_row}=    Set Variable    0

    FOR    ${i}    IN RANGE    (${CUSTOM_FAN_CURVE_TEST_DURATION} / ${CUSTOM_FAN_CURVE_MEASURE_INTERVAL})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.

        ${new_result}=    Verify Fan Speeds    ${profile}
        IF    not ${result} and not ${new_result}
            ${fails_in_a_row}=    Evaluate    ${fails_in_a_row}+1
        ELSE
            ${fails_in_a_row}=    Set Variable    0
        END
        ${result}=    Set Variable    ${new_result}

        Sleep    ${CUSTOM_FAN_CURVE_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${CUSTOM_FAN_CURVE_MEASURE_INTERVAL}
    END
    Stress Test Stop
    IF    ${fails_in_a_row} > 1
        Log    Invalid fan speeds detected. Needs manual verification    WARN
        Log To Console    Invalid fan speeds detected. Needs manual verification    WARN
        Fail
    END

Verify Fan Speeds
    [Documentation]    Measures PWM/RPM and compares to target values depending
    ...    on CPU temperature and a fan curve. Mode is a string and can be
    ...    either "performance", "silent" or "off" depending on the fan curve
    ...    to compare against.
    [Arguments]    ${mode}
    ${pwm_support}=    Is Fan PWM Measurement Supported
    ${rpm_support}=    Is Fan RPM Measurement Supported
    IF    ${pwm_support}
        ${speed_unit}=    Set Variable    pwm
        ${fan_speed}=    Get Fan PWM
    ELSE IF    ${rpm_support}
        ${speed_unit}=    Set Variable    rpm
        ${fan_speed}=    Get Fan RPM
    ELSE
        Log To Console
        ...    Invalid device configuration. CUSTOM_FAN_CURVE_X_MODE_SUPPORT is True, but fan speed measurement method is `none`
        ...    ERROR
        Fail
    END

    ${temperature}=    Get CPU Temperature
    IF    '${mode}' == 'silent'
        ${expected_fan_speed}    ${tolerance}=    Calculate Speed Percentage Based On Temperature In Silent Mode
        ...    ${temperature}    ${speed_unit}
    ELSE IF    '${mode}' == 'performance'
        ${expected_fan_speed}    ${tolerance}=    Calculate Speed Percentage Based On Temperature In Performance Mode
        ...    ${temperature}    ${speed_unit}
    ELSE IF    '${mode}' == 'off'
        ${expected_fan_speed}    ${tolerance}=    Calculate Speed Percentage Based On Temperature In Off Mode
        ...    ${temperature}    ${speed_unit}
    END

    ${speed_is_valid}=    Verify With Tolerance
    ...    ${fan_speed}
    ...    ${expected_fan_speed}
    ...    ${speed_unit}
    ...    ${tolerance}

    Log To Console    Temp: ${temperature}
    Log To Console    Fan Speed: ${fan_speed}
    Log To Console    Expected Speed: ${expected_fan_speed}
    Log To Console    Tolerance: ${tolerance}
    IF    not ${speed_is_valid}
        Log    Invalid fan speed detected    WARN
        Log To Console    Invalid fan speed detected    WARN
        RETURN    ${FALSE}
    END
    RETURN    ${TRUE}

Verify With Tolerance
    [Documentation]    Compares the actual and expected value of the fan speed,
    ...    taking tolerance into account.
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
    [Arguments]    ${temperature}    ${speed_unit}
    ${fan_speed}    ${tolerance}=    Calculate Speed Percentage Based On Temperature
    ...    ${temperature}
    ...    ${speed_unit}
    ...    @{TEMPERATURE_CURVE_OFF}
    RETURN    ${fan_speed}    ${tolerance}
