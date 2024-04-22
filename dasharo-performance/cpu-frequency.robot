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
...                     AND
...                     Skip If    not ${CPU_FREQUENCY_MEASURE}    CPU frequency measurement tests not supported
...                     AND
...                     Check Power Supply
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
CPF001.001 CPU not stuck on initial frequency (Ubuntu 22.04)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF001.001 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Not Stuck On Initial Frequency (Ubuntu 22.04)

CPF001.002 CPU not stuck on initial frequency (Windows 11)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF001.002 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Not Stuck On Initial Frequency (Windows 11)

CPF001.003 CPU not stuck on initial frequency (Heads+Debian)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${TESTS_IN_DEBIAN_SUPPORT}    CPF001.003 not supported
    Skip If    not ${HEADS_PAYLOAD_SUPPORT}    CPF001.003 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Not Stuck On Initial Frequency (Heads+Debian)

CPF001.004 CPU not stuck on initial frequency (Ubuntu 22.04) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.004 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF001.004 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Not Stuck On Initial Frequency (Ubuntu 22.04)

CPF001.005 CPU not stuck on initial frequency (Windows 11) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.005 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF001.005 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Not Stuck On Initial Frequency (Windows 11)

CPF001.006 CPU not stuck on initial frequency (Heads+Debian) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.006 not supported
    Skip If    not ${TESTS_IN_DEBIAN_SUPPORT}    CPF001.006 not supported
    Skip If    not ${HEADS_PAYLOAD_SUPPORT}    CPF001.006 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Not Stuck On Initial Frequency (Heads+Debian)

CPF001.007 CPU not stuck on initial frequency (Ubuntu 22.04) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.007 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF001.007 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Not Stuck On Initial Frequency (Ubuntu 22.04)

CPF001.008 CPU not stuck on initial frequency (Windows 11) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.008 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF001.008 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Not Stuck On Initial Frequency (Windows 11)

CPF001.009 CPU not stuck on initial frequency (Heads+Debian) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.009 not supported
    Skip If    not ${TESTS_IN_DEBIAN_SUPPORT}    CPF001.009 not supported
    Skip If    not ${HEADS_PAYLOAD_SUPPORT}    CPF001.009 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Not Stuck On Initial Frequency (Heads+Debian)

CPF001.010 CPU not stuck on initial frequency (Ubuntu 22.04) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.010 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF001.010 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB-PD_connected}    USB-PD not connected
    CPU Not Stuck On Initial Frequency (Ubuntu 22.04)

CPF001.011 CPU not stuck on initial frequency (Windows 11) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.011 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF001.011 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB-PD_connected}    USB-PD not connected
    CPU Not Stuck On Initial Frequency (Windows 11)

CPF001.012 CPU not stuck on initial frequency (Heads+Debian) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.012 not supported
    Skip If    not ${TESTS_IN_DEBIAN_SUPPORT}    CPF001.012 not supported
    Skip If    not ${HEADS_PAYLOAD_SUPPORT}    CPF001.012 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB-PD_connected}    USB-PD not connected
    CPU Not Stuck On Initial Frequency (Heads+Debian)

CPF002.001 CPU runs on expected frequency (Ubuntu 22.04)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF002.001 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Runs On Expected Frequency (Ubuntu 22.04)

CPF002.002 CPU runs on expected frequency (Windows 11)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF002.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF002.002 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Runs On Expected Frequency (Windows 11)

CPF002.003 CPU runs on expected frequency (Ubuntu 22.04) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF002.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF002.003 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Runs On Expected Frequency (Ubuntu 22.04)

CPF002.004 CPU runs on expected frequency (Windows 11) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF002.004 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF002.004 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Runs On Expected Frequency (Windows 11)

CPF002.005 CPU runs on expected frequency (Ubuntu 22.04) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF002.005 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF002.005 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Runs On Expected Frequency (Ubuntu 22.04)

CPF002.006 CPU runs on expected frequency (Windows 11) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF002.006 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF002.006 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU Runs On Expected Frequency (Windows 11)

CPF002.007 CPU runs on expected frequency (Ubuntu 22.04) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF002.007 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF002.007 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB-PD_connected}    USB-PD not connected
    CPU Runs On Expected Frequency (Ubuntu 22.04)

CPF002.008 CPU runs on expected frequency (Windows 11) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF002.008 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF002.008 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB-PD_connected}    USB-PD not connected
    CPU Runs On Expected Frequency (Windows 11)

CPF004.001 CPU with load runs on expected frequency (Ubuntu 22.04)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF004.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF004.001 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU With Load Runs On Expected Frequency (Ubuntu 22.04)

CPF004.002 CPU with load runs on expected frequency (Windows 11)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF004.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF004.002 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU With Load Runs On Expected Frequency (Windows 11)

CPF004.003 CPU with load runs on expected frequency (Ubuntu 22.04) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF004.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF004.003 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU With Load Runs On Expected Frequency (Ubuntu 22.04)

CPF004.004 CPU with load runs on expected frequency (Windows 11) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF004.004 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF004.004 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU With Load Runs On Expected Frequency (Windows 11)

CPF004.005 CPU with load runs on expected frequency (Ubuntu 22.04) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF004.005 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF004.005 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU With Load Runs On Expected Frequency (Ubuntu 22.04)

CPF004.006 CPU with load runs on expected frequency (Windows 11) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF004.006 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF004.006 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB-PD_connected}    USB-PD connected
    CPU With Load Runs On Expected Frequency (Windows 11)

CPF004.007 CPU with load runs on expected frequency (Ubuntu 22.04) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF004.007 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF004.007 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB-PD_connected}    USB-PD not connected
    CPU With Load Runs On Expected Frequency (Ubuntu 22.04)

CPF004.008 CPU with load runs on expected frequency (Windows 11) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF004.008 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF004.008 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB-PD_connected}    USB-PD not connected
    CPU With Load Runs On Expected Frequency (Windows 11)


*** Keywords ***
CPU Not Stuck On Initial Frequency (Ubuntu 22.04)
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Sleep    10s
    Check If CPU Not Stuck On Initial Frequency In Ubuntu

CPU Not Stuck On Initial Frequency (Windows 11)
    Power On
    Login To Windows
    Sleep    10s
    Check If CPU Not Stuck On Initial Frequency In Windows

CPU Not Stuck On Initial Frequency (Heads+Debian)
    Power On
    Detect Heads Main Menu
    # Proceed with default boot
    Write Bare Into Terminal    ${ENTER}
    Read From Terminal Until    Please unlock disk nvme0n1p3_crypt:
    Write Into Terminal    debian
    Login To Linux With Root Privileges
    Sleep    10s
    Check If CPU Not Stuck On Initial Frequency In Ubuntu

CPU Runs On Expected Frequency (Ubuntu 22.04)
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${FREQUENCY_TEST_DURATION} / ${FREQUENCY_TEST_MEASURE_INTERVAL})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        @{frequencies}=    Get CPU Frequencies In Ubuntu
        FOR    ${frequency}    IN    @{frequencies}
            Run Keyword And Continue On Failure
            ...    Should Be True    ${CPU_MAX_FREQUENCY} >= ${frequency}
            Run Keyword And Continue On Failure
            ...    Should Be True    ${CPU_MIN_FREQUENCY} <= ${frequency}
        END
        Sleep    ${FREQUENCY_TEST_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${FREQUENCY_TEST_MEASURE_INTERVAL}
    END

CPU Runs On Expected Frequency (Windows 11)
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

CPU With Load Runs On Expected Frequency (Ubuntu 22.04)
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Stress Test    ${FREQUENCY_TEST_DURATION}m
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${FREQUENCY_TEST_DURATION} / ${FREQUENCY_TEST_MEASURE_INTERVAL})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        @{frequencies}=    Get CPU Frequencies In Ubuntu
        FOR    ${frequency}    IN    @{frequencies}
            Run Keyword And Continue On Failure
            ...    Should Be True    ${CPU_MAX_FREQUENCY} >= ${frequency}
            Run Keyword And Continue On Failure
            ...    Should Be True    ${CPU_MIN_FREQUENCY} <= ${frequency}
        END
        Sleep    ${FREQUENCY_TEST_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${FREQUENCY_TEST_MEASURE_INTERVAL}
    END

CPU With Load Runs On Expected Frequency (Windows 11)
    Power On
    Login To Windows
    ${out}=    Run
    ...    sshpass -p ${DEVICE_WINDOWS_PASSWORD} scp stress-test-windows.ps1 ${DEVICE_WINDOWS_USERNAME}@${DEVICE_IP}:/C:/Users/user
    ${result}=    Remove String
    ...    ${out}
    ...    Warning: Permanently added '${DEVICE_IP}' (ED25519) to the list of known hosts.
    Should Be Empty    ${result}
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
