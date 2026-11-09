*** Settings ***
Library             OperatingSystem
Library             TelnetLibrary    timeout=20 seconds    connection_timeout=120 seconds
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
# Supported TPM: 1.2 or 2.0 (any active PCR banks)


*** Test Cases ***
WTD001.001 All cores are up
    [Documentation]    Verifies that all CPUs are online with DRTM.
    ${offline}=    Execute Command In Terminal
    ...    cat /sys/devices/system/cpu/offline
    Should Be Equal As Strings    ${offline}    ${EMPTY}
    ...    Not all cores are up

WTD002.001 DRTM PCRs are updated with TB
    [Documentation]    Checks that DRTM changes 17-22 PCRs as it should.
    [Tags]    criterion:C01

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
    [Tags]    criterion:C02
    ${present}=    Execute Command In Terminal
    ...    test -f /sys/kernel/security/slaunch/eventlog && echo y
    Should Be Equal As Strings    ${present}    y    msg=DRTM log is missing

WTD005.001 DRTM event log has DRTM entries
    [Documentation]    Verifies that the DRTM event log has the events the
    ...    launch (Intel SINIT ACM or AMD Secure Kernel Loader) and the kernel
    ...    log, with their types, PCRs and order
    [Tags]    criterion:C04
    ${present}=    Execute Command In Terminal
    ...    test -f /sys/kernel/security/slaunch/eventlog && echo y
    Skip If    "${present}" != "y"    DRTM log is missing
    DRTM Event Log Should Follow Secure Launch Order

WTD006.001 DRTM log aligns with PCR values
    [Documentation]    Verify that all DRTM measurements are correctly reflected
    ...    in DRTM event log
    [Tags]    criterion:C02
    Validate DRTM PCRs Against Event Log    17    18

WTD007.001 SRTM log aligns with PCR values
    [Documentation]    Verify that all SRTM measurements are correctly reflected
    ...    in SRTM event log
    Validate PCRs Against Event Log    /sys/kernel/security/tpm0/binary_bios_measurements

WTD008.001 DRTM log covers every active PCR bank
    [Documentation]    Verify that every DRTM measurement for PCR 17 and 18 is
    ...    logged in every active PCR bank, so that each bank can be replayed
    [Tags]    criterion:C13
    Skip If    '${TPM_SUPPORTED_VERSION}' == '1'    TPM 1.2 has only the SHA-1 bank
    DRTM Event Log Should Cover Banks    17    18

WTD009.001 DRTM log digests match the measured data
    [Documentation]    Verify that the DRTM log digests whose measured value
    ...    the OS knows (SINIT ACM data, kernel command line) are its hash
    [Tags]    criterion:C03
    DRTM Event Log Should Match Measured Values

WTD010.001 PCR 19 to 22 are zero in every active bank
    [Documentation]    Verify that the launch resets PCR 19 to 22 to zero and
    ...    extends none of them, in every active PCR bank
    [Tags]    criterion:C01
    Skip If    '${TPM_SUPPORTED_VERSION}' == '1'    TPM 1.2 has no per-bank PCRs in sysfs
    PCRs Should Be Zero In Every Active Bank    19    20    21    22

WTD011.001 TPM quote of PCR 17 and 18 verifies
    [Documentation]    Verify that a quote of PCR 17 and 18 in the SHA-256
    ...    bank, made with an AK under the EK and a nonce from the runner,
    ...    carries the nonce, verifies with the AK and covers the PCR values
    ...    the OS reads
    [Tags]    criterion:C08
    Skip If    '${TPM_SUPPORTED_VERSION}' == '1'    TPM 1.2 has no TPM2_Quote
    DRTM TPM Quote Should Verify

WTD012.001 PCR 17 and 18 extends from the OS are refused
    [Documentation]    Verify that once the kernel has extended its
    ...    measurements, the OS can extend neither PCR 17 nor PCR 18: the
    ...    launch's write access to them is closed. An accepted extend
    ...    changes the PCR, so this is the last test of the suite.
    [Tags]    criterion:C07
    Skip If    '${TPM_SUPPORTED_VERSION}' == '1'    TPM 1.2 has no per-bank PCRs in sysfs
    PCR Extend From OS Should Be Refused    17    18


*** Keywords ***
TrenchBoot Suite Setup
    Prepare Test Suite

    Skip If    ${TPM_SUPPORTED_VERSION} == None    TPM tests not supported
    Skip If    not ${TRENCHBOOT_SUPPORT}    TrenchBoot tests aren't supported
    Skip If    not ${TESTS_IN_METATB_SUPPORT}    Tests in meta-trenchboot aren't supported

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_TRENCHBOOT}
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
