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
Variables           ../platform-configs/fan-curve-config.yaml

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
CFC001.001 Custom fan curve silent profile measure (Ubuntu)
    [Documentation]    Check whether the fan curve is configured correctly in
    ...    silent profile and the fan spins up and down according to
    ...    the defined values.
    Skip If    not ${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}    CFC001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CFC001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Prepare Lm-sensors
    Stress Test    ${CUSTOM_FAN_CURVE_TEST_DURATION}m
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${CUSTOM_FAN_CURVE_TEST_DURATION} / ${CUSTOM_FAN_CURVE_MEASURE_INTERVAL})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        ${temperature}=    Get Temperature CURRENT
        ${pwm}=    Get PWM Value
        ${expected_speed_percentage}=    Calculate Speed Percentage Based On Temperature In Silent Mode
        ...    ${temperature}
        Calculate Smoothing    ${pwm}    ${expected_speed_percentage}
        Sleep    ${CUSTOM_FAN_CURVE_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${CUSTOM_FAN_CURVE_MEASURE_INTERVAL}
    END

CFC002.001 Custom fan curve performance profile measure (Ubuntu)
    [Documentation]    Check whether the fan curve is configured correctly in
    ...    silent profile and the fan spins up and down according to
    ...    the defined values.
    Skip If    not ${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}    CFC002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CFC002.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Prepare Lm-sensors
    Stress Test    ${CUSTOM_FAN_CURVE_TEST_DURATION}m
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${CUSTOM_FAN_CURVE_TEST_DURATION} / ${CUSTOM_FAN_CURVE_MEASURE_INTERVAL})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        ${temperature}=    Get Temperature CURRENT
        ${pwm}=    Get PWM Value
        ${expected_speed_percentage}=    Calculate Speed Percentage Based On Temperature In Performance Mode
        ...    ${temperature}
        Calculate Smoothing    ${pwm}    ${expected_speed_percentage}
        Sleep    ${CUSTOM_FAN_CURVE_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${CUSTOM_FAN_CURVE_MEASURE_INTERVAL}
    END


*** Keywords ***
Calculate Speed Percentage Based On Temperature
    [Documentation]    Calculates the expected speed percentage by config file
    ...    for a given temperature based on an algorithm and a
    ...    defined curve.
    [Arguments]    ${temperature}    @{temperature_curve}
    ${rpm}=    Evaluate    -1
    FOR    ${range_data}    IN    @{temperature_curve}
        ${min_temp}    ${max_temp}=    Get From Dictionary    ${range_data}    range
        ${eval_min}    ${eval_max}=    Get From Dictionary    ${range_data}    evaluation
        # if temperature is equal to start of the range then rpm value will be
        # equal to minimal rpm for this range
        IF    ${temperature} == ${min_temp}
            ${rpm}=    Evaluate    float(${eval_min})
            BREAK
            # if not check if the temperature is lower than maximum temperature in
            # this range and if so, then calculate rpm by finding a linear function
            # and its ordinate
        ELSE IF    ${temperature} < ${max_temp}
            ${rpm}=    Evaluate
            ...    float(((${eval_max}-${eval_min})/(${max_temp}-${min_temp}))*(${temperature}-${min_temp})+${eval_min})
            BREAK
        END
    END

    IF    ${rpm} == -1    FAIL
    RETURN    ${rpm}

Calculate Speed Percentage Based On Temperature In Performance Mode
    [Documentation]    Calculates the expected speed percentage in performance
    ...    mode for a given temperature based on an algorithm and a
    ...    defined curve.
    [Arguments]    ${temperature}
    ${rpm}=    Calculate Speed Percentage Based On Temperature    ${temperature}    @{TEMPERATURE_CURVE_PERFORMANCE}
    RETURN    ${rpm}

Calculate Speed Percentage Based On Temperature In Silent Mode
    [Documentation]    Calculates the expected speed percentage in silent
    ...    mode for a given temperature based on an algorithm and a
    ...    defined curve.
    [Arguments]    ${temperature}
    ${rpm}=    Calculate Speed Percentage Based On Temperature    ${temperature}    @{TEMPERATURE_CURVE_SILENT}
    RETURN    ${rpm}
