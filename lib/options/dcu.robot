*** Settings ***
Documentation       Library for UEFI configuration using Dasharo Configuration
...                 Utility tool. Commonly used when serial port is not
...                 available.

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             SSHLibrary
Resource            ../terminal.robot
Resource            ../../keywords.robot
Resource            ../cbmem.robot
Resource            ../dcu.robot


*** Keywords ***
Set UEFI Option
    [Documentation]    Set an UEFI option to a value.
    [Arguments]    ${option_name}    ${value}
    DCU Variable Set UEFI Option In DUT    ${option_name}    ${value}
    Execute Reboot Command
    Sleep    20s

Get UEFI Option
    [Documentation]    Read an UEFI option value.
    [Arguments]    ${option_name}
    ${out}=    DCU Variable Get UEFI Option From DUT    ${option_name}
    RETURN    ${out}

Reset UEFI Options To Defaults
    [Documentation]    Resets all UEFI options to defaults
    Flash Firmware    ${FW_FILE}

Get UEFI Boot Manager Entries
    [Documentation]    Read list of UEFI boot manager

    Login To Linux
    Switch To Root User

    ${boot_menu}=    SSHLibrary.Execute Command    efibootmgr
    RETURN    ${boot_menu}

Measure Coldboot Time
    [Documentation]    Performs a measurement of average coldboot
    ...    boot time

    Skip    Coldboot not supported without serial connection

Measure Warmboot Time
    [Documentation]    Performs a measurement of warmboot
    ...    boot time
    [Arguments]    ${iterations}

    ${durations}=    Create List
    Log To Console    \n

    FOR    ${index}    IN RANGE    0    ${iterations}
        Login To Linux
        Switch To Root User

        # Using "Execute Command In Terimal" will cause the test to wait
        # for command prompt to appear before continuing but the prompt
        # will not appear again until we Login after reboot, so the test
        # would hang here and fail.
        # Sometimes it may take long to shutdown all systemd services,
        # so the waiting times have to be excessive to avoid false negatives.
        Write Into Terminal    rtcwake -m off -s 60

        Set DUT Response Timeout    300s

        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s
        Append To List    ${durations}    ${boot_time}
    END
    ${min}    ${max}    ${average}    ${stddev}=
    ...    Calculate Boot Time Statistics    ${durations}
    RETURN    ${min}    ${max}    ${average}    ${stddev}

Measure Reboot Time
    [Documentation]    Performs a measurement of reboot
    ...    boot time
    [Arguments]    ${iterations}

    ${durations}=    Create List
    Log To Console    \n

    FOR    ${index}    IN RANGE    0    ${iterations}
        Login To Linux
        Switch To Root User

        Execute Reboot Command
        Sleep    10s

        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s
        Append To List    ${durations}    ${boot_time}
    END

    ${min}    ${max}    ${average}    ${stddev}=
    ...    Calculate Boot Time Statistics    ${durations}
    RETURN    ${min}    ${max}    ${average}    ${stddev}

Make Sure That Flash Locks Are Disabled
    [Documentation]    Keyword makes sure firmware flashing is not prevented by
    ...    any Dasharo Security Options, if they are present.
    IF    not ${DASHARO_SECURITY_MENU_SUPPORT}    RETURN
    Power On
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    Should Not Contain    ${out_flashrom}    read-only

Login To Windows
    Power On
    Boot System Or From Connected Disk    ${OS_WINDOWS}

Boot System Or From Connected Disk
    [Documentation]    Keyword makes the DUT to reboot in chosen OS. There is a requirement for DUT to always reboot to Ubuntu.
    [Arguments]    ${os}
    ${os_boot_id}=    Set Variable    ${EMPTY}
    ${os}=    Convert To Lower Case    ${os}

    Login To Linux
    Switch To Root User

    ${boot_entries}=    Execute Command In Terminal    efibootmgr

    @{lines}=    Split To Lines    ${boot_entries}

    FOR    ${line}    IN    @{lines}
        ${tmp}=    Encode String To Bytes    ${line}    ASCII    errors=replace
        ${line}=    Decode Bytes To String    ${tmp}    ASCII    errors=replace
        ${line}=    Get Substring    ${line}    0    150
        ${line}=    Convert To Lower Case    ${line}

        IF    '${os}' in '${line}'
            ${os_boot_id}=    Set Variable    ${line}
            BREAK
        END
    END
    IF    '${os_boot_id}' != '${EMPTY}'
        ${id}=    Get Substring    ${os_boot_id}    4    8
        Execute Command In Terminal    efibootmgr --bootnext ${id}
        Sleep    1s
        Write Into Terminal    reboot
        Sleep    30s
    ELSE
        Fail    Os entry not found
    END

Login To Windows Via SSH
    [Documentation]    Login to Windows via SSH by using provided arguments as
    ...    username and password respectively.
    [Arguments]    ${username}=${DEVICE_WINDOWS_USERNAME}    ${password}=${DEVICE_WINDOWS_PASSWORD}    ${timeout}=180
    SSHLibrary.Open Connection    ${DEVICE_IP}    prompt=${DEVICE_WINDOWS_USER_PROMPT}
    SSHLibrary.Set Client Configuration
    ...    timeout=${timeout}
    ...    term_type=vt100
    ...    width=400
    ...    height=100
    ...    escape_ansi=True
    ...    newline=CRLF

    ${login}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    10x    30s
    ...    SSHLibrary.Login    ${username}    ${password}
