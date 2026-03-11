*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       common keywords for CPT_CPF_STB concurrent tests

Library             Collections
Library             DateTime
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../lib/performance/cpu.robot
Resource            ../../lib/sensors/sensors.robot
Resource            ../../lib/concurrent-testing.robot


*** Keywords ***
Background Measurements
    [Documentation]    Keyword for gathering CPU temps, freqs and stability info
    ...    in concurrent. Set '${id_*}' vars to a test case ID to save the results
    ...    for this type of measurements under a chosen ID. Set to none to skip
    ...    measurements of the given type.
    [Arguments]    ${id_temp}=${None}    ${id_freq}=${None}    ${id_stab}=${None}
    # Initialization
    VAR    @{temp_list}=    @{EMPTY}
    VAR    @{freq_list}=    @{EMPTY}
    VAR    @{stab_list}=    @{EMPTY}
    ${next_temp_time}=    Evaluate    0 if $id_temp is not ${None} else 999999
    ${next_freq_time}=    Evaluate    0 if $id_freq is not ${None} else 999999
    ${next_stab_time}=    Evaluate    0 if $id_stab is not ${None} else 999999
    VAR    ${longest_duration}=
    ...    max(${TEMPERATURE_TEST_DURATION}, ${FREQUENCY_TEST_DURATION}, ${STABILITY_TEST_DURATION})

    ${start}=    Get Current Date
    VAR    ${timer}=    0
    VAR    ${time_to_next_interval}=    0
    # measurement loop
    WHILE    ${timer} < ${longest_duration}
        Sleep    ${time_to_next_interval}s
        Log To Console    === ${timer} s:

        IF    ${TEMPERATURE_TEST_DURATION} >= ${timer} >= ${next_temp_time}
            ${temperature}=    Get CPU Temperature
            ${next_temp_time}=    Evaluate    ${timer} + ${TEMPERATURE_TEST_MEASURE_INTERVAL}
            Append To List    ${temp_list}    ${temperature}
            Log To Console    Temperature: ${temperature}
        END
        IF    ${timer} > ${TEMPERATURE_TEST_DURATION}
            VAR    ${next_temp_time}=    999999
        END

        IF    ${FREQUENCY_TEST_DURATION} >= ${timer} >= ${next_freq_time}
            ${freqs}=    Get CPU Frequencies In Linux
            ${next_freq_time}=    Evaluate    ${timer} + ${FREQUENCY_TEST_MEASURE_INTERVAL}
            Append To List    ${freq_list}    ${freqs}
            Log To Console    Frequencies: ${freqs}
        END
        IF    ${timer} > ${FREQUENCY_TEST_DURATION}
            VAR    ${next_freq_time}=    999999
        END

        IF    ${STABILITY_TEST_DURATION} >= ${timer} >= ${next_stab_time}
            ${network_status}=    Execute Command In Terminal    ip link | grep -E 'enp|eno' | grep -Eo 'UP|DOWN'
            ${uptime_output}=    Execute Command In Terminal    cat /proc/uptime
            ${uptime_list}=    Split String    ${uptime_output}    ${SPACE}
            ${current_uptime}=    Convert To Number    ${uptime_list}[0]
            VAR    &{stab_data}=    network=${network_status}    uptime=${current_uptime}
            ${next_stab_time}=    Evaluate    ${timer} + ${STABILITY_TEST_MEASURE_INTERVAL}
            Append To List    ${stab_list}    ${stab_data}
            Log To Console    Stability: uptime ${current_uptime}
        END
        IF    ${timer} > ${STABILITY_TEST_DURATION}
            VAR    ${next_stab_time}=    999999
        END

        ${now}=    Get Current Date
        ${timer}=    Subtract Date From Date    ${now}    ${start}
        ${time_to_next_interval}=    Evaluate
        ...    max(0, min(${next_stab_time}, ${next_freq_time}, ${next_temp_time}) - ${timer})
    END

    Set Concurrent Test Outputs    ${id_temp}    ${temp_list}
    Set Concurrent Test Outputs    ${id_freq}    ${freq_list}
    Set Concurrent Test Outputs    ${id_stab}    ${stab_list}

Background Measurements Windows
    [Documentation]    Keyword for gathering CPU temps, freqs and stability info
    ...    in concurrent. Set '${id_*}' vars to a test case ID to save the results
    ...    for this type of measurements under a chosen ID. Set to none to skip
    ...    measurements of the given type.
    [Arguments]    ${id_freq}=${None}    ${id_stab}=${None}
    # Initialization
    VAR    @{freq_list}=    @{EMPTY}
    VAR    @{stab_list}=    @{EMPTY}
    ${next_freq_time}=    Evaluate    0 if $id_freq is not ${None} else 999999
    ${next_stab_time}=    Evaluate    0 if $id_stab is not ${None} else 999999
    VAR    ${longest_duration}=
    ...    max(${FREQUENCY_TEST_DURATION}, ${STABILITY_TEST_DURATION})

    ${start}=    Get Current Date
    VAR    ${timer}=    0
    VAR    ${time_to_next_interval}=    0
    # measurement loop
    WHILE    ${timer} < ${longest_duration}
        Sleep    ${time_to_next_interval}

        IF    ${FREQUENCY_TEST_DURATION} >= ${timer} >= ${next_freq_time}
            ${freqs}=    Get CPU Frequency In Windows
            VAR    @{freqs}=    ${freqs}
            # Only single value can be read using this KWd in
            ${next_freq_time}=    Evaluate    ${timer} + ${FREQUENCY_TEST_MEASURE_INTERVAL}
            Append To List    ${freq_list}    ${freqs}
            Log To Console    ${timer}s: Frequencies: ${freqs}
        END
        IF    ${timer} > ${FREQUENCY_TEST_DURATION}
            VAR    ${next_freq_time}=    999999
        END

        IF    ${STABILITY_TEST_DURATION} >= ${timer} >= ${next_stab_time}
            ${uptime_output}=    Execute Command In Terminal
            ...    (get-date) - (gcim Win32_OperatingSystem).LastBootUpTime
            ${network_status}=    Execute Command In Terminal    Get-NetAdapter -Name "Ethernet*"
            ${total_seconds_line}=    Get Lines Matching Regexp    ${uptime_output}    .*TotalSeconds.*
            @{line_parts}=    Split String    ${total_seconds_line}    :
            VAR    ${total_seconds}=    ${line_parts[1]}
            ${total_seconds}=    Strip String    ${total_seconds}
            ${total_seconds}=    Convert To Number    ${total_seconds}
            VAR    &{stab_data}=    network=${network_status}    uptime=${total_seconds}
            ${next_stab_time}=    Evaluate    ${timer} + ${STABILITY_TEST_MEASURE_INTERVAL}
            Append To List    ${stab_list}    ${stab_data}
            Log To Console    ${timer}s: Stability: uptime ${total_seconds}
        END
        IF    ${timer} > ${STABILITY_TEST_DURATION}
            VAR    ${next_stab_time}=    999999
        END

        ${now}=    Get Current Date
        ${timer}=    Subtract Date From Date    ${now}    ${start}
        ${time_to_next_interval}=    Evaluate
        ...    max(0, min(${next_stab_time}, ${next_freq_time}) - ${timer})
    END

    Set Concurrent Test Outputs    ${id_freq}    ${freq_list}
    Set Concurrent Test Outputs    ${id_stab}    ${stab_list}

Check CPU Frequencies Not Stuck
    [Documentation]    Check if a list of CPU frequencies shows them being stuck
    ...    to defaults.
    [Arguments]    ${frequencies}
    ${first_frequency}=    Get From List    ${frequencies}    0
    FOR    ${frequency}    IN    @{frequencies}
        IF    ${frequency} != ${INITIAL_CPU_FREQUENCY}
            Pass Execution    CPU does not stuck on initial frequency
        END
    END
    Fail    CPU stuck on initial frequency: ${INITIAL_CPU_FREQUENCY}

Check CPU Temps
    [Documentation]    Check if a list of temperature measurements shows
    ...    acceptable temperature values
    [Arguments]    ${temps}
    ${sum}=    Evaluate    0
    ${len}=    Get Length    ${temps}
    FOR    ${temp}    IN    @{temps}
        ${sum}=    Evaluate    ${sum} + ${temp}
    END
    ${avg}=    Evaluate    ${sum} / ${len}
    ${min}=    Evaluate    min($temps)
    ${max}=    Evaluate    max($temps)
    Log To Console    Average temp: ${avg}
    Log To Console    Min temp: ${min}
    Log To Console    Max temp: ${max}
    Log To Console    Test threshold of CPU temp: ${MAX_CPU_TEMP}°C
    Should Be True    ${avg} < ${MAX_CPU_TEMP}    Average is higher than threshold

Check CPU Freqs Linux
    [Documentation]    Check if a list of frequency measurements shows
    ...    acceptable frequency values
    [Arguments]    ${freqs}
    ${cpu_max_frequency_tol}=    Evaluate    ${CPU_MAX_FREQUENCY} * 1.125
    ${cpu_min_frequency_tol}=    Evaluate    ${CPU_MIN_FREQUENCY} * 0.875
    FOR    ${freqs_cores}    IN    @{freqs}
        FOR    ${core}    IN    @{freqs_cores}
            ${in_range}=    Evaluate    ${cpu_min_frequency_tol} <= ${core} <= ${cpu_max_frequency_tol}
            Should Be True    ${in_range}    Encountered invalid frequency: ${in_range} MHz
        END
    END

Check CPU Freqs Windows
    [Documentation]    Check if a list of frequency measurements shows
    ...    acceptable frequency values
    [Arguments]    ${freqs}
    ${freq_max_info}=    Execute Command In Terminal    (Get-CimInstance CIM_Processor).MaxClockSpeed
    FOR    ${number}    IN RANGE    0    10
        ${freq_current_info}=    Execute Command In Terminal
        ...    (Get-CimInstance CIM_Processor).MaxClockSpeed*((Get-Counter -Counter "\\Processor Information(_Total)\\% Processor Performance").CounterSamples.CookedValue)/100
        ${freq_current_line}=    Get Line    ${freq_current_info}    -1
        ${matches}=    Get Regexp Matches    ${freq_current_line}    \\d+(?:\\.\\d+)?
        ${freq_current}=    Get From List    ${matches}    0
        Should Not Be Empty    ${freq_current}    Failed to get current frequency
        ${freq_current}=    Convert To Number    ${freq_current}
        Run Keyword And Continue On Failure
        ...    Should Be True    ${CPU_MAX_FREQUENCY} >= ${freq_current}
    END

Check Platform Stability
    [Documentation]    Check if a list of stability measurements shows
    ...    the platform is stable
    [Arguments]    ${measurements}
    ${last_uptime}=    Evaluate    0
    FOR    ${measurement}    IN    @{measurements}
        # no reboot since previous measurement
        Should Be True    float(${measurement["uptime"]}) > float(${last_uptime})
        # the network interface is up
        Should Contain    ${measurement["network"]}    UP    ignore_case=${True}
    END

Check Unexpected Boot Errors
    [Documentation]    This keyword checks if any unexpected boot messages
    ...    appear in kernel logs. Messages with loglevel 3 (error) or lower
    ...    (more critical) are considered.
    [Arguments]    ${log}
    VAR    @{dmesg_err_allowlist}=    @{EMPTY}
    # Harmless error on Bluetooth modules
    Append To List    ${dmesg_err_allowlist}    Bluetooth: hci0: Malformed MSFT vendor event: 0x02
    # Intel AX-series WiFi+BT adapters throw these when debug features are disabled
    Append To List    ${dmesg_err_allowlist}    Bluetooth: hci0: No support for _PRR ACPI method
    Append To List    ${dmesg_err_allowlist}    iwlwifi 0000:00:14.3: WRT: Invalid buffer destination
    Append To List
    ...    ${dmesg_err_allowlist}
    ...    iwlwifi 0000:00:14.3: Not valid error log pointer 0x0027B0C0 for RT uCode
    # GSC firmware loading via MEI fails when ME is disabled - not our bug
    Append To List
    ...    ${dmesg_err_allowlist}
    ...    i915 0000:00:02.0: [drm] *ERROR* GT1: GSC proxy component didn't bind within the expected timeout
    Append To List    ${dmesg_err_allowlist}    i915 0000:00:02.0: [drm] *ERROR* GT1: GSC proxy handler failed to init
    # Not our bug
    Append To List    ${dmesg_err_allowlist}    proc_thermal_pci 0000:00:04.0: error: proc_thermal_add, will continue
    Append To List    ${dmesg_err_allowlist}    tmpfs: Unsupported parameter 'huge'
    Append To List    ${dmesg_err_allowlist}    x86/mktme: No known encryption algorithm is supported: 0x4
    @{log}=    Split To Lines    ${log}
    FOR    ${error}    IN    @{log}
        Should Contain    ${dmesg_err_allowlist}    ${error}
    END
