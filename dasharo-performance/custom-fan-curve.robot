*** Settings ***
Library             Collections
Library             DateTime
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Library             CSVLibrary
Library             ../lib/fan_curve_tool/FanCurveTool.py
Library             ../lib/images.py
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/sensors/sensors.robot
Resource            ../lib/performance/cpu.robot

Suite Setup         Gather All Enabled Fan Profiles
Suite Teardown      Run Keywords
...                     Fan Measure Stop Stress
...                     AND
...                     Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
CFC001.201 Custom fan curve silent profile measure (Ubuntu)
    [Documentation]    Show the overlay plot of all gathered fan profiles and
    ...    ask the tester whether the Silent curve is correct relative to the
    ...    others (e.g. monotonic in temperature, below Performance, above Off).
    Skip If    not ${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}    CFC001.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CFC001.201 not supported
    Show Fan Curve Overlay And Confirm
    ...    Silent: PASS if Silent is monotonic in temperature and lies between Off (lower) and Performance (higher) at matched temperatures.

CFC002.201 Custom fan curve performance profile measure (Ubuntu)
    [Documentation]    Show the overlay plot of all gathered fan profiles and
    ...    ask the tester whether the Performance curve is correct relative to
    ...    the others (faster than Silent at matched temperatures).
    Skip If    not ${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}    CFC002.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CFC002.201 not supported
    Show Fan Curve Overlay And Confirm
    ...    Performance: PASS if Performance spins faster than Silent at matched temperatures across the reachable range.

CFC003.201 Custom fan curve OFF profile measure (Ubuntu)
    [Documentation]    Show the overlay plot of all gathered fan profiles and
    ...    ask the tester whether the Fans Off curve is correct (fan stays at
    ...    baseline RPM across the reachable temperature range).
    Skip If    not ${CUSTOM_FAN_CURVE_OFF_MODE_SUPPORT}    CFC003.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CFC003.201 not supported
    Show Fan Curve Overlay And Confirm
    ...    Off: PASS if fan stays at baseline RPM across the reachable temperature range and below Silent.


*** Keywords ***
Gather All Enabled Fan Profiles
    [Documentation]    Suite setup. Initialises the fan-measure tool and then,
    ...    for each enabled profile, sets FanCurveOption (reboots the DUT),
    ...    boots Ubuntu, becomes root, and runs Fan Measure Gather. Failures of
    ...    a single profile are logged as WARN so the remaining profiles still
    ...    gather and the test cases run with partial data.
    [Arguments]    ${os_id}=${ENV_ID_UBUNTU}
    Prepare Test Suite
    Skip If    '''${CUSTOM_FAN_CURVE_FILE}''' == '''${TBD}'''
    ...    CFC not supported - CUSTOM_FAN_CURVE_FILE not defined
    Import Variables    ${CURDIR}/../platform-configs/${CUSTOM_FAN_CURVE_FILE}
    Power On
    Boot And Login To OS    ${os_id}
    VAR    ${DUT_CONNECTION_METHOD}=    SSH    scope=SUITE
    Login To Booted OS
    Fan Measure Init    ${SENSORS_CONFIG_FILE}    ${CUSTOM_FAN_CURVE_FILE}
    IF    ${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}
        Log To Console    Gathering Silent curve
        Gather One Fan Profile    Silent    silent    ${os_id}
    END
    IF    ${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}
        Log To Console    Gathering Performance curve
        Gather One Fan Profile    Performance    performance    ${os_id}
    END
    IF    ${CUSTOM_FAN_CURVE_OFF_MODE_SUPPORT}
        Log To Console    Gathering Fans Off curve
        Gather One Fan Profile    Fans Off    off    ${os_id}
    END

Gather One Fan Profile
    [Documentation]    Reboots into the requested FanCurveOption, boots Ubuntu,
    ...    becomes root, and runs Fan Measure Gather for the named profile.
    [Arguments]    ${uefi_value}    ${profile}    ${os_id}
    Set UEFI Option    FanCurveOption    ${uefi_value}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    Run Keyword And Warn On Failure    Fan Measure Gather    ${profile}    ${os_id}

Show Fan Curve Overlay And Confirm
    [Documentation]    Renders the combined fan-curve overlay, embeds it inline
    ...    in the Robot report, and asks the tester to PASS/FAIL via dialog.
    [Arguments]    ${dialog_message}
    ${img}=    Fan Measure Show Graphs

    Log Image    ${img}
    Start Process    xdg-open    ${img}
    Sleep    1s
    Execute Manual Step    ${dialog_message}\n\nOverlay: ${img}
