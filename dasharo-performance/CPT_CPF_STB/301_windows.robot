*** Settings ***
Resource            ./common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Check Power Supply
...                     AND    Init Concurrent Testing
...                     AND    Prepare CPF
...                     AND    Prepare STB
...                     AND    Print Concurrent Tests Summary
Suite Teardown      Run Keywords
...                     Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
...                     AND    Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
############################################
#    Tests that can be done immediately    #
############################################
_CONCURRENT_Background Measurements Immediate (no load) (Windows)
    # immediately skip if no tests want these measurements
    ${will_any_be_run}=    Check Concurrent Test Supported Regex
    ...    ${CPF_STUCK_ID}.301
    Skip If    not ${will_any_be_run}    No test depends on this step

    Power On
    Boot And Login To Windows

    # CPF001.301 steps
    VAR    ${concurrent_test_id}=    ${CPF_STUCK_ID}.301
    ${check_frequency}=    Check Concurrent Test Supported    ${concurrent_test_id}
    IF    ${check_frequency}
        Sleep    10s
        ${frequencies}=    Get CPU Frequency In Windows
        VAR    @{frequencies}=    ${frequencies}
        # Only single value can be read using this KWd in Windows
        Set Concurrent Test Outputs    ${concurrent_test_id}    ${frequencies}
    END

CPF001.301 CPU not stuck on initial frequency (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.002
    VAR    ${concurrent_test_id}=    CPF001.301
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${outs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Frequencies Not Stuck    ${outs}

CPF002.301 CPU not stuck on initial frequency (Battery) (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.005
    VAR    ${concurrent_test_id}=    CPF002.301
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${outs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Frequencies Not Stuck    ${outs}

CPF003.301 CPU not stuck on initial frequency (AC) (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.008
    VAR    ${concurrent_test_id}=    CPF003.301
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${outs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Frequencies Not Stuck    ${outs}

CPF004.301 CPU not stuck on initial frequency (USB-PD) (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.011
    VAR    ${concurrent_test_id}=    CPF004.301
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${outs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Frequencies Not Stuck    ${outs}

#############################################################################
#    Tests that gather measurements on Windows, no load, n/a power source    #
#############################################################################

_CONCURRENT_Background Measurements (no load) (Windows)
    ${gather_freqs}=    Will Concurrent Test Be Run    ${CPF_NO_LOAD_ID}.301
    ${gather_stab}=    Will Concurrent Test Be Run    STB001.301
    Skip If    not (${gather_freqs} or ${gather_stab})    No test depends on this step

    Power On
    Boot And Login To Windows

    ${gather_freqs}=    Evaluate    "${CPF_NO_LOAD_ID}.301" if ${gather_freqs} else ${None}
    ${gather_stab}=    Evaluate    "STB001.301" if ${gather_stab} else ${None}

    Background Measurements Windows
    ...    id_freq=${gather_freqs}    id_stab=${gather_stab}

CPF005.301 CPU runs on expected frequency (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.002
    VAR    ${concurrent_test_id}=    CPF005.301
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Windows    ${freqs}

CPF006.301 CPU runs on expected frequency (Battery) (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.004
    VAR    ${concurrent_test_id}=    CPF006.301
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Windows    ${freqs}

CPF007.301 CPU runs on expected frequency (AC) (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.006
    VAR    ${concurrent_test_id}=    CPF007.301
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Windows    ${freqs}

CPF008.301 CPU runs on expected frequency (USB-PD) (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.008
    VAR    ${concurrent_test_id}=    CPF008.301
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Windows    ${freqs}

STB001.301 Verify if no reboot occurs in the OS (Windows)
    [Documentation]    This test aims to verify that the DUT booted to the
    ...    Operating System does not reset. The test is performed in multiple
    ...    iterations - after a defined time an attempt to read the output of
    ...    specific commands confirming the stability of work is repeated.
    ...    Previous IDs: STB001.002
    VAR    ${concurrent_test_id}=    STB001.301
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${measurements}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check Platform Stability    ${measurements}

#############################################################################
#    Tests that gather measurements on Windows, load, n/a power source    #
#############################################################################

_CONCURRENT_Background Measurements (load) (Windows)
    ${gather_freqs}=    Will Concurrent Test Be Run    ${CPF_LOAD_ID}.301
    ${gather_stab}=    Will Concurrent Test Be Run    STB002.301
    Skip If    not (${gather_freqs} or ${gather_stab})    No test depends on this step

    Power On
    Boot And Login To Windows

    ${gather_freqs}=    Evaluate    "${CPF_LOAD_ID}.301" if ${gather_freqs} else ${None}
    ${gather_stab}=    Evaluate    "STB002.301" if ${gather_stab} else ${None}

    # Start CPU Stress
    ${stress_duration}=    Evaluate
    ...    max(${TEMPERATURE_TEST_DURATION}, ${FREQUENCY_TEST_DURATION}, ${STABILITY_TEST_DURATION})
    Stress Test Windows
    Background Measurements Windows
    ...    id_freq=${gather_freqs}    id_stab=${gather_stab}

CPF009.301 CPU with load runs on expected frequency (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.002
    VAR    ${concurrent_test_id}=    CPF009.301
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Windows    ${freqs}

CPF010.301 CPU with load runs on expected frequency (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.004
    VAR    ${concurrent_test_id}=    CPF010.301
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Windows    ${freqs}

CPF011.301 CPU with load runs on expected frequency (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.006
    VAR    ${concurrent_test_id}=    CPF011.301
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Windows    ${freqs}

CPF012.301 CPU with load runs on expected frequency (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.008
    VAR    ${concurrent_test_id}=    CPF012.301
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Windows    ${freqs}

STB002.301 Verify if no reboot occurs in the OS (Windows)
    [Documentation]    This test aims to verify that the DUT booted to the
    ...    Operating System does not reset. The test is performed in multiple
    ...    iterations - after a defined time an attempt to read the output of
    ...    specific commands confirming the stability of work is repeated.
    VAR    ${concurrent_test_id}=    STB002.301
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${measurements}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check Platform Stability    ${measurements}


*** Keywords ***
Stress Test Windows
    SSHLibrary.Put File    stress-test-windows.ps1    /C:/Users/user
    Execute Command In Terminal    .\\stress-test-windows.ps1    60s

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
    # Not Stuck
    Add Concurrent Test Skip Condition
    ...    ${CPF_STUCK_ID}.301
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported
    Add Concurrent Test Skip Condition
    ...    ${CPF_STUCK_ID}.301
    ...    not ${TESTS_IN_WINDOWS_SUPPORT}
    ...    frequency measure not supported
    # No load
    Add Concurrent Test Skip Condition
    ...    ${CPF_NO_LOAD_ID}.301
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported
    Add Concurrent Test Skip Condition
    ...    ${CPF_NO_LOAD_ID}.301
    ...    not ${TESTS_IN_WINDOWS_SUPPORT}
    ...    tests in Windows not supported
    # Load
    Add Concurrent Test Skip Condition
    ...    ${CPF_LOAD_ID}.301
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported
    Add Concurrent Test Skip Condition
    ...    ${CPF_LOAD_ID}.301
    ...    not ${TESTS_IN_WINDOWS_SUPPORT}
    ...    tests in Windows not supported

Prepare STB
    [Documentation]    Setup STB concurrent test contexts
    # Stability check
    Add Concurrent Test Skip Condition
    ...    STB001.301
    ...    not ${PLATFORM_STABILITY_CHECKING}
    ...    Stability checking not supported
    Add Concurrent Test Skip Condition
    ...    STB001.301
    ...    not ${TESTS_IN_WINDOWS_SUPPORT}
    ...    Tests in Windows not supported
    Add Concurrent Test Skip Condition
    ...    STB002.301
    ...    not ${PLATFORM_STABILITY_CHECKING}
    ...    Stability checking not supported
    Add Concurrent Test Skip Condition
    ...    STB002.301
    ...    not ${TESTS_IN_WINDOWS_SUPPORT}
    ...    Tests in Windows not supported
