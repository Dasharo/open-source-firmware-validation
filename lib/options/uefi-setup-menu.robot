*** Settings ***
Documentation       Library for UEFI configuration using the UEFI setup menu
...                 app (e.g. over serial port)

Library             Collections
Library             String
Resource            ../bios/edk2.robot
Resource            ../../keywords.robot
Resource            ../cbmem.robot


*** Keywords ***
Set UEFI Option
    [Documentation]    Set an UEFI option to a value.
    ...    TODO: Only works with options following the submenu/submenu/option
    ...    pattern (e.g. all Dasharo System Features options).
    [Arguments]    ${option_name}    ${value}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Can not configure UEFI settings on this platform.

    TRY
        @{option_path}=    Option Name To UEFI Path    ${option_name}
    EXCEPT
        Skip    Setting option ${option_name} is currently unimplemented.
    END

    Power On
    ${menu}=    Enter Setup Menu Tianocore And Return Construction

    ${path_len}=    Get Length    ${option_path}
    FOR    ${i}    IN RANGE    ${path_len} - 1
        ${menu}=    Enter Submenu From Snapshot And Return Construction
        ...    ${menu}
        ...    ${option_path[${i}]}
    END

    Set Option State    ${menu}    ${option_path[${path_len}-1]}    ${value}
    Save Changes And Reset

Get UEFI Option
    [Documentation]    Set an UEFI option to a value.
    ...    TODO: Only works with options following the submenu/submenu/option
    ...    pattern (e.g. all Dasharo System Features options).
    [Arguments]    ${option_name}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Can not configure UEFI settings on this platform.

    TRY
        @{option_path}=    Option Name To UEFI Path    ${option_name}
    EXCEPT
        Skip    Setting option ${option_name} is currently unimplemented.
    END

    Power On
    ${menu}=    Enter Setup Menu Tianocore And Return Construction

    ${path_len}=    Get Length    ${option_path}
    FOR    ${i}    IN RANGE    ${path_len} - 1
        ${menu}=    Enter Submenu From Snapshot And Return Construction
        ...    ${menu}
        ...    ${option_path[${i}]}
    END

    ${state}=    Get Option State    ${menu}    ${option_path[${path_len}-1]}
    RETURN    ${state}

Reset UEFI Options To Defaults
    [Documentation]    Resets all UEFI options to defaults
    Power On
    Enter Setup Menu Tianocore
    Reset To Defaults Tianocore
    Save Changes And Reset

Get UEFI Boot Manager Entries
    [Documentation]    Read list of UEFI boot manager

    Power On

    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    RETURN    ${boot_menu}

Measure Coldboot Time
    [Documentation]    Performs a measurement of coldboot
    ...    boot time
    [Arguments]    ${iterations}
    Skip If    '${POWER_CTRL}' == 'none'    Coldboot automatic tests not supported
    ${durations}=    Create List
    Log To Console    \n
    # Do one more iteration than requested, as we may hit first boot which is always longer.
    FOR    ${index}    IN RANGE    0    ${iterations}+1
        Power Cycle On    power_button=${TRUE}
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s
        # Skip appending first result, as it may be the first boot which is longer
        IF    ${index} > 0    Append To List    ${durations}    ${boot_time}
    END
    ${min}    ${max}    ${average}    ${stddev}=
    ...    Calculate Boot Time Statistics    ${durations}
    RETURN    ${min}    ${max}    ${average}    ${stddev}

Measure Warmboot Time
    [Documentation]    Performs a measurement of warmboot
    ...    boot time
    [Arguments]    ${iterations}
    ${durations}=    Create List
    Log To Console    \n
    # Do one more iteration than requested, as we may hit first boot which is always longer.
    FOR    ${index}    IN RANGE    0    ${iterations}+1
        Power On
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s
        # Skip appending first result, as it may be the first boot which is longer
        IF    ${index} > 0    Append To List    ${durations}    ${boot_time}
    END
    ${min}    ${max}    ${average}    ${stddev}=
    ...    Calculate Boot Time Statistics    ${durations}
    RETURN    ${min}    ${max}    ${average}    ${stddev}

Measure Reboot Time
    [Documentation]    Performs a measurement of reboot
    ...    boot time
    [Arguments]    ${iterations}

    Power On
    ${average}=    Set Variable    0
    ${durations}=    Create List
    Log To Console    \n
    # Do one more iteration than requested, as we may hit first boot which is always longer.
    FOR    ${index}    IN RANGE    0    ${iterations}+1
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s
        # Skip appending first result, as it may be the first boot which is longer
        IF    ${index} > 0    Append To List    ${durations}    ${boot_time}
        Execute Reboot Command
    END
    ${min}    ${max}    ${average}    ${stddev}=
    ...    Calculate Boot Time Statistics    ${durations}
    RETURN    ${min}    ${max}    ${average}    ${stddev}

Make Sure That Flash Locks Are Disabled
    [Documentation]    Keyword makes sure firmware flashing is not prevented by
    ...    any Dasharo Security Options, if they are present.
    IF    not ${DASHARO_SECURITY_MENU_SUPPORT}    RETURN
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${index}=    Get Index Of Matching Option In Menu
    ...    ${dasharo_menu}    Dasharo Security Options
    IF    ${index} != -1
        ${security_menu}=    Enter Dasharo Submenu
        ...    ${dasharo_menu}    Dasharo Security Options
        ${index}=    Get Index Of Matching Option In Menu
        ...    ${security_menu}    Lock the BIOS boot medium    ${TRUE}
        IF    ${index} != -1
            Set Option State    ${security_menu}    Lock the BIOS boot medium    ${FALSE}
            Reenter Menu
        END
        ${index}=    Get Index Of Matching Option In Menu
        ...    ${security_menu}    Enable SMM BIOS write    ${TRUE}
        IF    ${index} != -1
            Set Option State    ${security_menu}    Enable SMM BIOS write    ${FALSE}
            Reenter Menu
        END
        Save Changes And Reset
    END
