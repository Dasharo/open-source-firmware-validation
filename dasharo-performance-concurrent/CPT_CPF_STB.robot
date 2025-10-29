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
Resource        ../lib/concurrent-testing.robot

Suite Setup     Run Keywords
...                 Prepare Test Suite
...                 AND    Check Power Supply
...                 AND    Prepare Sensors
...                 AND    Init Concurrent Testing
...                 AND    Prepare CPT
...                 AND    Prepare CPF
...                 AND    Prepare STB
...                 AND    Print Concurrent Tests Summary


*** Variables ***
# TODO: remove, temporary debug values
${FREQUENCY_TEST_MEASURE_INTERVAL}=         1
${TEMPERATURE_TEST_MEASURE_INTERVAL}=       1
${STABILITY_TEST_MEASURE_INTERVAL}=         1
${TEMPERATURE_TEST_DURATION}=               5
${FREQUENCY_TEST_DURATION}=                 5
${STABILITY_TEST_DURATION}=                 5


*** Test Cases ***
############################################
#    Tests that can be done immediately    #
############################################
_CONCURRENT_Background Measurements Immediate (no load) (Ubuntu)
    # immediately skip if no tests want these measurements
    ${will_any_be_run}=    Check Concurrent Test Supported Regex
    ...    (CPF001)|(STB002).201
    Skip If    not ${will_any_be_run}    No test depends on this step

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    # CPF001.201 steps
    VAR    ${concurrent_test_id}=    CPF001.201
    ${check_frequency}=    Check Concurrent Test Supported    ${concurrent_test_id}
    IF    ${check_frequency}
        Sleep    10s
        @{frequencies}=    Get CPU Frequencies In Ubuntu
        Set Concurrent Test Outputs    ${concurrent_test_id}    ${frequencies}
    END

    # STB002.201 steps
    VAR    ${concurrent_test_id}=    STB002.201
    ${check_logs}=    Check Concurrent Test Supported    ${concurrent_test_id}
    IF    ${check_logs}
        ${dmesg_err_txt}=    Execute Linux Command    dmesg -t -l err,crit,alert,emerg
        Set Concurrent Test Outputs    ${concurrent_test_id}    ${dmesg_err_txt}
    END

CPF001.201 CPU not stuck on initial frequency (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.001
    VAR    ${concurrent_test_id}=    CPF001.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${outs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Frequencies Not Stuck    ${outs}

CPF002.201 CPU not stuck on initial frequency (Battery) (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.001
    VAR    ${concurrent_test_id}=    CPF002.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${outs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Frequencies Not Stuck    ${outs}

CPF003.201 CPU not stuck on initial frequency (AC) (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.001
    VAR    ${concurrent_test_id}=    CPF003.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${outs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Frequencies Not Stuck    ${outs}

CPF004.201 CPU not stuck on initial frequency (USB-PD) (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.001
    VAR    ${concurrent_test_id}=    CPF004.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${outs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Frequencies Not Stuck    ${outs}

STB002.201 Verify if no unexpected boot errors appear in Linux logs
    [Documentation]    This test aims to verify that there are no unexpected
    ...    error ,essages in Linux kernel logs.
    ...    Previous IDs: STB002.001
    VAR    ${concurrent_test_id}=    STB001.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${outs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check Unexpected Boot Errors    ${outs}

#############################################################################
#    Tests that gather measurements on Ubuntu, no load, n/a power source    #
#############################################################################

_CONCURRENT_Background Measurements (no load) (Ubuntu)
    ${gather_temps}=    Will Concurrent Test Be Run    CPT001.201
    ${gather_freqs}=    Will Concurrent Test Be Run    CPF005.201
    ${gather_stab}=    Will Concurrent Test Be Run    STB001.201
    Skip If    not (${gather_temps} or ${gather_freqs} or ${gather_stab})    No test depends on this step

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${gather_temps}=    Evaluate    "CPT001.201" if ${gather_temps} else ${None}
    ${gather_freqs}=    Evaluate    "CPF005.201" if ${gather_freqs} else ${None}
    ${gather_stab}=    Evaluate    "STB001.201" if ${gather_stab} else ${None}

    Background Measurements
    ...    id_temp=${gather_temps}    id_freq=${gather_freqs}    id_stab=${gather_stab}

CPT001.201 CPU temperature without load (Ubuntu)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    ...    Previous IDs: CPT001.001
    VAR    ${concurrent_test_id}=    CPT001.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${temps}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Temps    ${temps}

CPT002.201 CPU temperature without load (Battery) (Ubuntu)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    ...    Previous IDs: CPT001.001
    VAR    ${concurrent_test_id}=    CPT002.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${temps}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Temps    ${temps}

CPT003.201 CPU temperature without load (AC) (Ubuntu)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    ...    Previous IDs: CPT001.001
    VAR    ${concurrent_test_id}=    CPT003.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${temps}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Temps    ${temps}

CPT004.201 CPU temperature without load (USB-PD) (Ubuntu)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    ...    Previous IDs: CPT001.001
    VAR    ${concurrent_test_id}=    CPT004.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${temps}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Temps    ${temps}

CPF005.201 CPU runs on expected frequency (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.001
    VAR    ${concurrent_test_id}=    CPF005.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs    ${freqs}

CPF006.201 CPU runs on expected frequency (Battery) (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.001
    VAR    ${concurrent_test_id}=    CPF006.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs    ${freqs}

CPF007.201 CPU runs on expected frequency (AC) (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.001
    VAR    ${concurrent_test_id}=    CPF007.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs    ${freqs}

CPF008.201 CPU runs on expected frequency (USB-PD) (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.001
    VAR    ${concurrent_test_id}=    CPF008.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs    ${freqs}

STB001.201 Verify if no reboot occurs in the OS (Ubuntu)
    [Documentation]    This test aims to verify that the DUT booted to the
    ...    Operating System does not reset. The test is performed in multiple
    ...    iterations - after a defined time an attempt to read the output of
    ...    specific commands confirming the stability of work is repeated.
    ...    Previous IDs: STB001.002
    VAR    ${concurrent_test_id}=    STB001.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${measurements}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check Platform Stability    ${measurements}

#############################################################################
#    Tests that gather measurements on Ubuntu, load, n/a power source    #
#############################################################################

_CONCURRENT_Background Measurements (load) (Ubuntu)
    ${gather_temps}=    Will Concurrent Test Be Run    CPT005.201
    ${gather_freqs}=    Will Concurrent Test Be Run    CPF009.201
    ${gather_stab}=    Will Concurrent Test Be Run    STB001.201
    Skip If    not (${gather_temps} or ${gather_freqs} or ${gather_stab})    No test depends on this step

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${gather_temps}=    Evaluate    "CPT005.201" if ${gather_temps} else ${None}
    ${gather_freqs}=    Evaluate    "CPF009.201" if ${gather_freqs} else ${None}
    ${gather_stab}=    Evaluate    "STB001.201" if ${gather_stab} else ${None}

    # Start CPU Stress
    ${stress_duration}=    Evaluate
    ...    max(${TEMPERATURE_TEST_DURATION}, ${FREQUENCY_TEST_DURATION}, ${STABILITY_TEST_DURATION})
    Stress Test    ${stress_duration}s
    Background Measurements
    ...    id_temp=${gather_temps}    id_freq=${gather_freqs}    id_stab=${gather_stab}
    # Make sure to stop any CPU stress after we end
    Execute Command In Terminal    pkill stress-ng

CPT005.201 CPU temperature after stress test (Ubuntu)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    ...    Previous IDs: CPT002.001
    VAR    ${concurrent_test_id}=    CPT001.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${temps}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Temps    ${temps}

CPF009.201 CPU with load runs on expected frequency (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.001
    VAR    ${concurrent_test_id}=    CPF005.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs    ${freqs}


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

    Set Concurrent Test Outputs    ${id_temp}    ${temp_list}
    Set Concurrent Test Outputs    ${id_freq}    ${freq_list}
    Set Concurrent Test Outputs    ${id_stab}    ${stab_list}

Prepare STB
    [Documentation]    Setup STB concurrent test contexts
    # Stability check
    Add Concurrent Test Skip Condition
    ...    STB001.201
    ...    not ${PLATFORM_STABILITY_CHECKING}
    ...    Stability checking not supported
    Add Concurrent Test Skip Condition
    ...    STB001.201
    ...    not ${TESTS_IN_UBUNTU_SUPPORT}
    ...    Tests in Ubuntu not supported
    Add Concurrent Test Skip Condition
    ...    STB001.201
    ...    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros
    # Linux dmesg check
    Add Concurrent Test Skip Condition
    ...    STB002.201
    ...    not ${PLATFORM_STABILITY_CHECKING}
    ...    Stability checking not supported
    Add Concurrent Test Skip Condition
    ...    STB002.201
    ...    not ${TESTS_IN_UBUNTU_SUPPORT}
    ...    Tests in Ubuntu not supported
    Add Concurrent Test Skip Condition
    ...    STB002.201
    ...    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros

Prepare CPF
    [Documentation]    Setup CPF concurrent test contexts
    IF    not ${LAPTOP_PLATFORM}
        VAR    ${CPF_STUCK_ID}=    CPF001    scope=SUITE
        VAR    ${CPF_NO_LOAD_ID}=    CPF005    scope=SUITE
        VAR    ${CPF_LOAD_ID}=    CPF009    scope=SUITE
    ELSE IF    ${BATTERY_PRESENT}
        VAR    ${CPF_STUCK_ID}=    CPF002    scope=SUITE
        VAR    ${CPF_NO_LOAD_ID}=    CPF006    scope=SUITE
        VAR    ${CPF_LOAD_ID}=    CPF010    scope=SUITE
    ELSE IF    ${AC_CONNECTED}
        VAR    ${CPF_STUCK_ID}=    CPF003    scope=SUITE
        VAR    ${CPF_NO_LOAD_ID}=    CPF007    scope=SUITE
        VAR    ${CPF_LOAD_ID}=    CPF011    scope=SUITE
    ELSE IF    ${USB_PD_CONNECTED}
        VAR    ${CPF_STUCK_ID}=    CPF004    scope=SUITE
        VAR    ${CPF_NO_LOAD_ID}=    CPF008    scope=SUITE
        VAR    ${CPF_LOAD_ID}=    CPF012    scope=SUITE
    END
    # Not Stuck Ubuntu
    Add Concurrent Test Skip Condition
    ...    ${CPF_STUCK_ID}.201
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported
    Add Concurrent Test Skip Condition
    ...    ${CPF_STUCK_ID}.201
    ...    not ${TESTS_IN_UBUNTU_SUPPORT}
    ...    tests in Ubuntu not supported
    Add Concurrent Test Skip Condition
    ...    ${CPF_STUCK_ID}.201
    ...    '201' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros
    # No load Ubuntu
    Add Concurrent Test Skip Condition
    ...    ${CPF_NO_LOAD_ID}.201
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported
    Add Concurrent Test Skip Condition
    ...    ${CPF_NO_LOAD_ID}.201
    ...    not ${TESTS_IN_UBUNTU_SUPPORT}
    ...    tests in Ubuntu not supported
    Add Concurrent Test Skip Condition
    ...    ${CPF_NO_LOAD_ID}.201
    ...    '201' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros
    # Load Ubuntu
    Add Concurrent Test Skip Condition
    ...    ${CPF_LOAD_ID}.201
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported
    Add Concurrent Test Skip Condition
    ...    ${CPF_LOAD_ID}.201
    ...    not ${TESTS_IN_UBUNTU_SUPPORT}
    ...    tests in Ubuntu not supported
    Add Concurrent Test Skip Condition
    ...    ${CPF_LOAD_ID}.201
    ...    '201' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros

Prepare CPT
    [Documentation]    Setup CPT concurrent test contexts
    IF    not ${LAPTOP_PLATFORM}
        VAR    ${CPT_NO_LOAD_ID}=    CPT001    scope=SUITE
        VAR    ${CPF_LOAD_ID}=    CPT005    scope=SUITE
    ELSE IF    ${BATTERY_PRESENT}
        VAR    ${CPT_NO_LOAD_ID}=    CPT002    scope=SUITE
        VAR    ${CPF_LOAD_ID}=    CPT006    scope=SUITE
    ELSE IF    ${AC_CONNECTED}
        VAR    ${CPT_NO_LOAD_ID}=    CPT003    scope=SUITE
        VAR    ${CPF_LOAD_ID}=    CPT007    scope=SUITE
    ELSE IF    ${USB_PD_CONNECTED}
        VAR    ${CPT_NO_LOAD_ID}=    CPT004    scope=SUITE
        VAR    ${CPF_LOAD_ID}=    CPT008    scope=SUITE
    END

    # No load Ubuntu
    Add Concurrent Test Skip Condition
    ...    ${CPT_NO_LOAD_ID}.201
    ...    not ${TESTS_IN_UBUNTU_SUPPORT}
    ...    tests in Ubuntu not supported
    Add Concurrent Test Skip Condition
    ...    ${CPT_NO_LOAD_ID}.201
    ...    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros
    # Load Ubuntu
    Add Concurrent Test Skip Condition
    ...    ${CPF_LOAD_ID}.201
    ...    not ${TESTS_IN_UBUNTU_SUPPORT}
    ...    tests in Ubuntu not supported
    Add Concurrent Test Skip Condition    ${CPF_LOAD_ID}.201
    ...    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros

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

Check CPU Freqs
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
