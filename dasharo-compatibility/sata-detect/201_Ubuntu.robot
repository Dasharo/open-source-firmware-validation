*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
...                     AND    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
...                     AND    Depends On    ${SATA_SUPPORT}
...                     AND    Init SAT Ubuntu
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
SAT001.201 SATA support in OS (Ubuntu)
    [Documentation]    This test aims to verify that SATA is detected from Ubuntu
    ...    by using smartctl.
    Check SATA Support In Linux


*** Keywords ***
Init SAT Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
