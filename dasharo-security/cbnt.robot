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
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/tpm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${INTEL_CBNT_SUPPORT}    Intel CBnT not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CBNT001.201 Converged Boot Guard and TXT - CBnT profile is 5 / FVME (Ubuntu)
    [Documentation]    CBnT profile MUST be 5 - FVME
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBNT001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CBNT001.201 not supported
    Check CBnT Profile 5    ${ENV_ID_UBUNTU}

CBNT002.101 Converged Boot Guard and TXT Status Menu is visible
    [Documentation]    CBnT status menu must be visible. We can only test if the
    ...    first 9 lines are visible due to the limitations of a 80x25 terminal
    ...    size and the current test keywords not handling scrolling.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBNT002.101 not supported
    Skip If    not ${INTEL_CBNT_STATUS_MENU_SUPPORT}    CBNT002.101 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    Enter Submenu From Snapshot    ${dasharo_menu}    Intel Management Engine Options
    Read From Terminal Until    BOOT_GUARD_SACM_INFO_MSR
    Read From Terminal Until    NEM Enabled
    Read From Terminal Until    TPM Type
    Read From Terminal Until    TPM Success
    Read From Terminal Until    Force Anchor Cove Boot
    Read From Terminal Until    Measured Boot
    Read From Terminal Until    Verified Boot
    Read From Terminal Until    Revoked
    Read From Terminal Until    Boot Guard Capability

CBNT003.201 Converged Boot Guard and TXT - PCR-0 is reconstructed correctly (Ubuntu)
    [Documentation]    coreboot must correctly replicate and log to TPM event
    ...    log the data CBnT used to extend PCR-0
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBNT003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CBNT003.201 not supported

    Boot OS And Enter Root Shell    ${ENV_ID_UBUNTU}

    ${tpm2_eventlog}=    Execute Command In Terminal
    ...    tpm2_eventlog /sys/kernel/security/tpm0/binary_bios_measurements
    Should Not Contain    ${tpm2_eventlog}    ERROR: Unable to run tpm2_eventlog
    Should Not Contain    ${tpm2_eventlog}    not found

    # coreboot supports extending only a single PCR bank which is selected at
    # build time, this is normally SHA256. Check that this bank was extended
    # properly and SHA1 (if active) wasn't.

    ${eventlog_pcrs}=    Get PCRs From Eventlog    ${tpm2_eventlog}    sha256
    FOR    ${pcr_element}    IN    @{eventlog_pcrs}
        ${pcr}    ${expected}=    Split String    ${pcr_element}    separator=:
        IF    ${pcr} != 0    CONTINUE

        ${actual}=    Execute Command In Terminal
        ...    cat /sys/class/tpm/tpm0/pcr-sha256/${pcr}
        Should Contain    ${expected}    ${actual}    ignore_case=${TRUE}
    END

    ${eventlog_pcrs}=    Get PCRs From Eventlog    ${tpm2_eventlog}    sha1
    FOR    ${pcr_element}    IN    @{eventlog_pcrs}
        ${pcr}    ${expected}=    Split String    ${pcr_element}    separator=:
        IF    ${pcr} != 0    CONTINUE

        ${actual}=    Execute Command In Terminal
        ...    cat /sys/class/tpm/tpm0/pcr-sha1/${pcr}
        Should Not Contain    ${expected}    ${actual}    ignore_case=${TRUE}
    END


*** Keywords ***
Check CBnT Profile 5
    [Documentation]    Check if F, V and M components of the boot policy match
    ...    profile 5
    [Tags]    robot:private
    [Arguments]    ${os_id}
    Boot OS And Enter Root Shell    ${os_id}
    ${out_cbmem}=    Execute Command In Terminal    cbmem -1
    Should Match Regexp    ${out_cbmem}    FACB:\\S+1\\n
    Should Match Regexp    ${out_cbmem}    measured boot:\\S+1\\n
    Should Match Regexp    ${out_cbmem}    verified boot:\\S+1\\n
    Exit From Root User

Boot OS And Enter Root Shell
    [Documentation]    Boots a specified OS and prepares for running commands as
    ...    root
    [Tags]    robot:private
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
