*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
SAT001.001 SATA should be visible from OS using smartctl
    [Documentation]    This test aims to verify that SATA is detected from OS
    ...    by using smartctl.
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Depends On    ${SATA_SUPPORT}

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    smartmontools

    ${lsblk_out}=    Execute Command In Terminal    lsblk -d -o NAME -n
    @{disks}=    Split String    ${lsblk_out}    \n

    FOR    ${disk}    IN    @{disks}
        ${out}=    Execute Command In Terminal    sudo smartctl -i /dev/${disk}
        Log    ${out}
        ${sata_present}=    Run Keyword And Return Status    Should Contain    ${out}    SATA Version is:
        Pass Execution If    '${sata_present}' == 'TRUE'    'SATA disk found, passing test'
    END

    Fail    No SATA disk was found, failing test

SAT001.002 SATA should be visible from OS using hwinfo
    [Documentation]    This test aims to verify that SATA is detected from OS
    ...    by using hwinfo.

    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Depends On    ${SATA_SUPPORT}

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    hwinfo

    ${out}=    Execute Command In Terminal    sudo hwinfo --disk --short
    Log    ${out}
    Should Contain    ${out}    SATA
