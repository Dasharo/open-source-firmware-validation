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
Resource            ../lib/performance/common.robot
Resource            ../lib/sensors/sensors.robot
Resource            ../lib/performance/cpu.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPU temperature measurement tests not supported
...                     AND
...                     Check Power Supply
...                     AND
...                     Prepare Sensors
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CPT001.201 CPU temperature without load (Ubuntu)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    ...    Previous IDs: CPT001.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPT001.201 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    CPU Temperature Without Load

CPT002.201 CPU temperature without load (Ubuntu) (battery)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    ...    Previous IDs: CPT001.002
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT002.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPT002.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Skip If Battery Level Below 30 Percent
    CPU Temperature Without Load
    Exit From Root User

CPT003.201 CPU temperature without load (Ubuntu) (AC)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    ...    Previous IDs: CPT001.003
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT003.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPT003.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    CPU Temperature Without Load
    Exit From Root User

CPT004.201 CPU temperature without load (Ubuntu) (USB-PD)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    ...    Previous IDs: CPT001.004
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT004.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPT004.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB_PD_CONNECTED}    USB-PD not connected
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    CPU Temperature Without Load
    Exit From Root User

CPT005.201 CPU temperature after stress test (Ubuntu)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    ...    Previous IDs: CPT002.001
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT005.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT005.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPT005.201 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    CPU Temperature After Stress Test
    Exit From Root User

CPT006.201 CPU temperature after stress test (Ubuntu) (battery)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    ...    Previous IDs: CPT002.002 CPT006.002
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT006.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT006.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPT006.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Skip If Battery Level Below 30 Percent
    CPU Temperature After Stress Test
    Exit From Root User

CPT007.201 CPU temperature after stress test (Ubuntu) (AC)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    ...    Previous IDs: CPT002.003
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT007.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT007.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPT007.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    CPU Temperature After Stress Test
    Exit From Root User

CPT008.201 CPU temperature after stress test (Ubuntu) (USB-PD)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    ...    Previous IDs: CPT002.004
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT008.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPT008.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CPT008.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB_PD_CONNECTED}    USB-PD not connected
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    CPU Temperature After Stress Test
    Exit From Root User

CPT001.202 CPU temperature without load (Fedora)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPT001.202 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    CPU Temperature Without Load
    Exit From Root User

CPT002.202 CPU temperature without load (Fedora) (battery)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT002.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPT002.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Skip If Battery Level Below 30 Percent
    CPU Temperature Without Load
    Exit From Root User

CPT003.202 CPU temperature without load (Fedora) (AC)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT003.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPT003.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    CPU Temperature Without Load
    Exit From Root User

CPT004.202 CPU temperature without load (Fedora) (USB-PD)
    [Documentation]    This test aims to verify whether the temperature of CPU
    ...    cores after system booting is not higher than the maximum
    ...    allowed temperature.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT004.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPT004.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB_PD_CONNECTED}    USB-PD not connected
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    CPU Temperature Without Load
    Exit From Root User

CPT005.202 CPU temperature after stress test (Fedora)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT005.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPT005.202 not supported
    Skip If    ${LAPTOP_PLATFORM}    The Platform is a Laptop
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    CPU Temperature After Stress Test
    Exit From Root User

CPT006.202 CPU temperature after stress test (Fedora) (battery)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT006.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPT006.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Skip If Battery Level Below 30 Percent
    CPU Temperature After Stress Test
    Exit From Root User

CPT007.202 CPU temperature after stress test (Fedora) (AC)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT007.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPT007.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    AC not connected
    Skip If    ${USB_PD_CONNECTED}    USB-PD connected
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    CPU Temperature After Stress Test
    Exit From Root User

CPT008.202 CPU temperature after stress test (Fedora) (USB-PD)
    [Documentation]    This test aims to verify whether the temperature of the
    ...    CPU cores is not higher than the maximum allowed
    ...    temperature during stress test.
    Skip If    not ${CPU_TEMPERATURE_MEASURE}    CPT008.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CPT008.202 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If    not ${USB_PD_CONNECTED}    USB-PD not connected
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    CPU Temperature After Stress Test
    Exit From Root User


*** Keywords ***
CPU Temperature Without Load
    Execute Command In Terminal    sensors-detect --auto
    ${timer}=    Convert To Integer    0
    VAR    @{temperature_list}=    @{EMPTY}
    VAR    ${max_temperature}=    0
    VAR    ${min_temperature}=    999
    ${sum}=    Convert To Integer    0
    ${sum_previous}=    Convert To Integer    0
    ${total_intervals}=    Evaluate    (${TEMPERATURE_TEST_DURATION} / ${TEMPERATURE_TEST_MEASURE_INTERVAL}) + 1
    VAR    ${minute_counter}=    0
    Log To Console    \nStarting Test...
    FOR    ${i}    IN RANGE    ${total_intervals}
        ${temperature}=    Get CPU Temperature
        Append To List    ${temperature_list}    ${temperature}
        ${max_temperature}=    Evaluate    max(${max_temperature}, ${temperature})
        ${min_temperature}=    Evaluate    min(${min_temperature}, ${temperature})
        ${sum}=    Evaluate    ${sum} + ${temperature}
        Sleep    ${TEMPERATURE_TEST_MEASURE_INTERVAL}s
        ${timer}=    Evaluate    ${timer} + ${TEMPERATURE_TEST_MEASURE_INTERVAL}
        ${minute_counter}=    Evaluate    ${minute_counter} + ${TEMPERATURE_TEST_MEASURE_INTERVAL}
        IF    ${minute_counter} >= 60
            ${mean_last_minute_temperature}=    Evaluate    ((${sum} - ${sum_previous}) / 60)
            VAR    ${sum_previous}=    ${sum}
            Log To Console    \n----------------------------------------------------------------
            Log To Console    ${timer}/${TEMPERATURE_TEST_DURATION} seconds passed.
            Log To Console    Mean temperature over last minute: ${mean_last_minute_temperature}°C
            VAR    ${minute_counter}=    0
        END
    END
    ${average}=    Evaluate    ${sum} / ${total_intervals}
    Log To Console    \n----------------------------------------------------------------
    Log To Console    Mean temperature over test duration: ${average}°C
    Log To Console    Max temperature over test duration: ${max_temperature}°C
    Log To Console    Min temperature over test duration: ${min_temperature}°C
    Log To Console    Test threshold of CPU temp: ${MAX_CPU_TEMP}°C
    Should Be True    ${average} < ${MAX_CPU_TEMP}

CPU Temperature After Stress Test
    Execute Command In Terminal    sensors-detect --auto
    Stress Test    ${TEMPERATURE_TEST_DURATION}s
    ${timer}=    Convert To Integer    0
    VAR    @{temperature_list}=    @{EMPTY}
    VAR    ${max_temperature}=    0
    VAR    ${min_temperature}=    999
    ${sum}=    Convert To Integer    0
    ${sum_previous}=    Convert To Integer    0
    ${total_intervals}=    Evaluate    (${TEMPERATURE_TEST_DURATION} / ${TEMPERATURE_TEST_MEASURE_INTERVAL}) + 1
    VAR    ${minute_counter}=    0
    Log To Console    \nStarting Test...
    FOR    ${i}    IN RANGE    ${total_intervals}
        ${temperature}=    Get CPU Temperature
        Append To List    ${temperature_list}    ${temperature}
        ${max_temperature}=    Evaluate    max(${max_temperature}, ${temperature})
        ${min_temperature}=    Evaluate    min(${min_temperature}, ${temperature})
        ${sum}=    Evaluate    ${sum} + ${temperature}
        Sleep    ${TEMPERATURE_TEST_MEASURE_INTERVAL}s
        ${timer}=    Evaluate    ${timer} + ${TEMPERATURE_TEST_MEASURE_INTERVAL}
        ${minute_counter}=    Evaluate    ${minute_counter} + ${TEMPERATURE_TEST_MEASURE_INTERVAL}
        IF    ${minute_counter} >= 60
            ${mean_last_minute_temperature}=    Evaluate    ((${sum} - ${sum_previous}) / 60)
            VAR    ${sum_previous}=    ${sum}
            Log To Console    \n----------------------------------------------------------------
            Log To Console    ${timer}/${TEMPERATURE_TEST_DURATION} seconds passed.
            Log To Console    Mean temperature over last minute: ${mean_last_minute_temperature}°C
            VAR    ${minute_counter}=    0
        END
    END
    ${average}=    Evaluate    ${sum} / ${total_intervals}
    Log To Console    \n----------------------------------------------------------------
    Log To Console    Mean temperature under stress over test duration: ${average}°C
    Log To Console    Max temperature under stress over test duration: ${max_temperature}°C
    Log To Console    Min temperature over test duration: ${min_temperature}°C
    Log To Console    Test threshold of CPU temp: ${MAX_CPU_TEMP}°C
    Should Be True    ${average} < ${MAX_CPU_TEMP}
