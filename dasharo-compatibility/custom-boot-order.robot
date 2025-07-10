*** Settings ***
Resource            ../lib/platform/power.robot
Resource            ../lib/platform/boot.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CBO001.101 Custom Boot Order (EDK2)
    [Documentation]    Check if customization of Boot Order persists and
    ...    correct OS boots.
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}

    Power Cycle Into Firmware Setup
    Set Selected OS As First In Boot Order Via EDK2    ${ENV_ID_UBUNTU}
    Verify Selected OS As First In Boot Order Via EDK2    ${ENV_ID_UBUNTU}

    Power Cycle Into Firmware Setup
    Set Selected OS As First In Boot Order Via EDK2    ${ENV_ID_WINDOWS}
    Verify Selected OS As First In Boot Order Via EDK2    ${ENV_ID_WINDOWS}
