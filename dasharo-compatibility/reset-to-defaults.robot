*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}    Reset to defaults tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
RTD001.001 F9 resets Enable USB stack option to true
    [Documentation]    Check whether pressing F9 resets Enable USB stack
    ...    option to be enabled.
    Skip If    not ${DASHARO_USB_MENU_SUPPORT}    RTD001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD001.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${usb_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    USB Configuration
    Set Option State    ${usb_menu}    Enable USB stack    ${FALSE}
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${usb_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    USB Configuration
    ${usb_stack_state}=    Get Option State    ${usb_menu}    Enable USB stack
    Should Be True    ${usb_stack_state}

RTD002.001 F9 resets Enable USB Mass Storage driver option to true
    [Documentation]    Check whether pressing F9 resets Enable Mass Storage
    ...    driver option to be enabled
    Skip If    not ${DASHARO_USB_MENU_SUPPORT}    RTD002.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD002.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${usb_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    USB Configuration
    Set Option State    ${usb_menu}    Enable USB Mass Storage    ${FALSE}
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${usb_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    USB Configuration
    ${usb_storage_state}=    Get Option State    ${usb_menu}    Enable USB Mass Storage
    Should Be True    ${usb_storage_state}

RTD003.001 F9 resets Lock the BIOS boot medium option to true
    [Documentation]    Check whether pressing F9 resets Lock the BIOS boot
    ...    medium driver option to be enabled
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD003.001 not supported
    Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}    RTD003.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${security_menu}    Lock the BIOS boot medium    ${FALSE}
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    ${bios_lock_state}=    Get Option State    ${security_menu}    Lock the BIOS boot medium
    Should Be True    ${bios_lock_state}

RTD004.001 F9 resets Enable SMM BIOS write protection to false
    [Documentation]    Check whether pressing F9 resets Enable SMM BIOS write
    ...    protection option to be disabled
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD004.001 not supported
    Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}    RTD004.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${security_menu}    Enable SMM BIOS write    ${TRUE}
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    ${smm_state}=    Get Option State    ${security_menu}    Enable SMM BIOS write
    Should Not Be True    ${smm_state}

RTD005.001 F9 resets Early boot DMA Protection to true
    [Documentation]    Check whether pressing F9 resets Early boot DMA
    ...    Protection option to be enabled
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD005.001 not supported
    Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}    RTD005.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${security_menu}    Early boot DMA Protection    ${TRUE}
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    ${early_dma_state}=    Get Option State    ${security_menu}    Early boot DMA Protection
    Should Not Be True    ${early_dma_state}

RTD007.001 F9 resets Enable network boot to false
    [Documentation]    Check whether pressing F9 resets Keep IOMMU enabled when
    ...    transfer control to OS option to be disabled
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD007.001 not supported
    Skip If    not ${DASHARO_NETWORKING_MENU_SUPPORT}    RTD007.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${network_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
    Set Option State    ${network_menu}    Enable network boot    ${TRUE}
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${network_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
    ${network_boot_state}=    Get Option State    ${network_menu}    Enable network boot
    Should Not Be True    ${network_boot_state}

RTD008.001 F9 resets Intel ME mode to enabled
    [Documentation]    Check whether pressing F9 resets Intel ME mode option
    ...    to be enabled
    Skip If    not ${DASHARO_INTEL_ME_MENU_SUPPORT}    RTD008.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD008.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${me_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Intel Management Engine Options
    Set Option State    ${me_menu}    Intel ME mode    Disabled (HAP)
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${me_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Intel Management Engine Options
    ${me_mode_state}=    Get Option State    ${me_menu}    Intel ME mode
    Should Be Equal    ${me_mode_state}    Enabled

RTD009.001 F9 resets Enable PS2 Controller to enabled
    [Documentation]    Check whether pressing F9 resets Enable PS2 Controller
    ...    to be enabled
    Skip If    not ${DASHARO_CHIPSET_MENU_SUPPORT}    RTD009.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD009.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${chipset_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Chipset Configuration
    Set Option State    ${chipset_menu}    Enable PS2 Controller    ${FALSE}
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${chipset_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Chipset Configuration
    ${ps2_state}=    Get Option State    ${chipset_menu}    Enable PS2 Controller
    Should Be True    ${ps2_state}

RTD010.001 F9 resets Enable watchdog to enabled
    [Documentation]    Check whether pressing F9 resets Enable watchdog
    ...    to be enabled
    Skip If    not ${DASHARO_CHIPSET_MENU_SUPPORT}    RTD010.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD010.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${chipset_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Chipset Configuration
    Set Option State    ${chipset_menu}    Enable watchdog    ${FALSE}
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${chipset_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Chipset Configuration
    ${watchdog_state}=    Get Option State    ${chipset_menu}    Enable watchdog
    Should Be True    ${watchdog_state}

RTD011.001 F9 resets Watchdog timeout value to 500
    [Documentation]    Check whether pressing F9 resets Watchdog timeout value
    ...    to 500
    Skip If    not ${DASHARO_CHIPSET_MENU_SUPPORT}    RTD011.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD011.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${chipset_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Chipset Configuration
    Set Option State    ${chipset_menu}    Watchdog timeout value    400
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${chipset_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Chipset Configuration
    ${watchdog_timeout}=    Get Option State    ${chipset_menu}    Watchdog timeout value
    Should Be Equal As Integers    ${watchdog_timeout}    500

RTD012.001 F9 resets Fan profile to Silent
    [Documentation]    Check whether pressing F9 resets Fan profile to Silent
    Skip If    not ${DASHARO_POWER_MGMT_MENU_SUPPORT}    RTD012.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD012.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${power_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    Set Option State    ${power_menu}    Fan profile    Performance
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${power_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    ${fan_profile}=    Get Option State    ${power_menu}    Fan profile
    Should Be Equal    ${fan_profile}    Silent

RTD013.001 F9 resets Platform sleep type to Suspend to Idle
    [Documentation]    Check whether pressing F9 resets Platform sleep type to
    ...    Suspend to Idle
    Skip If    not ${DASHARO_POWER_MGMT_MENU_SUPPORT}    RTD013.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD013.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${power_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    Set Option State    ${power_menu}    Platform sleep type    Suspend to RAM (S3)
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${power_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    ${sleep_type}=    Get Option State    ${power_menu}    Platform sleep type
    Should Be Equal    ${sleep_type}    Suspend to Idle (S0ix)

RTD014.001 F9 resets Memory SPD Profile to JEDEC
    [Documentation]    Check whether pressing F9 resets Memory SPD Profile to
    ...    JEDEC
    Skip If    not ${DASHARO_MEMORY_MENU_SUPPORT}
    Skip If    not ${MEMORY_PROFILE_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD014.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${memory_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Memory Configuration
    Set Option State    ${memory_menu}    Memory SPD Profile    XMP#1 (predefined
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${memory_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Memory Configuration
    ${memory_profile}=    Get Option State    ${memory_menu}    Memory SPD Profile
    Should Be Equal    ${memory_profile}    JEDEC (safe

RTD015.001 F9 reset is effective across DSF
    [Documentation]    Check whether pressing F9 in one menu resets changes
    ...    made in another menu within Dasharo System Features
    Skip If    not ${MEMORY_PROFILE_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD014.001 not supported
    Skip If    not ${DASHARO_NETWORKING_MENU_SUPPORT}
    Skip If    not ${DASHARO_POWER_MGMT_MENU_SUPPORT}
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${memory_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
    Set Option State    ${memory_menu}    Enable network boot    ${TRUE}
    Press Key N Times And Enter    2    ${ESC}
    ${memory_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${network_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
    ${network_boot_state}=    Get Option State    ${network_menu}    Enable network boot
    Should Not Be True    ${network_boot_state}

RTD016.001 F9 reset is globally effective
    [Documentation]    Check whether pressing F9 in a standard menu resets
    ...    changes made in a DSF menu.
    Skip If    not ${MEMORY_PROFILE_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD014.001 not supported
    Skip If    not ${DASHARO_NETWORKING_MENU_SUPPORT}
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${memory_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
    Set Option State    ${memory_menu}    Enable network boot    ${TRUE}
    Press Key N Times    2    ${ESC}
    Press Key N Times And Enter    1    ${ARROW_UP}
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${network_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
    ${network_boot_state}=    Get Option State    ${network_menu}    Enable network boot
    Should Not Be True    ${network_boot_state}

RTD016.002 F9 reset is globally effective
    [Documentation]    Check whether pressing F9 in a DSF menu resets
    ...    changes made in a standard menu.
    Skip If    not ${MEMORY_PROFILE_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD014.001 not supported
    Skip If    not ${DASHARO_NETWORKING_MENU_SUPPORT}
    Power On
    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${bmm_index}=    Get Index Of Matching Option In Menu    ${setup_menu}    Boot Maintenance Manager
    ${dsf_index}=    Get Index Of Matching Option In Menu    ${setup_menu}    Dasharo System Features
    ${dsf_relative_index}=    Evaluate    ${bmm_index} - ${dsf_index}
    ${bmm_menu}=    Enter Submenu From Snapshot And Return Construction    ${setup_menu}    Boot Maintenance Manager
    Set Option State    ${bmm_menu}    Auto Boot Time-out    123
    Press Key N Times    1    ${ESC}

    Press Key N Times And Enter    ${dsf_relative_index}    ${ARROW_UP}
    ${dasharo_menu}=    Get Submenu Construction
    ${network_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Networking Options
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu And Return Construction
    ${bmm_menu}=    Enter Submenu From Snapshot And Return Construction    ${setup_menu}    Boot Maintenance Manager
    ${out}=    Get Option State    ${bmm_menu}    Auto Boot Time-out
    Should Not Be Equal As Integers    ${out}    123
