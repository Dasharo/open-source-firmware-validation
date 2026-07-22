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
Resource            ../custom_bootentries.robot


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
    Set Nextboot    ${BOOTED_OS_ID}
    DCU Variable Set UEFI Option In DUT    ${option_name}    ${value}
    IF    '${option_name}' == 'PowerStateAfterPowerAcLoss'
        VAR    ${POWER_STATE_AFTER_FAIL}=    ${value}    scope=GLOBAL
    END

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
    Skip If
    ...    not ${RTC_BOOT_SUPPORT} and ${INCLUDE_TAGS} is not ${None} and 'semiauto' not in ${INCLUDE_TAGS}

    VAR    @{durations}=    @{EMPTY}
    Log To Console    \n

    FOR    ${index}    IN RANGE    0    ${iterations}
        Execute Manual Step    Perform a coldboot (power cycle the device).

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
                Execute Manual Step    Perform a warmboot (poweroff/shutdown initiated from the OS).
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
    Boot And Login To OS    ${DEFAULT_BOOT_OS_ID}
    Switch To Root User
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    ${ro}=    Run Keyword And Return Status    Should Not Contain    ${out_flashrom}    read-only
    IF    not ${ro}    Set UEFI Option    LockBios    Disabled

Login To Windows
    [Arguments]    ${retries}=5 min    ${timeout}=60
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        VAR    ${DUT_CONNECTION_METHOD}=    SSH    scope=SUITE
    END
    Login To Windows Via SSH    ${DEVICE_OS_USERNAME}    ${DEVICE_OS_PASSWORD}
    ...    retries=${retries}    timeout=${timeout}

Boot And Login To Windows
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_WINDOWS}
    Login To Windows

Boot System Or From Connected Disk
    [Documentation]    Keyword makes the DUT to reboot in chosen OS.
    [Arguments]    ${env_id}    ${boot_menu}=NOT_SET
    Load OS Credentials    ${BOOTED_OS_ID}
    Restore Initial DUT Connection Method

    IF    '${BOOTED_OS_ID}' == '${env_id}'
        Login To Booted OS
        Log    Target OS already booted
        RETURN
    END

    IF    '${BOOTED_OS_ID}'.startswith('3')    # Windows
        Login To Booted OS
        Execute Reboot Command    windows
        Load OS Credentials    ${DEFAULT_BOOT_OS_ID}
        VAR    ${BOOTED_OS_ID}=    ${DEFAULT_BOOT_OS_ID}    scope=GLOBAL
        Sleep    30s
        IF    '${DEFAULT_BOOT_OS_ID}'=='${env_id}'    RETURN
    END

    VAR    ${os_boot_id}=    ${EMPTY}
    ${os_bootentry_name}=    Get From Dictionary    ${ENV_ID_OS_BOOTMENU_NAMES}    ${env_id}

    Login To Booted OS
    Switch To Root User

    ${os_boot_id}=    Set Nextboot    ${env_id}
    Write Into Terminal    reboot

    Load OS Credentials    ${env_id}
    VAR    ${BOOTED_OS_ID}=    ${env_id}    scope=GLOBAL
    Sleep    30s
