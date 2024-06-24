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
    Execute Command In Terminal    shopt -s extglob
    ${hashes}=    Execute Command In Terminal
    ...    grep . /sys/class/tpm/tpm0/pcr-sha@(1|256)/[0-3]
    Should Not Contain Any    ${hashes}
    ...    0000000000000000000000000000000000000000
    ...    FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    ...    No such file or directory
    ...    error
    ...    ignore_case=${TRUE}


*** Keywords ***
Measured Boot Suite Setup
    Prepare Test Suite
    Skip If    not ${MEASURED_BOOT_SUPPORT}    Measured boot is not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Tests in Ubuntu are not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    tpm2-tools
