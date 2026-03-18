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

CBNT002.101 Converged Boot Guard and TXT Status Menu is visible (EDK2 UEFI)
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
        Should Contain    ${expected}    ${actual}    ignore_case=${TRUE}
    END

CBNT004.201 Converged Boot Guard and TXT - TPM Startup from locality 3 (Ubuntu)
    [Documentation]    Verify that TPM Startup is done from locality 3
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBNT004.201 not supported on this system
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CBNT004.201 not supported
    Check TPM Startup From Locality 3    ${ENV_ID_UBUNTU}

CBNT005.201 Converged Boot Guard and TXT - Fused platform EoM set and FPFs Committed (Ubuntu)
    [Documentation]    Verify that the system meets the expectations for a
    ...    permanently fused platform:
    ...    - ME Manufacturing Mode is NOT enabled
    ...    - Field Programmable Fuses (FPFs) are committed
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBNT005.201 not supported on this system
    Skip If    not ${INTEL_CBNT_BOOTGUARD_FUSING_SUPPORT}    CBNT005.201 not supported on this system
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CBNT005.201 not supported
    Check EoM And FPFs Committed    ${ENV_ID_UBUNTU}

CBNT006.101 Setup Menu Boot Guard Information (EDK2 UEFI)
    [Documentation]    Check whether setting Auto Boot Time-out to 7 the value
    ...    is remembered after restart
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}

    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_system_features_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${submenu}=    Enter Dasharo Submenu    ${dasharo_system_features_menu}    Intel Management Engine Options

    VAR    ${s_acm_success}=    ${False}
    VAR    ${cpu_debug}=    ${False}
    VAR    ${bsp_init}=    ${False}
    VAR    ${reg_cont}=    ${False}
    VAR    ${nem_enabled}=    ${False}
    VAR    ${tpm_success}=    ${False}
    VAR    ${measured_boot}=    ${False}
    VAR    ${verified_boot}=    ${False}
    VAR    ${boot_guard}=    ${False}
    VAR    ${dma_protection}=    ${False}
    Write Bare Into Terminal    ${ARROW_UP}    # this is necessary to unlock next keyword for good

    FOR    ${i}    IN RANGE    0    45
        ${submenu}=    Get Submenu Construction
        Match BtG Option State    ${submenu}    S-ACM Startup Success <Yes>    s_acm_success
        # Boot Policy: Disable CPU Debugging
        Match BtG Option State
        ...    ${submenu}
        ...    Boot Policy: Disable <Yes>
        ...    cpu_debug
        ...    CPU Debugging
        # Boot Policy: Disable BSP #INIT
        Match BtG Option State
        ...    ${submenu}
        ...    Boot Policy: Disable <Yes>
        ...    bsp_init
        ...    BSP #INIT
        # Register Contents Valid
        Match BtG Option State
        ...    ${submenu}
        ...    Register Contents <No>
        ...    reg_cont
        ...    Valid
        Match BtG Option State    ${submenu}    DMA Protection <Yes>    dma_protection
        Match BtG Option State    ${submenu}    TPM Success <Yes>    tpm_success
        Match BtG Option State    ${submenu}    NEM Enabled <Yes>    nem_enabled
        Match BtG Option State    ${submenu}    Verified Boot <Yes>    verified_boot

        Write Bare Into Terminal    ${ARROW_DOWN}
        Sleep    1s
    END

    ${all_found}=    Evaluate
    ...    ${s_acm_success} and ${cpu_debug} and ${bsp_init} and ${reg_cont} and ${tpm_success} and ${dma_protection} and ${nem_enabled} and ${verified_boot}
    # Final verification
    Log To Console    \n===== Results =====
    Log To Console    S-ACM Startup Success: ${s_acm_success}
    Log To Console    Boot Policy: Disable CPU Debugging <Yes>: ${cpu_debug}
    Log To Console    Boot Policy: Disable BSP #INIT <Yes>: ${bsp_init}
    Log To Console    Register Contents Valid: ${reg_cont}
    Log To Console    DMA Protection <Yes>: ${dma_protection}
    Log To Console    TPM Success <Yes>: ${tpm_success}
    Log To Console    NEM Enabled <Yes>: ${nem_enabled}
    Log To Console    Verified Boot <Yes>: ${verified_boot}
    Log To Console    =====================
    Should Be True    ${all_found}


*** Keywords ***
Check TPM Startup From Locality 3
    [Documentation]    Check TPM Startup locality print in cbmem to verify
    ...    that TPM started from locality 3
    [Arguments]    ${os_id}
    Boot OS And Enter Root Shell    ${os_id}
    ${out_cbmem}=    Execute Command In Terminal    cbmem -1 | grep Startup
    Should Match Regexp    ${out_cbmem}    TPM Startup locality:\\s+3
    Exit From Root User

Check EoM And FPFs Committed
    [Documentation]    Check Manufacturing Mode and FPFs Committed
    ...    prints in cbmem for the expected state
    [Arguments]    ${os_id}
    Boot OS And Enter Root Shell    ${os_id}
    ${out_cbmem}=    Execute Command In Terminal    cbmem -1 | grep ME
    Should Match Regexp    ${out_cbmem}    Manufacturing Mode\\s+:\\s+NO
    Should Match Regexp    ${out_cbmem}    FPFs Committed\\s+:\\s+YES
    Exit From Root User

Check CBnT Profile 5
    [Documentation]    Check if F, V and M components of the boot policy match
    ...    profile 5
    [Arguments]    ${os_id}
    Boot OS And Enter Root Shell    ${os_id}
    ${out_cbmem}=    Execute Command In Terminal    cbmem -1    timeout=180s
    Should Match Regexp    ${out_cbmem}    FACB:\\s+1
    Should Match Regexp    ${out_cbmem}    measured boot:\\s+1
    Should Match Regexp    ${out_cbmem}    verified boot:\\s+1
    Exit From Root User

Boot OS And Enter Root Shell
    [Documentation]    Boots a specified OS and prepares for running commands as
    ...    root
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User

Match BtG Option State
    [Arguments]    ${submenu}    ${wanted_option}    ${varname}    ${second_option}=None
    VAR    ${final_match}=    ${False}

    ${index1}=    Get Index From List    ${submenu}    ${wanted_option}
    IF    ${index1} != -1
        IF    '${second_option}' != 'None'
            ${index2}=    Evaluate    ${index1} + 1
            IF    ${index2} < len(${submenu})
                ${final_match}=    Run Keyword And Return Status
                ...    Should Contain
                ...    '${submenu}[${index2}]'
                ...    '${second_option}'
            END
        ELSE
            VAR    ${final_match}=    ${True}
        END
    END

    IF    ${final_match}
        VAR    ${${varname}}=    ${True}    scope=TEST
    END
