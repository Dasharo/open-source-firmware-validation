*** Settings ***
Documentation       CPU header for OSFV Performance Library

Resource            common.robot


*** Keywords ***
Get CPU Frequency MAX
    [Documentation]    Get max CPU Frequency.
    ${freq}=    Execute Command In Terminal    lscpu | grep "CPU max"
    ${freq}=    Split String    ${freq}
    ${freq}=    Get From List    ${freq}    3
    ${freq}=    Split String    ${freq}    separator=,
    ${freq}=    Get From List    ${freq}    0
    ${freq}=    Convert To Number    ${freq}
    ${freq}=    Evaluate    ${freq}+100
    RETURN    ${freq}

Get CPU Frequency MIN
    [Documentation]    Get min CPU Frequency.
    ${freq}=    Execute Command In Terminal    lscpu | grep "CPU min"
    ${freq}=    Split String    ${freq}
    ${freq}=    Get From List    ${freq}    3
    ${freq}=    Split String    ${freq}    separator=,
    ${freq}=    Get From List    ${freq}    0
    ${freq}=    Convert To Number    ${freq}
    ${freq}=    Evaluate    ${freq}-100
    RETURN    ${freq}

Get CPU Frequencies In Linux
    [Documentation]    Get all CPU frequencies in Ubuntu OS. Keyword returns
    ...    list of current CPU frequencies
    VAR    @{frequency_list}=    @{EMPTY}
    ${output}=    Execute Command In Terminal    cat /proc/cpuinfo
    ${output}=    Get Lines Containing String    ${output}    cpu MHz
    @{frequencies}=    Split To Lines    ${output}
    FOR    ${frequency}    IN    @{frequencies}
        ${frequency}=    Fetch From Right    ${frequency}    :
        ${frequency}=    Convert To Number    ${frequency}
        Append To List    ${frequency_list}    ${frequency}
    END
    RETURN    @{frequency_list}

Check If CPU Not Stuck On Initial Frequency In Linux
    [Documentation]    Check that CPU not stuck on initial frequency.
    VAR    ${are_frequencies_equal}=    ${TRUE}
    @{frequencies}=    Get CPU Frequencies In Linux
    ${first_frequency}=    Get From List    ${frequencies}    0
    FOR    ${frequency}    IN    @{frequencies}
        IF    ${frequency} != ${first_frequency}
            VAR    ${are_frequencies_equal}=    ${FALSE}
        ELSE
            VAR    ${are_frequencies_equal}=    ${NONE}
        END
        IF    '${are_frequencies_equal}'=='False'    BREAK
    END
    IF    '${are_frequencies_equal}'=='False'
        Pass Execution    CPU does not stuck on initial frequency
    END
    IF    ${first_frequency}!=${INITIAL_CPU_FREQUENCY}
        Pass Execution    CPU does not stuck on initial frequency
    ELSE
        FAIL    CPU stuck on initial frequency: ${INITIAL_CPU_FREQUENCY}
    END

Check If CPU Not Stuck On Initial Frequency In Windows
    [Documentation]    Check that CPU not stuck on initial frequency.
    ${out}=    Execute Command In Terminal
    ...    (Get-CimInstance CIM_Processor).MaxClockSpeed*((Get-Counter -Counter "\\Processor Information(_Total)\\% Processor Performance").CounterSamples.CookedValue/100)
    FOR    ${number}    IN RANGE    0    10
        ${out2}=    Execute Command In Terminal
        ...    (Get-CimInstance CIM_Processor).MaxClockSpeed*((Get-Counter -Counter "\\Processor Information(_Total)\\% Processor Performance").CounterSamples.CookedValue/100)
        Should Not Be Equal    ${out}    ${out2}
    END

Get CPU Frequency In Windows
    ${freq_current_info}=    Execute Command In Terminal
    ...    (Get-CimInstance CIM_Processor).MaxClockSpeed*((Get-Counter -Counter "\\Processor Information(_Total)\\% Processor Performance").CounterSamples.CookedValue)/100
    ${freq_current_line}=    Get Line    ${freq_current_info}    -1
    ${matches}=    Get Regexp Matches    ${freq_current_line}    \\d+(?:\\.\\d+)?
    ${freq_current}=    Get From List    ${matches}    0
    Should Not Be Empty    ${freq_current}    Failed to get current frequency
    ${freq_current}=    Convert To Number    ${freq_current}
    RETURN    ${freq_current}

Check CPU Frequency In Windows
    [Documentation]    Check that CPU is running on expected frequency.
    ${freq_max_info}=    Execute Command In Terminal    (Get-CimInstance CIM_Processor).MaxClockSpeed
    ${freq}=    Get CPU Frequency In Windows
    Should Be True    ${CPU_MAX_FREQUENCY} >= ${freq}

Stress Test
    [Documentation]    Proceed with the stress test.
    [Arguments]    ${time}=60s    ${workers}=$(nproc)    ${load_percent}=100    ${start_delay_seconds}=0

    VAR    ${cmd}=
    ...    $(
    ...    pkill stress-ng;
    ...    sleep ${start_delay_seconds};
    ...    stress-ng --cpu ${workers} --cpu-load ${load_percent} --timeout ${time} -q &> /dev/null
    ...    ) & disown
    ...    separator=${SPACE}
    Execute Command In Terminal    ${cmd}

Stress Test Stop
    Execute Command In Terminal    pkill stress-ng
