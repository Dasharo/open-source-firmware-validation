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
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
MBO001.001 Measured Boot support (Ubuntu)
    [Documentation]    Check whether Measured Boot is functional and
    ...    measurements are stored into the TPM.a.
    Skip If    not ${MEASURED_BOOT_SUPPORT}    MBO001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MBO001.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    tpm2-tools
    ${out_tpm2_pcrread}=    Execute Command In Terminal    tpm2_pcrread
    ${matching_lines}=    Get Lines Matching Regexp    ${out_tpm2_pcrread}    .*([0-3]) :.*
    Should Not Be Empty    ${matching_lines}
    Should Not Contain    ${matching_lines}    0x0000000000000000000000000000000000000000
    Should Not Contain    ${matching_lines}    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
