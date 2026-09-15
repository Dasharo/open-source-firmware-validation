*** Settings ***
Documentation       Testing STM requires Ubuntu 26.04 with a patched kernel, as
...                 described in
...                 https://docs.dasharo.com/guides/smi-transfer-monitor/#preparing-to-launch-stm.
...                 A disk image with the required changes already applied is
...                 available on Clonezilla.

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/sleep-lib.robot
Resource            ../lib/tpm.robot
Resource            ../lib/trenchboot.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Tests in Firmware not supported
...                     AND
...                     Skip If    not ${STM_SUPPORT}    STM is not supported
...                     AND
...                     Enable STM
Suite Teardown      Run Keywords
...                     Disable STM
...                     AND
...                     Log Out And Close Connection
Test Setup          Restore Initial DUT Connection Method

Default Tags        automated


*** Variables ***
${STM_LAUNCHED_STRING}=     STM apparently launched
${STM_ERROR_STRING}=        EPTViolationHandler


*** Test Cases ***
STM001.201 STM dual-monitor treatment is active after boot (Ubuntu)
    [Documentation]    Verify The STM Loaded And The Dual Boot Monitor Treatment Is Active After Boot

    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    STM001.201 Not Supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Ensure STM Module Is Loaded

    ${dmesg_out}=    Execute Command In Terminal    dmesg | grep -i -E "stm|dual.monitor"
    Should Contain    ${dmesg_out}    ${STM_LAUNCHED_STRING}

STM002.201 SMI handler works correctly with the STM active (Ubuntu)
    [Documentation]    Verify That The SMI handler works correctly with the STM active

    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    STM002.201 Not Supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Ensure STM Module Is Loaded

    Execute Command In Terminal    efibootmgr -t 4

    ${dmesg_out}=    Execute Command In Terminal    dmesg | grep -i -E "stm|dual.monitor"
    Should Contain    ${dmesg_out}    ${STM_LAUNCHED_STRING}
    ${cbmem_out}=    Execute Command In Terminal    cbmem -1 | grep "(STM)"
    Should Not Contain    ${cbmem_out}    ${STM_ERROR_STRING}
    [Teardown]    Execute Command In Terminal    efibootmgr -t ${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}

STM004.201 Verify the platform remains stable under SMI load with the STM enforcing (Ubuntu)
    [Documentation]    Verify the platform remains stable under SMI load with the STM enforcing

    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    STM004.201 Not Supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Ensure STM Module Is Loaded

    ${dmesg_lines_before}=    Execute Command In Terminal    dmesg | wc -l

    TRY
        Generate SMI Load
    EXCEPT
        Fail    Platform became unresponsive under SMI load
    END

    ${new_dmesg}=    Execute Command In Terminal
    ...    dmesg | tail -n +$((${dmesg_lines_before} + 1))
    Should Not Match Regexp    ${new_dmesg}    (?i)(oops|panic|bug:|call trace|nmi watchdog|soft lockup)

    ${cbmem_out}=    Execute Command In Terminal    cbmem -1 | grep "(STM)"
    Should Not Contain    ${cbmem_out}    ${STM_ERROR_STRING}

    ${dmesg_out}=    Execute Command In Terminal    dmesg | grep -i -E "stm|dual.monitor"
    Should Contain    ${dmesg_out}    ${STM_LAUNCHED_STRING}

STM003.204 Verify a measured launch succeeds with the STM active (TrenchBoot)
    [Documentation]    Verify a measured launch succeeds with the STM active
    Skip If    '${ENV_ID_TRENCHBOOT}' not in ${TESTED_LINUX_DISTROS}    STM003.204 not supported
    Skip If    not ${TRENCHBOOT_SUPPORT}    STM003.201 Not Supported
    Skip If    not ${STM_WITH_TXT_SUPPORT}    STM003.201 Not Supported
    Skip If    not ${TESTS_IN_METATB_SUPPORT}    STM003.201 Not Supported

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_TRENCHBOOT}
    Trigger Measured Launch

    ${pcr_with_stm}=    Get PCRs State From Linux    17

    Disable STM

    Boot System Or From Connected Disk    ${ENV_ID_TRENCHBOOT}
    Trigger Measured Launch
    ${pcr_without_stm}=    Get PCRs State From Linux    17

    Should Not Be Equal    ${pcr_with_stm}    ${pcr_without_stm}
    ...    The STM measurement is not reflected in the PCR
    [Teardown]    Run Keyword If    '${TEST_STATUS}' != 'SKIP'    Enable STM


*** Keywords ***
Trigger Measured Launch
    [Documentation]    Triggers Measured Launch
    Read From Terminal Until    Press enter to boot the selected OS
    Press Key N Times And Enter    5    ${ARROW_DOWN}
    TrenchBoot Telnet Root Login

Ensure STM Module Is Loaded
    [Documentation]    Loads the dual_monitor_mode kernel module
    ${out}=    Execute Command In Terminal    modprobe dual_monitor_mode
    IF    '''${out}''' != '''${EMPTY}'''
        Fail    Failed to load dual_monitor_mode module
    END

Enable STM
    [Documentation]    Enables STM option
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${security_menu}    Enable SMI Transfer    ${TRUE}
    Save Changes And Reset

Disable STM
    [Documentation]    Disable STM option
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${security_menu}    Enable SMI Transfer    ${FALSE}
    Save Changes And Reset

Generate SMI Load
    [Documentation]    Constantly writes to the I/O port 0xB2 via /dev/port
    ...    for ``${duration}`` seconds.
    [Arguments]    ${duration}=60
    Execute Command In Terminal
    ...    timeout ${duration}s python3 -c "import os, itertools; fd = os.open('/dev/port', os.O_WRONLY); [os.pwrite(fd, b'\\x00', 0xb2) for _ in itertools.count()]"
    ...    ${{int($duration) + 300}}s
