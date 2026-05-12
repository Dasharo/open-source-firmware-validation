*** Settings ***
Metadata        ORDER_SENSITIVE

Resource        ./common.resource

Suite Setup     Run Keywords
...                 Prepare Test Suite
...                 AND    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
...                 AND    Check Power Supply
...                 AND    Prepare Sensors
...                 AND    Init Concurrent Testing
...                 AND    Prepare CPT QUBES
...                 AND    Prepare CPF QUBES
...                 AND    Prepare STB QUBES
...                 AND    Print Concurrent Tests Summary
...                 AND    Power On
...                 AND    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
...                 AND    Login To Linux
Suite Teardown  Run Keyword
...                 Log Out And Close Connection

Default Tags    automated


*** Test Cases ***
############################################
#    Immediate Measurements (Qubes OS)    #
############################################
_CONCURRENT_Background Measurements Immediate (no load) (Qubes OS)
    ${will_any_be_run}=    Check Concurrent Test Supported Regex
    ...    (${CPF_STUCK_ID})|(STB002).203
    Skip If    not ${will_any_be_run}    No test depends on this step

    # CPU stuck freq (CPF001.203)
    VAR    ${con_id}=    ${CPF_STUCK_ID}.203
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
        ${outs}=    Get Concurrent Test Outputs    ${t}
        Log To Console    -----------------------------
        Log To Console    Test: ${t}
        Log To Console    Supported: ${supported}
        Log To Console    Outputs: ${outs}
    END

############################################
# Qubes OS CPU Frequency / Temperature Tests #
############################################

CPF001.203 CPU not stuck on initial frequency (Qubes OS)
    VAR    ${con_id}=    CPF001.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Frequencies Not Stuck    ${outs}

CPF002.203 CPU not stuck on initial frequency (Qubes OS) (battery)
    VAR    ${con_id}=    CPF002.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Frequencies Not Stuck    ${outs}

CPF003.203 CPU not stuck on initial frequency (Qubes OS) (AC)
    VAR    ${con_id}=    CPF003.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Frequencies Not Stuck    ${outs}

CPF004.203 CPU not stuck on initial frequency (Qubes OS) (USB-PD)
    VAR    ${con_id}=    CPF004.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Frequencies Not Stuck    ${outs}

############################################
# Boot log check    #
############################################

STB002.203 Verify if no unexpected boot errors appear in logs (Qubes OS)
    VAR    ${con_id}=    STB002.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check Unexpected Boot Errors    ${outs}

############################################
# No‑load Background Measurements    #
############################################

_CONCURRENT_Background Measurements (no load) (Qubes OS)
    ${gather_temps}=    Will Concurrent Test Be Run    ${CPT_NO_LOAD_ID}.203
    ${gather_freqs}=    Will Concurrent Test Be Run    ${CPF_NO_LOAD_ID}.203
    ${gather_stab}=    Will Concurrent Test Be Run    STB001.203
    Skip If    not (${gather_temps} or ${gather_freqs} or ${gather_stab})    No test depends on this step

    ${gather_temps}=    Evaluate    "${CPT_NO_LOAD_ID}.203" if ${gather_temps} else ${None}
    ${gather_freqs}=    Evaluate    "${CPF_NO_LOAD_ID}.203" if ${gather_freqs} else ${None}
    ${gather_stab}=    Evaluate    "STB001.203" if ${gather_stab} else ${None}

    Background Measurements
    ...    id_temp=${gather_temps}
    ...    id_freq=${gather_freqs}
    ...    id_stab=${gather_stab}
    ...    iface_pattern=${EMPTY}

CPT001.203 CPU temperature without load (Qubes OS)
    VAR    ${con_id}=    CPT001.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Temps    ${outs}

CPT002.203 CPU temperature without load (Qubes OS) (battery)
    VAR    ${con_id}=    CPT002.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Temps    ${outs}

CPT003.203 CPU temperature without load (Qubes OS) (AC)
    VAR    ${con_id}=    CPT003.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Temps    ${outs}

CPT004.203 CPU temperature without load (Qubes OS) (USB-PD)
    VAR    ${con_id}=    CPT004.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Temps    ${outs}

CPF005.203 CPU runs on expected frequency (Qubes OS)
    VAR    ${con_id}=    CPF005.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Freqs Linux    ${outs}

CPF006.203 CPU runs on expected frequency (Qubes OS) (battery)
    VAR    ${con_id}=    CPF006.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Freqs Linux    ${outs}

CPF007.203 CPU runs on expected frequency (Qubes OS) (AC)
    VAR    ${con_id}=    CPF007.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Freqs Linux    ${outs}

CPF008.203 CPU runs on expected frequency (Qubes OS) (USB-PD)
    VAR    ${con_id}=    CPF008.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Freqs Linux    ${outs}

STB001.203 Verify if no reboot occurs (Qubes OS)
    VAR    ${con_id}=    STB001.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check Platform Stability    ${outs}

############################################
# Load Background Measurements    #
############################################

_CONCURRENT_Background Measurements (load) (Qubes OS)
    ${gather_temps}=    Will Concurrent Test Be Run    ${CPT_LOAD_ID}.203
    ${gather_freqs}=    Will Concurrent Test Be Run    ${CPF_LOAD_ID}.203
    ${gather_stab}=    Will Concurrent Test Be Run    STB001.203

    Skip If    not (${gather_temps} or ${gather_freqs} or ${gather_stab})    No test depends on this step

    ${gather_temps}=    Evaluate    "${CPT_LOAD_ID}.203" if ${gather_temps} else ${None}
    ${gather_freqs}=    Evaluate    "${CPF_LOAD_ID}.203" if ${gather_freqs} else ${None}
    ${gather_stab}=    Evaluate    "STB001.203" if ${gather_stab} else ${None}

    ${stress_duration}=    Evaluate
    ...    max(${TEMPERATURE_TEST_DURATION}, ${FREQUENCY_TEST_DURATION}, ${STABILITY_TEST_DURATION})

    Stress Test    ${stress_duration}s

    Background Measurements
    ...    id_temp=${gather_temps}
    ...    id_freq=${gather_freqs}
    ...    id_stab=${gather_stab}
    ...    iface_pattern=${EMPTY}

    Stress Test Stop

CPT005.203 CPU temperature after stress test (Qubes OS)
    VAR    ${con_id}=    CPT005.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Temps    ${outs}

CPT006.203 CPU temperature after stress test (Qubes OS) (battery)
    VAR    ${con_id}=    CPT006.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Temps    ${outs}

CPT007.203 CPU temperature after stress test (Qubes OS) (AC)
    VAR    ${con_id}=    CPT007.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Temps    ${outs}

CPT008.203 CPU temperature after stress test (Qubes OS) (USB-PD)
    VAR    ${con_id}=    CPT008.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Temps    ${outs}

CPF009.203 CPU with load runs on expected frequency (Qubes OS)
    VAR    ${con_id}=    CPF009.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Freqs Linux    ${outs}

CPF010.203 CPU with load runs on expected frequency (Qubes OS) (battery)
    VAR    ${con_id}=    CPF010.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Freqs Linux    ${outs}

CPF011.203 CPU with load runs on expected frequency (Qubes OS) (AC)
    VAR    ${con_id}=    CPF011.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Freqs Linux    ${outs}

CPF012.203 CPU with load runs on expected frequency (Qubes OS) (USB-PD)
    VAR    ${con_id}=    CPF012.203
    Skip If Concurrent Test Not Supported    ${con_id}
    ${outs}=    Get Concurrent Test Outputs    ${con_id}
    Check CPU Freqs Linux    ${outs}


*** Keywords ***
Prepare STB QUBES
    [Documentation]    Setup STB concurrent test contexts
    # Stability check
    Add Concurrent Test Skip Condition
    ...    STB001.203
    ...    not ${PLATFORM_STABILITY_CHECKING}
    ...    Stability checking not supported
    Add Concurrent Test Skip Condition
    ...    STB001.203
    ...    not ${PLATFORM_STABILITY_CHECKING}
    ...    Stability checking not supported
    Add Concurrent Test Skip Condition
    ...    STB001.203
    ...    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    ...    Tests in Qubes OS not supported
    # Linux dmesg check
    Add Concurrent Test Skip Condition
    ...    STB002.203
    ...    not ${PLATFORM_STABILITY_CHECKING}
    ...    Stability checking not supported
    Add Concurrent Test Skip Condition
    ...    STB002.203
    ...    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    ...    Tests in Qubes OS not supported

Prepare CPF QUBES
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

    Add Concurrent Test Skip Condition
    ...    ${CPF_STUCK_ID}.203
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported
    Add Concurrent Test Skip Condition
    ...    ${CPF_STUCK_ID}.203
    ...    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    ...    Tests in Qubes OS not supported

    Add Concurrent Test Skip Condition
    ...    ${CPF_NO_LOAD_ID}.203
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported
    Add Concurrent Test Skip Condition
    ...    ${CPF_NO_LOAD_ID}.203
    ...    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    ...    Tests in Qubes OS not supported

    Add Concurrent Test Skip Condition
    ...    ${CPF_LOAD_ID}.203
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported
    Add Concurrent Test Skip Condition
    ...    ${CPF_LOAD_ID}.203
    ...    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    ...    Tests in Qubes OS not supported

Prepare CPT QUBES
    IF    not ${LAPTOP_PLATFORM}
        VAR    ${CPT_NO_LOAD_ID}=    CPT001    scope=SUITE
        VAR    ${CPT_LOAD_ID}=    CPT005    scope=SUITE
    ELSE IF    ${BATTERY_PRESENT}
        VAR    ${CPT_NO_LOAD_ID}=    CPT002    scope=SUITE
        VAR    ${CPT_LOAD_ID}=    CPT006    scope=SUITE
    ELSE IF    ${AC_CONNECTED}
        VAR    ${CPT_NO_LOAD_ID}=    CPT003    scope=SUITE
        VAR    ${CPT_LOAD_ID}=    CPT007    scope=SUITE
    ELSE IF    ${USB_PD_CONNECTED}
        VAR    ${CPT_NO_LOAD_ID}=    CPT004    scope=SUITE
        VAR    ${CPT_LOAD_ID}=    CPT008    scope=SUITE
    END

    Add Concurrent Test Skip Condition
    ...    ${CPT_NO_LOAD_ID}.203
    ...    not ${CPU_TEMPERATURE_MEASURE}
    ...    temperature measure not supported
    Add Concurrent Test Skip Condition
    ...    ${CPT_NO_LOAD_ID}.203
    ...    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    ...    tests in Qubes OS not supported

    Add Concurrent Test Skip Condition
    ...    ${CPT_LOAD_ID}.203
    ...    not ${CPU_TEMPERATURE_MEASURE}
    ...    temperature measure not supported
    Add Concurrent Test Skip Condition
    ...    ${CPT_LOAD_ID}.203
    ...    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    ...    tests in Qubes OS not supported
