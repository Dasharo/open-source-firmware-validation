*** Settings ***
Library     Collections
Library     OperatingSystem
Library     String


*** Variables ***
# Reconstruction of these PCRs is not critical. I.e. if their value fails to be
# reconstructed from the TPM log, it's expected, or is not a firmware issue.
# - 10:
#    - this PCR is not supposed to be extended by firmware
#    - it's the default PCR used by IMA implementation in Linux, which uses a separate log for its measurements
#    - if compiled into the kernel, IMA cannot be completely disabled at runtime
@{ACCEPTABLE_PCR_FAILS}=    10


*** Keywords ***
Get PCRs State From Linux
    [Documentation]    Returns list of strings containing
    ...    ["<path_to_pcr>:<hash>"]. Should be called when logged in Linux
    [Arguments]    ${pcr_glob}
    Execute Command In Terminal    shopt -s extglob
    # grep returns file path and it's content i.e.
    # "/sys/class/tpm/tpm0/pcr-sha1/0:", each in
    # new line
    ${hashes}=    Execute Command In Terminal
    ...    grep -H . /sys/class/tpm/tpm0/pcr-sha*/@(${pcr_glob})
    Should Not Contain    ${hashes}    No such file or directory
    ${pcr_state}=    Split To Lines    ${hashes}
    RETURN    ${pcr_state}

Save Event Log
    [Documentation]    Saves the TPM event log parsed by tpm2_eventlog to
    ...    ${OUTPUT DIR}/<name>.yaml, so that event logs from different boots
    ...    can be compared. Should be called when logged in Linux as root.
    [Arguments]    ${name}
    ${eventlog}=    Execute Command In Terminal
    ...    tpm2_eventlog /sys/kernel/security/tpm0/binary_bios_measurements
    Should Not Contain    ${eventlog}    ERROR: Unable to run tpm2_eventlog
    VAR    ${path}=    ${OUTPUT_DIR}${/}${name}.yaml
    Create File    ${path}    ${eventlog}
    Log    Event log saved to ${path}

Get Active PCR Banks
    [Documentation]    Returns the PCR banks the TPM driver exposes in sysfs,
    ...    for example ["sha256", "sha384"]. Should be called when logged in
    ...    Linux.
    ${out}=    Execute Command In Terminal
    ...    for d in /sys/class/tpm/tpm0/pcr-*/; do d=\${d%/}; echo "\${d##*/pcr-}"; done
    ${lines}=    Get Lines Matching Regexp    ${out}    [a-z0-9_]+
    @{banks}=    Split To Lines    ${lines}
    Should Not Be Empty    ${banks}    No PCR banks in /sys/class/tpm/tpm0
    RETURN    ${banks}

Get PCRs From Eventlog
    [Documentation]    Returns PCRs from Eventlog as a list of strings:
    ...    ["<pcr>:<hash>"] with spaces removed. Only the "<pcr> : 0x<hash>"
    ...    lines count, because the last bank runs to the end of the output.
    [Arguments]    ${eventlog}    ${sha}
    @{eventlog}=    Split To Lines    ${eventlog}
    ${sha_index_start}=    Get Index From List Regexp
    ...    ${eventlog}    ${sha}:
    Run Keyword And Return If    ${sha_index_start} == -1    Create List
    ${sha_index_start}=    Evaluate    ${sha_index_start} + 1
    ${sha_index_end}=    Get Index From List Regexp
    ...    ${eventlog}    sha[0-9]+:    start=${sha_index_start}
    IF    ${sha_index_end} == -1
        VAR    ${sha_index_end}=    ${NONE}
    END
    ${lines}=    Get Slice From List
    ...    ${eventlog}    ${sha_index_start}    ${sha_index_end}
    VAR    @{pcrs}=    @{EMPTY}
    FOR    ${line}    IN    @{lines}
        ${stripped_line}=    Remove String    ${line}    ${SPACE}
        ${is_pcr}=    Run Keyword And Return Status
        ...    Should Match Regexp    ${stripped_line}    ^[0-9]+:0x[0-9a-fA-F]+$
        IF    ${is_pcr}    Append To List    ${pcrs}    ${stripped_line}
    END
    RETURN    ${pcrs}

Get Index From List Regexp
    [Documentation]    Same as "Get Index From List" but with regexp
    [Arguments]    ${list}    ${regexp}    ${start}=0    ${end}=None
    ${list}=    Get Slice From List    ${list}    ${start}    ${end}
    FOR    ${index}    ${element}    IN ENUMERATE    @{list}    start=${start}
        ${found}=    Run Keyword And Return Status
        ...    Should Match Regexp    ${element}    ${regexp}
        IF    ${found} == ${TRUE}    RETURN    ${index}
    END
    RETURN    -1

Validate PCRs Against Event Log
    [Documentation]    Check that current PCRs values match result of replaying
    ...    some binary event log, in each bank of \${banks}. By default the
    ...    banks are the active ones, and a bank the log has no PCRs in is
    ...    logged as a warning. A bank passed in \${banks} must have PCRs in
    ...    the log. Fails when no PCR was compared at all.
    [Arguments]    ${binary_log_file}    ${banks}=${NONE}
    ${tpm2_eventlog}=    Execute Command In Terminal
    ...    tpm2_eventlog ${binary_log_file}
    Should Not Contain    ${tpm2_eventlog}    ERROR: Unable to run tpm2_eventlog
    VAR    ${required}=    ${{$banks is not None}}
    IF    not ${required}
        ${banks}=    Get Active PCR Banks
    END
    VAR    @{acceptable_invalid_prcs}=    @{EMPTY}
    VAR    @{critical_invalid_pcrs}=    @{EMPTY}
    VAR    ${compared}=    ${0}
    FOR    ${algo}    IN    @{banks}
        ${eventlog_pcrs}=    Get PCRs From Eventlog    ${tpm2_eventlog}    ${algo}
        IF    not $eventlog_pcrs and ${required}
            Fail    ${binary_log_file} has no PCRs in the ${algo} bank
        ELSE IF    not $eventlog_pcrs
            Log    ${binary_log_file} has no PCRs in the active ${algo} bank    WARN
        END
        FOR    ${pcr_element}    IN    @{eventlog_pcrs}
            ${pcr}    ${hash}=    Split String    ${pcr_element}    separator=:
            ${sha_hash}=    Execute Command In Terminal
            ...    cat /sys/class/tpm/tpm0/pcr-${algo}/${pcr}
            ${status}=    Run Keyword And Return Status
            ...    Should Be Equal As Strings    ${hash}    0x${sha_hash}    ignore_case=${TRUE}
            ${compared}=    Evaluate    ${compared} + 1
            IF    not ${status}
                VAR    &{pcr_fail}=    pcr=pcr${pcr}-${algo}    log_hash=${hash}    real_hash=${sha_hash}
                IF    '${pcr}' in $ACCEPTABLE_PCR_FAILS
                    Append To List    ${acceptable_invalid_prcs}    ${pcr_fail}
                ELSE
                    Append To List    ${critical_invalid_pcrs}    ${pcr_fail}
                END
            END
        END
    END
    IF    ${compared} == 0
        Fail    ${binary_log_file} replays no PCRs in the banks ${banks}
    END
    IF    @{acceptable_invalid_prcs}
        Log    Invalid PCRs found, but they don't necessarily mean a firmware issue    WARN
        Log To Console    ${acceptable_invalid_prcs}
    END
    IF    @{critical_invalid_pcrs}
        Log    Invalid PCRs found, and they indicate a firmware issue    WARN
        Log To Console    ${critical_invalid_pcrs}
        Fail    Critical PCRs are invalid
    END

Validate Expected TPM Version Via Sysfs
    [Documentation]    Checks if detected major TPM version matches the expected
    ...    value.
    ${tpm_ver}=    Execute Command In Terminal    cat /sys/class/tpm/tpm0/tpm_version_major
    IF    '${TPM_SUPPORTED_VERSION}' != '${tpm_ver}'
        Fail    Platform TPM version mismatch
    END

Validate Expected TPM Chip Via Cbmem Console Log
    [Documentation]    Check that correct TPM chip is found while FW boots
    ${tpm_chip_found}=    Execute Command In Terminal
    ...    cbmem -1 | grep -iE "Found TPM|Initialized TPM device"
    Should Contain    ${tpm_chip_found}    ${TPM_EXPECTED_CHIP}

Validate Expected TPM Version Via Cbmem TPM Eventlog
    [Documentation]    Check if appropriate log is created by FW
    ${out}=    Execute Command In Terminal    cbmem -L
    IF    '${TPM_SUPPORTED_VERSION}' == '1'
        Should Contain    ${out}    TCPA log
    ELSE IF    '${TPM_SUPPORTED_VERSION}' == '2'
        Should Contain    ${out}    TPM2 log
    ELSE
        Fail    Invalid expected version, please verify config
    END

Verify Presence Of TPM Via Sysfs
    [Documentation]    Use sysfs interface to detect presence of TPM
    ...    in the system.
    ${tpm_presence}=    Execute Command In Terminal    test -d /sys/class/tpm/tpm0 && echo "Found TPM"
    Should Contain    ${tpm_presence}    Found TPM

Verify Presence Of Any PCRs Via Sysfs
    [Documentation]    Check sysfs interface for presence of any PCR
    ${pcr_state}=    Execute Command In Terminal    ls /sys/class/tpm/tpm0/pcr-sha* &>/dev/null && echo "Found PCRs"
    Should Contain    ${pcr_state}    Found PCRs

Enter The TCG Configuration Menu
    [Documentation]    Following a reboot triggered outside of this KWD,
    ...    enters the TCG or TCG2 Configuration menu.
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_manager_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager

    IF    'TCG2 Configuration' in '''${device_manager_menu}'''
        Enter Submenu From Snapshot
        ...    ${device_manager_menu}
        ...    TCG2 Configuration
    ELSE
        Enter Submenu From Snapshot
        ...    ${device_manager_menu}
        ...    TCG Configuration
    END

Check TPM PCR Banks State In FW
    [Documentation]    Build & return dictionary containing all existing PCR bank options
    ...    and state of each.
    VAR    ${checkpoint}=    F9=Reset to Defaults
    Read From Terminal Until    ${checkpoint}
    Press Key N Times    1    ${ARROW_UP}
    ${tpm2_operation_menu}=    Read From Terminal Until    ${checkpoint}
    ${tgc2_menu_protocol_part}=    Parse Menu Snapshot Into Construction    ${tpm2_operation_menu}    6    1
    ${sha_banks}=    Get Matches    ${tgc2_menu_protocol_part}    PCR Bank: SHA*
    VAR    &{sha_state}=    &{EMPTY}
    FOR    ${item}    IN    @{sha_banks}
        IF    'PCR Bank: SHA1 [' in '${item}'
            IF    '[X]' in '${item}'
                Set To Dictionary    ${sha_state}    SHA1=${TRUE}
            ELSE IF    '[ ]' in '${item}'
                Set To Dictionary    ${sha_state}    SHA1=${FALSE}
            END
        ELSE IF    'PCR Bank: SHA256 [' in '${item}'
            IF    '[X]' in '${item}'
                Set To Dictionary    ${sha_state}    SHA256=${TRUE}
            ELSE IF    '[ ]' in '${item}'
                Set To Dictionary    ${sha_state}    SHA256=${FALSE}
            END
        ELSE IF    'PCR Bank: SHA384 [' in '${item}'
            IF    '[X]' in '${item}'
                Set To Dictionary    ${sha_state}    SHA384=${TRUE}
            ELSE IF    '[ ]' in '${item}'
                Set To Dictionary    ${sha_state}    SHA384=${FALSE}
            END
        ELSE IF    'PCR Bank: SHA512 [' in '${item}'
            IF    '[X]' in '${item}'
                Set To Dictionary    ${sha_state}    SHA512=${TRUE}
            ELSE IF    '[ ]' in '${item}'
                Set To Dictionary    ${sha_state}    SHA512=${FALSE}
            END
        ELSE IF    'PCR Bank: SM3_256 [' in '${item}'    # highly experimental
            IF    '[X]' in '${item}'
                Set To Dictionary    ${sha_state}    SM3_256=${TRUE}
            ELSE IF    '[ ]' in '${item}'
                Set To Dictionary    ${sha_state}    SM3_256=${FALSE}
            END
        END
    END
    RETURN    ${sha_state}

Get TPM PCR Banks Menu Positions In FW
    [Documentation]    Returns dictionary containing menu positions od PCR bank options.
    ...    Requires dictionary containing available bank names as keys as an argument.
    [Arguments]    ${pcr_banks}
    VAR    &{sha_positions}=    &{EMPTY}
    FOR    ${bank_name}    IN    @{pcr_banks}
        VAR    ${real_bank_name}=    PCR Bank:    ${bank_name}    separator=${SPACE}
        ${position}=    Search For Option Not Visible After Entering Menu    ${real_bank_name}
        Set To Dictionary    ${sha_positions}    ${bank_name}=${position}
    END
    RETURN    ${sha_positions}

Toggle TPM PCR Bank In FW
    [Documentation]    Toggle PCR bank option at given position by pressing Enter key.
    [Arguments]    ${bank_positions}    ${bank_name}
    Press Key N Times And Enter    ${bank_positions["${bank_name}"]}+1    ${ARROW_DOWN}
    RETURN    ${bank_name}

Single PCR Bank Confirm In FW Popup
    [Documentation]    When only one active PCR bank is allowed and at least two
    ...    PCR baks are selected, pop-up is displayed after reset, to select single
    ...    active PCR bank.
    ...    Parse pop-up bank list and press corresponding key to select active bank.
    [Arguments]    ${bank_to_be_confirmed}
    Read From Terminal Until    Multiple PCR banks have been selected, but the current TPM
    Read From Terminal Until    only one active bank at a time.
    ${slice}=    Read From Terminal Until    Press ESC to stay with the previously active bank.
    @{matches}=    Get Regexp Matches    ${slice}    ([0-9])\\)\\sSHA[0-9]+
    Should Not Be Empty    ${matches}    Can not parse list of PCR banks & keys from pop-up.
    VAR    &{bank_keys}=    &{EMPTY}
    FOR    ${match}    IN    @{matches}
        @{split}=    Split String    ${match}    \)${SPACE}
        VAR    ${bank_name}=    ${split[1]}
        Set To Dictionary    ${bank_keys}    ${bank_name}=${split[0]}
    END
    Press Key N Times    1    ${bank_keys["${bank_to_be_confirmed}"]}

Prepare Dictionary Containing Expected PCRs State
    [Documentation]    Generate dictionary describing expected PCRs menu state
    ...    for platforms with multiple PCR bank support and for those with single.
    ...    Requires already generated dictionary on input, it's size and keys are
    ...    reused.
    [Arguments]    ${current}    ${active}    ${to_set}
    Variable Should Exist    ${TPM_MULTIPLE_BANK_SUPPORT}
    &{expected}=    Copy Dictionary    ${current}
    IF    ${TPM_MULTIPLE_BANK_SUPPORT} == ${FALSE}
        Set To Dictionary    ${expected}    ${active}=${FALSE}
        Set To Dictionary    ${expected}    ${to_set}=${TRUE}
    ELSE
        Set To Dictionary    ${expected}    ${active}=${TRUE}
        Set To Dictionary    ${expected}    ${to_set}=${TRUE}
    END
    RETURN    ${expected}
