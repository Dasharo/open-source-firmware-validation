*** Settings ***
Library             OperatingSystem
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/trenchboot.robot
Resource            ../lib/tpm.robot

Suite Setup         TrenchBoot Suite Setup
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
# WTD -- WiTh Drtm
#
# These tests verify sanity of the platform when DRTM is enabled.
#
# Supported TPM: 1.2 or 2.0 (SHA1 and/or SHA256 PCR banks)


*** Test Cases ***
WTD001.001 All cores are up
    [Documentation]    Verifies that all CPUs are online with DRTM.
    ${offline}=    Execute Command In Terminal
    ...    cat /sys/devices/system/cpu/offline
    Should Be Equal As Strings    ${offline}    ${EMPTY}
    ...    Not all cores are up

WTD002.001 DRTM PCRs are updated with TB
    [Documentation]    Checks that DRTM changes 17-22 PCRs as it should.

    ${pcr_hashes}=    Get PCRs State From Linux    1[7-8]
    FOR    ${pcr_hash}    IN    @{pcr_hashes}
        ${pcr}    ${hash}=    Split String    ${pcr_hash}    separator=:
        ${unique_values_str}=    Evaluate    ''.join(set("${hash}"))
        Should Not Be Equal    ${unique_values_str}    F    msg=${pcr}
        Should Not Be Equal    ${unique_values_str}    0    msg=${pcr}
    END

    ${pcr_hashes}=    Get PCRs State From Linux    19|2[0-2]
    FOR    ${pcr_hash}    IN    @{pcr_hashes}
        ${pcr}    ${hash}=    Split String    ${pcr_hash}    separator=:
        ${unique_values_str}=    Evaluate    ''.join(set("${hash}"))
        Should Be Equal    ${unique_values_str}    0    msg=${pcr}
    END

WTD003.001 SRTM event log exists
    [Documentation]    Verifies that SRTM event log is present with DRTM.
    ${present}=    Execute Command In Terminal
    ...    test -f /sys/kernel/security/tpm0/binary_bios_measurements && echo y
    Should Be Equal As Strings    ${present}    y    msg=SRTM log is missing

WTD004.001 DRTM event log exists
    [Documentation]    Verifies that DRTM event log is present with DRTM.
    ${present}=    Execute Command In Terminal
    ...    test -f /sys/kernel/security/slaunch/eventlog && echo y
    Should Be Equal As Strings    ${present}    y    msg=DRTM log is missing

WTD005.001 DRTM event log has DRTM entries (AMD)
    [Documentation]    Verifies that event log includes DRTM entries

    ${cpuinfo}=    Execute Command In Terminal    cat /proc/cpuinfo
    Skip If    "AuthenticAMD" not in """${cpuinfo}"""    Not an AMD CPU

    ${present}=    Execute Command In Terminal
    ...    test -f /sys/kernel/security/slaunch/eventlog && echo y
    Skip If    "${present}" != "y"    DRTM log is missing

    Execute Command In Terminal
    ...    tpm2_eventlog /sys/kernel/security/slaunch/eventlog > /tmp/event-log
    Execute Command In Terminal
    ...    function to_hex() { echo -n "$1" | hexdump -ve '1/1 "%02x"'; }
    Execute Command In Terminal
    ...    function find_event() { sed -n "/\\s*PCRIndex: $1/,/Event: \\"/s/\\s*Event: \\"$(to_hex "$2")\\"/MATCH/p" /tmp/event-log; }

    ${match}=    Execute Command In Terminal
    ...    find_event 17 "SKINIT"
    Should Be Equal As Strings    ${match}    MATCH    No "SKINIT" entry

    ${match}=    Execute Command In Terminal
    ...    find_event 17 "DLME entry offset"
    Should Be Equal As Strings    ${match}    MATCH    No "DLME entry offset" entry

    ${match}=    Execute Command In Terminal
    ...    find_event 17 "DLME"
    Should Be Equal As Strings    ${match}    MATCH    No "DLME" entry

    # XXX: No part of SLRT is measured on AMD platforms.
    # Early TPM code doesn't identify SLRT measurement event in any way.
    # ${match}=    Execute Command In Terminal
    # ...    find_event 18 ""
    # Should Be Equal As Strings    ${match}    MATCH    No SLRT entry

    # XXX: This is only for Multiboot2 protocol.
    # ${match}=    Execute Command In Terminal
    # ...    find_event 17 "Measured MB2 module"
    # Should Be Equal As Strings    ${match}    MATCH\nMATCH    No "Measured MB2 module" entries

WTD006.001 DRTM log aligns with PCR values
    [Documentation]    Verify that all DRTM measurements are correctly reflected
    ...    in DRTM event log
    Validate PCRs Against Event Log    /sys/kernel/security/slaunch/eventlog

WTD007.001 SRTM log aligns with PCR values
    [Documentation]    Verify that all SRTM measurements are correctly reflected
    ...    in SRTM event log
    Validate PCRs Against Event Log    /sys/kernel/security/tpm0/binary_bios_measurements


*** Keywords ***
TrenchBoot Suite Setup
    Prepare Test Suite

    Skip If    not ${TPM_SUPPORT}    TPM tests not supported
    Skip If    not ${TRENCHBOOT_SUPPORT}    TrenchBoot tests aren't supported
    Skip If    not ${TESTS_IN_METATB_SUPPORT}    Tests in meta-trenchboot aren't supported

    Power On
    Boot System Or From Connected Disk    trenchboot
    Read From Terminal Until    Press enter to boot the selected OS
    # Slaunch is the second boot option, pick it.
    Write Bare Into Terminal    ${ARROW_DOWN}
    Write Bare Into Terminal    ${ENTER}

    # Permit trying running the tests in QEMU even though DRTM sequence won't
    # work
    IF    "${MANUFACTURER}" != "QEMU"
        ${grub_out}=    Read From Terminal Until    Press any key to continue...
        Should Not Contain    ${grub_out}    error: secure launch not enabled.
    END

    TrenchBoot Telnet Root Login
