*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary

Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot

*** Keywords ***
Intel ME Mode Option Enabled Works Correctly
    [Documentation]    Check whether the Intel ME mode option in state Enabled
    ...    works correctly.
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Set UEFI Option    MeMode    Enabled
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${result}=    Check ME Out
    Should Be Equal As Strings    ${result}    Enabled

Intel ME Mode Option Disabled (Soft) Works Correctly
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disabled (Soft) works correctly
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Set UEFI Option    MeMode    Disabled (Soft)
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${result}=    Check ME Out
    IF    '${result}' == 'Disabled'
        Log    ME Device Is Disabled (HAP/Soft) Or Does Not Exist    WARN
    ELSE
        Should Be Equal As Strings    ${result}    Disabled (Soft)
    END

Intel ME Mode Option Disabled (HAP) Works Correctly
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disabled (HAP) works correctly.
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Set UEFI Option    MeMode    Disabled (HAP)
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${result}=    Check ME Out
    IF    '${result}' == 'Disabled'
        Log    ME Device Is Disabled (HAP/Soft) Or Does Not Exist    WARN
    ELSE
        Should Be Equal As Strings    ${result}    Disabled (HAP)
    END

Check Intel ME Version
    [Documentation]    This test aims to verify that the Intel ME version might
    ...    be read on the Operating System level. The read version should be
    ...    the same as in the release notes.
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Set UEFI Option    MeMode    Enabled
    Power On Ex    force_reboot=${TRUE}
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    cat /sys/class/mei/mei0/fw_ver
    Should Not Be Empty    ${out}
