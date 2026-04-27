*** Settings ***
Documentation       Common header for OSFV boot management

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             RequestsLibrary
Library             SSHLibrary
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot


*** Keywords ***
Set Selected OS As First In Boot Order Via EDK2
    [Documentation]    Uses EDK2 menu to select given OS as first in
    ...    boot menu.
    ...
    ...    === Requirements ===
    ...    - Serial port connection has to be supported by the platform
    ...    - Must be within Dasharo's main UEFI firmware setup
    ...
    ...    === Arguments ===
    ...    - ``${os}``: ``string`` - ENV_ID of the OS we want to boot
    ...
    ...    === Return Value ===
    ...    - None
    ...
    ...    === Effects ===
    ...    - OS specified by ENV_ID will be priority during subsequent boots
    ...    - Resets the DUT via EDK2 reset
    [Arguments]    ${os}
    ${system_name}=    Get From Dictionary    ${ENV_ID_OS_BOOTMENU_NAMES}    ${os}

    # When ESP scanning feature is there, boot entries are named differently than
    # they used to
    IF    ${ESP_SCANNING_SUPPORT} == ${TRUE}
        IF    "${system_name}" == "ubuntu"
            VAR    ${system_name}=    Ubuntu
        ELSE IF    "${system_name}" == "fedora"
            VAR    ${system_name}=    Fedora
        ELSE IF    "${system_name}" == "trenchboot" and "${MANUFACTURER}" == "QEMU"
            VAR    ${system_name}=    QEMU HARDDISK
        END
    END

    ${menu}=    Get Setup Menu Construction
    ${menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${menu}
    ...    Boot Maintenance Manager
    ${menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${menu}
    ...    Boot Options
    ${menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${menu}
    ...    Change Boot Order
    Press Enter
    ${os_list_raw}=    Read From Terminal Until    ---/
    ${os_list}=    Extract Strings From Frame    ${os_list_raw}
    VAR    ${first_item}=    ${os_list}[0]
    ${is_first}=    Run Keyword And Return Status    Should Contain    ${first_item}    ${system_name}

    IF    '${is_first}' == 'False'
        VAR    ${index}=    -1
        FOR    ${i}    ${item}    IN ENUMERATE    @{os_list}
            ${item_lower}=    Convert To Lowercase    ${item}
            ${system_lower}=    Convert To Lowercase    ${system_name}
            ${found}=    Run Keyword And Return Status    Should Contain    ${item_lower}    ${system_lower}
            IF    '${found}' == 'True'
                VAR    ${index}=    ${i}
                BREAK
            END
        END

        Should Not Be Equal As Integers    ${index}    -1
        ...    System name '${system_name}' not found in boot menu list

        Press Key N Times    ${index}    ${ARROW_DOWN}
        Press Key N Times    ${index}    ${KEY_PLUS}
        Press Enter
        Write Bare Into Terminal    ${F10}
        Sleep    1s
        Write Bare Into Terminal    y
        # Return to main menu
        Press Key N Times    3    ${ESC}
        Sleep    1s
        # Issue reset in the menu
        Press Key N Times    2    ${ARROW_DOWN}
        Press Enter
    ELSE
        # We have to reset anyways, because the keyword
        # "Verify Selected OS As First In Boot Order Via EDK2" followed
        # by this keyword is expecting the boot prompt
        Tianocore Reset System
    END

Set Selected OS As First In Boot Order Via Efibootmgr
    [Documentation]    Uses Ubuntu and efibootmgr to select boot prioroty
    ...
    ...    === Requirements ===
    ...    - Connection to DUT must be established.
    ...    - Platform must boot Ubuntu to access efibootmgr
    ...
    ...    === Arguments ===
    ...    - ``${os}``: ``string`` - ENV_ID of the OS we want to boot
    ...
    ...    === Return Value ===
    ...    - None
    ...
    ...    === Effects ===
    ...    - OS specified by ENV_ID will be priority during subsequent
    [Arguments]    ${os}
    ${system_name}=    Get From Dictionary    ${ENV_ID_OS_BOOTMENU_NAMES}    ${os}

    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${os_boot_id}=    Execute Linux Command
    ...    efibootmgr | grep -i "${system_name}" | awk 'NR==1 {print $1}' | sed 's/Boot//g' | sed 's/*//g'
    Should Not Be Empty    ${os_boot_id}

    ${order_check}=    Execute Linux Command
    ...    efibootmgr | grep "BootOrder: ${os_boot_id}"

    # Trim the boot list to exclude target OS
    IF    '${order_check}' == '${EMPTY}'
        ${boot_order_trimmed}=    Execute Linux Command
        ...    efibootmgr | grep "BootOrder" | awk '{print $2}' | sed -e 's/,${os_boot_id}//g'
        Should Not Be Empty    ${boot_order_trimmed}

        VAR    ${set_order_cmd}=    efibootmgr -o
        VAR    ${set_order_cmd}=    ${set_order_cmd}    ${os_boot_id},${boot_order_trimmed}    separator=${SPACE}

        ${out}=    Execute Linux Command    ${set_order_cmd}
        Should Contain    ${out}    BootOrder: ${os_boot_id}
    END

Verify Selected OS As First In Boot Order Via EDK2
    [Documentation]    Uses dasharo edk2 boot menu to check first OS
    ...    in the boot order
    ...    === Requirements ===
    ...    - Must be run in quick succession after Powering On
    ...
    ...    === Arguments ===
    ...    - ``${os}``: ``string`` - ENV_ID of the OS we want to check
    ...
    ...    === Return Value ===
    ...    - None
    ...
    ...    === Effects ===
    ...    - Fails if specified OS is not first boot entry
    [Arguments]    ${os}
    ${system_name}=    Get From Dictionary    ${ENV_ID_OS_BOOTMENU_NAMES}    ${os}

    # When ESP scanning feature is there, boot entries are named differently than
    # they used to
    IF    ${ESP_SCANNING_SUPPORT} == ${TRUE}
        IF    "${system_name}" == "ubuntu"
            VAR    ${system_name}=    Ubuntu
        ELSE IF    "${system_name}" == "fedora"
            VAR    ${system_name}=    Fedora
        ELSE IF    "${system_name}" == "trenchboot" and "${MANUFACTURER}" == "QEMU"
            VAR    ${system_name}=    QEMU HARDDISK
        END
    END

    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    ${top_os}=    Get From List    ${boot_menu}    0
    Should Contain    ${top_os}    ${system_name}
