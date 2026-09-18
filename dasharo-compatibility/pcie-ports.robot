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

Suite Setup         Prepare Test Suite
Suite Teardown      Run Keywords
...                     Run Keyword If    ${PCIE_BIFURCATION_SUPPORT}
...                     Set Bifurcation Layout In Firmware    ${BIFURCATION_X16_1}
...                     AND
...                     Log Out And Close Connection

Default Tags        automated


*** Variables ***
${BIFURCATION_X16_1}=       x16
${BIFURCATION_X8_2}=        x8x8
${BIFURCATION_X4_4}=        x4x4x4x4
${BIFURCATION_X4_X8_3}=     x4x4x8
${BIFURCATION_X8_X4_3}=     x8x4x4


*** Test Cases ***
PEX001.201 PCI Express card detection (Ubuntu)
    [Documentation]    Check whether the PCI Express extension card is enumerated correctly and can be detected from Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PEX001.201 not supported
    Execute Manual Step    [1/4] Power on the DUT with the PCI Express extension card plugged into the tested slot.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Open a terminal window and execute the following command: lspci
    Execute Manual Step
    ...    [Expected result] The output of the command should contain the plugged device name. The exact name and revision may be different depending on hardware configuration.

PEX002.201 PCI Express Bifurcation x16 (Ubuntu)
    [Documentation]    Check whether all PCIe slots are working properly
    ...    in x16 bifurcation layout.
    Skip If    not ${PCIE_BIFURCATION_SUPPORT}    PEX002.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PEX002.201 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PEX002.201 not supported
    Test Bifurcation Topology    ${BIFURCATION_X16_1}

PEX003.201 PCI Express Bifurcation Card Detection x16 (Ubuntu)
    [Documentation]    Check whether all devices in a PCIe bifurcation are
    ...    recognized properly in x16 bifurcation layout.
    Skip If    not ${PCIE_BIFURCATION_SUPPORT}    PEX003.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PEX003.201 not supported
    Test Bifurcation Card Disk Detection    ${BIFURCATION_X16_1}

PEX004.201 PCI Express Bifurcation x8x8 (Ubuntu)
    [Documentation]    Check whether all PCIe slots are working properly
    ...    in x8x8 bifurcation layout.
    Skip If    not ${PCIE_BIFURCATION_SUPPORT}    PEX004.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PEX004.201 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PEX004.201 not supported
    Test Bifurcation Topology    ${BIFURCATION_X8_2}

PEX005.201 PCI Express Bifurcation Card Detection x8x8 (Ubuntu)
    [Documentation]    Check whether all devices in a PCIe bifurcation are
    ...    recognized properly in x8x8 bifurcation layout.
    Skip If    not ${PCIE_BIFURCATION_SUPPORT}    PEX005.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PEX005.201 not supported
    Test Bifurcation Card Disk Detection    ${BIFURCATION_X8_2}

PEX006.201 PCI Express Bifurcation x4x4x4x4 (Ubuntu)
    [Documentation]    Check whether all PCIe slots are working properly
    ...    in x4x4x4x4 bifurcation layout.
    Skip If    not ${PCIE_BIFURCATION_SUPPORT}    PEX006.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PEX006.201 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PEX006.201 not supported
    Test Bifurcation Topology    ${BIFURCATION_X4_4}

PEX007.201 PCI Express Bifurcation Card Detection x4x4x4x4 (Ubuntu)
    [Documentation]    Check whether all devices in a PCIe bifurcation are
    ...    recognized properly in x4x4x4x4 bifurcation layout.
    Skip If    not ${PCIE_BIFURCATION_SUPPORT}    PEX007.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PEX007.201 not supported
    Test Bifurcation Card Disk Detection    ${BIFURCATION_X4_4}

PEX008.201 PCI Express Bifurcation x4x4x8 (Ubuntu)
    [Documentation]    Check whether all PCIe slots are working properly
    ...    in x4x4x4x4 bifurcation layout.
    Skip If    not ${PCIE_BIFURCATION_SUPPORT}    PEX008.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PEX008.201 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PEX008.201 not supported
    Test Bifurcation Topology    ${BIFURCATION_X4_X8_3}

PEX009.201 PCI Express Bifurcation Card Detection x4x4x8 (Ubuntu)
    [Documentation]    Check whether all devices in a PCIe bifurcation are
    ...    recognized properly in x4x4x4x4 bifurcation layout.
    Skip If    not ${PCIE_BIFURCATION_SUPPORT}    PEX009.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PEX009.201 not supported
    Test Bifurcation Card Disk Detection    ${BIFURCATION_X8_X4_3}

PEX010.201 PCI Express Bifurcation x8x4x4 (Ubuntu)
    [Documentation]    Check whether all PCIe slots are working properly
    ...    in x4x4x4x4 bifurcation layout.
    Skip If    not ${PCIE_BIFURCATION_SUPPORT}    PEX010.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PEX010.201 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PEX010.201 not supported
    Test Bifurcation Topology    ${BIFURCATION_X8_X4_3}

PEX011.201 PCI Express Bifurcation Card Detection x8x4x4 (Ubuntu)
    [Documentation]    Check whether all devices in a PCIe bifurcation are
    ...    recognized properly in x4x4x4x4 bifurcation layout.
    Skip If    not ${PCIE_BIFURCATION_SUPPORT}    PEX011.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PEX011.201 not supported
    Test Bifurcation Card Disk Detection    ${BIFURCATION_X8_X4_3}

PEX001.301 PCI Express card detection (Windows)
    [Documentation]    Check whether the PCI Express extension card is enumerated correctly and can be detected from Windows.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    PEX001.301 not supported
    Execute Manual Step    [1/5] Power on the DUT with the PCI Express extension card plugged into the tested slot.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Open Device Manager and find the plugged device.
    Execute Manual Step    [5/5] Note the device status.
    Execute Manual Step
    ...    [Expected result] The device status in the Device Manager should indicate that the device is working properly and has no problems.


*** Keywords ***
Test Bifurcation Card Disk Detection
    [Documentation]    Test if all NVMe drives in a bifurcation card appear
    ...    in lspci.
    [Arguments]    ${bifurcation_layout}
    ${bifurcation_count}=    Get Link Count Per PCI Express Slot    ${bifurcation_layout}

    # Get NVme drives from lspci
    ${lspci_output}=    Execute Command In Terminal
    ...    lspci -tv | grep '[+\\\\]-0[1357]\\.0-\\[[0-9a-fA-F]\\+\\]--.*NVMe' | wc -l
    IF    '${lspci_output}'!='${bifurcation_count}'
        Fail    NVMe drive count does not match bifurcation layout!
    END

Test Bifurcation Topology
    [Documentation]    Set a specified bifurcation layout and verify
    ...    whether resulting PCIe link topology matches the setting.
    [Arguments]    ${bifurcation_layout}
    Set Bifurcation Layout In Firmware    ${bifurcation_layout}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Wait Until Keyword Succeeds    2x
    ...    2s
    ...    Verify Bifurcation In Ubuntu    ${bifurcation_layout}

Verify Bifurcation In Ubuntu
    [Documentation]    Verify whether PCIe link topology matches
    ...    selected bifurcation layout.
    [Arguments]    ${bifurcation_layout}
    ${bifurcation_count}=    Get Link Count Per PCI Express Slot    ${bifurcation_layout}

    # Get number of PCIe links from lspci
    ${lspci_output}=    Execute Command In Terminal
    ...    lspci -tv | grep '[+\\\\]-0[1357]\\.0-\\[[0-9a-fA-F]\\+\\]--' | wc -l

    # Calculate theoretical number of links from count of PCIe slots (and MCIO)
    ${pcie_slots_count}=    Get Length    ${PCIE_SLOTS}
    ${link_count}=    Evaluate    ${pcie_slots_count}*${bifurcation_count}

    # Print found PCIe links
    Log To Console    Found ${lspci_output} PCIe links. Should be: ${link_count}
    ${lspci_output_full}=    Execute Command In Terminal
    ...    lspci -tv | grep '[+\\\\]-0[1357]\\.0-\\[[0-9a-fA-F]\\+\\]--'
    Log To Console    ${lspci_output_full}

    IF    '${lspci_output}'!='${link_count}'
        Fail    PCIe link count does not match bifurcation layout!
    END

Set Bifurcation Layout In Firmware
    [Documentation]    Set specified bifurcation layout in firmware.
    [Arguments]    ${bifurcation_layout}

    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo Submenu    ${setup_menu}    Platform Setup Menu

    FOR    ${pcie_slot}    IN    @{PCIE_SLOTS}
        FOR    ${_}    IN RANGE    0    4    1
            ${option_set}=    Set Option State
            ...    ${dasharo_menu}
            ...    ${pcie_slot} bifurcation
            ...    ${bifurcation_layout}

            # Reload menu state after changing bifurcation option
            ${dasharo_menu}=    Reenter Menu And Return Construction    submenu_opt_only=${TRUE}
            IF    '${option_set}'!='${TRUE}'    BREAK
        END

        # Check if option is set
        IF    '${option_set}'=='${TRUE}'
            Fail    Failed to set ${pcie_slot} bifurcation to ${bifurcation_layout}.
        END
        Log To Console    ${pcie_slot} bifurcation set to ${bifurcation_layout}
    END

    # Exit to setup menu
    Exit From Current Menu
    Exit From Current Menu
    Save Changes And Reset

Get Link Count Per PCI Express Slot
    [Documentation]    Returns number of PCIe links per PCIe slot
    ...    based on the bifurcation layout
    [Arguments]    ${bifurcation_layout}
    IF    '${bifurcation_layout}'=='${BIFURCATION_X16_1}'
        VAR    ${bifurcation_count}=    1
    ELSE IF    '${bifurcation_layout}'=='${BIFURCATION_X8_2}'
        VAR    ${bifurcation_count}=    2
    ELSE IF    '${bifurcation_layout}'=='${BIFURCATION_X4_4}'
        VAR    ${bifurcation_count}=    4
    ELSE IF    '${bifurcation_layout}'=='${BIFURCATION_X4_X8_3}'
        VAR    ${bifurcation_count}=    3
    ELSE IF    '${bifurcation_layout}'=='${BIFURCATION_X8_X4_3}'
        VAR    ${bifurcation_count}=    3
    ELSE
        Fail    Wrong bifurcation layout!
    END
    RETURN    ${bifurcation_count}
