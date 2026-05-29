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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${COREBOOT_FAN_CONTROL_SUPPORT}    coreboot fan control not supported
...                     AND    Prepare Sensors
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CFN001.201 CPU temperature and fan speed can be read (Ubuntu)
    [Documentation]    Check whether the data of CPU temperature and CPU fan
    ...    is available and can be read.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CFN001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${rpm}=    Get Fan RPM
    ${temperature}=    Get CPU Temperature
    IF    ${rpm}==${0}    FAIL    Fan speed not measured
    IF    ${temperature}==${0}    FAIL    Temperature not measured

CFN002.201 CPU fan speed increases if the temperature rises (Ubuntu)
    [Documentation]    Check whether CPU fan speed increases if the CPU
    ...    temperature rises.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CFN002.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    # Colling procedure: sometimes before starting the test case, CPU
    # temperature or CPU's fan speed might be too high. To prevent test case
    # from failing a cooling procedure is used. This procedure is to delay the
    # start of the test case while waiting for the temperature and fan speed
    # drop.
    FOR    ${iteration}    IN RANGE    0    ${COOLING_PROCEDURE_ITERATIONS}
        ${rpm}=    Get Fan RPM
        ${temperature}=    Get CPU Temperature
        IF    ${rpm}>=3000 or ${temperature}>=40
            Sleep    60s
        ELSE
            BREAK
        END
    END
    ${rpm_1}=    Get Fan RPM
    ${temperature_1}=    Get CPU Temperature
    Execute Command In Terminal    stress-ng --cpu 16 --io 8 --vm 4 --vm-bytes 4G --timeout 60s --metrics
    # Due to the stress test CPU temperature should increase.
    ${rpm_2}=    Get Fan RPM
    ${temperature_2}=    Get CPU Temperature
    Sleep    240s
    # Due to the temperature increasing fan speed should rise.
    ${rpm_3}=    Get Fan RPM
    ${temperature_3}=    Get CPU Temperature
    IF    ${temperature_1}>=${temperature_2}
        FAIL    Temperature did not increase
    END
    IF    ${rpm_2}>=${rpm_3}    FAIL    Fan speed not increased
