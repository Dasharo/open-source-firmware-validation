*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
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
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
MBO001.001 Measured Boot support (Ubuntu 20.04)
    [Documentation]    Check whether Measured Boot is functional and
    ...    measurements are stored into the TPM.a.
    Skip If    not ${measured_boot_support}    MBO001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    MBO001.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Get cbmem from cloud
    ${out_cbmem}=    Execute Command In Terminal    cbmem -1 | grep PCR
    ${matching_lines}=    Get Lines Matching Regexp    ${out_cbmem}    ^\\?TPM: Digest of .* to PCR \\d+ measured$
    Should Not Be Empty    ${matching_lines}
