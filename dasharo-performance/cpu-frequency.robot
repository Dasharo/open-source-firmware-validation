*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../keys-and-keywords/heads-keywords.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     Check Power Supply And Return Name
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
CPF001.001 CPU not stuck on initial frequency (Ubuntu 22.04) ${POWER_SUPPLY_TEST_NAME}
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF001.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Sleep    10s
    Check If CPU Not Stucks On Initial Frequency In Ubuntu

CPF001.002 CPU not stuck on initial frequency (Windows 11) ${POWER_SUPPLY_TEST_NAME}
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF001.002 not supported
    Power On
    Login To Windows
    Sleep    10s
    Check If CPU Not Stucks On Initial Frequency In Windows

CPF001.003 CPU not stuck on initial frequency (Heads+Debian) ${POWER_SUPPLY_TEST_NAME}
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.003 not supported
    Skip If    not ${TESTS_IN_DEBIAN_SUPPORT}    CPF001.003 not supported
    Skip If    not ${HEADS_PAYLOAD_SUPPORT}    CPF001.003 not supported
    Power On
    Detect Heads Main Menu
    # Proceed with default boot
    Write Bare Into Terminal    ${ENTER}
    Read From Terminal Until    Please unlock disk nvme0n1p3_crypt:
    Write Into Terminal    debian
    Login To Linux With Root Privileges
    Sleep    10s
    Check If CPU Not Stucks On Initial Frequency In Ubuntu

CPF002.001 CPU runs on expected frequency (Ubuntu 22.04) ${POWER_SUPPLY_TEST_NAME}
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF002.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${freq_max}=    Get CPU Frequency MAX
    ${freq_min}=    Get CPU Frequency MIN
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${FREQUENCY_TEST_DURATION} / ${FREQUENCY_TEST_MEASURE_INTERVAL})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        @{frequencies}=    Get CPU Frequencies In Ubuntu
        FOR    ${frequency}    IN    @{frequencies}
            Run Keyword And Continue On Failure
            ...    Should Be True    ${freq_max} > ${frequency}
            Run Keyword And Continue On Failure
            ...    Should Be True    ${freq_min} < ${frequency}
        END
        Sleep    ${FREQUENCY_TEST_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${FREQUENCY_TEST_MEASURE_INTERVAL}
    END

CPF002.002 CPU runs on expected frequency (Windows 11) ${POWER_SUPPLY_TEST_NAME}
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF002.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF002.002 not supported
    Power On
    Login To Windows
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${FREQUENCY_TEST_DURATION} / ${FREQUENCY_TEST_MEASURE_INTERVAL})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        Check CPU Frequency In Windows
        Sleep    ${FREQUENCY_TEST_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${FREQUENCY_TEST_MEASURE_INTERVAL}
    END

CPF004.001 CPU with load runs on expected frequency (Ubuntu 22.04) ${POWER_SUPPLY_TEST_NAME}
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF004.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF004.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${freq_max}=    Get CPU Frequency MAX
    ${freq_min}=    Get CPU Frequency MIN
    Stress Test    ${FREQUENCY_TEST_DURATION}m
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${FREQUENCY_TEST_DURATION} / ${FREQUENCY_TEST_MEASURE_INTERVAL})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        @{frequencies}=    Get CPU Frequencies In Ubuntu
        FOR    ${frequency}    IN    @{frequencies}
            Run Keyword And Continue On Failure
            ...    Should Be True    ${freq_max} > ${frequency}
            Run Keyword And Continue On Failure
            ...    Should Be True    ${freq_min} < ${frequency}
        END
        Sleep    ${FREQUENCY_TEST_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${FREQUENCY_TEST_MEASURE_INTERVAL}
    END

CPF004.002 CPU with load runs on expected frequency (Windows 11) ${POWER_SUPPLY_TEST_NAME}
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF004.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF004.002 not supported
    Power On
    Login To Windows
    ${out}=    Run
    ...    sshpass -p ${DEVICE_WINDOWS_PASSWORD} scp stress-test-windows.ps1 ${DEVICE_WINDOWS_USERNAME}@${DEVICE_IP}:/C:/Users/user
    Should Be Empty    ${out}
    SSHLibrary.Execute Command    .\\stress-test-windows.ps1
    # ...    sshpass -p ${DEVICE_WINDOWS_PASSWORD} scp stress-test-windows.ps1 ${DEVICE_WINDOWS_USERNAME}@${DEVICE_IP}:/C:/Users/${DEVICE_WINDOWS_USERNAME}
    # Should Be Empty    ${out}
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${FREQUENCY_TEST_DURATION} / ${FREQUENCY_TEST_MEASURE_INTERVAL})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        Check CPU Frequency In Windows
        Sleep    ${FREQUENCY_TEST_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${FREQUENCY_TEST_MEASURE_INTERVAL}
    END
