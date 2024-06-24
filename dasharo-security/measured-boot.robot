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
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
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
MBO001.001 Measured Boot support (Ubuntu 20.04)
    [Documentation]    Check whether Measured Boot is functional and
    ...    measurements are stored into the TPM.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Tests in Ubuntu are not supported
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
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Tests in Ubuntu are not supported
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

MBO003.001 Changing Secure Boot certificate changes only PCR-7
    [Documentation]    Check if changes to Secure Boot certificates influence
    ...    PCR-7 value and only PCR-7
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Tests in firmware are not supported
    Restore Secure Boot Defaults
    ${sb_menu}=    Reenter Menu And Return Construction
    Disable Secure Boot    ${sb_menu}
    Save Changes And Reset
    Make Sure That Network Boot Is Enabled
    Power On
    # Using DTS here because Ubuntu enrolls DTX certificates
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    ${default_hashes}=    Execute Command In Terminal
    ...    grep . /sys/class/tpm/tpm0/pcr-sha*/*
    Should Not Contain    ${default_hashes}    No such file or directory
    ${default_hashes}=    Split To Lines    ${default_hashes}
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${sb_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    ${sb_menu}=    Enter Submenu From Snapshot And Return Construction    ${sb_menu}    DBX Options
    ${sb_menu}=    Enter Submenu From Snapshot And Return Construction    ${sb_menu}    Delete Signature
    Enter Submenu From Snapshot    ${sb_menu}    Delete All Signature List
    Read From Terminal Until    Press 'Y' to delete signature list
    Write Into Terminal    Y
    Sleep    1s
    Save Changes And Reset
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    FOR    ${pcr_hash}    IN    @{default_hashes}
        ${pcr}    ${hash}=    Split String    ${pcr_hash}    separator=:
        ${new_hash}=    Execute Command In Terminal    cat ${pcr}
        IF    '/7' in '${pcr}'
            Should Not Be Equal    ${hash}    ${new_hash}
        ELSE
            Should Be Equal    ${hash}    ${new_hash}
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
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    tpm2-tools
