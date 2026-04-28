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
Resource            ../lib/bios/menus.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/linux.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite    AND
...                     Skip If    not ${APU_CONFIGURATION_MENU_SUPPORT}    APU configuration tests not supported.
Suite Teardown      Run Keywords
...                     Run Keyword If    '${SUITE_STATUS}' != 'SKIP'    Flash Firmware ${FW_FILE}
...                     AND
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
APU001.101 Check if apu2 watchdog option is available (EDK2 UEFI)
    [Documentation]    Check if the watchdog timer can be enabled in the apu2
    ...    configuration submenu.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    APU001.101 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${apu_menu}=    Enter Dasharo APU Configuration    ${setup_menu}
    Should Contain Match    ${apu_menu}    Enable watchdog*

APU002.101 Enable apu2 watchdog (EDK2 UEFI)
    [Documentation]    Enable apu2 watchdog with the default timeout and verify
    ...    that it resets the platform.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    APU002.101 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${apu_menu}=    Enter Dasharo APU Configuration    ${setup_menu}
    Set Option State    ${apu_menu}    Enable watchdog    ${TRUE}
    Save Changes And Reset
    Enter Setup Menu Tianocore And Return Construction
    # We're in the setup menu. Now just wait until the platform resets. Wait a
    # bit longer than the timeout to give the platform to actually reset.
    Set DUT Response Timeout    70s
    Read From Terminal Until    ${TIANOCORE_STRING}

APU003.101 Disable apu2 watchdog (EDK2 UEFI)
    [Documentation]    Disable the watchdog after enabling it to verify it does
    ...    not reset the platform anymore.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    APU003.101 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${apu_menu}=    Enter Dasharo APU Configuration    ${setup_menu}
    Set Option State    ${apu_menu}    Enable watchdog    ${FALSE}
    Save Changes And Reset
    Enter Setup Menu Tianocore And Return Construction
    # We're in the setup menu. Now just wait more than the default timeout to
    # make sure the watchdog does not reset the platform anymore.
    VAR    ${platform_has_reset}=    ${TRUE}
    Set DUT Response Timeout    70s
    TRY
        Read From Terminal Until    ${TIANOCORE_STRING}
    EXCEPT
        VAR    ${platform_has_reset}=    ${FALSE}
    END
    Should Be Equal    ${platform_has_reset}    ${FALSE}

APU004.101 Change apu2 watchdog timeout (EDK2 UEFI)
    [Documentation]    Enable apu2 watchdog with a higher timeout than default
    ...    and verify that it resets the platform.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    APU004.101 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${apu_menu}=    Enter Dasharo APU Configuration    ${setup_menu}
    Set Option State    ${apu_menu}    Enable watchdog    ${TRUE}
    # Refresh menu, now that watchdog timeout is available
    ${apu_menu}=    Reenter Menu And Return Construction
    Set Option State    ${apu_menu}    Watchdog timeout value    120
    Save Changes And Reset
    Enter Setup Menu Tianocore And Return Construction
    # We're in the setup menu. Wait 60s to make sure platform does not reset
    # after the default timeout of 60s.
    VAR    ${platform_has_reset}=    ${TRUE}
    Set DUT Response Timeout    60s
    TRY
        Read From Terminal Until    ${TIANOCORE_STRING}
    EXCEPT
        VAR    ${platform_has_reset}=    ${FALSE}
    END
    Should Be Equal    ${platform_has_reset}    ${FALSE}
    # Now wait another 70s to make sure the platform resets within 120s of boot.
    Set DUT Response Timeout    70s
    Read From Terminal Until    ${TIANOCORE_STRING}
    [Teardown]    Flash Firmware    ${FW_FILE}

APU005.201 Check if disabling CPB decreases performance (Ubuntu)
    [Documentation]    This Test Checks Whether Performance Changes With Core Performance Boost Disabled
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    APU005.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    APU005.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    APU005.201 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${apu_menu}=    Enter Dasharo Submenu    ${setup_menu}    Dasharo APU Configuration
    Set Option State    ${apu_menu}    Core Performance Boost    ${FALSE}
    Save Changes And Reset
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Execute Command In Terminal
    ...    dd if=/dev/zero of=/dev/null bs=64k count=1M 2>&1 | awk 'END{printf $(NF-3)}' > .dd_time
    ...    300
    ${first_check}=    Execute Command In Terminal    cat .dd_time
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${apu_menu}=    Enter Dasharo Submenu    ${setup_menu}    Dasharo APU Configuration
    Set Option State    ${apu_menu}    Core Performance Boost    ${TRUE}
    Save Changes And Reset
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Execute Command In Terminal
    ...    dd if=/dev/zero of=/dev/null bs=64k count=1M 2>&1 | awk 'END{printf $(NF-3)}' > .dd_time
    ...    300
    ${second_check}=    Execute Command In Terminal    cat .dd_time
    ${status}=    Evaluate    ${first_check} > ${second_check}
    Should Be True    ${status}

APU006.201 Disabling Enable PCIe power management features disables ASPM (Ubuntu)
    [Documentation]    Checks whether disabling PCIe power management features disables ASPM
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    APU006.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    APU006.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    APU006.201 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${apu_menu}=    Enter Dasharo Submenu    ${setup_menu}    Dasharo APU Configuration
    Set Option State    ${apu_menu}    Enable PCI Express power    ${FALSE}
    Save Changes And Reset
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${aspm_check}=    Execute Command In Terminal
    ...    echo -n `lspci -s 00:02 -vv | grep "ASPM Disabled" | wc -l`
    Should Be True    3 <= ${aspm_check} <= 5

APU007.201 Enabling Enable PCIe power management features enables ASPM (Ubuntu)
    [Documentation]    Checks whether "enabling PCIe power management features" enables ASPM
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    APU007.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    APU007.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    APU007.201 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${apu_menu}=    Enter Dasharo Submenu    ${setup_menu}    Dasharo APU Configuration
    Set Option State    ${apu_menu}    Enable PCI Express power    ${TRUE}
    Save Changes And Reset
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${aspm_check}=    Execute Command In Terminal
    ...    echo -n `lspci -s 00:02 -vv | grep "ASPM L1 Enabled" | wc -l`
    Should Be True    3 <= ${aspm_check} <= 5
