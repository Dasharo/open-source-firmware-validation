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
...                     AND
...                     Skip If    not ${CPU_TESTS_SUPPORT}    CPU tests not supported
...                     AND
...                     Reset UEFI Options To Defaults
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
ETH001.203 All Expected NET Controllers Detected (XCP-NG)
    [Documentation]    This test verifies that all expected onboard or add-in
    ...    Ethernet network controllers are correctly detected in XCP-NG OS.
    Skip If    not ${TESTS_IN_XCP_NG_SUPPORT}    ETH001.203 not supported
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    ETH001.203 not supported
    Execute Manual Step
    ...    All Expected NET Controllers Detected
    ...    ${ENV_ID_XCP_NG}
    ...    ${DEF_EXPECTED_NET_CONTROLLERS}*** Keywords ***

ETH002.203 All Expected SFP Controllers Detected (XCP-NG)
    [Documentation]    This test verifies that all expected onboard SFP network
    ...    controllers are correctly detected by the XCP-NG OS.
    Skip If    not ${TESTS_IN_XCP_NG_SUPPORT}    ETH002.203 not supported
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    ETH002.203 not supported
    Execute Manual Step    All Expected SFP Controllers Detected    ${ENV_ID_XCP_NG}    ${DEF_EXPECTED_SFP_CONTROLLERS}


*** Keywords ***
All Expected NET Controllers Detected
    [Documentation]    Power on, boot, login, and verify that all expected Ethernet controllers are detected.
    [Tags]    robot:private
    [Arguments]    ${env_id}    @{expected_controllers}

    Power On
    Boot System Or From Connected Disk    ${env_id}
    Login To Linux

    ${lspci_out}=    Execute Linux Command    lspci -nn | grep -i ethernet
    Log    ${lspci_out}

    FOR    ${controller}    IN    @{expected_controllers}
        Should Contain    ${lspci_out}    ${controller}    Missing expected Ethernet controller: ${controller}
    END

All Expected SFP Controllers Detected
    [Documentation]    Power on, boot, login, and verify that all expected SFP controllers are detected.
    [Tags]    robot:private
    [Arguments]    ${env_id}    @{expected_sfp}

    Power On
    Boot System Or From Connected Disk    ${env_id}
    Login To Linux

    ${lspci_out}=    Execute Linux Command    lspci -nn | grep -i SFP
    Log    ${lspci_out}

    FOR    ${sfp}    IN    @{expected_sfp}
        Should Contain    ${lspci_out}    ${sfp}    Missing expected SFP controller: ${sfp}
    END
