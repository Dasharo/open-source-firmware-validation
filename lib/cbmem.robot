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

Measure Average Warmboot Time Cbmem
    [Documentation]    Performs a measurement of average warmboot
    ...    boot time
    [Arguments]    ${iterations}

    ${average}=    Set Variable    0
    Log To Console    \n

    FOR    ${index}    IN RANGE    0    ${iterations}
        Login To Linux
        Switch To Root User

        # Using "Execute Command In Terimal" will cause the test to wait
        # for command prompt to appear before continuing but the prompt
        # will not appear again until we Login after reboot, so the test
        # would hang here and fail.
        # Sometimes it may take long to shutdown all systemd services,
        # so the waiting times have to be excessive to avoid false negatives.
        Write Into Terminal    rtcwake -m off -s 60

        Set DUT Response Timeout    300s

        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s)
        ${average}=    Evaluate    ${average}+${boot_time}
    END
    ${average}=    Evaluate    ${average}/${iterations}
    RETURN    ${average}

Measure Average Reboot Time Cbmem
    [Documentation]    Performs a measurement of average reboot
    ...    boot time
    [Arguments]    ${iterations}

    ${average}=    Set Variable    0
    Log To Console    \n

    FOR    ${index}    IN RANGE    0    ${iterations}
        Login To Linux
        Switch To Root User

        Execute Reboot Command
        Sleep    10s

        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s)
        ${average}=    Evaluate    ${average}+${boot_time}
    END

    ${average}=    Evaluate    ${average}/${iterations}
    RETURN    ${average}