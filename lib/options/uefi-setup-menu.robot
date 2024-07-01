*** Settings ***
Documentation       Library for UEFI configuration using the UEFI setup menu
...                 app (e.g. over serial port)

Library             Collections
Library             String
Resource            ../bios/menus.robot
Resource            ../../keywords.robot


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

    ${state}=    Get Option State    ${menu}    ${option_path[${path_len}-1]}    ${VALUE}
    RETURN    ${state}

Get UEFI Boot Manager Entries
    [Documentation]    Read list of UEFI boot manager

    Power On

    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    RETURN    ${boot_menu}

Get Boot Time From Cbmem
    [Documentation]    Calculates boot time based on cbmem timestamps
    # fix for LT1000 and protectli platforms (output without tabs)
    Get Cbmem From Cloud
    ${out_cbmem}=    Execute Command In Terminal    cbmem -T
    Should Not Contain
    ...    ${out_cbmem}
    ...    Operation not permitted
    ...    msg=Cannot get cbmem log. Probably Secure Boot is enabled (kernel lockdown mode).
    ${lines}=    Split To Lines    ${out_cbmem}
    ${first_line}=    Get From List    ${lines}    0
    ${last_line}=    Get From List    ${lines}    -1
    ${first_timestamp}=    Get Timestamp From Cbmem Log    ${first_line}
    ${last_timestamp}=    Get Timestamp From Cbmem Log    ${last_line}
    ${boot_time}=    Evaluate    (${last_timestamp} - ${first_timestamp}) / 1000000
    RETURN    ${boot_time}

Get Timestamp From Cbmem Log
    [Documentation]    Returns timestamp from a single cbmem -T log line
    [Arguments]    ${line}
    ${columns}=    Split String    ${line}
    ${timestamp}=    Get From List    ${columns}    1
    RETURN    ${timestamp}

Perform Warmboot Time Measure Verbose
    [Documentation]    Performs a measurement of average warmboot
    ...    boot time
    [Arguments]    ${iterations}

    ${average}=    Set Variable    0
    Log To Console    \n
    FOR    ${index}    IN RANGE    0    ${ITERATIONS}
        Power On
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s)
        ${average}=    Evaluate    ${average}+${boot_time}
    END
    ${average}=    Evaluate    ${average}/${ITERATIONS}
    RETURN    ${average}

Measure Average Warmboot Time
    [Documentation]    Performs a measurement of average warmboot
    ...    boot time
    [Arguments]    ${iterations}

    ${average}=    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${iterations}
        Power On
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        ${average}=    Evaluate    ${average}+${boot_time}
    END
    ${average}=    Evaluate    ${average}/${ITERATIONS}
    RETURN    ${average}

Measure Average Reboot Time Verbose
    [Documentation]    Performs a measurement of average reboot
    ...    boot time
    [Arguments]    ${iterations}

    Power On
    ${average}=    Set Variable    0
    Log To Console    \n
    FOR    ${index}    IN RANGE    0    ${ITERATIONS}
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s)
        ${average}=    Evaluate    ${average}+${boot_time}
        Execute Reboot Command
    END
    ${average}=    Evaluate    ${average}/${ITERATIONS}
    RETURN    ${average}

Measure Average Reboot Time
    [Documentation]    Performs a measurement of average reboot
    ...    boot time
    [Arguments]    ${iterations}

    Power On
    ${average}=    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${ITERATIONS}
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        ${average}=    Evaluate    ${average}+${boot_time}
        Execute Reboot Command
    END
    ${average}=    Evaluate    ${average}/${ITERATIONS}
    RETURN    ${average}
