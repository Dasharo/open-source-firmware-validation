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

Default Tags        automated


*** Test Cases ***
SAT001.001 SATA support in firmware
    [Documentation]    This test aims to verify that SATA is detected from FW
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Depends On    ${SATA_SUPPORT}

    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${boot_manager_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Boot Maintenance Manager

    ${bff_manager_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${boot_manager_menu}
    ...    Boot From File

    Count Arrows Down To Reach The Option    /Sata    # this KWD return error if string not found

SAT001.201 SATA support in OS (Ubuntu)
    [Documentation]    This test aims to verify that SATA is detected from Ubuntu
    ...    by using smartctl.
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Depends On    ${SATA_SUPPORT}
    SATA Support In OS    ${ENV_ID_UBUNTU}

# TODO
# SAT001.003 SATA support in OS (Windows)

SAT001.205 SATA support in OS (XCP-NG)
    [Documentation]    Verify SATA support via smartctl in XCP-NG.
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Depends On    ${TESTS_IN_XCP_NG_SUPPORT}
    Depends On    ${SATA_SUPPORT}

    Power On
    Boot And Login To OS    ${ENV_ID_XCP_NG}

    ${lsblk_out}=    Execute Command In Terminal    lsblk -d -o NAME -n
    @{disks}=    Split String    ${lsblk_out}    \n
    VAR    ${sata_found}=    False

    FOR    ${disk}    IN    @{disks}
        ${out}=    Execute Command In Terminal    sudo smartctl -i /dev/${disk}
        Log    ${out}
        ${sata_present}=    Run Keyword And Return Status    Should Contain    ${out}    SATA
        IF    ${sata_present}
            VAR    ${sata_found}=    True
        END
    END

    IF    ${sata_found}    Pass Execution    SATA disk found, passing test
    Fail    No SATA disk was found, failing test
# TODO
# SAT001.003 SATA support in OS (Windows)

SAT001.301 SATA support in OS (Windows)
    [Documentation]    This test aims to verify that SATA is detected from Windows
    ...    by using powershell.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SAT001.301 not supported
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Depends On    ${SATA_SUPPORT}

    Power On
    Boot And Login To OS    ${ENV_ID_WINDOWS}
    ${output}=    Execute Command In Terminal
    ...    Get-PhysicalDisk | Select-Object DeviceID, MediaType, BusType, Model
    Should Contain    ${output}    SATA

SAT001.401 SATA support in OS (ESXi)
    [Documentation]    Verify that a SATA storage device is detected by the ESXi system
    ...    and optionally check SMART data if available.
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    SAT001.401 not supported
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Boot And Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli storage core device list
    Should Contain Any    ${out}    Vendor: ATA    Vendor: SATA
    Should Contain    ${out}    Is Boot Device: true


*** Keywords ***
SATA Support In OS
    [Arguments]    ${env_id}

    Power On
    Boot System Or From Connected Disk    ${env_id}
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
