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


*** Variables ***
@{ESXI_ETH_PORTS}=          @{EMPTY}
@{ESXI_ETH_SFP_PORTS}=      @{EMPTY}


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
