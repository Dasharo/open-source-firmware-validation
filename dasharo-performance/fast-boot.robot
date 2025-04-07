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

Suite Setup         Initialize Fast Boot Suite
Suite Teardown      Log Out And Close Connection


*** Variables ***
${ITERATIONS}=      5


*** Test Cases ***
FBT001.201 Fast Boot Reduces Boot Time
    [Documentation]    Check whether the DUT boot time is reduced with
    ...    fast boot enabled.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PLB001.201 not supported
    Log To Console    \nMeasuring boot time with Fast Boot\n
    Login To Linux
    Switch To Root User
    Set Fast Boot State    on
    ${fast_min}    ${fast_max}    ${fast_avg}    ${fast_stddev}=
    ...    Measure FW Boot Time On Linux    ${ITERATIONS}

    Log To Console    \nMeasuring boot time without Fast Boot\n
    Login To Linux
    Switch To Root User
    Set Fast Boot State    off
    ${slow_min}    ${slow_max}    ${slow_avg}    ${slow_stddev}=
    ...    Measure FW Boot Time On Linux    ${ITERATIONS}

    ${average_gain}=
    ...    Evaluate    ${slow_avg} - ${fast_avg}
    ${min_gain}=
    ...    Evaluate    ${slow_min} - ${fast_min}
    ${max_gain}=
    ...    Evaluate    ${slow_max} - ${fast_max}

    Log To Console    \nAverage (No Fast Boot): ${slow_avg} s
    Log To Console    \nAverage (With Fast Boot): ${fast_avg} s
    Log To Console    \nFastboot average time gain: ${average_gain} s
    Log To Console    \nFastboot longest time gain: ${max_gain} s
    Log To Console    \nFastboot shortest time gain: ${min_gain} s
    ${relative_boot_time}=    Evaluate    (${fast_avg} / ${slow_avg}) * 100
    Log To Console
    ...    \nFastboot took ${relative_boot_time}% of regular boot on average

    IF    ${relative_boot_time} > 70.0    Fail


*** Keywords ***
Set Fast Boot State
    [Documentation]    Set fast boot to on/off via Linux Shell
    [Tags]    robot:private
    [Arguments]    ${state}

    ${var_file_name}=    Execute Linux Command
    ...    ls /sys/firmware/efi/efivars -l | grep "FastBoot" | awk '{print $NF}'
    Should Not Be Empty    ${var_file_name}
    ${var_file_path}=    Catenate    SEPARATOR=    /sys/firmware/efi/efivars/    ${var_file_name}
    Execute Linux Command    chattr -i ${var_file_path}

    ${new_var_path}=    Set Variable    /tmp/${var_file_name}

    Execute Linux Command    touch ${new_var_path}
    IF    '${state}' == 'on'
        Execute Linux Command    printf '\\x07\\x00\\x00\\x00\\x01' \> ${new_var_path}
    ELSE IF    '${state}' == 'off'
        Execute Linux Command    printf '\\x07\\x00\\x00\\x00\\x00' \> ${new_var_path}
    END

    ${out}=    Execute Linux Command
    ...    dd if=${new_var_path} of=${var_file_path} bs=5

    Should Not Contain    ${out}    Operation Not Permitted
    Execute Linux Command    rm ${new_var_path}

Measure FW Boot Time On Linux
    [Documentation]    Performs a measurement of firmware boot time
    ...    over number of iterations provided as argument.
    [Tags]    robot:private
    [Arguments]    ${iterations}
    ${durations}=    Create List
    Log To Console    \n

    FOR    ${index}    IN RANGE    0    ${iterations}
        Power Cycle On
        Login To Linux
        Switch To Root User
        ${boot_time}=    Get FW Boot Time From Systemd-analyze
        Log To Console    (${index}) Boot time: ${boot_time} s
        Append To List    ${durations}    ${boot_time}
    END

    ${min}    ${max}    ${average}    ${stddev}=
    ...    Calculate Boot Time Statistics    ${durations}
    RETURN    ${min}    ${max}    ${average}    ${stddev}

Get FW Boot Time From Systemd-analyze
    [Documentation]    Use systemd-analyze to get firmware boot time
    [Tags]    robot:private
    FOR    ${index}    IN RANGE    0    10
        ${boot_time}=    Execute Linux Command
        ...    systemd-analyze | awk 'NR==1 {print $4}' | sed 's/s//g'

        # ssh opens before GDM might finish loading desktop
        ${status}=    Run Keyword And Ignore Error
        ...    Should Not Contain    ${boot_time}    not yet finished

        IF    '${status}[0]' != 'FAIL'    RETURN    ${boot_time}

        Sleep    5s
    END
    Fail    Could not acquire boot time

Initialize Fast Boot Suite
    [Documentation]    Use efibootmgr to list entries, and set new order,
    ...    with Ubuntu at the top of the list.
    [Tags]    robot:private
    Prepare Test Suite
    Skip If    not ${FAST_AND_QUIET_BOOT_SUPPORT}    Boot performance measurement tests not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Boot performance measurement tests not supported

    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${ubuntu_boot_id}=    Execute Linux Command
    ...    efibootmgr | grep -i "ubuntu" | awk 'NR==1 {print $1}' | sed 's/Boot//g' | sed 's/*//g'
    Should Not Be Empty    ${ubuntu_boot_id}

    ${order_check}=    Execute Linux Command
    ...    efibootmgr | grep "BootOrder: ${ubuntu_boot_id}"

    IF    '${order_check}' == '${EMPTY}'
        ${boot_order_no_ubuntu}=    Execute Linux Command
        ...    efibootmgr | grep "BootOrder" | awk '{print $2}' | sed -e 's/,${ubuntu_boot_id}//g'
        Should Not Be Empty    ${boot_order_no_ubuntu}

        ${set_order_cmd}=    Set Variable    efibootmgr -o
        ${set_order_cmd}=    Catenate    ${set_order_cmd}
        ...    ${ubuntu_boot_id},${boot_order_no_ubuntu}

        ${out}=    Execute Linux Command    ${set_order_cmd}
        Should Contain    ${out}    BootOrder: ${ubuntu_boot_id}
    END
