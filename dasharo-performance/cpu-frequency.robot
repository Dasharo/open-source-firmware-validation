*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
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
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
CPF001.001 CPU not stuck on initial frequency (Ubuntu 22.04)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${cpu_frequency_measure}    CPF001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    CPF001.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Sleep    10s
    Check If CPU not stucks on Initial Frequency in Ubuntu

CPF001.002 CPU not stuck on initial frequency (Windows 11)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${cpu_frequency_measure}    CPF001.002 not supported
    Skip If    not ${tests_in_windows_support}    CPF001.002 not supported
    Power On
    Boot system or from connected disk    windows
    Login to Windows
    Sleep    10s
    Check If CPU not stucks on Initial Frequency in Windows

CPF001.003 CPU not stuck on initial frequency (Heads+Debian)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${cpu_frequency_measure}    CPF001.003 not supported
    Skip If    not ${tests_in_debian_support}    CPF001.003 not supported
    Skip If    not ${heads_payload_support}    CPF001.003 not supported
    Power On
    Detect Heads Main Menu
    # Proceed with default boot
    Write Bare Into Terminal    ${ENTER}
    Read From Terminal Until    Please unlock disk nvme0n1p3_crypt:
    Write Into Terminal    debian
    Login to Linux with Root Privileges
    Sleep    10s
    Check If CPU not stucks on Initial Frequency in Ubuntu

CPF002.001 CPU runs on expected frequency (Ubuntu 22.04)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${cpu_frequency_measure}    CPF002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    CPF002.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${freq_max}=    Get CPU Frequency MAX
    ${freq_min}=    Get CPU Frequency MIN
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${frequency_test_duration} / ${frequency_test_measure_interval})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        @{frequencies}=    Get CPU frequencies in Ubuntu
        FOR    ${frequency}    IN    @{frequencies}
            Run Keyword And Continue On Failure    Should Be True    ${freq_max} > ${frequency}
            Run Keyword And Continue On Failure    Should Be True    ${freq_min} < ${frequency}
        END
        Sleep    ${frequency_test_measure_interval}m
        ${timer}=    Evaluate    ${timer} + ${frequency_test_measure_interval}
    END

CPF002.002 CPU runs on expected frequency (Windows 11)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${cpu_frequency_measure}    CPF002.002 not supported
    Skip If    not ${tests_in_windows_support}    CPF002.002 not supported
    Power On
    Boot system or from connected disk    windows
    Login to Windows
    Check CPU frequency in Windows

CPF003.001 CPU runs on expected frequency (Ubuntu 22.04, battery)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${cpu_frequency_measure}    CPF003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    CPF003.001 not supported
    Check Battery Backup
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${freq_max}=    Get CPU Frequency MAX
    ${freq_min}=    Get CPU Frequency MIN
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${frequency_test_duration} / ${frequency_test_measure_interval})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        @{frequencies}=    Get CPU frequencies in Ubuntu
        FOR    ${frequency}    IN    @{frequencies}
            Run Keyword And Continue On Failure    Should Be True    ${freq_max} > ${frequency}
            Run Keyword And Continue On Failure    Should Be True    ${freq_min} < ${frequency}
        END
        Sleep    ${frequency_test_measure_interval}m
        ${timer}=    Evaluate    ${timer} + ${frequency_test_measure_interval}
    END

CPF003.002 CPU runs on expected frequency (Windows 11, battery)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${cpu_frequency_measure}    CPF002.002 not supported
    Skip If    not ${tests_in_windows_support}    CPF002.002 not supported
    Check Battery Backup
    Power On
    Boot system or from connected disk    windows
    Login to Windows
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${frequency_test_duration} / ${frequency_test_measure_interval})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        Check CPU frequency in Windows
        Sleep    ${frequency_test_measure_interval}m
        ${timer}=    Evaluate    ${timer} + ${frequency_test_measure_interval}
    END

CPF004.001 CPU with load runs on expected frequency (Ubuntu 22.04)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${cpu_frequency_measure}    CPF004.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    CPF004.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${freq_max}=    Get CPU Frequency MAX
    ${freq_min}=    Get CPU Frequency MIN
    Stress Test    ${frequency_test_duration}m
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${frequency_test_duration} / ${frequency_test_measure_interval})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        @{frequencies}=    Get CPU frequencies in Ubuntu
        FOR    ${frequency}    IN    @{frequencies}
            Run Keyword And Continue On Failure    Should Be True    ${freq_max} > ${frequency}
            Run Keyword And Continue On Failure    Should Be True    ${freq_min} < ${frequency}
        END
        Sleep    ${frequency_test_measure_interval}m
        ${timer}=    Evaluate    ${timer} + ${frequency_test_measure_interval}
    END

CPF004.002 CPU with load runs on expected frequency (Windows 11)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${cpu_frequency_measure}    CPF004.002 not supported
    Skip If    not ${tests_in_windows_support}    CPF004.002 not supported
    Power On
    ${out}=    Run
    ...    sshpass -p ${device_windows_password} scp stress-test-windows.ps1 ${device_windows_username}@${device_ip}:/C:/Users/user
    Should Be Empty    ${out}
    Boot system or from connected disk    windows
    Login to Windows
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${frequency_test_duration} / ${frequency_test_measure_interval})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        Check CPU frequency in Windows
        Sleep    ${frequency_test_measure_interval}m
        ${timer}=    Evaluate    ${timer} + ${frequency_test_measure_interval}
    END

CPF005.001 CPU with load runs on expected frequency (Ubuntu 22.04, battery)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${cpu_frequency_measure}    CPF005.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    CPF005.001 not supported
    Check Battery Backup
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${freq_max}=    Get CPU Frequency MAX
    ${freq_min}=    Get CPU Frequency MIN
    Stress Test    ${frequency_test_duration}m
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${frequency_test_duration} / ${frequency_test_measure_interval})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        @{frequencies}=    Get CPU frequencies in Ubuntu
        FOR    ${frequency}    IN    @{frequencies}
            Run Keyword And Continue On Failure    Should Be True    ${freq_max} > ${frequency}
            Run Keyword And Continue On Failure    Should Be True    ${freq_min} < ${frequency}
        END
        Sleep    ${frequency_test_measure_interval}m
        ${timer}=    Evaluate    ${timer} + ${frequency_test_measure_interval}
    END

CPF005.002 CPU with load runs on expected frequency (Windows 11, battery)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${cpu_frequency_measure}    CPF004.002 not supported
    Skip If    not ${tests_in_windows_support}    CPF004.002 not supported
    Check Battery Backup
    Power On
    ${out}=    Run
    ...    sshpass -p ${device_windows_password} scp stress-test-windows.ps1 ${device_windows_username}@${device_ip}:/C:/Users/user
    Should Be Empty    ${out}
    Boot system or from connected disk    windows
    Login to Windows
    SSHLibrary.Execute Command    .\\stress-test-windows.ps1
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${frequency_test_duration} / ${frequency_test_measure_interval})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        Check CPU frequency in Windows
        Sleep    ${frequency_test_measure_interval}m
        ${timer}=    Evaluate    ${timer} + ${frequency_test_measure_interval}
    END


*** Keywords ***
Check Battery Backup
    [Documentation]    Check if the current platform is equipped with a battery.
    Set Local Variable    ${is_battery}    ${False}
    IF    '${platform}'== 'novacustom-ns50'
        RETURN
    ELSE IF    '${platform}' == 'tuxedo-ns50'
        RETURN
    ELSE IF    '${platform}' == 'novacustom-ns70'
        RETURN
    ELSE IF    '${platform}' == 'novacustom-nv41-mb'
        RETURN
    ELSE IF    '${platform}' == 'novacustom-nv41-mz'
        RETURN
    ELSE IF    '${platform}' == 'novacustom-ns70pu'
        RETURN
    ELSE IF    '${platform}' == 'novacustom-ns50pu'
        RETURN
    ELSE IF    '${platform}' == 'novacustom-nv41-pz'
        RETURN
    ELSE
        SKIP    \nPlatform does not have battery backup
    END
