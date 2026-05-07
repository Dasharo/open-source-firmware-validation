*** Settings ***
Resource            ./common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Check Power Supply
...                     AND    Prepare Sensors
...                     AND    Init Concurrent Testing
...                     AND    Prepare CPT QUBES
...                     AND    Prepare CPF QUBES
...                     AND    Prepare STB QUBES
...                     AND    Print Concurrent Tests Summary
...                     AND    Power On
...                     AND    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
...                     AND    Login To Linux
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
############################################
#    Immediate Measurements (QubesOS)    #
############################################
_CONCURRENT_Background Measurements Immediate (no load) (QubesOS)
    ${will_any_be_run}=    Check Concurrent Test Supported Regex
    ...    (CPF001)|(STB002).203
    Skip If    not ${will_any_be_run}    No test depends on this step

    # CPU stuck freq (CPF001.203)
    VAR    ${con_id}=    CPF001.203
    ${check}=    Check Concurrent Test Supported    ${con_id}
    IF    ${check}
        Sleep    5s
        ${raw}=    Execute Command In Terminal    xenpm start 1 | grep -i "avg freq" | awk '{print $3}'
        ${raw}=    Replace String    ${raw}    \r    ${EMPTY}
        @{freqs}=    Split String    ${raw}    \n
        Log To Console    CPU freqs: @{freqs}
        Set Concurrent Test Outputs    ${con_id}    ${freqs}
    END

    # Boot log errors (STB002.203)
    VAR    ${con_id}=    STB002.203
    ${check}=    Check Concurrent Test Supported    ${con_id}
    IF    ${check}
        ${dmesg_err}=    Execute Command In Terminal    sudo dmesg -t -l err,crit,alert,emerg
        Set Concurrent Test Outputs    ${con_id}    ${dmesg_err}
    END
    VAR    @{tests}=    CPF001.203    CPF005.203    CPF009.203    CPT001.203    CPT005.203    STB001.203    STB002.203
    FOR    ${t}    IN    @{tests}
        ${supported}=    Check Concurrent Test Supported    ${t}
        ${outs}=    Get Concurrent Test Outputs    ${con_id}
        Log To Console    -----------------------------
        Log To Console    Test: ${t}
        Log To Console    Supported: ${supported}
        Log To Console    Outputs: ${outs}
    END

############################################
# QubesOS CPU Frequency / Temperature Tests #
############################################

CPF001.203 CPU not stuck on initial frequency (QubesOS)
    VAR    ${con_id}=    CPF001.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Frequencies Not Stuck    ${outs}

CPF002.203 CPU not stuck on initial frequency (QubesOS) (battery)
    VAR    ${con_id}=    CPF002.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Frequencies Not Stuck    ${outs}

CPF003.203 CPU not stuck on initial frequency (QubesOS) (AC)
    VAR    ${con_id}=    CPF003.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Frequencies Not Stuck    ${outs}

CPF004.203 CPU not stuck on initial frequency (QubesOS) (USB-PD)
    VAR    ${con_id}=    CPF004.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Frequencies Not Stuck    ${outs}

############################################
# Boot log check    #
############################################

STB002.203 Verify if no unexpected boot errors appear in logs (QubesOS)
    VAR    ${con_id}=    STB002.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check Unexpected Boot Errors    ${outs}

############################################
# No‑load Background Measurements    #
############################################

_CONCURRENT_Background Measurements (no load) (QubesOS)
    ${gather_temps}=    Will Concurrent Test Be Run    CPT001.203
    ${gather_freqs}=    Will Concurrent Test Be Run    CPF005.203
    ${gather_stab}=    Will Concurrent Test Be Run    STB001.203
    Skip If    not (${gather_temps} or ${gather_freqs} or ${gather_stab})    No test depends on this step

    ${gather_temps}=    Evaluate    "CPT001.203" if ${gather_temps} else ${None}
    ${gather_freqs}=    Evaluate    "CPF005.203" if ${gather_freqs} else ${None}
    ${gather_stab}=    Evaluate    "STB001.203" if ${gather_stab} else ${None}

    Background Measurements
    ...    id_temp=${gather_temps}
    ...    id_freq=${gather_freqs}
    ...    id_stab=${gather_stab}

CPT001.203 CPU temperature without load (QubesOS)
    VAR    ${con_id}=    CPT001.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Temps    ${outs}

CPF005.203 CPU runs on expected frequency (QubesOS)
    VAR    ${con_id}=    CPF005.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Freqs Linux    ${outs}

STB001.203 Verify if no reboot occurs (QubesOS)
    VAR    ${con_id}=    STB001.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check Platform Stability    ${outs}

############################################
# Load Background Measurements    #
############################################

_CONCURRENT_Background Measurements (load) (QubesOS)
    ${gather_temps}=    Will Concurrent Test Be Run    CPT005.203
    ${gather_freqs}=    Will Concurrent Test Be Run    CPF009.203
    ${gather_stab}=    Will Concurrent Test Be Run    STB001.203

    Skip If    not (${gather_temps} or ${gather_freqs} or ${gather_stab})    No test depends on this step

    ${stress_duration}=    Evaluate
    ...    max(${TEMPERATURE_TEST_DURATION}, ${FREQUENCY_TEST_DURATION}, ${STABILITY_TEST_DURATION})

    Execute Command In Terminal    stress-ng --cpu 8 --timeout ${stress_duration}s &

    Background Measurements
    ...    id_temp=${gather_temps}
    ...    id_freq=${gather_freqs}
    ...    id_stab=${gather_stab}

    Execute Command In Terminal    pkill stress-ng

CPT005.203 CPU temperature after stress test (QubesOS)
    VAR    ${con_id}=    CPT005.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Temps    ${outs}

CPF009.203 CPU with load runs on expected frequency (QubesOS)
    VAR    ${con_id}=    CPF009.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Freqs Linux    ${outs}


*** Keywords ***
Prepare STB QUBES
    Add Concurrent Test Skip Condition
    ...    STB001.203
    ...    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    ...    Tests in QubesOS not supported

    Add Concurrent Test Skip Condition
    ...    STB002.203
    ...    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    ...    Tests in QubesOS not supported

Prepare CPF QUBES
    VAR    ${CPF_STUCK_ID}=    CPF001    scope=SUITE
    VAR    ${CPF_NO_LOAD_ID}=    CPF005    scope=SUITE
    VAR    ${CPF_LOAD_ID}=    CPF009    scope=SUITE

    Add Concurrent Test Skip Condition
    ...    ${CPF_STUCK_ID}.203
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported

    Add Concurrent Test Skip Condition
    ...    ${CPF_NO_LOAD_ID}.203
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported

    Add Concurrent Test Skip Condition
    ...    ${CPF_LOAD_ID}.203
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported

Prepare CPT QUBES
    VAR    ${CPT_NO_LOAD_ID}=    CPT001    scope=SUITE
    VAR    ${CPT_LOAD_ID}=    CPT005    scope=SUITE

    Add Concurrent Test Skip Condition
    ...    ${CPT_NO_LOAD_ID}.203
    ...    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    ...    tests in QubesOS not supported

    Add Concurrent Test Skip Condition
    ...    ${CPT_LOAD_ID}.203
    ...    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    ...    tests in QubesOS not supported
