*** Settings ***
Documentation       This library defines keywords for reading sensor data from
...                 devices. It might need to be mostly scrapped and implemented as keywords
...                 defined in the platform configs if it turns out that this process
...                 differs too much depending on the platform.

Resource            ../terminal.robot


*** Keywords ***
Prepare Sensors
    [Documentation]    Boot, then run the device's `requirements` (once) and
    ...    `prepare` (per boot) bash steps from the config.
    Power On
    Boot System Or From Connected Disk    ${BOOTED_OS_ID}
    Login To Linux
    IF    ${BOOTED_OS_ID} != ${ENV_ID_QUBES}    Switch To Root User
    Import Variables    ${CURDIR}/../../platform-configs/${SENSORS_CONFIG_FILE}
    ${requirements}=    Get From Dictionary    ${SENSORS_REQUIREMENTS_COMMANDS}    ${BOOTED_OS_ID}    default=@{EMPTY}
    FOR    ${cmd}    IN    @{requirements}
        Execute Command In Terminal    ${cmd}
    END
    FOR    ${cmd}    IN    @{SENSORS_PREPARE_COMMANDS}
        Execute Command In Terminal    ${cmd}
    END

Sensors Measure
    [Documentation]    Run a measurement bash pipeline:
    ...    gather -> filter -> postprocess
    ...    Piping stdout to stdin of every command and logging each stage.
    [Arguments]    ${measurement}
    ${gather}=    Get From Dictionary    ${measurement}    gather
    ${filter}=    Get From Dictionary    ${measurement}    filter    default=${EMPTY}
    IF    not $filter or $filter=='None'    VAR    ${filter}=    cat
    ${postprocess}=    Get From Dictionary    ${measurement}    postprocess    default=${EMPTY}
    IF    not $postprocess or $postprocess=='None'
        VAR    ${postprocess}=    cat
    END
    ${value}=    Execute Command In Terminal
    ...    set -o pipefail; ${gather} | tee /tmp/sensors.gather | ${filter} | tee /tmp/sensors.filter | ${postprocess}
    # For debugging in the future save the intermediate values
    ${raw}=    Execute Command In Terminal    cat /tmp/sensors.gather
    ${filtered}=    Execute Command In Terminal    cat /tmp/sensors.filter
    RETURN    ${value}

Get CPU Temperature
    [Documentation]    Get current CPU temperature. Might need preparing the
    ...    sensors using `Prepare Sensors` keyword.
    ${v}=    Sensors Measure    ${CPU_TEMPERATURE_MEASUREMENT}
    RETURN    ${v}

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
    [Documentation]    Get current CPU fan PWM. Might need preparing the
    ...    sensors using `Prepare Sensors` keyword.
    ${v}=    Sensors Measure    ${FAN_PWM_MEASUREMENT}
    RETURN    ${v}

Get Fan RPM
    [Documentation]    Get current CPU fan RPM. Might need preparing the
    ...    sensors using `Prepare Sensors` keyword.
    ${v}=    Sensors Measure    ${FAN_RPM_MEASUREMENT}
    RETURN    ${v}

Is Fan PWM Measurement Supported
    ${supported}=    Run Keyword And Return Status
    ...    Variable Should Exist    ${FAN_PWM_MEASUREMENT}
    RETURN    ${supported}

Is Fan RPM Measurement Supported
    ${supported}=    Run Keyword And Return Status
    ...    Variable Should Exist    ${FAN_RPM_MEASUREMENT}
    RETURN    ${supported}

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
