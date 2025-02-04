*** Settings ***
Library     OperatingSystem
Library     String


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

Get PCRs From Eventlog
    [Documentation]    Returns PCRs from Eventlog as a list of strings:
    ...    ["<pcr>:<hash>"] with spaces removed
    [Arguments]    ${eventlog}    ${sha}
    @{eventlog}=    Split To Lines    ${eventlog}
    ${sha_index_start}=    Get Index From List Regexp
    ...    ${eventlog}    ${sha}:
    Run Keyword And Return If    ${sha_index_start} == -1    Create List
    ${sha_index_start}=    Evaluate    ${sha_index_start} + 1
    ${sha_index_end}=    Get Index From List Regexp
    ...    ${eventlog}    sha[0-9]+:    start=${sha_index_start}
    IF    ${sha_index_end} == -1
        ${sha_index_end}=    Set Variable    ${NONE}
    END
    ${pcrs}=    Get Slice From List
    ...    ${eventlog}    ${sha_index_start}    ${sha_index_end}
    FOR    ${index}    ${element}    IN ENUMERATE    @{pcrs}
        ${stripped_element}=    Remove String    ${element}    ${SPACE}
        Set List Value    ${pcrs}    ${index}    ${stripped_element}
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
    ...    some binary event log
    [Arguments]    ${binary_log_file}
    ${tpm2_eventlog}=    Execute Command In Terminal
    ...    tpm2_eventlog ${binary_log_file}
    Should Not Contain    ${tpm2_eventlog}    ERROR: Unable to run tpm2_eventlog
    FOR    ${algo}    IN    sha1    sha256
        ${eventlog_pcrs}=    Get PCRs From Eventlog    ${tpm2_eventlog}    ${algo}
        FOR    ${pcr_element}    IN    @{eventlog_pcrs}
            ${pcr}    ${hash}=    Split String    ${pcr_element}    separator=:
            ${sha_hash}=    Execute Command In Terminal
            ...    cat /sys/class/tpm/tpm0/pcr-${algo}/${pcr}
            Should Contain    ${hash}    ${sha_hash}    ignore_case=${TRUE}
        END
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
    Get Cbmem From Cloud
    ${tpm_chip_found}=    Execute Command In Terminal    cbmem -1 | grep -i "Found TPM"
    Should Contain    ${tpm_chip_found}    ${TPM_EXPECTED_CHIP}

Validate Expected TPM Version Via Cbmem TPM Eventlog
    [Documentation]    Check if appropriate log is created by FW
    Get Cbmem From Cloud
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
