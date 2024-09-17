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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
# TODO: Bring back these tests once ACPI driver and fw support is developed
# FAN001.001 CPU fan speed measure
#    [Documentation]    Check whether there's a possibility to measure CPU fan
#    ...    current speed.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FAN001.001 not supported
#    Skip If    not ${FAN_SPEED_MEASURE_SUPPORT}    FAN001.001 not supported
#    Power On
#    Login To Linux
#    Switch To Root User
#    Prepare Lm-sensors
#    ${output}=    Get RPM Value From System76 Acpi
#    Should Not Be Empty    ${output}
#    Should Not Be Equal    ${output}    0

# FAN001.002 All available fans are running
#    [Documentation]    Check if all available fans are running
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FAN001.001 not supported
#    Skip If    not ${FAN_SPEED_MEASURE_SUPPORT}    FAN001.001 not supported
#    Power On
#    Login To Linux
#    Switch To Root User
#    Prepare Lm-sensors
#    Execute Command In Terminal    stress-ng -c $(nproc) -t 10
#    ${output}=    Execute Command In Terminal    sensors | grep "CPU fan"
#    Should Not Be Empty    ${output}
#    Should Not Be Equal    ${output}    0

# TODO: Previously, this test was documented as FAN001.002, specific
#    to Asus KGPE platforms. Determine if it possible to use this
#    on other platforms.
# FAN001.003 Check if increasing CPU temperature increases CPU fan speed
#    [Documentation]    This test aims to verify that CPU fan speed
#    ...    responds properly to increasing CPU temperature.

# TODO: Determine if it is possible to get RPM values from graphics card.
#    It is possible on some of the NVIDIA cards using nvidia-smi
# FAN002.001 GPU fan speed measure
#    [Documentation]    The fan has been configured to follow a custom curve.
#    ...    This test aims to verify that the fan curve is configured correctly
#    ...    and the fan spins up and down according to the defined values.

FAN003.001 Fans are turning off during suspend mode (ME Enabled)
    [Documentation]    Check for correct behavior
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FAN003.001 not supported
    Skip If    not ${FAN_SPEED_MEASURE_SUPPORT}    FAN001.001 not supported
    Power On
    Set UEFI Option    MeMode    Enabled
    Login To Linux
    Switch To Root User
    Prepare Lm-sensors
    Detect Or Install FWTS
    Log To Console    \nPlease check fan state manually
    Execute Command In Terminal    fwts s3 -f -r /tmp/suspend_test_log.log    90
    Log To Console    \nFan state test ended, please note the result

FAN003.002 Fans are turning off during suspend mode (ME Soft disable)
    [Documentation]    Check for correct behavior
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FAN003.002 not supported
    Skip If    not ${FAN_SPEED_MEASURE_SUPPORT}    FAN001.001 not supported
    Power On
    Set UEFI Option    MeMode    Disabled (Soft)
    Login To Linux
    Switch To Root User
    Prepare Lm-sensors
    Detect Or Install FWTS
    Log To Console    \nPlease check fan state manually
    Execute Command In Terminal    fwts s3 -f -r /tmp/suspend_test_log.log    90
    Log To Console    \nFan state test ended, please note the result

FAN003.003 Fans are turning off during suspend mode (ME HAP disable)
    [Documentation]    Check for correct behavior
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FAN003.002 not supported
    Skip If    not ${FAN_SPEED_MEASURE_SUPPORT}    FAN001.001 not supported
    Power On
    Set UEFI Option    MeMode    Disabled (HAP)
    Login To Linux
    Switch To Root User
    Prepare Lm-sensors
    Detect Or Install FWTS
    Log To Console    \nPlease check fan state manually
    Execute Command In Terminal    fwts s3 -f -r /tmp/suspend_test_log.log    90
    Log To Console    \nFan state test ended, please note the result
