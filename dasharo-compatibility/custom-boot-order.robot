*** Settings ***
Resource            ../lib/platform/power.robot
Resource            ../lib/platform/boot.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CBO001.101 Custom Boot Order (EDK2 UEFI)
    [Documentation]    Check if customization of Boot Order persists and
    ...    correct OS boots.
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}

    Power Cycle Into Firmware Setup
    Set Selected OS As First In Boot Order Via EDK2    ${ENV_ID_UBUNTU}
    Verify Selected OS As First In Boot Order Via EDK2    ${ENV_ID_UBUNTU}

    Power Cycle Into Firmware Setup
    Set Selected OS As First In Boot Order Via EDK2    ${ENV_ID_WINDOWS}
    Verify Selected OS As First In Boot Order Via EDK2    ${ENV_ID_WINDOWS}

CBO001.102 Custom boot order (SeaBIOS)
    [Documentation]    Check whether the custom boot order is respected in SeaBIOS.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CBO001.102 not supported
    Execute Manual Step    [1/3] Power on the DUT.
    Execute Manual Step    [2/3] Press BOOT_MENU_KEY key to display boot menu.
    Execute Manual Step    [3/3] Compare the listed devices with the desired boot order.
    VAR    ${msg}=
    ...    [Expected result] Priority will be given to the system booted from SSD connected by mSATA.
    ...    If above-mentioned SSD does not include system, it will be booted from USB.
    ...    If it either not include system, it will be booted from SSD connected by SATA 2.5.
    ...    If there is only one bootable medium the platform shall boot from it.
    ...    separator=${SPACE}
    Execute Manual Step    ${msg}
