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
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Force Tags          automated


*** Variables ***
${DEF_EXPECTED_NET_CONTROLLERS}=    ${EMPTY}
@{ESXI_ETH_PORTS}=                  @{EMPTY}
@{ESXI_ETH_SFP_PORTS}=              @{EMPTY}


*** Test Cases ***
ETH001.401 All expected NET controllers detected (ESXi)
    [Documentation]    Verify that all expected onboard or add-in Ethernet controllers
    ...    are detected and reported by ESXi with valid driver, link, and MAC.
    ...    Previous IDs: ETH001.011
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    ETH001.401 not supported
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli network nic list
    ${lines}=    Split To Lines    ${out}
    FOR    ${element}    IN    @{ETH_PORTS}
        ${new_element}=    Replace String    ${element}    -    :
        Append To List    ${ESXI_ETH_PORTS}    ${new_element}
    END
    FOR    ${element}    IN    @{ETH_SFP_PORTS}
        ${new_element}=    Replace String    ${element}    -    :
        Append To List    ${ESXI_ETH_SFP_PORTS}    ${new_element}
    END
    Should Contain All    ${out}    @{ESXI_ETH_PORTS}
    Should Contain All    ${out}    @{ESXI_ETH_SFP_PORTS}

ETH001.205 All Expected NET Controllers Detected (XCP-NG)
    [Documentation]    This test verifies that all expected onboard or add-in
    ...    Ethernet network controllers are correctly detected in XCP-NG OS.
    ...    Previous IDs: ETH001.010
    Skip If    not ${TESTS_IN_XCP_NG_SUPPORT}    ETH001.203 not supported
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    ETH001.203 not supported
    All Expected NET Controllers Detected    ${ENV_ID_XCP_NG}    ${DEF_EXPECTED_NET_CONTROLLERS}

ETH002.205 All Expected SFP Controllers Detected (XCP-NG)
    [Documentation]    This test verifies that all expected onboard SFP network
    ...    controllers are correctly detected by the XCP-NG OS.
    ...    Previous IDs: ETH002.010
    Skip If    not ${TESTS_IN_XCP_NG_SUPPORT}    ETH002.203 not supported
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    ETH002.203 not supported
    All Expected SFP Controllers Detected    ${ENV_ID_XCP_NG}    ${DEF_EXPECTED_NET_CONTROLLERS}


*** Keywords ***
All Expected NET Controllers Detected
    [Documentation]    Power on, boot, login, and verify that all expected Ethernet controllers are detected.
    [Arguments]    ${env_id}    @{expected_controllers}

    Power On
    Login To OS    ${env_id}

    ${lspci_out}=    Execute Linux Command    lspci -QQnn | grep -i ethernet
    Log    ${lspci_out}

    FOR    ${controller}    IN    @{expected_controllers}
        Should Contain    ${lspci_out}    ${controller}    Missing expected Ethernet controller: ${controller}
    END

All Expected SFP Controllers Detected
    [Documentation]    Power on, boot, login, and verify that all expected SFP controllers are detected.
    [Arguments]    ${env_id}    @{expected_sfp}

    Power On
    Login To OS    ${env_id}

    ${lspci_out}=    Execute Linux Command    lspci -QQnn | grep -i SFP
    Log    ${lspci_out}

    FOR    ${sfp}    IN    @{expected_sfp}
        Should Contain    ${lspci_out}    ${sfp}    Missing expected SFP controller: ${sfp}
    END
