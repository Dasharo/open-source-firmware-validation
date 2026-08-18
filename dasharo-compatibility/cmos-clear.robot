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
Suite Teardown      Restore Default UEFI Options

Default Tags        automated


*** Test Cases ***
CMOS001.101 Clearing CMOS resets firmware settings (EDK2 UEFI)
    [Documentation]    Check whether clearing CMOS resets firmware settings
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Set UEFI Option    UsbDriverStack    ${FALSE}
    Set UEFI Option    NetworkBoot    ${TRUE}
    Set UEFI Option    EnableWifiBt    ${FALSE}

    Clear Cmos With Fallback
    Power On

    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    ${after}=    Get UEFI Option    UsbDriverStack
    Should Be True    ${after}
    ${after}=    Get UEFI Option    NetworkBoot
    Should Not Be True    ${after}
    ${after}=    Get UEFI Option    EnableWifiBt
    Should Be True    ${after}

    Restore Boot Order After CMOS Clear


*** Keywords ***
Clear Cmos With Fallback
    [Documentation]    Clears CMOS via RTE, otherwise instructs
    ...    tester to manually disconnect battery
    IF    ${DUT_HAS_CMOS_RESET}
        Rte Psu Off
        Rte Clear Cmos
    ELSE
        Log    RTE CMOS clear not supported. Test becomes semiauto.    level=WARN
        Skip If    'semiauto' not in ${INCLUDE_TAGS}    `semiauto` tag not selected
        Execute Manual Step
        ...    Power off the device, unplug AC, disconnect battery, disconnect the CMOS battery and wait ~30 seconds
        Execute Manual Step    Reconnect the CMOS battery, connect the battery and plug the AC
        IF    $POWER_CTRL == 'none'
            Execute Manual Step    Power the device back on manually and boot into Ubuntu
        END
    END

Restore Default UEFI Options
    [Documentation]    Reset modified UEFI options after failed test
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Set UEFI Option    UsbDriverStack    ${TRUE}
    Set UEFI Option    NetworkBoot    ${FALSE}
    Set UEFI Option    EnableWifiBt    ${TRUE}
    Log Out And Close Connection

Restore Boot Order After CMOS Clear
    [Documentation]    Re-runs BPS009 logic to restore the custom boot entry
    ...    that CMOS clear wiped.
    Skip If    '${OPTIONS_LIB}' != 'options-lib_dcu'
    Boot And Login To OS    ${DEFAULT_BOOT_OS_ID}
    Switch To Root User
    ${custom_bootnum}=    Ensure Custom Entry    ${DEFAULT_BOOT_OS_ID}    force=${TRUE}
    ${bootorder}=    Get BootOrder
    BootOrder Should Start With Bootnum    ${bootorder}    ${custom_bootnum}
