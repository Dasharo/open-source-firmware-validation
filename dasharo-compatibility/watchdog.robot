*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../lib/bios/menus.robot
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggests (not
#    exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keywords
...                     Log Out And Close Connection


*** Test Cases ***
WDT001.001 Check if watchdog option is available
    [Documentation]    Check if the watchdog timer can be enabled in the chipset
    ...    configuration submenu.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    WDT001.001 not supported
    Skip If    not ${WATCHDOG_SUPPORT}    Watchdog tests not supported.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${chipset_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Chipset Configuration
    Should Contain Match    ${chipset_menu}    Enable watchdog*

WDT002.001 Enable watchdog
    [Documentation]    Enable watchdog with the default timeout and verify that
    ...    it resets the platform.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    WDT002.001 not supported
    Skip If    not ${WATCHDOG_SUPPORT}    Watchdog tests not supported.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${chipset_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Chipset Configuration
    Set Option State    ${chipset_menu}    Enable watchdog    ${TRUE}
    Save Changes And Reset
    Enter Setup Menu Tianocore And Return Construction
    # We're in the setup menu. Now just wait until the platform resets. Wait a
    # little longer than the timeout to give the platform time to reset.
    Set DUT Response Timeout    320s
    Read From Terminal Until    ${TIANOCORE_STRING}

WDT003.001 Disable watchdog
    [Documentation]    Disable the watchdog after enabling it to verify it does
    ...    not reset the platform anymore.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    WDT003.001 not supported
    Skip If    not ${WATCHDOG_SUPPORT}    Watchdog tests not supported.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${chipset_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Chipset Configuration
    Set Option State    ${chipset_menu}    Enable watchdog    ${FALSE}
    Save Changes And Reset
    Enter Setup Menu Tianocore And Return Construction
    # We're in the setup menu. Now just wait more than the default timeout to
    # make sure the watchdog does not reset the platform.
    ${platform_has_reset}=    Set Variable    ${TRUE}
    Set DUT Response Timeout    360s
    TRY
        Read From Terminal Until    ${TIANOCORE_STRING}
    EXCEPT
        ${platform_has_reset}=    Set Variable    ${FALSE}
    END
    Should Be Equal    ${platform_has_reset}    ${FALSE}

WDT004.001 Change watchdog timeout
    [Documentation]    Enable watchdog timer with a higher timeout than default
    ...    and verify that it resets the platform.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    WDT004.001 not supported
    Skip If    not ${WATCHDOG_SUPPORT}    Watchdog tests not supported.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${chipset_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Chipset Configuration
    Set Option State    ${chipset_menu}    Enable watchdog    ${TRUE}
    # Refresh menu, now that watchdog timeout is available
    ${chipset_menu}=    Reenter Menu And Return Construction
    Set Option State    ${chipset_menu}    Watchdog timeout value    360
    Save Changes And Reset
    Enter Setup Menu Tianocore And Return Construction
    # We're in the setup menu. Wait 320s to make sure platform does not reset
    # after the default timeout of 300s.
    ${platform_has_reset}=    Set Variable    ${TRUE}
    Set DUT Response Timeout    320s
    TRY
        Read From Terminal Until    ${TIANOCORE_STRING}
    EXCEPT
        ${platform_has_reset}=    Set Variable    ${FALSE}
    END
    Should Be Equal    ${platform_has_reset}    ${FALSE}
    # Now wait another 60s to make sure the platform resets within ~360s of
    # boot.
    Set DUT Response Timeout    60s
    Read From Terminal Until    ${TIANOCORE_STRING}

WDT005.001 Watchdog is detected by OS (Ubuntu)
    [Documentation]    Boot into an OS with the watchdog enabled and verify
    ...    that the OS detects and stops the watchdog.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    APU002.001 not supported
    Skip If    not ${WATCHDOG_SUPPORT}    Watchdog tests not supported.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${chipset_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Chipset Configuration
    Set Option State    ${chipset_menu}    Enable watchdog    ${TRUE}
    # Refresh menu, in case the watchdog timeout wasn't already available
    ${chipset_menu}=    Reenter Menu And Return Construction
    Set Option State    ${chipset_menu}    Watchdog timeout value    300
    Save Changes And Reset
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Execute Linux Command    modprobe wdat_wdt
    # OS should take control of the WDT at this point. Just wait for the timeout
    # to pass and verify no reboot occurred.
    ${platform_has_reset}=    Set Variable    ${TRUE}
    Set DUT Response Timeout    300s
    TRY
        Read From Terminal Until    ${TIANOCORE_STRING}
    EXCEPT
        ${platform_has_reset}=    Set Variable    ${FALSE}
    END
    Should Be Equal    ${platform_has_reset}    ${FALSE}
