*** Settings ***
Documentation       This library defines keywords for reading sensor data from
...                 devices. It might need to be mostly scrapped and implemented as keywords
...                 defined in the platform configs if it turns out that this process
...                 differs too much depending on the platform.

Resource            ../terminal.robot


*** Keywords ***
Prepare Sensors
    [Documentation]    Do any preparation work needed for accessing sensors

    # Might only do this when any method is said to be lm-sensors.

    Import Variables    ${CURDIR}/../../platform-configs/${SENSORS_CONFIG_FILE}
    ${cpu_temperature_measurement_method}=    Get From Dictionary    ${CPU_TEMPERATURE_MEASUREMENT}    method
    ${fan_pwm_measurement_method}=    Get From Dictionary    ${FAN_PWM_MEASUREMENT}    method
    ${fan_rpm_measurement_method}=    Get From Dictionary    ${FAN_RPM_MEASUREMENT}    method

    ${lm_sensors_used}=    Catenate
    ...    '''${cpu_temperature_measurement_method}''' == '''system76-acpi''' or
    ...    '''${cpu_temperature_measurement_method}''' == '''lm-sensors''' or
    ...    '''${fan_rpm_measurement_method}''' != '''lm-sensors''' or
    ...    '''${fan_pwm_measurement_method}''' == '''lm-sensors'''
    ${lm_sensors_used}=    Evaluate    ${lm_sensors_used}

    FOR    ${module}    IN    @{SENSORS_KERNEL_MODULES}
        ${module_name}=    Get From Dictionary    ${module}    module
        ${force_id}=    Get From Dictionary    ${module}    force_id
        ${optional_force_id}=    Set Variable    ${EMPTY}
        IF    '''${force_id}''' != '''none'''
            ${optional_force_id}=    Set Variable    force_id=${force_id}
        END
        Execute Command In Terminal    modprobe ${module_name} ${optional_force_id}
    END

    IF    ${lm_sensors_used} == ${TRUE}
        Detect Or Install Package    lm-sensors
        Execute Command In Terminal    sudo sensors-detect --auto
    END

Get CPU Temperature
    [Documentation]    Get current CPU temperature. Might need preparing the
    ...    sensors using `Prepare Sensors` keyword.
    ${cpu_temperature_measurement_method}=    Get From Dictionary    ${CPU_TEMPERATURE_MEASUREMENT}    method
    IF    '''${cpu_temperature_measurement_method}''' == '''lm-sensors'''
        ${temperature}=    Execute Command In Terminal
        ...    sensors 2>/dev/null | awk -F '[+°]' '/Package id 0:/ {printf $2}'
        RETURN    ${temperature}
    ELSE IF    '${cpu_temperature_measurement_method}' == 'hwmon'
        ${cpu_temperature_measurement_hwmon_path}=    Get From Dictionary
        ...    ${CPU_TEMPERATURE_MEASUREMENT}
        ...    hwmon_path

        ${temperature}=    Execute Command In Terminal
        ...    cat ${cpu_temperature_measurement_hwmon_path}
        ${temperature}=    Evaluate    ${temperature[:2]}
        ${temperature}=    Convert To Number    ${temperature}
        RETURN    ${temperature}
    ELSE
        Fail    Wrong platform configuration. CPU_TEMPERATURE_MEASUREMENT["method"]
        ...    is of unknown value ${cpu_temperature_measurement_method}.
    END

Get Fan Speed
    [Documentation]    Get PWM or RPM depending on argument
    [Arguments]    ${mode}    # Can be "rpm" or "pwm"
    IF    """${mode}""" == "rpm"
        ${v}=    Get Fan RPM
        RETURN    ${v}
    ELSE IF    """${mode}""" == "pwm"
        ${v}=    Get Fan PWM
        RETURN    ${v}
    ELSE
        Fail    Invalid fan speed measurement mode "${mode}"
    END

Get Fan PWM
    [Documentation]    Get current CPU fan PWM
    ${fan_pwm_measurement_method}=    Get From Dictionary    ${FAN_PWM_MEASUREMENT}    method
    IF    '''${fan_pwm_measurement_method}''' == '''none'''
        Fail    Wrong platform configuration. FAN_PWM_MEASUREMENT["method"] is
        ...    none. Either it should be changed or this test should not be
        ...    performed on this platform.
    ELSE IF    '''${fan_pwm_measurement_method}''' == '''hwmon'''
        ${fan_pwm_measurement_hwmon_path}=    Get From Dictionary    ${FAN_PWM_MEASUREMENT}    hwmon_path
        ${pwm}=    Execute Command In Terminal
        ...    cat ${fan_pwm_measurement_hwmon_path}
        ${pwm}=    Convert To Number    ${pwm}
        RETURN    ${pwm}
    ELSE
        Fail    Wrong platform configuration. FAN_PWM_MEASUREMENT["method"] is
        ...    of unknown value ${fan_pwm_measurement_method}.
    END

Get Fan RPM
    [Documentation]    Get current CPU fan RPM
    ${fan_rpm_measurement_method}=    Get From Dictionary    ${FAN_RPM_MEASUREMENT}    method
    IF    '''${fan_rpm_measurement_method}''' == '''lm-sensors'''
        ${fan_rpm_measurement_sensor}=    Get From Dictionary    ${FAN_RPM_MEASUREMENT}    lm_sensors_sensor_name
        IF    '''${fan_rpm_measurement_sensor}''' == '''none'''
            Fail
            ...    FAN_RPM_MEASUREMENT["lm_sensors_sensor_name"] mustn't be "none" if FAN_RPM_MEASUREMENT["method"] is "lm-sensors"
        END
        ${rpm}=    Execute Linux Command
        ...    sensors ${fan_rpm_measurement_sensor} 2> /dev/null | grep -E 'fan1' | tr -s ' ' | cut -d ' ' -f2
        ${rpm}=    Convert To Integer    ${rpm}
        RETURN    ${rpm}
    ELSE IF    '''${fan_rpm_measurement_method}''' == '''system76-acpi'''
        ${speed}=    Execute Command In Terminal    sensors | grep "CPU fan"
        ${speed_split}=    Split String    ${speed}
        ${rpm}=    Get From List    ${speed_split}    2
        RETURN    ${rpm}
    ELSE IF    '''${fan_rpm_measurement_method}''' == '''none'''
        Fail    Wrong platform configuration. FAN_RPM_MEASUREMENT["method"] is
        ...    none. Either it should be changed or this test should not be
        ...    performed on this platform.
    ELSE
        Fail    Wrong platform configuration. FAN_RPM_MEASUREMENT["method"] is
        ...    of unknown value ${fan_rpm_measurement_method}.
    END

Is Fan PWM Measurement Supported
    ${fan_pwm_measurement_method}=    Get From Dictionary    ${FAN_PWM_MEASUREMENT}    method
    IF    '''${fan_pwm_measurement_method}''' == '''none'''
        RETURN    ${FALSE}
    END
    RETURN    ${TRUE}

Is Fan RPM Measurement Supported
    ${fan_rpm_measurement_method}=    Get From Dictionary    ${FAN_RPM_MEASUREMENT}    method
    IF    '''${fan_rpm_measurement_method}''' == '''none'''
        RETURN    ${FALSE}
    END
    RETURN    ${TRUE}

Get Fan Measurement Unit Name
    [Documentation]    Returns "pwm" or "rpm" depending on which is supported
    ...    on the DUT. If both are, then "pwm" takes priority.
    ${pwm_support}=    Is Fan PWM Measurement Supported
    ${rpm_support}=    Is Fan RPM Measurement Supported
    IF    ${pwm_support}
        RETURN    pwm
    ELSE IF    ${rpm_support}
        RETURN    rpm
    ELSE
        Fail
        ...    Invalid device configuration. CUSTOM_FAN_CURVE_X_MODE_SUPPORT is True, but fan speed measurement method is `none`
    END
