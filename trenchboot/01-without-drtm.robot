*** Settings ***
Library             OperatingSystem
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/trenchboot.robot
Resource            ../lib/tpm.robot

Suite Setup         TrenchBoot Suite Setup
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
# WOD -- WithOut Drtm
#
# These tests verify sanity of the platform when DRTM is not employed and should
# precede tests with DRTM on.
#
# Supported TPM: 1.2 or 2.0 (SHA1 and/or SHA256 PCR banks)


*** Test Cases ***
WOD001.001 All cores are up
    [Documentation]    Verifies that all CPUs are online without DRTM because
    ...    it's easy to do and this could potentially catch an issue.
    ${offline}=    Execute Command In Terminal
    ...    cat /sys/devices/system/cpu/offline
    Should Be Equal As Strings    ${offline}    ${EMPTY}
    ...    Not all cores are up

WOD002.001 SRTM event log exists
    [Documentation]    SRTM event log should be present even without DRTM.
    ${present}=    Execute Command In Terminal
    ...    test -f /sys/kernel/security/tpm0/binary_bios_measurements && echo y
    Should Be Equal As Strings    ${present}    y    msg=SRTM log is missing

WOD003.001 DRTM PCRs are not updated without TB
    [Documentation]    Checks that PCRs 17-22 have values of FF* when DRTM
    ...    isn't active.

    ${pcr_hashes}=    Get PCRs State From Linux    1[7-9]|2[0-2]
    FOR    ${pcr_hash}    IN    @{pcr_hashes}
        ${pcr}    ${hash}=    Split String    ${pcr_hash}    separator=:
        ${unique_values_str}=    Evaluate    ''.join(set("${hash}"))
        Should Be Equal    ${unique_values_str}    F    msg=${pcr}
    END

WOD004.001 DRTM event log doesn't exist
    [Documentation]    Verifies that DRTM event log is missing without DRTM.
    ${present}=    Execute Command In Terminal
    ...    test -f /sys/kernel/security/slaunch/eventlog && echo y
    Should Be Equal As Strings    ${present}    ${EMPTY}    msg=DRTM log is missing


*** Keywords ***
TrenchBoot Suite Setup
    Prepare Test Suite

    Skip If    not ${TPM_SUPPORT}    TPM tests not supported
    Skip If    not ${TRENCHBOOT_SUPPORT}    TrenchBoot tests aren't supported
    Skip If    not ${TESTS_IN_METATB_SUPPORT}    Tests in meta-trenchboot aren't supported

    Power On
    Boot System Or From Connected Disk    trenchboot
    Read From Terminal Until    Press enter to boot the selected OS
    Write Bare Into Terminal    ${ENTER}

    TrenchBoot Telnet Root Login
