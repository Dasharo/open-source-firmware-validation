*** Settings ***
Documentation       This library defines keywords for reading sensor data from
...                 devices. It might need to be mostly scrapped and implemented as keywords
...                 defined in the platform configs if it turns out that this process
...                 differs too much depending on the platform.

Resource            ../platform-configs/include/default.robot


*** Keywords ***
Prepare Sensors
    [Documentation]    Do any preparation work needed for accessing sensors

    # Might only do this when any method is said to be lm-sensors.
    # "${FAN_RPM_MEASUREMENT_METHOD}" == "system76-acpi" also needs this
    Detect Or Install Package    lm-sensors
    Execute Command In Terminal    sudo sensors-detect --auto

Get CPU Temperature CURRENT
    [Documentation]    Get current CPU temperature.
    IF    "${CPU_TEMPERATURE_MEASUREMENT_METHOD}" == "lm-sensors"
        ${temperature}=    Execute Command In Terminal
        ...    sensors 2>/dev/null | awk -F '[+°]' '/Package id 0:/ {printf $2}'
        RETURN    ${temperature}
    ELSE IF    "${CPU_TEMPERATURE_MEASUREMENT_METHOD}" == "hwmon"
        ${hwmon}=    Execute Command In Terminal
        ...    ls ${CPU_TEMPERATURE_MEASUREMENT_HWMON_PATH} | grep hwmon
        ${temperature}=    Execute Command In Terminal
        ...    cat ${CPU_TEMPERATURE_MEASUREMENT_HWMON_PATH}/${hwmon}/temp1_input
        ${temperature}=    Evaluate    ${temperature[:2]}
        ${temperature}=    Convert To Number    ${temperature}
        RETURN    ${temperature}
    ELSE
        Fail    Wrong platform configuration. CPU_TEMPERATURE_MEASUREMENT_METHOD
        ...    is of unknown value ${CPU_TEMPERATURE_MEASUREMENT_METHOD}.
    END

Get Fan PWM
    [Documentation]    Get current CPU fan PWM
    IF    "${FAN_PWM_MEASUREMENT_METHOD}" == "none"
        Fail    Wrong platform configuration. FAN_RPM_MEASUREMENT_METHOD is
        ...    none. Either it should be changed or this test should not be
        ...    performed on this platform.
    ELSE IF    "${FAN_PWM_MEASUREMENT_METHOD}" == "hwmon"
        ${hwmon}=    Execute Command In Terminal
        ...    ls ${FAN_PWM_MEASUREMENT_HWMON_PATH} | grep hwmon
        ${pwm}=    Execute Command In Terminal
        ...    cat ${FAN_PWM_MEASUREMENT_HWMON_PATH}/${hwmon}/pwm1
        ${pwm}=    Convert To Number    ${pwm}
        RETURN    ${pwm}
    END

Get Fan RPM
    [Documentation]    Get current CPU fan RPM
    IF    "${FAN_RPM_MEASUREMENT_METHOD}" == "lm-sensors"
        IF    "${FAN_RPM_MEASUREMENT_SENSOR}" != "none"
            ${rpm}=    Execute Linux Command
            ...    sensors ${FAN_RPM_MEASUREMENT_SENSOR} 2> /dev/null | grep -E 'fan1' | tr -s ' ' | cut -d ' ' -f2
            ${rpm}=    Convert To Integer    ${rpm}
            RETURN    ${rpm}
        ELSE
            Fail    FAN_RPM_MEASUREMENT_METHOD "${FAN_RPM_MEASUREMENT_METHOD}"
            ...    requires giving a valid FAN_RPM_MEASUREMENT_SENSOR,
            ...    currently set to ${FAN_RPM_MEASUREMENT_SENSOR}
        END
    ELSE IF    "${FAN_RPM_MEASUREMENT_METHOD}" == "system76-acpi"
        ${speed}=    Execute Command In Terminal    sensors | grep "CPU fan"
        ${speed_split}=    Split String    ${speed}
        ${rpm}=    Get From List    ${speed_split}    2
        RETURN    ${rpm}
    ELSE IF    "${FAN_RPM_MEASUREMENT_METHOD}" == "none"
        Fail    Wrong platform configuration. FAN_RPM_MEASUREMENT_METHOD is
        ...    none. Either it should be changed or this test should not be
        ...    performed on this platform.
    ELSE
        Fail    Wrong platform configuration. FAN_RPM_MEASUREMENT_METHOD is
        ...    of unknown value ${FAN_RPM_MEASUREMENT_METHOD}.
    END
