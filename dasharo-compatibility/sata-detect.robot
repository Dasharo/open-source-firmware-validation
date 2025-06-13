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
# TODO
# SAT001.001 SATA support in firmware

SAT001.201 SATA support in OS (Ubuntu)
    [Documentation]    This test aims to verify that SATA is detected from OS
    ...    by using smartctl.
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Depends On    ${SATA_SUPPORT}

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Detect Or Install Package    smartmontools

    ${lsblk_out}=    Execute Command In Terminal    lsblk -d -o NAME -n
    @{disks}=    Split String    ${lsblk_out}    \n

    FOR    ${disk}    IN    @{disks}
        ${out}=    Execute Command In Terminal    sudo smartctl -i /dev/${disk}
        Log    ${out}
        ${sata_present}=    Run Keyword And Return Status    Should Contain    ${out}    SATA Version is:
        Pass Execution If    '${sata_present}' == 'True'    'SATA disk found, passing test'
    END

    Fail    No SATA disk was found, failing test

# TODO
# SAT001.003 SATA support in OS (Windows)

SAT001.401 SATA support in OS (ESXi)
    [Documentation]    Verify that a SATA storage device is detected by the ESXi system
    ...    and optionally check SMART data if available.
    ...    Previous IDs: SAT001.011
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    SAT001.401 not supported
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli storage core device list
    Should Contain Any    ${out}    Vendor: ATA    Vendor: SATA
    Should Contain    ${out}    Is Boot Device: true
