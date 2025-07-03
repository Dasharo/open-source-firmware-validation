*** Settings ***
Documentation       Collection of keywords related to common firmware operations.

Library             Collections
Library             String


*** Keywords ***
Enter Boot Menu
    [Documentation]    Enter Boot Menu with tianocore boot menu key mapped in
    ...    keys list.
    Read From Terminal Until    ${FW_STRING}
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Single Key PiKVM    ${BOOT_MENU_KEY}
    ELSE
        Write Bare Into Terminal    ${BOOT_MENU_KEY}
    END
    IF    ${LAPTOP_EC_SERIAL_WORKAROUND} == ${TRUE}
        # FIXME: Laptop EC serial workaround
        Press Key N Times    1    ${ARROW_DOWN}
        Press Key N Times    1    ${ARROW_UP}
    END

Enter Boot Menu And Return Construction
    [Documentation]    Enters boot menu, returning menu construction
    Enter Boot Menu
    ${menu}=    Get Boot Menu Construction
    RETURN    ${menu}

Enter Setup Menu
    [Documentation]    Enter Setup Menu with key specified in platform-configs.
    Read From Terminal Until    ${FW_STRING}
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Single Key PiKVM    ${SETUP_MENU_KEY}
    ELSE
        Write Bare Into Terminal    ${SETUP_MENU_KEY}
        IF    '${BIOS_LIB}' == 'seabios'
            ${menu}=    Get Boot Menu Construction
            Enter Submenu From Snapshot    ${menu}    setup
        END
    END

Parse Menu Snapshot Into Construction
    [Documentation]    Breaks grabbed menu data into lines.
    [Arguments]    ${menu}    ${lines_top}    ${lines_bot}
    ${slice_start}=    Set Variable    ${lines_top}
    IF    ${lines_bot} == 0
        ${slice_end}=    Set Variable    None
    ELSE
        ${slice_end}=    Evaluate    ${lines_bot} * -1
    END
    ${menu}=    Remove String    ${menu}    \r
    @{menu_lines}=    Split To Lines    ${menu}
    @{construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        # Replace multiple spaces with a single one
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        # Remove leading and trailing spaces
        ${line}=    Strip String    ${line}
        # Drop leading and trailing pipes (e.g. in One Time Boot Menu)
        ${line}=    Strip String    ${line}    characters=|
        # Remove leading and trailing spaces
        ${line}=    Strip String    ${line}
        # Drop all remaining borders
        ${line}=    Remove String Using Regexp    ${line}    ^[\\|\\s/\\\\-]+$
        # If the resulting line is not empty, add it as a menu entry
        ${length}=    Get Length    ${line}
        IF    ${length} > 0    Append To List    ${construction}    ${line}
    END
    Log    ${construction}
    ${construction}=    Get Slice From List    ${construction}    ${slice_start}    ${slice_end}
    # TODO: Improve parsing of the menu into construction. It can probably be
    # simplified, but at least we have this only in one kewyrod not in multiple
    # ones.
    # Make sure to remove control help text appearing in the screen if somehow
    # they are still there.
    Remove Values From List
    ...    ${construction}
    ...    Esc\=Exit
    ...    ^v\=Move High
    ...    <Enter>\=Select Entry
    ...    F9\=Reset to Defaults F10\=Save
    ...    LCtrl+LAlt+F12\=Save screenshot
    ...    <Spacebar>Toggle Checkbox
    ...    one adjusts to change
    ...    Select boot device:
    ...    , N for PXE boot
    RETURN    ${construction}

Get Menu Construction
    [Documentation]    Keyword allows to get and return setup menu construction.
    [Arguments]    ${checkpoint}=ESC=exit    ${lines_top}=1    ${lines_bot}=0
    Sleep    1s
    ${out}=    Read From Terminal Until    ${checkpoint}
    ${menu}=    Parse Menu Snapshot Into Construction    ${out}    ${lines_top}    ${lines_bot}
    RETURN    ${menu}

Get Index Of Matching Option In Menu
    [Documentation]    This keyword returns the index of element that matches
    ...    one in given menu
    [Arguments]    ${menu_construction}    ${option}    ${ignore_not_found_error}=${FALSE}
    FOR    ${element}    IN    @{menu_construction}
        ${matches}=    Run Keyword And Return Status
        ...    Should Match    ${element}    *${option}*
        IF    ${matches}
            ${option}=    Set Variable    ${element}
            BREAK
        END
    END
    ${index}=    Get Index From List    ${menu_construction}    ${option}
    IF    ${ignore_not_found_error} == ${FALSE}
        Should Be True    ${index} >= 0    Option ${option} not found in the list
    END
    RETURN    ${index}

Boot System Or From Connected Disk    # robocop: disable=too-long-keyword
    [Documentation]    Tries to boot ${system_name}. If it is not possible then it tries
    ...    to boot from connected disk set up in config
    [Arguments]    ${system_name}
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN

    IF    '''${SEABIOS_BOOT_DEVICE}''' != ''
        Read From Terminal Until    for boot menu
        Write Bare Into Terminal    ${BOOT_MENU_KEY}
        Read From Terminal Until    Select boot device
        Write Bare Into Terminal    ${SEABIOS_BOOT_DEVICE}
        RETURN
    END
    ${menu_construction}=    Enter Boot Menu And Return Construction
    # With ESP scanning feature boot entries are named differently:
    IF    ${ESP_SCANNING_SUPPORT} == ${TRUE}
        IF    "${system_name}" == "ubuntu"
            ${system_name}=    Set Variable    Ubuntu
        END
        IF    "${system_name}" == "trenchboot" and "${MANUFACTURER}" == "QEMU"
            ${system_name}=    Set Variable    QEMU HARDDISK
        END
    END
    ${is_system_present}=    Evaluate    "${system_name}" in """${menu_construction}"""
    IF    not ${is_system_present}
        ${ssd_list}=    Get Current CONFIG List Param    Storage_SSD    boot_name
        ${ssd_list_length}=    Get Length    ${ssd_list}
        IF    ${ssd_list_length} == 0
            ${hdd_list}=    Get Current CONFIG List Param    HDD_Storage    boot_name
            ${hdd_list_length}=    Get Length    ${hdd_list}
            IF    ${hdd_list_length} == 0
                ${mmc_list}=    Get Current CONFIG List Param    MMC_Storage    boot_name
                ${mmc_list_length}=    Get Length    ${mmc_list}
                IF    ${mmc_list_length} == 0
                    FAIL    "System was not found and there are no disk connected"
                END
                ${disk_name}=    Set Variable    ${mmc_list[0]}
            ELSE
                ${disk_name}=    Set Variable    ${hdd_list[0]}
            END
        ELSE
            ${disk_name}=    Set Variable    ${ssd_list[0]}
        END
        # Search the menu for disk name occurrence
        ${system_index}=    Set Variable    -1
        ${system_index}=    Evaluate
        ...    next((i for i, entry in enumerate(${menu_construction}) if "${disk_name}" in entry), -1)
        IF    ${system_index} == -1
            Fail    Disk: ${disk_name} not found in Boot Menu
        END
    ELSE
        ${system_index}=    Get Index Of Matching Option In Menu    ${menu_construction}    ${system_name}
    END
    Select Boot Menu Option    ${system_index}    ${ARROW_DOWN}

Make Sure That Network Boot Is Enabled
    [Documentation]    This keywords checks that "Enable network boot" in
    ...    "Networking Options" is enabled when present, so the network
    ...    boot tests can be executed.
    IF    not ${DASHARO_NETWORKING_MENU_SUPPORT}    RETURN
    IF    '${BIOS_LIB}' == 'seabios'
        Power On
        Enable Network/PXE Boot
    ELSE
        Set UEFI Option    NetworkBoot    ${TRUE}
    END

Get IPXE Boot Menu Construction
    [Documentation]    Keyword allows to get and return iPXE menu construction.
    [Arguments]    ${lines_top}=1    ${lines_bot}=0    ${checkpoint}=${EDK2_IPXE_CHECKPOINT}
    ${menu}=    Read From Terminal Until    ${checkpoint}
    ${construction}=    Parse Menu Snapshot Into Construction    ${menu}    ${lines_top}    ${lines_bot}
    RETURN    ${construction}

Press Key N Times And Enter
    [Documentation]    Enter specified in the first argument times the specified
    ...    in the second argument key and then press Enter.
    [Arguments]    ${n}    ${key}
    Press Key N Times    ${n}    ${key}
    Press Enter

Press Key N Times
    [Documentation]    Enter specified in the first argument times the specified
    ...    in the second argument key.
    [Arguments]    ${n}    ${key}
    FOR    ${index}    IN RANGE    0    ${n}
        IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
            Single Key PiKVM    ${key}
            # Key press time as defined in PiKVM library is 200ms. We need some
            # additional delay to make sure we can gather all input from terminal after
            # key press.
            Sleep    2s
        ELSE
            Write Bare Into Terminal    ${key}
            # Escape sequences in EDK2 have 2 seconds to complete on serial.
            # After 2 seconds if it is not completed, it is returned as a
            # keystroke. So we need at least 2 seconds interval for pressing
            # ESC for example.
            Sleep    2s
        END
    END

Press Enter
    # Before entering new menu, make sure we get rid of all leftovers
    Sleep    1s
    Read From Terminal
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Single Key PiKVM    Enter
    ELSE
        Press Key N Times    1    ${ENTER}
    END
