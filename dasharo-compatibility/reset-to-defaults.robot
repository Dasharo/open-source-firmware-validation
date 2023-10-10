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
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
RTD001.001 F9 resets Enable USB stack option to true
    [Documentation]    Check whether pressing F9 resets Enable USB stack
    ...    option to be enabled.
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD001.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter USB Configuration Submenu
    Refresh Serial Screen In BIOS Editable Settings Menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=3
    Disable Option In Submenu    ${submenu_construction}    Enable USB stack
    Reset To Defaults Tianocore
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Enable USB stack
    Should Be Equal    ${value}    [X]

RTD002.001 F9 resets Enable USB Mass Storage driver option to true
    [Documentation]    Check whether pressing F9 resets Enable Mass Storage
    ...    driver option to be enabled
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD002.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter USB Configuration Submenu
    Refresh Serial Screen In BIOS Editable Settings Menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=3
    Disable Option In Submenu    ${submenu_construction}    Enable USB Mass Storage
    Reset To Defaults Tianocore
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Enable USB Mass Storage
    Should Be Equal    ${value}    [X]

RTD003.001 F9 resets Lock the BIOS boot medium option to true
    [Documentation]    Check whether pressing F9 resets Lock the BIOS boot
    ...    medium driver option to be enabled
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD003.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features Submenu    Dasharo Security Options
    Refresh Serial Screen In BIOS Editable Settings Menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=3
    Disable Option In Submenu    ${submenu_construction}    Lock the BIOS boot medium
    Reset To Defaults Tianocore
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Lock the BIOS boot medium
    Should Be Equal    ${value}    [X]

RTD004.001 F9 resets Enable SMM BIOS write protection to false
    [Documentation]    Check whether pressing F9 resets Enable SMM BIOS write
    ...    protection option to be disabled
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD004.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features Submenu    Dasharo Security Options
    Refresh Serial Screen In BIOS Editable Settings Menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=2
    Enable Option In Submenu    ${submenu_construction}    Enable SMM BIOS write
    Reset To Defaults Tianocore
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Enable SMM BIOS write
    Should Be Equal    ${value}    [ ]

RTD005.001 F9 resets Early boot DMA Protection to true
    [Documentation]    Check whether pressing F9 resets Early boot DMA
    ...    Protection option to be enabled
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD005.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features Submenu    Dasharo Security Options
    Refresh Serial Screen In BIOS Editable Settings Menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=3
    Enable Option In Submenu    ${submenu_construction}    Early boot DMA Protection
    Reset To Defaults Tianocore
    Press Key N Times    1    ${F10}
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
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD007.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features Submenu    Networking Options
    Refresh Serial Screen In BIOS Editable Settings Menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=2
    Enable Option In Submenu    ${submenu_construction}    Enable network boot
    Reset To Defaults Tianocore
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Enable network boot
    Should Be Equal    ${value}    [ ]

RTD008.001 F9 resets Intel ME mode to enabled
    [Documentation]    Check whether pressing F9 resets Intel ME mode option
    ...    to be enabled
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD008.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features Submenu    Intel Management Engine Options
    Refresh Serial Screen In BIOS Editable Settings Menu
    Change To Next Option In Setting    Intel ME mode
    Reset To Defaults Tianocore
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Intel ME mode
    Should Be Equal    ${value}    <Enabled>

RTD009.001 F9 resets Enable PS2 Controller to enabled
    [Documentation]    Check whether pressing F9 resets Enable PS2 Controller
    ...    to be enabled
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD009.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features Submenu    Chipset Configuration
    Refresh Serial Screen In BIOS Editable Settings Menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=3
    Disable Option In Submenu    ${submenu_construction}    Enable PS2 Controller
    Reset To Defaults Tianocore
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Enable PS2 Controller
    Should Be Equal    ${value}    [X]

RTD010.001 F9 resets Enable watchdog to enabled
    [Documentation]    Check whether pressing F9 resets Enable watchdog
    ...    to be enabled
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD010.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features Submenu    Chipset Configuration
    Refresh Serial Screen In BIOS Editable Settings Menu
    ${submenu_construction}=    Get Setup Submenu Construction    description_lines=3
    Disable Option In Submenu    ${submenu_construction}    Enable watchdog
    Reset To Defaults Tianocore
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Enable watchdog
    Should Be Equal    ${value}    [X]

RTD011.001 F9 resets Watchdog timeout value to 500
    [Documentation]    Check whether pressing F9 resets Watchdog timeout value
    ...    to 500
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD011.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features Submenu    Chipset Configuration
    Refresh Serial Screen In BIOS Editable Settings Menu
    Change Numeric Value Of Setting    Watchdog timeout value    400
    Reset To Defaults Tianocore
    ${value}=    Get Option Value    Watchdog timeout value
    Should Be Equal    ${value}    [500]

RTD012.001 F9 resets Fan profile to Silent
    [Documentation]    Check whether pressing F9 resets Fan profile to Silent
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD012.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features Submenu    Power Management Options
    Refresh Serial Screen In BIOS Editable Settings Menu
    Change To Next Option In Setting    Fan profile
    Reset To Defaults Tianocore
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Fan profile
    Should Be Equal    ${value}    <Silent>

RTD013.001 F9 resets Platform sleep type to Suspend to Idle
    [Documentation]    Check whether pressing F9 resets Platform sleep type to
    ...    Suspend to Idle
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD013.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features Submenu    Power Management Options
    Refresh Serial Screen In BIOS Editable Settings Menu
    Change To Next Option In Setting    Platform sleep type
    Reset To Defaults Tianocore
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Platform sleep type
    Should Be Equal    ${value}    <Suspend to Idle>

RTD014.001 F9 resets Memory SPD Profile to JEDEC
    [Documentation]    Check whether pressing F9 resets Memory SPD Profile to
    ...    JEDEC
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${MEMORY_PROFILE_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD014.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features Submenu    Memory Configuration
    Refresh Serial Screen In BIOS Editable Settings Menu
    Change To Next Option In Setting    Memory SPD Profile
    Reset To Defaults Tianocore
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ESC to exit
    ${value}=    Get Option Value    Memory SPD Profile
    Should Start With    ${value}    <JEDEC
