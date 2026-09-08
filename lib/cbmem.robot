*** Settings ***
Documentation       Keywords for reading coreboot cbmem logs and timestamps in Linux

Resource            ../keywords.robot


*** Keywords ***
Get Coreboot Console Log
    [Documentation]
    ...    Returns the coreboot console log collected with ``cbmem -1``.
    ...    The first call in a suite boots Ubuntu, logs in as root, and
    ...    caches the log. Later calls reuse that cache so CBP log-check
    ...    tests do not each power-cycle the DUT.
    ...
    ...    === Requirements ===
    ...    - The device has to be turned on, or this keyword will power it on
    ...    - Ubuntu has to be bootable (``${TESTS_IN_UBUNTU_SUPPORT}``)
    ...    - ``cbmem`` available as root (same as other OSFV cbmem tests)
    ...
    ...    === Arguments ===
    ...    None
    ...
    ...    === Return Value ===
    ...    - ``string`` - Full coreboot console log from ``cbmem -1``
    ...
    ...    === Effects ===
    ...    - On cache miss: powers on the DUT, boots Ubuntu, logs in, and
    ...    \ switches to root. On cache hit: none.
    ${cached}=    Get Variable Value    ${COREBOOT_CONSOLE_LOG}    ${NONE}
    IF    $cached is not None    RETURN    ${cached}
    Power On
    Boot And Login To OS    ${ENV_ID_UBUNTU}
    Switch To Root User
    ${boot_log}=    Execute Command In Terminal    cbmem -1    timeout=180s
    ${boot_log}=    Strip String    ${boot_log}
    Should Not Be Empty    ${boot_log}    cbmem -1 returned an empty coreboot console log
    Should Not Contain
    ...    ${boot_log}
    ...    Operation not permitted
    ...    msg=Cannot get cbmem log. Probably Secure Boot is enabled (kernel lockdown mode).
    Should Not Contain    ${boot_log}    command not found    msg=cbmem is not installed on the DUT
    VAR    ${COREBOOT_CONSOLE_LOG}=    ${boot_log}    scope=SUITE
    RETURN    ${boot_log}

Get Boot Time From Cbmem
    [Documentation]    Calculates boot time based on cbmem timestamps
    # fix for LT1000 and protectli platforms (output without tabs)
    ${out_cbmem}=    Execute Command In Terminal    cbmem -T
    Should Not Contain
    ...    ${out_cbmem}
    ...    Operation not permitted
    ...    msg=Cannot get cbmem log. Probably Secure Boot is enabled (kernel lockdown mode).
    ${lines}=    Split To Lines    ${out_cbmem}
    ${first_line}=    Get From List    ${lines}    0
    ${last_line}=    Get From List    ${lines}    -1
    ${first_timestamp}=    Get Timestamp From Cbmem Log    ${first_line}
    ${last_timestamp}=    Get Timestamp From Cbmem Log    ${last_line}
    ${boot_time}=    Evaluate    (${last_timestamp} - ${first_timestamp}) / 1000000
    RETURN    ${boot_time}

Get Timestamp From Cbmem Log
    [Documentation]    Returns timestamp from a single cbmem -T log line
    [Arguments]    ${line}
    ${columns}=    Split String    ${line}
    ${timestamp}=    Get From List    ${columns}    1
    RETURN    ${timestamp}

Get First Timestamp From Cbmem Log
    [Documentation]    Return the first timestamp from cbmem timestamps
    # fix for LT1000 and protectli platforms (output without tabs)
    ${out_cbmem}=    Execute Command In Terminal    cbmem -T
    Should Not Contain
    ...    ${out_cbmem}
    ...    Operation not permitted
    ...    msg=Cannot get cbmem log. Probably Secure Boot is enabled (kernel lockdown mode).
    ${lines}=    Split To Lines    ${out_cbmem}
    ${first_line}=    Get From List    ${lines}    0
    ${first_timestamp}=    Get Timestamp From Cbmem Log    ${first_line}
    ${boot_start}=    Evaluate    float(${first_timestamp} / 1000000.0)
    RETURN    ${boot_start}

Calculate Boot Time Statistics
    [Documentation]    Calculates the standard deviation, min, max of
    ...    boot time measurements
    [Arguments]    ${samples}
    ${iterations}=    Get Length    ${samples}
    VAR    ${standard_deviation}=    0
    VAR    ${min}=    99999999
    VAR    ${max}=    0
    VAR    ${average}=    0

    FOR    ${index}    IN RANGE    0    ${iterations}
        ${duration}=    Get From List    ${samples}    ${index}
        ${min}=    Evaluate
        ...    ${min} if float(${min}) < float(${duration}) else ${duration}
        ${max}=    Evaluate
        ...    ${max} if float(${max}) > float(${duration}) else ${duration}
        ${average}=    Evaluate    ${average} + ${duration}
    END
    ${average}=    Evaluate    ${average}/${iterations}

    FOR    ${index}    IN RANGE    0    ${iterations}
        ${duration}=    Get From List    ${samples}    ${index}
        ${diff}=    Evaluate    (${duration} - ${average})
        ${diff}=    Evaluate    ${diff}*${diff}
        ${standard_deviation}=    Evaluate    ${standard_deviation} + ${diff}
    END
    ${standard_deviation}=    Evaluate
    ...    math.sqrt(${standard_deviation} / ${iterations})

    RETURN    ${min}    ${max}    ${average}    ${standard_deviation}
