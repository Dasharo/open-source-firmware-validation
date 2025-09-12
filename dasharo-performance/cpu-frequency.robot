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
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../keys-and-keywords/heads-keywords.robot
Resource            ../lib/performance/cpu.robot

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

Default Tags        automated


*** Test Cases ***
CPF001.201 CPU not stuck on initial frequency (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPF001.201 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Not Stuck On Initial Frequency (Linux)    ${ENV_ID_UBUNTU}

CPF002.201 CPU not stuck on initial frequency (Ubuntu) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.004
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF002.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPF002.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    Skip If Battery Level Below 30 Percent
    CPU Not Stuck On Initial Frequency (Linux)    ${ENV_ID_UBUNTU}

CPF003.201 CPU not stuck on initial frequency (Ubuntu) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.007
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF003.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPF003.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    CPU Not Stuck On Initial Frequency (Linux)    ${ENV_ID_UBUNTU}

CPF004.201 CPU not stuck on initial frequency (Ubuntu) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.0010
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF004.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPF004.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB_PD_CONNECTED}    USB-PD not connected
    CPU Not Stuck On Initial Frequency (Linux)    ${ENV_ID_UBUNTU}

CPF005.201 CPU runs on expected frequency (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.001
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF005.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF005.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPF005.201 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Runs On Expected Frequency (Linux)    ${ENV_ID_UBUNTU}

CPF006.201 CPU runs on expected frequency (Ubuntu) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.003
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF006.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF006.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPF006.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    Skip If Battery Level Below 30 Percent
    CPU Runs On Expected Frequency (Linux)    ${ENV_ID_UBUNTU}

CPF007.201 CPU runs on expected frequency (Ubuntu) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.005
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF007.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF007.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPF007.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    CPU Runs On Expected Frequency (Linux)    ${ENV_ID_UBUNTU}

CPF008.201 CPU runs on expected frequency (Ubuntu) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.007
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF008.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF008.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPF008.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB_PD_CONNECTED}    USB-PD not connected
    CPU Runs On Expected Frequency (Linux)    ${ENV_ID_UBUNTU}

CPF009.201 CPU with load runs on expected frequency (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.001
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF009.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF009.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPF009.201 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU With Load Runs On Expected Frequency (Linux)    ${ENV_ID_UBUNTU}

CPF010.201 CPU with load runs on expected frequency (Ubuntu) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.003
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF010.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF010.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPF010.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    Skip If Battery Level Below 30 Percent
    CPU With Load Runs On Expected Frequency (Linux)    ${ENV_ID_UBUNTU}

CPF011.201 CPU with load runs on expected frequency (Ubuntu) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.005
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF011.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF011.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPF011.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    CPU With Load Runs On Expected Frequency (Linux)    ${ENV_ID_UBUNTU}

CPF012.201 CPU with load runs on expected frequency (Ubuntu) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.007
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF012.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF012.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPF012.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB_PD_CONNECTED}    USB-PD not connected
    CPU With Load Runs On Expected Frequency (Linux)    ${ENV_ID_UBUNTU}

CPF001.202 CPU not stuck on initial frequency (Fedora)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF001.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPF001.202 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Not Stuck On Initial Frequency (Linux)    ${ENV_ID_FEDORA}

CPF002.202 CPU not stuck on initial frequency (Fedora) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF002.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPF002.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    Skip If Battery Level Below 30 Percent
    CPU Not Stuck On Initial Frequency (Linux)    ${ENV_ID_FEDORA}

CPF003.202 CPU not stuck on initial frequency (Fedora) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF003.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPF003.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    CPU Not Stuck On Initial Frequency (Linux)    ${ENV_ID_FEDORA}

CPF004.202 CPU not stuck on initial frequency (Fedora) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF004.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPF004.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB_PD_CONNECTED}    USB-PD not connected
    CPU Not Stuck On Initial Frequency (Linux)    ${ENV_ID_FEDORA}

CPF005.202 CPU runs on expected frequency (Fedora)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF005.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPF005.202 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Runs On Expected Frequency (Linux)    ${ENV_ID_FEDORA}

CPF006.202 CPU runs on expected frequency (Fedora) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF006.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPF006.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    Skip If Battery Level Below 30 Percent
    CPU Runs On Expected Frequency (Linux)    ${ENV_ID_FEDORA}

CPF007.202 CPU runs on expected frequency (Fedora) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF007.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPF007.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    CPU Runs On Expected Frequency (Linux)    ${ENV_ID_FEDORA}

CPF008.202 CPU runs on expected frequency (Fedora) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF008.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPF008.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB_PD_CONNECTED}    USB-PD not connected
    CPU Runs On Expected Frequency (Linux)    ${ENV_ID_FEDORA}

CPF009.202 CPU with load runs on expected frequency (Fedora)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF009.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPF009.202 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU With Load Runs On Expected Frequency (Linux)    ${ENV_ID_FEDORA}

CPF010.202 CPU with load runs on expected frequency (Fedora) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF010.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPF010.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    Skip If Battery Level Below 30 Percent
    CPU With Load Runs On Expected Frequency (Linux)    ${ENV_ID_FEDORA}

CPF011.202 CPU with load runs on expected frequency (Fedora) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF011.202 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPF011.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPF011.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    CPU With Load Runs On Expected Frequency (Linux)    ${ENV_ID_FEDORA}

CPF012.202 CPU with load runs on expected frequency (Fedora) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF012.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPF012.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB_PD_CONNECTED}    USB-PD not connected
    CPU With Load Runs On Expected Frequency (Linux)    ${ENV_ID_FEDORA}

CPF001.003 CPU not stuck on initial frequency (Heads+Debian)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${TESTS_IN_DEBIAN_SUPPORT}    CPF001.003 not supported
    Skip If    not ${HEADS_PAYLOAD_SUPPORT}    CPF001.003 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Not Stuck On Initial Frequency (Heads+Debian)

CPF001.006 CPU not stuck on initial frequency (Heads+Debian) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.006 not supported
    Skip If    not ${TESTS_IN_DEBIAN_SUPPORT}    CPF001.006 not supported
    Skip If    not ${HEADS_PAYLOAD_SUPPORT}    CPF001.006 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    CPU Not Stuck On Initial Frequency (Heads+Debian)

CPF001.009 CPU not stuck on initial frequency (Heads+Debian) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.009 not supported
    Skip If    not ${TESTS_IN_DEBIAN_SUPPORT}    CPF001.009 not supported
    Skip If    not ${HEADS_PAYLOAD_SUPPORT}    CPF001.009 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    CPU Not Stuck On Initial Frequency (Heads+Debian)

CPF001.012 CPU not stuck on initial frequency (Heads+Debian) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF001.012 not supported
    Skip If    not ${TESTS_IN_DEBIAN_SUPPORT}    CPF001.012 not supported
    Skip If    not ${HEADS_PAYLOAD_SUPPORT}    CPF001.012 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB_PD_CONNECTED}    USB-PD not connected
    CPU Not Stuck On Initial Frequency (Heads+Debian)

CPF001.301 CPU not stuck on initial frequency (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.002
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF001.301 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop`
    CPU Not Stuck On Initial Frequency (Windows)

CPF002.301 CPU not stuck on initial frequency (Windows) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.005
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF002.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF002.301 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    CPU Not Stuck On Initial Frequency (Windows)

CPF003.301 CPU not stuck on initial frequency (Windows) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.008
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF003.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF003.301 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    CPU Not Stuck On Initial Frequency (Windows)

CPF004.301 CPU not stuck on initial frequency (Windows) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.011
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF004.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF004.301 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB_PD_CONNECTED}    USB-PD not connected
    CPU Not Stuck On Initial Frequency (Windows)

CPF005.301 CPU runs on expected frequency (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.002
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF005.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF005.301 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Runs On Expected Frequency (Windows)

CPF006.301 CPU runs on expected frequency (Windows) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.004
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF006.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF006.301 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    CPU Runs On Expected Frequency (Windows)

CPF007.301 CPU runs on expected frequency (Windows) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.006
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF007.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF007.301 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    CPU Runs On Expected Frequency (Windows)

CPF008.301 CPU runs on expected frequency (Windows) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency.
    ...    Previous IDs: CPF002.008
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF008.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF008.301 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB_PD_CONNECTED}    USB-PD not connected
    CPU Runs On Expected Frequency (Windows)

CPF009.301 CPU with load runs on expected frequency (Windows)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.002
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF009.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF009.301 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU With Load Runs On Expected Frequency (Windows)

CPF010.301 CPU with load runs on expected frequency (Windows) (battery)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.004
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF010.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF010.301 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    CPU With Load Runs On Expected Frequency (Windows)

CPF011.301 CPU with load runs on expected frequency (Windows) (AC)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.006
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF011.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF011.301 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    CPU With Load Runs On Expected Frequency (Windows)

CPF012.301 CPU with load runs on expected frequency (Windows) (USB-PD)
    [Documentation]    This test aims to verify whether the mounted CPU is
    ...    running on expected frequency after stress test.
    ...    Previous IDs: CPF004.008
    Skip If    not ${CPU_FREQUENCY_MEASURE}    CPF012.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPF012.301 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB_PD_CONNECTED}    USB-PD not connected
    CPU With Load Runs On Expected Frequency (Windows)


*** Keywords ***
CPU Not Stuck On Initial Frequency (Linux)
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    Sleep    10s
    Check If CPU Not Stuck On Initial Frequency In Linux

CPU Not Stuck On Initial Frequency (Windows)
    Power On
    Login To Windows
    Sleep    10s
    Check If CPU Not Stuck On Initial Frequency In Windows
    IF    '${INITIAL_DUT_CONNECTION_METHOD}' != 'SSH'
        Execute Shutdown Command
    END

CPU Not Stuck On Initial Frequency (Heads+Debian)
    Power On
    Detect Heads Main Menu
    # Proceed with default boot
    Write Bare Into Terminal    ${ENTER}
    Read From Terminal Until    Please unlock disk nvme0n1p3_crypt:
    Write Into Terminal    debian
    Login To Linux With Root Privileges
    Sleep    10s
    Check If CPU Not Stuck On Initial Frequency In Linux

CPU Runs On Expected Frequency (Linux)
    [Arguments]    ${os_id}
    ${cpu_max_frequency_tol}=    Evaluate    ${CPU_MAX_FREQUENCY} * 1.125
    ${cpu_min_frequency_tol}=    Evaluate    ${CPU_MIN_FREQUENCY} * 0.875

    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${timer}=    Convert To Integer    0
    FOR    ${i}    IN RANGE    (${FREQUENCY_TEST_DURATION} / ${FREQUENCY_TEST_MEASURE_INTERVAL})
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        @{frequencies}=    Get CPU Frequencies In Ubuntu
        FOR    ${frequency}    IN    @{frequencies}
            Run Keyword And Continue On Failure
            ...    Should Be True    ${cpu_max_frequency_tol} >= ${frequency}
            Run Keyword And Continue On Failure
            ...    Should Be True    ${cpu_min_frequency_tol} <= ${frequency}
        END
        Sleep    ${FREQUENCY_TEST_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${FREQUENCY_TEST_MEASURE_INTERVAL}
    END

CPU Runs On Expected Frequency (Windows)
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
    IF    '${INITIAL_DUT_CONNECTION_METHOD}' != 'SSH'
        Execute Shutdown Command
    END

CPU With Load Runs On Expected Frequency (Linux)
    [Arguments]    ${os_id}
    ${cpu_max_frequency_tol}=    Evaluate    ${CPU_MAX_FREQUENCY} * 1.125
    ${cpu_min_frequency_tol}=    Evaluate    ${CPU_MIN_FREQUENCY} * 0.875

    Power On
    Boot System Or From Connected Disk    ${os_id}
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
            ...    Should Be True    ${cpu_max_frequency_tol} >= ${frequency}
            Run Keyword And Continue On Failure
            ...    Should Be True    ${cpu_min_frequency_tol} <= ${frequency}
        END
        Sleep    ${FREQUENCY_TEST_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${FREQUENCY_TEST_MEASURE_INTERVAL}
    END

CPU With Load Runs On Expected Frequency (Windows)
    Power On
    Login To Windows
    SSHLibrary.Put File    stress-test-windows.ps1    /C:/Users/user
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
    IF    '${INITIAL_DUT_CONNECTION_METHOD}' != 'SSH'
        Execute Shutdown Command
    END
