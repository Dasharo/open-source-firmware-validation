*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../variables.robot
Resource            ../lib/zarhus-provision-lib.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    '${MANUFACTURER}' == 'QEMU'
...                     AND
...                     Prepare ZPB OS
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
Test Setup          Run Keyword If    ${TESTS_IN_FIRMWARE_SUPPORT}
...                     Restore Initial DUT Connection Method


*** Test Cases ***
ZPBP001.101 Make sure that network boot is disabled
    [Documentation]    Make sure that Network Boot is disabled
    ${state}=    Get UEFI Option    NetworkBoot
    Should Not Be True    ${state}

ZPBP002.101 Make sure that BIOS boot medium is locked
    [Documentation]    Make sure that BIOS boot medium is locked
    ${state}=    Get UEFI Option    LockBios
    Should Be True    ${state}

ZPBP003.101 Make sure that SMM BIOS write protection is enabled
    [Documentation]    Make sure that SMM BIOS write protection is enabled
    ${state}=    Get UEFI Option    SmmBwp
    Should Be True    ${state}

ZPBP004.101 Make sure that Intel ME is HAP disabled
    [Documentation]    Make sure that Intel ME is HAP disabled
    ${state}=    Get UEFI Option    MeMode
    Should Be Equal    ${state}    Disabled (HAP)

ZPBP005.101 Make sure that OptionROM loading is disabled
    [Documentation]    Make sure that Network Boot is disabled
    ${state}=    Get UEFI Option    OptionROMExecutionPolicy
    Should Contain    ${state}    Disable all OptionROMs

ZPBP006.206 Make sure that zarhus status returns expected initial state
    [Documentation]    Make sure that `zarhus status` returns information that
    ...    BootGuard and Secure Boot is disabled and that Fusing state is
    ...    unknown
    Boot Zarhus OS
    ${output}=    Execute Command In Terminal    zarhus status
    Should Contain    ${output}    Boot Guard: Disabled
    Should Contain    ${output}    Secure Boot: Disabled
    Should Contain    ${output}    Fusing state: Unknown (ME may be disabled)

ZPBP007.206 Make sure that Secure Boot is in Setup Mode
    [Documentation]    Make sure that Secure Boot is in Setup Mode which means
    ...    it can be provisioned from OS
    Boot Zarhus OS
    ${output}=    Execute Command In Terminal    sbctl status
    @{lines}=    Split To Lines    ${output}
    FOR    ${line}    IN    @{lines}
        ${status}=    Run Keyword And Return Status
        ...    Should Match    ${line}    Setup Mode:*Enabled
        IF    ${status}    Pass Execution    Secure Boot is in Setup Mode
    END
    Fail    Couldn't find 'Setup Mode: *Enabled' string
