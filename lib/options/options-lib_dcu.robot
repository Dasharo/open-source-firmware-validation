*** Settings ***
Documentation       Library for UEFI configuration using Dasharo Configuration
...                 Utility tool. Commonly used when serial port is not
...                 available.

Library             Collections
Library             Dialogs
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
    ...    The device has to be ON and logged in to Ubuntu
    [Arguments]    ${option_name}    ${value}
    # Ensure a linux is booted
    Power On
    IF    '${BOOTED_OS_ID}'.startswith('2')
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
    ELSE
        Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    END
    Login To Linux
    Switch To Root User
    DCU Variable Set UEFI Option In DUT    ${option_name}    ${value}
    IF    '${option_name}' == 'PowerStateAfterPowerAcLoss'
        VAR    ${POWER_STATE_AFTER_FAIL}=    ${value}    scope=GLOBAL
    END
    Sleep    20s

Get UEFI Option
    [Documentation]    Read an UEFI option value.
    ...    The device has to be ON and logged in to Ubuntu
    [Arguments]    ${option_name}
    Login To Linux
    Switch To Root User
    ${out}=    DCU Variable Get UEFI Option From DUT    ${option_name}
    RETURN    ${out}

Reset UEFI Options To Defaults
    [Documentation]    Resets all UEFI options to defaults
    Flash Firmware    ${FW_FILE}

Get UEFI Boot Manager Entries
    [Documentation]    Read list of UEFI boot manager
    ...    The device does not need to be logged in to Ubuntu if $DUT_CONNETION_METHOD == SSH.
    ...    If $DUT_CONNETION_METHOD == Telnet, then the device must be logged
    ...    off, and the login prompt must be available in the Telnet buffer.

    Login To Linux
    Switch To Root User

    ${boot_menu}=    SSHLibrary.Execute Command    efibootmgr
    RETURN    ${boot_menu}

Measure Coldboot Time
    [Documentation]    Performs a measurement of coldboot boot time
    ...    The device does not need to be logged in to Ubuntu if $DUT_CONNETION_METHOD == SSH.
    ...    If $DUT_CONNETION_METHOD == Telnet, then the device must be logged
    ...    off, and the login prompt must be available in the Telnet buffer.
    [Arguments]    ${iterations}    ${os_id}=${BOOTED_OS_ID}

    VAR    @{durations}=    @{EMPTY}
    Log To Console    \n

    FOR    ${index}    IN RANGE    0    ${iterations}
        Execute Manual Step    message=Perform a coldboot

        Boot System Or From Connected Disk    ${os_id}
        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s
        Append To List    ${durations}    ${boot_time}
    END
    ${min}    ${max}    ${average}    ${stddev}=
    ...    Calculate Boot Time Statistics    ${durations}
    RETURN    ${min}    ${max}    ${average}    ${stddev}

Measure Warmboot Time
    [Documentation]    Performs a measurement of warmboot boot time
    ...    The device does not need to be logged in to Ubuntu if $DUT_CONNETION_METHOD == SSH.
    ...    If $DUT_CONNETION_METHOD == Telnet, then the device must be logged
    ...    off, and the login prompt must be available in the Telnet buffer.
    [Arguments]    ${iterations}    ${os_id}=${BOOTED_OS_ID}

    VAR    @{durations}=    @{EMPTY}
    Log To Console    \n

    FOR    ${index}    IN RANGE    0    ${iterations}
        Boot System Or From Connected Disk    ${os_id}
        Login To Linux
        Switch To Root User

        # Using "Execute Command In Terminal" will cause the test to wait
        # for command prompt to appear before continuing but the prompt
        # will not appear again until we Login after reboot, so the test
        # would hang here and fail.
        # Sometimes it may take long to shutdown all systemd services,
        # so the waiting times have to be excessive to avoid false negatives.
        IF    ${RTC_BOOT_SUPPORT}
            Perform Warmboot Using Rtcwake
        ELSE
            Execute Shutdown Command
            IF    '${POWER_CTRL}' == 'none'
                Execute Manual Step    Turn on the device
            ELSE
                Power On
            END
        END

        Boot System Or From Connected Disk    ${os_id}
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
    [Documentation]    Performs a measurement of reboot boot time
    ...    The device does not need to be logged in to Ubuntu if $DUT_CONNETION_METHOD == SSH.
    ...    If $DUT_CONNETION_METHOD == Telnet, then the device must be logged
    ...    off, and the login prompt must be available in the Telnet buffer.
    [Arguments]    ${iterations}    ${os_id}=${BOOTED_OS_ID}

    VAR    @{durations}=    @{EMPTY}
    Log To Console    \n

    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User

    FOR    ${index}    IN RANGE    0    ${iterations}
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
    [Documentation]    The keyword checks if there are any flash locks enabled,
    ...    which would interfere with the tests. Here, in the case of DCU-only
    ...    platforms, it can only provide a warning, since it can't reflash the
    ...    platform to disable the locks. The name is the same as the in UEFI
    ...    menu options for compatibility's sake.
    IF    not ${DASHARO_SECURITY_MENU_SUPPORT}    RETURN
    Power On
    Login To Linux
    Switch To Root User
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    ${ro}=    Run Keyword And Return Status    Should Not Contain    ${out_flashrom}    read-only
    IF    not ${ro}    Set UEFI Option    LockBios    Disabled

Login To Windows
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_WINDOWS}
    Login To Windows Via SSH    ${DEVICE_OS_USERNAME}    ${DEVICE_OS_PASSWORD}

Set Nextboot
    [Documentation]    Sets the OS of choice to be booted first on the next
    ...    reboot. Not persistent, only changes the first boot option for
    ...    one boot.
    [Arguments]    ${env_id}

    VAR    ${os_boot_id}=    ${EMPTY}
    ${os_bootentry_name}=    Get From Dictionary    ${ENV_ID_OS_BOOTMENU_NAMES}    ${env_id}
    Set Nextboot Bootentry    ${os_bootentry_name}

Set Nextboot Bootentry
    [Documentation]    Sets the botentry name of choice to be booted first on
    ...    the next reboot. Not persistent, only changes the first boot
    ...    option for one boot.
    [Arguments]    ${bootentry_name}
    ${bootentry_name}=    Convert To Lower Case    ${bootentry_name}
    ${boot_entries}=    Execute Command In Terminal    efibootmgr

    @{lines}=    Split To Lines    ${boot_entries}
    VAR    ${os_boot_id}=    ${EMPTY}
    FOR    ${line}    IN    @{lines}
        ${tmp}=    Encode String To Bytes    ${line}    ASCII    errors=replace
        ${line}=    Decode Bytes To String    ${tmp}    ASCII    errors=replace
        ${line}=    Get Substring    ${line}    0    150
        ${line}=    Convert To Lower Case    ${line}

        IF    $bootentry_name in $line
            VAR    ${os_boot_id}=    ${line}
            BREAK
        END
    END

    IF    $os_boot_id != ''
        ${id}=    Get Substring    ${os_boot_id}    4    8
        Execute Command In Terminal    efibootmgr --bootnext ${id}
    ELSE
        Fail    Os entry not found
    END

Boot System Or From Connected Disk
    [Documentation]    Keyword makes the DUT to reboot in chosen OS.
    [Arguments]    ${env_id}

    IF    '${BOOTED_OS_ID}' == '${env_id}'
        Log    Target OS already booted
        RETURN
    END

    IF    '${BOOTED_OS_ID}'.startswith('3')    # Windows
        Execute Reboot Command    windows
        Import Variables    ${CURDIR}/../../os-config/${DEFAULT_BOOT_OS_ID}-credentials.py
        VAR    ${BOOTED_OS_ID}=    ${DEFAULT_BOOT_OS_ID}    scope=GLOBAL
        Sleep    30s
        RETURN
    END

    VAR    ${os_boot_id}=    ${EMPTY}
    ${os_bootentry_name}=    Get From Dictionary    ${ENV_ID_OS_BOOTMENU_NAMES}    ${env_id}

    Import Variables    ${CURDIR}/../../os-config/${BOOTED_OS_ID}-credentials.py
    Login To Linux
    Switch To Root User

    ${os_boot_id}=    Set Nextboot    ${env_id}
    Write Into Terminal    reboot

    Import Variables    ${CURDIR}/../../os-config/${env_id}-credentials.py
    VAR    ${BOOTED_OS_ID}=    ${env_id}    scope=GLOBAL
    Sleep    30s

Login To Windows Via SSH
    [Documentation]    Login to Windows via SSH by using provided arguments as
    ...    username and password respectively.
    [Arguments]    ${username}=${DEVICE_OS_USERNAME}    ${password}=${DEVICE_OS_PASSWORD}    ${timeout}=180
    SSHLibrary.Open Connection    ${DEVICE_IP}    prompt=${DEVICE_OS_USER_PROMPT}
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
