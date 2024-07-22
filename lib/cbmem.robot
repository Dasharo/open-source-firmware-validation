*** Settings ***
Documentation       Collection of keywords for getting boot time from cbmem in linux

Resource            ../keywords.robot


*** Keywords ***
Get Boot Time From Cbmem
    [Documentation]    Calculates boot time based on cbmem timestamps
    # fix for LT1000 and protectli platforms (output without tabs)
    Get Cbmem From Cloud
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

Calculate Boot Time Statistics
    [Documentation]    Calculates the standard deviation, min, max of
    ...    boot time measurements
    [Arguments]    ${samples}
    ${iterations}=    Get Length    ${samples}
    ${standard_deviation}=    Set Variable    0
    ${min}=    Set Variable    99999999
    ${max}=    Set Variable    0
    ${average}=    Set Variable    0

    FOR    ${index}    IN RANGE    0    ${iterations}
        ${duration}=    Get From List    ${samples}    ${index}
        ${min}=    Evaluate    ${min} if float(${min}) < float(${duration}) else ${duration}
        ${max}=    Evaluate    ${max} if float(${max}) > float(${duration}) else ${duration}
        ${average}=    Evaluate    ${average} + ${duration}
    END
    ${average}=    Evaluate    ${average}/${iterations}

    FOR    ${index}    IN RANGE    0    ${iterations}
        ${duration}=    Get From List    ${samples}    ${index}
        ${diff}=    Evaluate    ${duration} - ${average}
        ${diff}=    Evaluate    ${diff}**2
        ${standard_deviation}=    Evaluate    ${standard_deviation} + ${diff}
    END

    RETURN    ${min}    ${max}    ${average}    ${standard_deviation}
