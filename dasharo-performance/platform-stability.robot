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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
STB001.001 Verify if no reboot occurs in the firmware
    [Documentation]    This test aims to verify that the DUT booted to the BIOS
    ...    does not reset. The test is performed in multiple iterations - after
    ...    a defined time an attempt to read the same menu is repeated.
    Skip If    not ${PLATFORM_STABILITY_CHECKING}    STB001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    STB001.001 not supported
    Power On
    Enter Boot Menu Tianocore
    Enter UEFI Shell Tianocore
    Read From Terminal Until    other key to continue
    Set Prompt For Terminal    Shell>
    Write Bare Into Terminal    ${ENTER}
    ${timer}=    Convert To Integer    0
    Telnet.Write Bare    time    0.1
    Write Bare Into Terminal    ${ENTER}
    Read From Terminal Until    LOCAL
    FOR    ${i}    IN RANGE    (${STABILITY_TEST_DURATION} / ${STABILITY_TEST_MEASURE_INTERVAL}) + 1
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        Telnet.Write Bare    time    0.1
        Write Bare Into Terminal    ${ENTER}
        Read From Terminal Until    LOCAL
        Log To Console    OK.
        Sleep    ${STABILITY_TEST_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${STABILITY_TEST_MEASURE_INTERVAL}
    END

STB001.002 Verify if no reboot occurs in the OS (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the DUT booted to the
    ...    Operating System does not reset. The test is performed in multiple
    ...    iterations - after a defined time an attempt to read the output of
    ...    specific commands confirming the stability of work is repeated.
    Skip If    not ${PLATFORM_STABILITY_CHECKING}    STB001.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    STB001.002 not supported
    Power On
    Boot Operating System    ubuntu
    Login To Linux
    Switch To Root User
    ${timer}=    Convert To Integer    0
    Set Local Variable    ${DEVICE_UPTIME}    0
    FOR    ${i}    IN RANGE    (${STABILITY_TEST_DURATION} / ${STABILITY_TEST_MEASURE_INTERVAL}) + 1
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        ${uptime_output}=    Execute Command In Terminal    uptime -p
        ${network_status}=    Execute Command In Terminal    ip link | grep -E 'enp'
        ${current_uptime}=    Convert To Integer    ${uptime_output.split()[1]}
        IF    ${current_uptime} >= ${DEVICE_UPTIME}
            Set Local Variable    ${DEVICE_UPTIME}    ${current_uptime}
        ELSE
            FAIL    \n The device has been reset during the test!
        END
        Should Contain    ${network_status}    UP
        Sleep    ${STABILITY_TEST_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${STABILITY_TEST_MEASURE_INTERVAL}
    END

STB001.003 Verify if no reboot occurs in the OS (Windows 11)
    [Documentation]    This test aims to verify that the DUT booted to the
    ...    Operating System does not reset. The test is performed in multiple
    ...    iterations - after a defined time an attempt to read the output of
    ...    specific commands confirming the stability of work is repeated.
    Skip If    not ${PLATFORM_STABILITY_CHECKING}    STB001.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    STB001.002 not supported
    Power On
    Boot Operating System    windows
    Login To Windows
    ${timer}=    Convert To Integer    0
    Set Local Variable    ${DEVICE_UPTIME}    0
    FOR    ${i}    IN RANGE    (${STABILITY_TEST_DURATION} / ${STABILITY_TEST_MEASURE_INTERVAL}) + 1
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        ${uptime_output}=    Execute Command In Terminal    (get-date) - (gcim Win32_OperatingSystem).LastBootUpTime
        ${network_status}=    Execute Command In Terminal    Get-NetAdapter -Name "Ethernet*"
        ${current_uptime}=    Convert To Number    ${uptime_output.split()[26]}
        ${current_uptime}=    Convert To Integer    ${current_uptime}
        IF    ${current_uptime} >= ${DEVICE_UPTIME}
            Set Local Variable    ${DEVICE_UPTIME}    ${current_uptime}
        ELSE
            FAIL    \n The device has been reset during the test!
        END
        Should Contain    ${network_status}    Up
        Sleep    ${STABILITY_TEST_MEASURE_INTERVAL}m
        ${timer}=    Evaluate    ${timer} + ${STABILITY_TEST_MEASURE_INTERVAL}
    END
