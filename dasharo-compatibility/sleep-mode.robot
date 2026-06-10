*** Settings ***
Library             DateTime
Library             Dialogs
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/sleep-lib.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
SLM001.201 Sleep mode - battery monitoring (Ubuntu)
    [Documentation]    Check how quickly the battery discharges while in sleep mode in Ubuntu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SLM001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SLM001.201 not supported
    VAR    ${sleep_duration_s}=    600
    VAR    ${total_time_s}=    21600
    VAR    ${elapsed}=    0
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Execute Manual Step    Disconnect the power supply
    ${ac_online}=    Execute Command In Terminal    cat /sys/class/power_supply/AC/online
    Should Be Equal    ${ac_online}    0
    ${capacity}=    Check Battery Percentage In Linux
    ${start_time}=    Get Current Date    result_format=epoch
    Log To Console    \n0s elapsed: battery at ${capacity}%
    WHILE    ${elapsed} < ${total_time_s}
        Perform Suspend And Wake Using Rtcwake    ${sleep_duration_s}
        Login To Linux
        Switch To Root User
        ${capacity}=    Check Battery Percentage In Linux
        ${now}=    Get Current Date    result_format=epoch
        ${elapsed}=    Evaluate    int(${now} - ${start_time})
        Log To Console    ${elapsed}s elapsed: battery at ${capacity}%
    END
    Execute Manual Step    Connect the power supply
    Exit From Root User

SLM000.301 Sleep mode - battery monitoring (Windows)
    [Documentation]    Check how quickly the battery discharges while in sleep mode in Windows.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SLM000.301 not supported
    VAR    ${sleep_duration_s}=    600
    VAR    ${total_time_s}=    21600
    VAR    ${elapsed}=    0
    Power On
    Boot And Login To Windows
    Execute Command In Terminal    powercfg /hibernate off
    Execute Command In Terminal
    ...    powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 1
    Execute Command In Terminal    powercfg /setactive SCHEME_CURRENT
    Execute Manual Step    Disconnect the power supply
    ${battery_status}=    Execute Command In Terminal    (Get-WmiObject Win32_Battery).BatteryStatus
    Should Be Equal    ${battery_status}    1
    ${capacity}=    Get Battery Power Level Windows
    ${start_time}=    Get Current Date    result_format=epoch
    Log To Console    \n0s elapsed: battery at ${capacity}%
    WHILE    ${elapsed} < ${total_time_s}
        VAR    ${cmd}=    Register-ScheduledTask -Force -TaskName SLMWake
        ...    -Action (New-ScheduledTaskAction -Execute cmd.exe -Argument '/c exit')
        ...    -Trigger (New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(${sleep_duration_s}))
        ...    -Settings (New-ScheduledTaskSettingsSet -WakeToRun)
        ...    separator=${SPACE}
        Execute Command In Terminal    ${cmd}
        Write Into Terminal    rundll32.exe powrprof.dll,SetSuspendState 0,1,0
        Sleep    ${sleep_duration_s}s
        Login To Windows
        ${capacity}=    Get Battery Power Level Windows
        ${now}=    Get Current Date    result_format=epoch
        ${elapsed}=    Evaluate    int(${now} - ${start_time})
        Log To Console    ${elapsed}s elapsed: battery at ${capacity}%
    END
    Execute Manual Step    Connect the power supply
    Execute Shutdown Command
