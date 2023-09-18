*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
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
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
RTD001.001 F9 resets Enable USB stack option to true
    [Documentation]    Check whether pressing F9 resets Enable USB stack
    ...    option to be enabled.
    Skip if    not ${reset_to_defaults_support}
    Skip If    not ${tests_in_firmware_support}    RTD001.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter USB Configuration Submenu
    Refresh serial screen in BIOS editable settings menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=3
    Disable Option In submenu    ${submenu_construction}    Enable USB stack
    Reset to Defaults Tianocore
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Enable USB stack
    Should Be Equal    ${value}    [X]

RTD002.001 F9 resets Enable USB Mass Storage driver option to true
    [Documentation]    Check whether pressing F9 resets Enable Mass Storage
    ...    driver option to be enabled
    Skip if    not ${reset_to_defaults_support}
    Skip If    not ${tests_in_firmware_support}    RTD002.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter USB Configuration Submenu
    Refresh serial screen in BIOS editable settings menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=3
    Disable Option In submenu    ${submenu_construction}    Enable USB Mass Storage
    Reset to Defaults Tianocore
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Enable USB Mass Storage
    Should Be Equal    ${value}    [X]

RTD003.001 F9 resets Lock the BIOS boot medium option to true
    [Documentation]    Check whether pressing F9 resets Lock the BIOS boot
    ...    medium driver option to be enabled
    Skip if    not ${reset_to_defaults_support}
    Skip If    not ${tests_in_firmware_support}    RTD003.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features submenu    Dasharo Security Options
    Refresh serial screen in BIOS editable settings menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=3
    Disable Option In submenu    ${submenu_construction}    Lock the BIOS boot medium
    Reset to Defaults Tianocore
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Lock the BIOS boot medium
    Should Be Equal    ${value}    [X]

RTD004.001 F9 resets Enable SMM BIOS write protection to false
    [Documentation]    Check whether pressing F9 resets Enable SMM BIOS write
    ...    protection option to be disabled
    Skip if    not ${reset_to_defaults_support}
    Skip If    not ${tests_in_firmware_support}    RTD004.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features submenu    Dasharo Security Options
    Refresh serial screen in BIOS editable settings menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=2
    Enable Option In submenu    ${submenu_construction}    Enable SMM BIOS write
    Reset to Defaults Tianocore
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Enable SMM BIOS write
    Should Be Equal    ${value}    [ ]

RTD005.001 F9 resets Early boot DMA Protection to true
    [Documentation]    Check whether pressing F9 resets Early boot DMA
    ...    Protection option to be enabled
    Skip if    not ${reset_to_defaults_support}
    Skip If    not ${tests_in_firmware_support}    RTD005.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features submenu    Dasharo Security Options
    Refresh serial screen in BIOS editable settings menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=3
    Enable Option In submenu    ${submenu_construction}    Early boot DMA Protection
    Reset to Defaults Tianocore
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Early boot DMA Protection
    Should Be Equal    ${value}    [ ]

# This is test is commented, because when reset to defaults is selected, then
# Early boot DMA Protection is set to disabled, hence this option is no
# longer present.
#
# RTD006.001 F9 resets Keep IOMMU enabled when transfer control to OS to false
#    [Documentation]    Check whether pressing F9 resets Keep IOMMU enabled when
#    ...    transfer control to OS option to be disabled
#    Power On
#    Enter Setup Menu Tianocore
#    Enter Dasharo System Features submenu    Dasharo Security Options
#    Refresh serial screen in BIOS editable settings menu
#    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=3
#    Enable Option In submenu    ${submenu_construction}    Keep IOMMU enabled when
#    Reset to Defaults Tianocore
#    Press key n times    1    ${F10}
#    Write Bare Into Terminal    y
#    Read From Terminal Until    ESC to exit
#    ${value}=    Get Option Value    Keep IOMMU enabled when
#    Should Be Equal    ${value}    [ ]

RTD007.001 F9 resets Enable network boot to false
    [Documentation]    Check whether pressing F9 resets Keep IOMMU enabled when
    ...    transfer control to OS option to be disabled
    Skip if    not ${reset_to_defaults_support}
    Skip If    not ${tests_in_firmware_support}    RTD007.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features submenu    Networking Options
    Refresh serial screen in BIOS editable settings menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=2
    Enable Option In submenu    ${submenu_construction}    Enable network boot
    Reset to Defaults Tianocore
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Enable network boot
    Should Be Equal    ${value}    [ ]

RTD008.001 F9 resets Intel ME mode to enabled
    [Documentation]    Check whether pressing F9 resets Intel ME mode option
    ...    to be enabled
    Skip if    not ${reset_to_defaults_support}
    Skip If    not ${tests_in_firmware_support}    RTD008.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features submenu    Intel Management Engine Options
    Refresh serial screen in BIOS editable settings menu
    Change to next option in setting    Intel ME mode
    Reset to Defaults Tianocore
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Intel ME mode
    Should Be Equal    ${value}    <Enabled>

RTD009.001 F9 resets Enable PS2 Controller to enabled
    [Documentation]    Check whether pressing F9 resets Enable PS2 Controller
    ...    to be enabled
    Skip if    not ${reset_to_defaults_support}
    Skip If    not ${tests_in_firmware_support}    RTD009.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features submenu    Chipset Configuration
    Refresh serial screen in BIOS editable settings menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=3
    Disable Option In submenu    ${submenu_construction}    Enable PS2 Controller
    Reset to Defaults Tianocore
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Enable PS2 Controller
    Should Be Equal    ${value}    [X]

RTD010.001 F9 resets Enable watchdog to enabled
    [Documentation]    Check whether pressing F9 resets Enable watchdog
    ...    to be enabled
    Skip if    not ${reset_to_defaults_support}
    Skip If    not ${tests_in_firmware_support}    RTD010.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features submenu    Chipset Configuration
    Refresh serial screen in BIOS editable settings menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=3
    Disable Option In submenu    ${submenu_construction}    Enable watchdog
    Reset to Defaults Tianocore
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Enable watchdog
    Should Be Equal    ${value}    [X]

RTD011.001 F9 resets Watchdog timeout value to 500
    [Documentation]    Check whether pressing F9 resets Watchdog timeout value
    ...    to 500
    Skip if    not ${reset_to_defaults_support}
    Skip If    not ${tests_in_firmware_support}    RTD011.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features submenu    Chipset Configuration
    Refresh serial screen in BIOS editable settings menu
    Change numeric value of setting    Watchdog timeout value    400
    Reset to Defaults Tianocore
    ${value}=    Get Option Value    Watchdog timeout value
    Should Be Equal    ${value}    [500]

RTD012.001 F9 resets Fan profile to Silent
    [Documentation]    Check whether pressing F9 resets Fan profile to Silent
    Skip if    not ${reset_to_defaults_support}
    Skip If    not ${tests_in_firmware_support}    RTD012.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features submenu    Power Management Options
    Refresh serial screen in BIOS editable settings menu
    Change to next option in setting    Fan profile
    Reset to Defaults Tianocore
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Fan profile
    Should Be Equal    ${value}    <Silent>

RTD013.001 F9 resets Platform sleep type to Suspend to Idle
    [Documentation]    Check whether pressing F9 resets Platform sleep type to
    ...    Suspend to Idle
    Skip if    not ${reset_to_defaults_support}
    Skip If    not ${tests_in_firmware_support}    RTD013.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features submenu    Power Management Options
    Refresh serial screen in BIOS editable settings menu
    Change to next option in setting    Platform sleep type
    Reset to Defaults Tianocore
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Platform sleep type
    Should Be Equal    ${value}    <Suspend to Idle>
