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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Measured Boot Suite Setup
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
MBO001.001 Measured Boot support (Ubuntu)
    [Documentation]    Check whether Measured Boot is functional and
    ...    measurements are stored into the TPM.
    Execute Command In Terminal    shopt -s extglob
    ${hashes}=    Execute Command In Terminal
    ...    grep . /sys/class/tpm/tpm0/pcr-sha@(1|256)/[0-3]
    Should Not Contain Any    ${hashes}
    ...    0000000000000000000000000000000000000000
    ...    FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    ...    No such file or directory
    ...    error
    ...    ignore_case=${TRUE}

MBO002.001 Check if event log PCRs match actual values (Ubuntu 22.04)
    [Documentation]    Check whether PCRs values calculated from event log match
    ...    actual PCRs values
    ${tpm2_eventlog}=    Execute Command In Terminal
    ...    tpm2_eventlog /sys/kernel/security/tpm0/binary_bios_measurements
    FOR    ${algo}    IN    sha1    sha256
        ${eventlog_pcrs}=    Get PCRs From Eventlog    ${tpm2_eventlog}    ${algo}
        FOR    ${pcr_element}    IN    @{eventlog_pcrs}
            ${pcr}    ${hash}=    Split String    ${pcr_element}    separator=:
            ${sha_hash}=    Execute Command In Terminal
            ...    cat /sys/class/tpm/tpm0/pcr-${algo}/${pcr}
            Should Contain    ${hash}    ${sha_hash}    ignore_case=${TRUE}
        END
    END


*** Keywords ***
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

Measured Boot Suite Setup
    Prepare Test Suite
    Skip If    not ${MEASURED_BOOT_SUPPORT}    Measured boot is not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Tests in Ubuntu are not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    tpm2-tools
