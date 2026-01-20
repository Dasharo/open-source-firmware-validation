*** Settings ***
Library             Collections
Library             Dialogs
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
...                     Prepare ZPB OS
...                     AND
...                     Setup ZPB
Suite Teardown      Run Keywords
...                     Teardown ZPB Test Suite
...                     AND
...                     Log Out And Close Connection
Test Setup          Run Keyword If    ${TESTS_IN_FIRMWARE_SUPPORT}
...                     Restore Initial DUT Connection Method


*** Test Cases ***
ZPB001.206 Make sure that cukinia tests pass
    [Documentation]    Run cukinia tests in ZPB OS
    Boot Zarhus OS
    Execute Command In Terminal With Sudo    cukinia

ZPB002.206 Make sure 'zarhus provision' verifies and creates checksum
    [Documentation]    Make sure that 'zarhus provision' verifies checksum of
    ...    file to be provisioned and creates checksum for provisioned firmware
    Boot Zarhus OS
    Execute Command In Terminal Should Succeed    sudo mount /dev/disk/by-label/zarhus-dtrpb /mnt
    Write Into Terminal    zarhus provision /mnt/${ZPB_FW_BOOTSTRAP_FILE}
    ${out}=    Wait For Checkpoint And Write    ${ENCRYPTED_STORAGE_PROMPT}    ${ENCRYPTED_STORAGE_PASSWORD}
    Should Contain    ${out}    checksum verified
    ${out}=    Wait For Checkpoint    ${KEY_CHOICE_PROMPT}
    ${choice}=    Get Regexp Matches
    ...    ${out}    .*\(\\d+\): ZPB_IBG.*    1
    Write Into Terminal    ${choice}[0]
    ${out}=    Read From Terminal Until Prompt

    Should Contain    ${out}    was provisioned successfully
    Should Contain    ${out}    Binary checksum:
    Execute Command In Terminal Should Succeed
    ...    diff <(sha256sum </mnt/${ZPB_FW_BOOTSTRAP_FILE}.provisioned) /mnt/${ZPB_FW_BOOTSTRAP_FILE}.provisioned.sha256

ZPB003.206 Make sure 'zarhus provision' fails if checksum is wrong
    [Documentation]    Make sure that 'zarhus provision' fails if file checksum
    ...    doesn't match
    Boot Zarhus OS
    Execute Command In Terminal Should Succeed    sudo mount /dev/disk/by-label/zarhus-dtrpb /mnt
    Execute Command In Terminal Should Succeed    cp /mnt/${ZPB_FW_BOOTSTRAP_FILE} /tmp/
    Execute Command In Terminal Should Succeed    sha256sum <<<"1" >/tmp/${ZPB_FW_BOOTSTRAP_FILE}.sha256
    ${out}    ${rc}=    Execute Command In Terminal And Return Output And RC
    ...    zarhus provision /tmp/${ZPB_FW_BOOTSTRAP_FILE}
    Should Contain    ${out}    checksum doesn't match
    Should Not Be Equal As Integers    ${rc}    0

ZPB004.206 Make sure 'zarhus provision' asks for checksum confirmation if it's missing
    [Documentation]    Make sure that 'zarhus provision' asks for checksum
    ...    confirmation if checksum file is missing
    Boot Zarhus OS
    Execute Command In Terminal Should Succeed    sudo mount /dev/disk/by-label/zarhus-dtrpb /mnt
    Execute Command In Terminal Should Succeed    cp /mnt/${ZPB_FW_BOOTSTRAP_FILE} /tmp/
    Write Into Terminal    zarhus provision /tmp/${ZPB_FW_BOOTSTRAP_FILE}
    ${out}=    Wait For Checkpoint And Write    [y|n]:    y
    Should Contain    ${out}    Please confirm that
    Should Contain    ${out}    checksum is correct
