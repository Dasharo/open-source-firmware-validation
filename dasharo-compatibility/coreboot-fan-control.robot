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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
CFN001.001 CPU temperature and fan speed can be read (Debian 11.02)
    [Documentation]    Check whether the data of CPU temperature and CPU fan
    ...    is available and can be read.
    Skip If    not ${coreboot_fan_control_support}    CFN001.001 not supported
    Skip If    not ${tests_in_debian_support}    CFN001.001 not supported
    Power On
    Boot from USB
    Serial root login Linux    debian
    ${rpm}    ${temperature}=    Get CPU temperature and CPU fan speed
    IF    ${rpm}==${0}    FAIL    Fan speed not measured
    IF    ${temperature}==${0}    FAIL    Temperature not measured

CFN002.001 CPU fan speed increases if the temperature rises (Debian 11.02)
    [Documentation]    Check whether CPU fan speed increases if the CPU
    ...    temperature rises.
    Skip If    not ${coreboot_fan_control_support}    CFN002.001 not supported
    Skip If    not ${tests_in_debian_support}    CFN002.001 not supported
    Power On
    Boot from USB
    Serial root login Linux    debian
    # Colling procedure: sometimes before starting the test case, CPU
    # temperature or CPU's fan speed might be too high. To prevent test case
    # from failing a cooling procedure is used. This procedure is to delay the
    # start of the test case while waiting for the temperature and fan speed
    # drop.
    FOR    ${iteration}    IN RANGE    0    ${cooling_procedure_iterations}
        ${rpm}    ${temperature}=    Get CPU temperature and CPU fan speed
        IF    ${rpm}>=3000 or ${temperature}>=40
            Sleep    60s
        ELSE
            BREAK
        END
    END
    ${rpm_1}    ${temperature_1}=    Get CPU temperature and CPU fan speed
    Telnet.Execute Command    stress-ng --cpu 16 --io 8 --vm 4 --vm-bytes 4G --timeout 60s --metrics
    # Due to the stress test CPU temperature should increase.
    ${rpm_2}    ${temperature_2}=    Get CPU temperature and CPU fan speed
    Sleep    240s
    # Due to the temperature increasing fan speed should rise.
    ${rpm_3}    ${temperature_3}=    Get CPU temperature and CPU fan speed
    IF    ${temperature_1}>=${temperature_2}
        FAIL    Temperature not increased
    END
    IF    ${rpm_2}>=${rpm_3}    FAIL    Fan speed not increased
