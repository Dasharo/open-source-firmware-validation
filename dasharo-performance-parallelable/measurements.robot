*** Settings ***
Library         Collections
Library         DateTime
Library         String
Library         Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library         SSHLibrary    timeout=90 seconds
Resource        ../variables.robot
Resource        ../keywords.robot
Resource        ../lib/performance/cpu.robot
Resource        ../lib/sensors/sensors.robot
Resource        ../lib/parallel-testing.robot

Suite Setup     Run Keywords
...                 Prepare Test Suite
...                 AND    Run Keyword If    "CPT" in " ".join($TEST_CASES) or "CPF" in " ".join($TEST_CASES)
...                 Check Power Supply
...                 AND    Init Parallel Testing
...                 AND    Prepare Parallel Test Suite

*** Variables ***
# TODO: remove, temporary debug values
${FREQUENCY_TEST_MEASURE_INTERVAL}=    1
${TEMPERATURE_TEST_MEASURE_INTERVAL}=    1
${STABILITY_TEST_MEASURE_INTERVAL}=    1
${TEMPERATURE_TEST_DURATION}=    5
${FREQUENCY_TEST_DURATION}=    5
${STABILITY_TEST_DURATION}=    5

*** Test Cases ***
############################################
#    Tests that can be done immediately    #
############################################
_PARALLEL_Background Measurements Immediate (no load) (Ubuntu)
    # immediately skip if no tests want these measurements
    ${will_any_be_run}=    Will Parallel Test Be Run Regex
    ...    (CPF001)|(STB002).201
    Skip If    not ${will_any_be_run}

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    # CPF001.201 steps
    VAR    ${parallel_test_id}=    CPF001.201
    ${check_frequency}=    Will Parallel Test Be Run    ${parallel_test_id}
    IF    ${check_frequency}
        Sleep    10s
        @{frequencies}=    Get CPU Frequencies In Ubuntu
        Set Parallel Test Outputs    ${parallel_test_id}    ${frequencies}
    END

    # STB002.201 steps
    VAR    ${parallel_test_id}=    STB002.201
    ${check_logs}=    Will Parallel Test Be Run    ${parallel_test_id}
    IF    ${check_logs}
        ${dmesg_err_txt}=    Execute Linux Command    dmesg -t -l err,crit,alert,emerg
        Set Parallel Test Outputs    ${parallel_test_id}    ${dmesg_err_txt}
    END

CPF001.201 CPU not stuck on initial frequency (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.001
    VAR    ${parallel_test_id}=    CPF001.201
    Skip If Parallel Test Not Supported    ${parallel_test_id}
    ${outs}=    Get Parallel Test Outputs    ${parallel_test_id}
    Check CPU Frequencies Not Stuck    ${outs}

STB002.201 Verify if no unexpected boot errors appear in Linux logs
    [Documentation]    This test aims to verify that there are no unexpected
    ...    error ,essages in Linux kernel logs.
    ...    Previous IDs: STB002.001
    VAR    ${parallel_test_id}=    STB001.201
    Skip If Parallel Test Not Supported    ${parallel_test_id}
    ${outs}=    Get Parallel Test Outputs    ${parallel_test_id}
    Check Unexpected Boot Errors    ${outs}

#############################################################################
#    Tests that gather measurements on Ubuntu, no load, n/a power source    #
#############################################################################

_PARALLEL_Background Measurements (no load) (Ubuntu)
    ${will_any_be_run}=    Will Parallel Test Be Run Regex
    ...    (CPF005)|(CPT001)|(STB001).201
    Skip If    not ${will_any_be_run}

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${gather_temps}=    Will Parallel Test Be Run Regex    CPT
    ${gather_freqs}=    Will Parallel Test Be Run Regex    CPF
    ${gather_stab}=    Will Parallel Test Be Run Regex    STB
    IF    ${gather_temps}
        VAR    ${gather_temps}=    CPT001.201
    ELSE
        VAR    ${gather_temps}=    ${None}
    END
    IF    ${gather_freqs}
        VAR    ${gather_freqs}=    CPF005.201
    ELSE
        VAR    ${gather_freqs}=    ${None}
    END
    IF    ${gather_stab}
        VAR    ${gather_stab}=    STB001.201
    ELSE
        VAR    ${gather_stab}=    ${None}
    END

    Background Measurements
    ...    id_temp=${gather_temps}    id_freq=${gather_freqs}

CPT001.201 CPU temperature without load (Ubuntu)
    VAR    ${parallel_test_id}=    CPT001.201
    Skip If Parallel Test Not Supported    ${parallel_test_id}
    ${temps}=    Get Parallel Test Outputs    ${parallel_test_id}
    Check CPU Temps    ${temps}

CPF005.201 CPU runs on expected frequency (Ubuntu)
    VAR    ${parallel_test_id}=    CPF005.201
    Skip If Parallel Test Not Supported    ${parallel_test_id}
    ${freqs}=    Get Parallel Test Outputs    ${parallel_test_id}
    Check CPU Freqs    ${freqs}

STB001.201 Verify if no reboot occurs in the OS (Ubuntu)
    [Documentation]    This test aims to verify that the DUT booted to the
    ...    Operating System does not reset. The test is performed in multiple
    ...    iterations - after a defined time an attempt to read the output of
    ...    specific commands confirming the stability of work is repeated.
    ...    Previous IDs: STB001.002
    VAR    ${parallel_test_id}=    STB001.201
    Skip If Parallel Test Not Supported    ${parallel_test_id}
    ${measurements}=    Get Parallel Test Outputs    ${parallel_test_id}
    Check Platform Stability    ${measurements}

#############################################################################
#    Tests that gather measurements on Ubuntu, load, n/a power source    #
#############################################################################

_PARALLEL_Background Measurements (load) (Ubuntu)
    ${will_any_be_run}=    Will Parallel Test Be Run Regex
    ...    (CPF005)|(CPT001)|(STB001).201
    Skip If    not ${will_any_be_run}

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${gather_temps}=    Will Parallel Test Be Run Regex    CPT
    ${gather_freqs}=    Will Parallel Test Be Run Regex    CPF
    IF    ${gather_temps}
        VAR    ${gather_temps}=    CPT005.201
    ELSE
        VAR    ${gather_temps}=    ${None}
    END
    IF    ${gather_freqs}
        VAR    ${gather_freqs}=    CPF009.201
    ELSE
        VAR    ${gather_freqs}=    ${None}
    END
    # Start CPU Stress
    ${stress_duration}=    Evaluate
    ...    max(${TEMPERATURE_TEST_DURATION}, ${FREQUENCY_TEST_DURATION})
    Stress Test    ${stress_duration}s
    Background Measurements
    ...    id_temp=${gather_temps}    id_freq=${gather_freqs}
    # Make sure to stop any CPU stress after we end
    Execute Command In Terminal    pkill stress-ng

CPT005.201 CPU temperature without load (Ubuntu)
    VAR    ${parallel_test_id}=    CPT001.201
    Skip If Parallel Test Not Supported    ${parallel_test_id}
    ${temps}=    Get Parallel Test Outputs    ${parallel_test_id}
    Check CPU Temps    ${temps}

CPF009.201 CPU runs on expected frequency (Ubuntu)
    VAR    ${parallel_test_id}=    CPF005.201
    Skip If Parallel Test Not Supported    ${parallel_test_id}
    ${freqs}=    Get Parallel Test Outputs    ${parallel_test_id}
    Check CPU Freqs    ${freqs}


*** Keywords ***
Background Measurements
    [Arguments]    ${id_temp}=${None}    ${id_freq}=${None}    ${id_stab}=${None}
    # Initialization
    VAR    @{temp_list}=    @{EMPTY}
    VAR    @{freq_list}=    @{EMPTY}
    VAR    @{stab_list}=    @{EMPTY}
    IF    ${id_temp} is not ${None}
        VAR    ${next_temp_time}=    0
    ELSE
        VAR    ${next_temp_time}=    999999
    END
    IF    ${id_freq} is not ${None}
        VAR    ${next_freq_time}=    0
    ELSE
        VAR    ${next_freq_time}=    999999
    END
    IF    ${id_stab} is not ${None}
        VAR    ${next_stab_time}=    0
    ELSE
        VAR    ${next_stab_time}=    999999
    END
    VAR    ${longest_duration}=
    ...    max(${TEMPERATURE_TEST_DURATION}, ${FREQUENCY_TEST_DURATION}, ${STABILITY_TEST_DURATION})
    ${start}=    DateTime.Get Current Date
    ${timer}=    Evaluate    0

    # measurement loop
    WHILE    ${timer} < ${longest_duration}
        ${now}=    Get Current Date
        ${timer}=    Subtract Date From Date    ${now}    ${start}

        IF    ${TEMPERATURE_TEST_DURATION} >= ${timer} >= ${next_temp_time}
            ${temperature}=    Get CPU Temperature
            ${next_temp_time}=    Evaluate    ${timer} + ${TEMPERATURE_TEST_MEASURE_INTERVAL}
            Append To List    ${temp_list}    ${temperature}
            Log To Console    ${timer}s: Temperature: ${temperature}
        END

        IF    ${FREQUENCY_TEST_DURATION} >= ${timer} >= ${next_freq_time}
            ${freqs}=    Get CPU Frequencies In Ubuntu
            ${next_freq_time}=    Evaluate    ${timer} + ${FREQUENCY_TEST_MEASURE_INTERVAL}
            Append To List    ${freq_list}    ${freqs}
            Log To Console    ${timer}s: Frequencies: ${freqs}
        END

        IF    ${FREQUENCY_TEST_DURATION} >= ${timer} >= ${next_freq_time}
            ${network_status}=    Execute Command In Terminal    ip link | grep -E 'enp|eno' | grep -Eo 'UP|DOWN'
            ${uptime_output}=    Execute Command In Terminal    cat /proc/uptime
            ${uptime_list}=    Split String    ${uptime_output}    ${SPACE}
            ${current_uptime}=    Convert To Number    ${uptime_list}[0]
            VAR    &{stab_data}=    network=${network_status}    uptime=${current_uptime}
            ${next_stab_time}=    Evaluate    ${timer} + ${FREQUENCY_TEST_MEASURE_INTERVAL}
            Append To List    ${freq_list}    ${stab_data}
            Log To Console    ${timer}s: Stability: uptime ${current_uptime}
        END

        ${time_to_next_interval}=    Evaluate    min(${next_temp_time}, ${next_stab_time}, ${next_freq_time})
        Sleep    ${time_to_next_interval}
    END

    Set Parallel Test Outputs    ${id_temp}    ${temp_list}
    Set Parallel Test Outputs    ${id_freq}    ${freq_list}
    Set Parallel Test Outputs    ${id_stab}    ${stab_list}

Prepare Parallel Test Suite
    # Preparing parallel test cases
    # STB
    VAR    ${PARALLEL_TEST_ID}=    STB001.201    scope=TEST
    Add Parallel Test Skip Condition    not ${TESTS_IN_UBUNTU_SUPPORT}    STB001.201 not supported
    Add Parallel Test Skip Condition    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    STB001.201 not supported
    VAR    ${PARALLEL_TEST_ID}=    STB002.201    scope=TEST
    Add Parallel Test Skip Condition    not ${PLATFORM_STABILITY_CHECKING}    STB002.201 not supported
    Add Parallel Test Skip Condition    not ${TESTS_IN_UBUNTU_SUPPORT}    STB002.201 not supported
    Add Parallel Test Skip Condition    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    STB002.201 not supported

    #CPF
    VAR    ${PARALLEL_TEST_ID}=    CPF001.201    scope=TEST
    Add Parallel Test Skip Condition    not ${CPU_FREQUENCY_MEASURE}    frequency measure not supported
    Add Parallel Test Skip Condition    not ${TESTS_IN_UBUNTU_SUPPORT}    tests in Ubuntu not supported
    Add Parallel Test Skip Condition    '201' not in ${TESTED_LINUX_DISTROS}    Ubuntu not in tested distros
    VAR    ${PARALLEL_TEST_ID}=    CPF005.201    scope=TEST
    Add Parallel Test Skip Condition    not ${CPU_FREQUENCY_MEASURE}    frequency measure not supported
    Add Parallel Test Skip Condition    not ${TESTS_IN_UBUNTU_SUPPORT}    tests in Ubuntu not supported
    Add Parallel Test Skip Condition    '201' not in ${TESTED_LINUX_DISTROS}    Ubuntu not in tested distros
    Add Parallel Test Skip Condition    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    VAR    ${PARALLEL_TEST_ID}=    CPF009.201    scope=TEST
    Add Parallel Test Skip Condition    not ${CPU_FREQUENCY_MEASURE}    frequency measure not supported
    Add Parallel Test Skip Condition    not ${TESTS_IN_UBUNTU_SUPPORT}    tests in Ubuntu not supported
    Add Parallel Test Skip Condition    '201' not in ${TESTED_LINUX_DISTROS}    Ubuntu not in tested distros
    Add Parallel Test Skip Condition    ${LAPTOP_PLATFORM}    The Platform is a Laptop

    #CPT
    VAR    ${PARALLEL_TEST_ID}=    CPT001.201    scope=TEST
    Add Parallel Test Skip Condition    not ${TESTS_IN_UBUNTU_SUPPORT}    tests in Ubuntu not supported
    Add Parallel Test Skip Condition
    ...    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros
    Add Parallel Test Skip Condition    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    VAR    ${PARALLEL_TEST_ID}=    CPT005.201    scope=TEST
    Add Parallel Test Skip Condition    not ${TESTS_IN_UBUNTU_SUPPORT}    tests in Ubuntu not supported
    Add Parallel Test Skip Condition
    ...    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros
    Add Parallel Test Skip Condition    ${LAPTOP_PLATFORM}    The Platform is a Laptop

    # Log to console to inform tester about the scope
    Log To Console    Tests to run:
    ${tests}=    Get Parallel Tests To Run
    Log To Console    ${tests}

    ${prepare_sensors}=    Will Parallel Test Be Run Regex    CP[TF]
    IF    ${prepare_sensors}    Prepare Sensors
    ${check_psu}=    Will Parallel Test Be Run Regex    CP[TF]
    IF    ${check_psu}    Check Power Supply

Check CPU Frequencies Not Stuck
    [Arguments]    ${frequencies}
    ${first_frequency}=    Get From List    ${frequencies}    0
    FOR    ${frequency}    IN    @{frequencies}
        IF    ${frequency} != ${INITIAL_CPU_FREQUENCY}
            Pass Execution    CPU does not stuck on initial frequency
        END
    END
    Fail    CPU stuck on initial frequency: ${INITIAL_CPU_FREQUENCY}

Check CPU Temps
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

Check CPU Freqs
    [Arguments]    ${freqs}
    ${cpu_max_frequency_tol}=    Evaluate    ${CPU_MAX_FREQUENCY} * 1.125
    ${cpu_min_frequency_tol}=    Evaluate    ${CPU_MIN_FREQUENCY} * 0.875
    FOR    ${freqs_cores}    IN    @{freqs}
        FOR    ${core}    IN    @{freqs_cores}
            ${in_range}=    Evaluate    ${cpu_min_frequency_tol} <= ${core} <= ${cpu_max_frequency_tol}
            Should Be True    ${in_range}    Encountered invalid frequency: ${in_range} MHz
        END
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
        Should Be Equal    ${measurement["network"]}    UP
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