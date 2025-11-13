*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
...                     AND    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
...                     AND    Depends On    ${SATA_SUPPORT}
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
SAT001.301 SATA support in OS (Windows)
    [Documentation]    This test aims to verify that SATA is detected from Windows
    ...    by using powershell.
    Power On
    Login To OS    ${ENV_ID_WINDOWS}
    ${output}=    Execute Command In Terminal
    ...    Get-PhysicalDisk | Select-Object DeviceID, MediaType, BusType, Model
    Should Contain    ${output}    SATA
