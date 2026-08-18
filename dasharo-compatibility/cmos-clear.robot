*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated    semiauto


*** Test Cases ***
CMOS001.101 Clearing CMOS resets firmware settings (EDK2 UEFI)
    [Documentation]    Check whether clearing CMOS resets firmware settings
    [Tags]    automated    semiauto
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Set UEFI Option    UsbDriverStack    ${FALSE}

    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    ${before}=    Get UEFI Option    UsbDriverStack
    Should Not Be True    ${before}

    Clear Cmos With Fallback

    Power On

    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    ${after}=    Get UEFI Option    UsbDriverStack
    Should Be True    ${after}


*** Keywords ***
Clear Cmos With Fallback
    [Documentation]    Clears CMOS via RTE, otherwise instructs
    ...    tester to manually disconnect battery
    IF    ${DUT_HAS_CMOS_RESET}
        Rte Clear Cmos
    ELSE
        Log    RTE CMOS clear not supported. Test becomes semiauto.    level=WARN
        Skip If    'semiauto' not in ${INCLUDE_TAGS}    `semiauto` tag not selected
        Execute Manual Step    Power off the device, disconnect the CMOS battery and wait 20 seconds
        Execute Manual Step    Reconnect the CMOS battery
        IF    $POWER_CTRL == 'none'
            Execute Manual Step    Power the device back on manually
        END
    END
