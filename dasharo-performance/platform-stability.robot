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
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
STB001.001 Verify if no reboot occurs in the firmware
    [Documentation]    This test aims to verify that the DUT booted to the BIOS
    ...    does not reset. The test is performed in multiple iterations - after
    ...    a defined time an attempt to read the same menu is repeated.
    Skip If    not ${platform_stability_checking}    STB001.001 not supported
    Skip If    not ${tests_in_firmware_support}    STB001.001 not supported
    Power On
    Enter Boot Menu Tianocore
    Enter UEFI Shell Tianocore
    Read From Terminal Until    other key to continue
    Set Prompt For Terminal    Shell>
    Write Bare Into Terminal    ${ENTER}
    ${timer}=    Convert To Integer    0
    Telnet.Write Bare    time    0.1
    Write Bare Into Terminal    ${Enter}
    Read From Terminal Until    LOCAL
    FOR    ${i}    IN RANGE    (${stability_test_duration} / ${stability_test_measure_interval}) + 1
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        Telnet.Write Bare    time    0.1
        Write Bare Into Terminal    ${Enter}
        Read From Terminal Until    LOCAL
        Log To Console    OK.
        Sleep    ${stability_test_measure_interval}m
        ${timer}=    Evaluate    ${timer} + ${stability_test_measure_interval}
    END

STB001.002 Verify if no reboot occurs in the OS (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the DUT booted to the
    ...    Operating System does not reset. The test is performed in multiple
    ...    iterations - after a defined time an attempt to read the output of
    ...    specific commands confirming the stability of work is repeated.
    Skip If    not ${platform_stability_checking}    STB001.002 not supported
    Skip If    not ${tests_in_ubuntu_support}    STB001.002 not supported
    Power On
    Boot operating system    ubuntu
    Login to Linux
    Switch to root user
    ${timer}=    Convert To Integer    0
    Set Local Variable    ${device_uptime}    0
    FOR    ${i}    IN RANGE    (${stability_test_duration} / ${stability_test_measure_interval}) + 1
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        ${uptime_output}=    Execute Command In Terminal    uptime -p
        ${network_status}=    Execute Command In Terminal    ip link | grep -E 'enp'
        ${current_uptime}=    Convert To Integer    ${uptime_output.split()[1]}
        IF    ${current_uptime} >= ${device_uptime}
            Set Local Variable    ${device_uptime}    ${current_uptime}
        ELSE
            FAIL    \n The device has been reset during the test!
        END
        Should Contain    ${network_status}    UP
        Sleep    ${stability_test_measure_interval}m
        ${timer}=    Evaluate    ${timer} + ${stability_test_measure_interval}
    END

STB001.003 Verify if no reboot occurs in the OS (Windows 11)
    [Documentation]    This test aims to verify that the DUT booted to the
    ...    Operating System does not reset. The test is performed in multiple
    ...    iterations - after a defined time an attempt to read the output of
    ...    specific commands confirming the stability of work is repeated.
    Skip If    not ${platform_stability_checking}    STB001.002 not supported
    Skip If    not ${tests_in_windows_support}    STB001.002 not supported
    Power On
    Boot operating system    windows
    Login to Windows
    ${timer}=    Convert To Integer    0
    Set Local Variable    ${device_uptime}    0
    FOR    ${i}    IN RANGE    (${stability_test_duration} / ${stability_test_measure_interval}) + 1
        Log To Console    \n ----------------------------------------------------------------
        Log To Console    ${timer} min.
        ${uptime_output}=    Execute Command In Terminal    (get-date) - (gcim Win32_OperatingSystem).LastBootUpTime
        ${network_status}=    Execute Command In Terminal    Get-NetAdapter -Name "Ethernet*"
        ${current_uptime}=    Convert To Number    ${uptime_output.split()[26]}
        ${current_uptime}=    Convert To Integer    ${current_uptime}
        IF    ${current_uptime} >= ${device_uptime}
            Set Local Variable    ${device_uptime}    ${current_uptime}
        ELSE
            FAIL    \n The device has been reset during the test!
        END
        Should Contain    ${network_status}    Up
        Sleep    ${stability_test_measure_interval}m
        ${timer}=    Evaluate    ${timer} + ${stability_test_measure_interval}
    END
