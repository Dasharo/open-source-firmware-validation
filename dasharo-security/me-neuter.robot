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
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${DASHARO_INTEL_ME_MENU_SUPPORT}    Dasharo Intel ME menu not supported
...                     AND
...                     Set UEFI Option    MeMode    Enabled
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
MNE001.001 ME disable option is available and has the correct default state
    [Documentation]    Check whether the Intel ME mode state after flashing the
    ...    platform with the Dasharo firmware is correct.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    MNE001.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${me_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Intel Management Engine Options
    ${state}=    Get Option State    ${me_menu}    Intel ME mode
    Should Be Equal    ${state}    Enabled

MNE002.201 ME disable option off works correctly (Ubuntu)
    [Documentation]    Check whether the Intel ME mode option in state Enabled
    ...    works correctly.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MNE002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    MNE002.201 not supported
    Intel ME Mode Option Enabled Works Correctly    ${ENV_ID_UBUNTU}

MNE003.201 ME disable option soft disable works correctly (Ubuntu)
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disabled (Soft) works correctly
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MNE003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    MNE003.201 not supported
    Intel ME Mode Option Disabled (Soft) Works Correctly    ${ENV_ID_UBUNTU}

MNE004.201 ME disable HAP bit option works correctly (Ubuntu)
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disabled (HAP) works correctly.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MNE004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    MNE004.201 not supported
    Intel ME Mode Option Disabled (HAP) Works Correctly    ${ENV_ID_UBUNTU}

MNE005.201 PCI Express 5.0 port is functional when ME disabled (Ubuntu)
    [Documentation]    This test aims to verify that Intel ME mode option in
    ...    state Disable (HAP) or Disable (Soft) does not break the PCIe 5.0
    ...    port functionality.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Execute Manual Step    [1/7] Power on the DUT
    Execute Manual Step    [2/7] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI Setup Menu
    Execute Manual Step
    ...    [3/7] Enter Dasharo System Features, then Intel Management Engine Options, set Intel ME mode to Disabled (HAP) or Disabled (Soft) and save
    Execute Manual Step    [4/7] Boot into Ubuntu and log in
    Execute Manual Step    [5/7] Open a terminal and run: sudo cbmem -1 > cbmem.log && lspci && lspci -t
    Execute Manual Step    [6/7] Check cbmem.log for the string: Loading HSPHY firmware from cache
    Execute Manual Step
    ...    [7/7] Confirm that PCI 00:01.0 (PCIe 5.0 bridge) and the device behind it are visible in lspci output and no HSPHY errors appear

MNE006.201 Check Intel ME version (Ubuntu)
    [Documentation]    This test aims to verify that the Intel ME version might
    ...    be read on the Operating System level. The read version should be
    ...    the same as in the release notes.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MNE006.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    MNE004.201 not supported
    Check Intel ME Version    ${ENV_ID_UBUNTU}

MNE002.202 Intel ME mode option Enabled works correctly (Fedora)
    [Documentation]    Check whether the Intel ME mode option in state Enabled
    ...    works correctly.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    MNE002.202 not supported
    Intel ME Mode Option Enabled Works Correctly    ${ENV_ID_FEDORA}

MNE003.202 Intel ME mode option Disabled (Soft) works correctly (Fedora)
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disabled (Soft) works correctly
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    MNE003.202 not supported
    Intel ME Mode Option Disabled (Soft) Works Correctly    ${ENV_ID_FEDORA}

MNE004.202 Intel ME mode option Disabled (HAP) works correctly (Fedora)
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disabled (HAP) works correctly.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    MNE004.202 not supported
    Intel ME Mode Option Disabled (HAP) Works Correctly    ${ENV_ID_FEDORA}

MNE005.202 PCI Express 5.0 port is functional when ME disabled (Fedora)
    [Documentation]    This test aims to verify that Intel ME mode option in
    ...    state Disable (HAP) or Disable (Soft) does not break the PCIe 5.0
    ...    port functionality.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Execute Manual Step    [1/7] Power on the DUT
    Execute Manual Step    [2/7] While the DUT is booting, hold the BIOS_SETUP_KEY to enter the UEFI Setup Menu
    Execute Manual Step
    ...    [3/7] Enter Dasharo System Features, then Intel Management Engine Options, set Intel ME mode to Disabled (HAP) or Disabled (Soft) and save
    Execute Manual Step    [4/7] Boot into Fedora and log in
    Execute Manual Step    [5/7] Open a terminal and run: sudo cbmem -1 > cbmem.log && lspci && lspci -t
    Execute Manual Step    [6/7] Check cbmem.log for the string: Loading HSPHY firmware from cache
    Execute Manual Step
    ...    [7/7] Confirm that PCI 00:01.0 (PCIe 5.0 bridge) and the device behind it are visible in lspci output and no HSPHY errors appear

MNE006.202 Check Intel ME version (Fedora)
    [Documentation]    This test aims to verify that the Intel ME version might
    ...    be read on the Operating System level. The read version should be
    ...    the same as in the release notes.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    MNE004.202 not supported
    Check Intel ME Version    ${ENV_ID_FEDORA}


*** Keywords ***
Intel ME Mode Option Enabled Works Correctly
    [Documentation]    Check whether the Intel ME mode option in state Enabled
    ...    works correctly.
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Set UEFI Option    MeMode    Enabled
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${result}=    Check ME Out
    Should Be Equal As Strings    ${result}    Enabled

Intel ME Mode Option Disabled (Soft) Works Correctly
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disabled (Soft) works correctly
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Set UEFI Option    MeMode    Disabled (Soft)
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${result}=    Check ME Out
    IF    '${result}' == 'Disabled'
        Log    ME Device Is Disabled (HAP/Soft) Or Does Not Exist    WARN
    ELSE
        Should Be Equal As Strings    ${result}    Disabled (Soft)
    END

Intel ME Mode Option Disabled (HAP) Works Correctly
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disabled (HAP) works correctly.
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Set UEFI Option    MeMode    Disabled (HAP)
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${result}=    Check ME Out
    IF    '${result}' == 'Disabled'
        Log    ME Device Is Disabled (HAP/Soft) Or Does Not Exist    WARN
    ELSE
        Should Be Equal As Strings    ${result}    Disabled (HAP)
    END

Check Intel ME Version
    [Documentation]    This test aims to verify that the Intel ME version might
    ...    be read on the Operating System level. The read version should be
    ...    the same as in the release notes.
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Set UEFI Option    MeMode    Enabled
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    cat /sys/class/mei/mei0/fw_ver
    Should Not Be Empty    ${out}
