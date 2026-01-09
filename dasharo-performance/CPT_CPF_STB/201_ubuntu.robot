*** Settings ***
Resource        ./common.resource

Suite Setup     Run Keywords
...                 Prepare Test Suite
...                 AND    Check Power Supply
...                 AND    Prepare Sensors
...                 AND    Init Concurrent Testing
...                 AND    Prepare CPT
...                 AND    Prepare CPF
...                 AND    Prepare STB
...                 AND    Print Concurrent Tests Summary

Default Tags    automated


*** Test Cases ***
############################################
#    Tests that can be done immediately    #
############################################
_CONCURRENT_Background Measurements Immediate (no load) (Ubuntu)
    [Tags]    automated    minimal-regression
    # immediately skip if no tests want these measurements
    ${will_any_be_run}=    Check Concurrent Test Supported Regex
    ...    (${CPF_STUCK_ID})|(STB002).201
    Skip If    not ${will_any_be_run}    No test depends on this step

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    # CPF001.201 / CPF002.201 / CPF003.201 steps
    VAR    ${concurrent_test_id}=    ${CPF_STUCK_ID}.201
    ${check_frequency}=    Check Concurrent Test Supported    ${concurrent_test_id}
    IF    ${check_frequency}
        Sleep    10s
        @{frequencies}=    Get CPU Frequencies In Linux
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
    [Tags]    automated    minimal-regression
    VAR    ${concurrent_test_id}=    STB001.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${outs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check Unexpected Boot Errors    ${outs}

#############################################################################
#    Tests that gather measurements on Ubuntu, no load,                     #
#############################################################################

_CONCURRENT_Background Measurements (no load) (Ubuntu)
    ${gather_temps}=    Will Concurrent Test Be Run    ${CPT_NO_LOAD_ID}.201
    ${gather_freqs}=    Will Concurrent Test Be Run    ${CPF_NO_LOAD_ID}.201
    ${gather_stab}=    Will Concurrent Test Be Run    STB001.201
    Skip If    not (${gather_temps} or ${gather_freqs} or ${gather_stab})    No test depends on this step

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${gather_temps}=    Evaluate    "${CPT_NO_LOAD_ID}.201" if ${gather_temps} else ${None}
    ${gather_freqs}=    Evaluate    "${CPF_NO_LOAD_ID}.201" if ${gather_freqs} else ${None}
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
    ...    Previous IDs: CPT001.002
    VAR    ${concurrent_test_id}=    CPT002.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${temps}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Temps    ${temps}

CPT003.201 CPU temperature without load (AC) (Ubuntu)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    ...    Previous IDs: CPT001.003
    VAR    ${concurrent_test_id}=    CPT003.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${temps}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Temps    ${temps}

CPT004.201 CPU temperature without load (USB-PD) (Ubuntu)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    ...    Previous IDs: CPT001.004
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
    Check CPU Freqs Linux    ${freqs}

CPF006.201 CPU runs on expected frequency (Battery) (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.003
    VAR    ${concurrent_test_id}=    CPF006.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Linux    ${freqs}

CPF007.201 CPU runs on expected frequency (AC) (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.005
    VAR    ${concurrent_test_id}=    CPF007.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Linux    ${freqs}

CPF008.201 CPU runs on expected frequency (USB-PD) (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.007
    VAR    ${concurrent_test_id}=    CPF008.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Linux    ${freqs}

#############################################################################
#    Tests that gather measurements on Ubuntu, load                         #
#############################################################################

_CONCURRENT_Background Measurements (load) (Ubuntu)
    ${gather_temps}=    Will Concurrent Test Be Run    ${CPT_LOAD_ID}.201
    ${gather_freqs}=    Will Concurrent Test Be Run    ${CPF_LOAD_ID}.201
    ${gather_stab}=    Will Concurrent Test Be Run    STB001.201
    Skip If    not (${gather_temps} or ${gather_freqs} or ${gather_stab})    No test depends on this step

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${gather_temps}=    Evaluate    "${CPT_LOAD_ID}.201" if ${gather_temps} else ${None}
    ${gather_freqs}=    Evaluate    "${CPF_LOAD_ID}.201" if ${gather_freqs} else ${None}
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
    VAR    ${concurrent_test_id}=    CPT005.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${temps}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Temps    ${temps}

CPT006.201 CPU temperature after stress test (Battery) (Ubuntu)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    ...    Previous IDs: CPT002.002
    VAR    ${concurrent_test_id}=    CPT006.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${temps}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Temps    ${temps}

CPT007.201 CPU temperature after stress test (AC) (Ubuntu)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    ...    Previous IDs: CPT002.003
    VAR    ${concurrent_test_id}=    CPT007.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${temps}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Temps    ${temps}

CPT008.201 CPU temperature after stress test (USB-PD) (Ubuntu)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    ...    Previous IDs: CPT002.004
    VAR    ${concurrent_test_id}=    CPT007.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${temps}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Temps    ${temps}

CPF009.201 CPU with load runs on expected frequency (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.002
    VAR    ${concurrent_test_id}=    CPF009.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Linux    ${freqs}

CPF010.201 CPU with load runs on expected frequency (Battery) (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.004
    VAR    ${concurrent_test_id}=    CPF010.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Linux    ${freqs}

CPF011.201 CPU with load runs on expected frequency (AC) (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.006
    VAR    ${concurrent_test_id}=    CPF011.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Linux    ${freqs}

CPF012.201 CPU with load runs on expected frequency (USB-PD) (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.008
    VAR    ${concurrent_test_id}=    CPF012.201
    Skip If Concurrent Test Not Supported    ${concurrent_test_id}
    ${freqs}=    Get Concurrent Test Outputs    ${concurrent_test_id}
    Check CPU Freqs Linux    ${freqs}

#############################################################################
#    Tests that gather measurements on Ubuntu, n\a load                     #
#############################################################################

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


*** Keywords ***
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
    ...    ${CPT_LOAD_ID}.201
    ...    not ${TESTS_IN_UBUNTU_SUPPORT}
    ...    tests in Ubuntu not supported
    Add Concurrent Test Skip Condition    ${CPT_LOAD_ID}.201
    ...    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros
