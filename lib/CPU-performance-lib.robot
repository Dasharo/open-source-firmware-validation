*** Keywords ***
Get CPU Frequency MAX
    [Documentation]    Get max CPU Frequency.
    ${freq}=    Execute Command In Terminal    lscpu | grep "CPU max"
    ${freq}=    Split String    ${freq}
    ${freq}=    Get From List    ${freq}    3
    ${freq}=    Split String    ${freq}    separator=,
    ${freq}=    Get From List    ${freq}    0
    ${freq}=    Convert To Number    ${freq}
    RETURN    ${freq}

Get CPU Frequency MIN
    [Documentation]    Get min CPU Frequency.
    ${freq}=    Execute Command In Terminal    lscpu | grep "CPU min"
    ${freq}=    Split String    ${freq}
    ${freq}=    Get From List    ${freq}    3
    ${freq}=    Split String    ${freq}    separator=,
    ${freq}=    Get From List    ${freq}    0
    ${freq}=    Convert To Number    ${freq}
    RETURN    ${freq}

Get CPU Temperature CURRENT
    [Documentation]    Get current CPU temperature.
    ${temperature}=    Execute Command In Terminal    sensors | grep "Package id 0"
    ${temperature}=    Fetch From Left    ${temperature}    °C
    ${temperature}=    Fetch From Right    ${temperature}    +
    ${temperature}=    Convert To Number    ${temperature}
    RETURN    ${temperature}

Get CPU Frequencies In Ubuntu
    [Documentation]    Get all CPU frequencies in Ubuntu OS. Keyword returns
    ...    list of current CPU frequencies
    @{frequency_list}=    Create List
    ${output}=    Execute Command In Terminal    cat /proc/cpuinfo
    ${output}=    Get Lines Containing String    ${output}    clock
    @{frequencies}=    Split To Lines    ${output}
    FOR    ${frequency}    IN    @{frequencies}
        ${frequency}=    Evaluate    re.sub(r'(?s)[^0-9]*([1-9][0-9]*)[,.][0-9]+MHz', r'\\1', $frequency)
        ${frequency}=    Convert To Number    ${frequency}
        Append To List    ${frequency_list}    ${frequency}
    END
    RETURN    @{frequency_list}

Check If CPU Not Stucks On Initial Frequency In Ubuntu
    [Documentation]    Check that CPU not stuck on initial frequency.
    ${is_cpu_stucks}=    Set Variable    ${FALSE}
    ${are_frequencies_equal}=    Set Variable    ${TRUE}
    @{frequencies}=    Get CPU Frequencies In Ubuntu
    ${first_frequency}=    Get From List    ${frequencies}    0
    FOR    ${frequency}    IN    @{frequencies}
        IF    ${frequency} != ${first_frequency}
            ${are_frequencies_equal}=    Set Variable    ${FALSE}
        ELSE
            ${are_frequencies_equal}=    Set Variable    ${NONE}
        END
        IF    '${are_frequencies_equal}'=='False'    BREAK
    END
    IF    '${are_frequencies_equal}'=='False'
        Pass Execution    CPU does not stuck on initial frequency
    END
    IF    ${first_frequency}!=${INITIAL_CPU_FREQUENCY}
        Pass Execution    CPU does not stuck on initial frequency
    ELSE
        FAIL    CPU stucks on initial frequency: ${INITIAL_CPU_FREQUENCY}
    END

Check If CPU Not Stucks On Initial Frequency In Windows
    [Documentation]    Check that CPU not stuck on initial frequency.
    ${out}=    Execute Command In Terminal
    ...    (Get-CimInstance CIM_Processor).MaxClockSpeed*((Get-Counter -Counter "\\Processor Information(_Total)\\% Processor Performance").CounterSamples.CookedValue/100)
    FOR    ${number}    IN RANGE    0    10
        ${out2}=    Execute Command In Terminal
        ...    (Get-CimInstance CIM_Processor).MaxClockSpeed*((Get-Counter -Counter "\\Processor Information(_Total)\\% Processor Performance").CounterSamples.CookedValue/100)
        Should Not Be Equal    ${out}    ${out2}
    END

Check CPU Frequency In Windows
    [Documentation]    Check that CPU is running on expected frequency.
    ${freq_max_info}=    Execute Command In Terminal    (Get-CimInstance CIM_Processor).MaxClockSpeed
    ${freq_max}=    Get Line    ${freq_max_info}    -1
    ${freq_max}=    Convert To Number    ${freq_max}
    FOR    ${number}    IN RANGE    0    10
        ${freq_current_info}=    Execute Command In Terminal
        ...    (Get-CimInstance CIM_Processor).MaxClockSpeed*((Get-Counter -Counter "\\Processor Information(_Total)\\% Processor Performance").CounterSamples.CookedValue)/100
        ${freq_current}=    Get Line    ${freq_current_info}    -1
        ${freq_current}=    Convert To Number    ${freq_current}
        Run Keyword And Continue On Failure
        ...    Should Be True    ${freq_max} > ${freq_current}
    END

Stress Test
    [Documentation]    Proceed with the stress test.
    [Arguments]    ${time}=60s
    Detect Or Install Package    stress-ng
    Execute Command In Terminal    stress-ng --cpu 1 --timeout ${time} &> /dev/null &

Check Power Supply
    IF    ${TESTS_IN_UBUNTU_SUPPORT}
        ${bat0_present}    ${ac_online}    ${usb-pd_online}=    Check Power Supply On Linux
    ELSE IF    ${TESTS_IN_WINDOWS_SUPPORT}
        Log    Check Power Supply on Windows not implemented yet    ERROR
    ELSE IF    ${HEADS_PAYLOAD_SUPPORT}
        Log    Check Power Supply on Heads not implemented yet    ERROR
    ELSE
        Fail    Fail: Check Power Supply is not implemented enough
    END
    Set Suite Variable    ${BATTERY_PRESENT}    ${bat0_present}
    Set Suite Variable    ${AC_CONNECTED}    ${ac_online}
    Set Suite Variable    ${USB-PD_CONNECTED}    ${usb-pd_online}

Check Power Supply On Linux
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    ${bat0_present_raw}=    Execute Command In Terminal    cat /sys/class/power_supply/BAT0/present
    ${bat0_present}=    Run Keyword And Return Status    Should Contain    ${bat0_present_raw}    1

    ${ac_online_raw}=    Execute Command In Terminal    cat /sys/class/power_supply/AC/online
    Should Not Contain    ${ac_online_raw}    No such file or directory
    ${ac_online}=    Run Keyword And Return Status    Should Contain    ${ac_online_raw}    1

    ${usb-pd_online_raw}=    Execute Command In Terminal    cat /sys/class/power_supply/USB-PD/online
    Log    'cat /sys/class/power_supply/USB-PD/online' not implemented yet, if implemented, remove #    WARN
    # Should Not Contain    ${USB-PD_online_raw}    No such file or directory
    ${usb-pd_online}=    Run Keyword And Return Status    Should Contain    ${usb-pd_online_raw}    1

    RETURN    ${bat0_present}    ${ac_online}    ${usb-pd_online}
