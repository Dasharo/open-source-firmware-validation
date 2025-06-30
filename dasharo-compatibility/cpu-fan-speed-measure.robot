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
Resource            ../lib/sensors/sensors.robot
Resource            ../lib/performance/cpu.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Prepare CPU Fan Speed Measure Suite
Suite Teardown      Log Out And Close Connection

Force Tags          automated


*** Test Cases ***
FAN001.201 CPU fan speed measure
    [Documentation]    Check whether there's a possibility to measure CPU fan
    ...    current speed.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FAN001.201 not supported
    Skip If    not ${FAN_SPEED_MEASURE_SUPPORT}    FAN001.201 not supported
    Power On
    Login To Linux
    ${output}=    Execute Linux Command
    ...    sensors | grep "CPU 0:" | awk 'NR==1 {print $3}'
    Should Not Be Empty    ${output}
    Should Not Be Equal    ${output}    0

FAN002.201 All available fans are running
    [Documentation]    Check if all available fans are running
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FAN002.201 not supported
    Skip If    not ${FAN_SPEED_MEASURE_SUPPORT}    FAN002.201 not supported
    Power On
    Login To Linux
    Switch To Root User
    Stress Test
    Exit From Root User
    ${output}=    Execute Linux Command
    ...    sensors | grep -E 'GPU|CPU' | grep -E 'RPM$' | awk '{print $3}'
    Should Not Be Empty    ${output}
    @{rpm_values}=    Split To Lines    ${output}
    FOR    ${element}    IN    @{rpm_values}
        Should Not Be Equal    ${output}    0
    END

FAN003.201 Fans are turning off during suspend mode with ME Enabled
    [Documentation]    Check for correct behavior
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FAN003.201 not supported
    Skip If    not ${FAN_SPEED_MEASURE_SUPPORT}    FAN003.201 not supported
    Power On
    Set UEFI Option    MeMode    Enabled
    Login To Linux
    Switch To Root User
    Log To Console    \nFan test started, please check fan state manually
    Execute Command In Terminal    fwts s3 -f -r /tmp/suspend_test_log.log    90
    Log To Console    \nFan state test ended, please note the result

FAN004.201 Fans are turning off during suspend mode with ME Soft disabled
    [Documentation]    Check for correct behavior
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FAN004.201 not supported
    Skip If    not ${FAN_SPEED_MEASURE_SUPPORT}    FAN004.201 not supported
    Power On
    Set UEFI Option    MeMode    Disabled (Soft)
    Login To Linux
    Switch To Root User
    Log To Console    \nFan test started, please check fan state manually
    Execute Command In Terminal    fwts s3 -f -r /tmp/suspend_test_log.log    90
    Log To Console    \nFan state test ended, please note the result

FAN005.201 Fans are turning off during suspend mode with ME HAP disabled
    [Documentation]    Check for correct behavior
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FAN005.201 not supported
    Skip If    not ${FAN_SPEED_MEASURE_SUPPORT}    FAN005.201 not supported
    Power On
    Set UEFI Option    MeMode    Disabled (HAP)
    Login To Linux
    Switch To Root User
    Log To Console    \nFan test started, please check fan state manually
    Execute Command In Terminal    fwts s3 -f -r /tmp/suspend_test_log.log    90
    Log To Console    \nFan state test ended, please note the result

FAN006.201 GPU fan speed measure
    [Documentation]    The fan has been configured to follow a custom curve.
    ...    This test aims to verify that the fan curve is configured correctly
    ...    and the fan spins up and down according to the defined values.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FAN006.201 not supported
    Skip If    not ${FAN_SPEED_MEASURE_SUPPORT}    FAN006.201 not supported
    Skip If    not ${NVIDIA_GRAPHICS_CARD_SUPPORT}    FAN006.201 not supported
    Power On
    Login To Linux
    ${output}=    Execute Linux Command
    ...    sensors | grep "GPU 0:" | awk 'NR==1 {print $3}'
    Should Not Be Empty    ${output}
    Should Not Be Equal    ${output}    0


*** Keywords ***
Prepare CPU Fan Speed Measure Suite
    [Documentation]    Prepare packages for testing CPU fans
    Prepare Test Suite
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install FWTS
    Prepare Sensors
