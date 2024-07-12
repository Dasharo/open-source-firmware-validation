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

Get CPU Temperature CURRENT
    [Documentation]    Get current CPU temperature.
    ${temperature}=    Execute Command In Terminal    sensors 2>/dev/null | awk -F '[+°]' '/Package id 0:/ {printf $2}'
    RETURN    ${temperature}

Get CPU Frequencies In Ubuntu
    [Documentation]    Get all CPU frequencies in Ubuntu OS. Keyword returns
    ...    list of current CPU frequencies
    @{frequency_list}=    Create List
    ${output}=    Execute Command In Terminal    cat /proc/cpuinfo
    ${output}=    Get Lines Containing String    ${output}    cpu MHz
    @{frequencies}=    Split To Lines    ${output}
    FOR    ${frequency}    IN    @{frequencies}
        ${frequency}=    Fetch From Right    ${frequency}    :
        ${frequency}=    Convert To Number    ${frequency}
        Append To List    ${frequency_list}    ${frequency}
    END
    RETURN    @{frequency_list}

Check If CPU Not Stuck On Initial Frequency In Ubuntu
    [Documentation]    Check that CPU not stuck on initial frequency.
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

Check CPU Frequency In Windows
    [Documentation]    Check that CPU is running on expected frequency.
    ${freq_max_info}=    Execute Command In Terminal    (Get-CimInstance CIM_Processor).MaxClockSpeed
    FOR    ${number}    IN RANGE    0    10
        ${freq_current_info}=    Execute Command In Terminal
        ...    (Get-CimInstance CIM_Processor).MaxClockSpeed*((Get-Counter -Counter "\\Processor Information(_Total)\\% Processor Performance").CounterSamples.CookedValue)/100
        ${freq_current}=    Get Line    ${freq_current_info}    -1
        ${freq_current}=    Convert To Number    ${freq_current}
        Run Keyword And Continue On Failure
        ...    Should Be True    ${CPU_MAX_FREQUENCY} >= ${freq_current}
    END

Stress Test
    [Documentation]    Proceed with the stress test.
    [Arguments]    ${time}=60s
    Detect Or Install Package    stress-ng
    Execute Command In Terminal    stress-ng --cpu $(nproc) --timeout ${time} &> /dev/null & disown

Check Power Supply
    ${laptop_platform}=    Check The Platform Is A Laptop
    Set Suite Variable    ${LAPTOP_PLATFORM}    ${laptop_platform}
    IF    ${LAPTOP_PLATFORM}
        IF    ${TESTS_IN_UBUNTU_SUPPORT}
            ${bat0_present}    ${ac_online}    ${usb_pd_online}=    Check Power Supply On Linux
        ELSE IF    ${TESTS_IN_WINDOWS_SUPPORT}
            ${bat0_present}    ${ac_online}    ${usb_pd_online}=    Check Power Supply On Windows
        ELSE IF    ${HEADS_PAYLOAD_SUPPORT}
            Log    Check Power Supply on Heads not implemented yet    ERROR
        ELSE
            Fail    Fail: Check Power Supply is not implemented enough
        END
        Set Suite Variable    ${BATTERY_PRESENT}    ${bat0_present}
        Set Suite Variable    ${AC_CONNECTED}    ${ac_online}
        Set Suite Variable    ${USB-PD_CONNECTED}    ${usb_pd_online}
    END

Check The Platform Is A Laptop
    ${laptop_platform}=    Run Keyword And Return Status    Should Contain Any    ${PLATFORM}    novacustom    tuxedo
    RETURN    ${laptop_platform}

Check Power Supply On Linux
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    ${bat0_present_raw}=    Execute Command In Terminal    cat /sys/class/power_supply/BAT0/present
    ${bat0_present}=    Run Keyword And Return Status    Should Be Equal    ${bat0_present_raw}    1

    ${ac_online_raw}=    Execute Command In Terminal    cat /sys/class/power_supply/AC/online
    Should Not Contain    ${ac_online_raw}    No such file or directory
    ${ac_online}=    Run Keyword And Return Status    Should Be Equal    ${ac_online_raw}    1

    # FIXME: USB-PD detection is not yet possible.
    ${usb_pd_online_raw}=    Execute Command In Terminal    cat /sys/class/power_supply/USB-PD/online
    Log    'cat /sys/class/power_supply/USB-PD/online' not implemented yet, if implemented, remove #    WARN
    # Should Not Contain    ${usb_pd_online_raw}    No such file or directory
    ${usb_pd_online}=    Run Keyword And Return Status    Should Be Equal    ${usb_pd_online_raw}    1

    RETURN    ${bat0_present}    ${ac_online}    ${usb_pd_online}

Check Power Supply On Windows
    Power On
    Login To Windows
    ${raw_output}=    Execute Command In Terminal    (Get-WmiObject Win32_Battery).BatteryStatus
    ${bat0_present}=    Run Keyword And Return Status    Should Not Be Empty    ${raw_output}

    # ${ac_online_raw}=    Execute Command In Terminal    (Get-WmiObject Win32_Battery).BatteryStatus
    ${ac_online_empty}=    Run Keyword And Return Status    Should Be Empty    ${raw_output}
    ${ac_online_equal_2}=    Run Keyword And Return Status    Should Be Equal    ${raw_output}    2
    # IF    ${ac_online_raw_empty}    or    ${ac_online_raw_equal_2}
    #    Set Local Variable    ${AC_ONLINE}=    ${TRUE}
    # END
    ${ac_online}=    Set Variable If
    ...    ${ac_online_empty}    ${TRUE}
    ...    ${ac_online_equal_2}    ${TRUE}

    # FIXME: USB-PD detection is not yet possible.
    Log    Check power supply USB-PD not implemented yet    WARN
    ${usb_pd_online}=    Run Keyword And Return Status
    ...    Should Be Equal
    ...    ${raw_output}
    ...    insert the correct USB-PD detection method here

    RETURN    ${bat0_present}    ${ac_online}    ${usb_pd_online}
