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
FAN001.001 CPU fan speed measure
    [Documentation]    Check whether there's a possibility to measure CPU fan
    ...    current speed.
    Skip If    not ${FAN_SPEED_MEASURE_SUPPORT}    FAN001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FAN001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Prepare Lm-sensors
    ${output}=    Get RPM Value From System76 Acpi
    Should Not Be Empty    ${output}
    Should Not Be Equal    ${output}    0

FAN002.001 All available fans are running
    [Documentation]    Check if all available fans are runing
#    Future Skip conditions
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    linux-oem-22.04a
    Prepare Lm-sensors
    Execute Command In Terminal    stress -c $(nproc) -t 10
    ${OUTPUT}= Execute Command In Terminal    sensors | grep "CPU fan"
    Should Not Contain    ${OUTPUT}    0 RPM

FAN003.001 Fans are turning off during suspend mode (ME Enabled)
    [Documentation]    Check for correct behavior
#    Future Skip conditions
    Power On
    Set UEFI Option    MeMode    Enabled
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Prepare Lm-sensors
    Detect Or Install FWTS
    Write Into Terminal    fwts s3 -f -r /tmp/suspend_test_log.log

FAN003.002 Fans are turning off during suspend mode (ME Soft disable)
    [Documentation]    Check for correct behavior
#    Future Skip conditions
    Power On
    Set UEFI Option    MeMode    Disabled (SOFT)
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Prepare Lm-sensors
    Detect Or Install FWTS
    Write Into Terminal    fwts s3 -f -r /tmp/suspend_test_log.log

FAN003.003 Fans are turning off during suspend mode (ME HAP disable)
    [Documentation]    Check for correct behavior
#    Future Skip conditions
    Power On
    Set UEFI Option    MeMode    Disabled (HAP)
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Prepare Lm-sensors
    Detect Or Install FWTS
    Write Into Terminal    fwts s3 -f -r /tmp/suspend_test_log.log
