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
Resource            ../lib/performance/network.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
ETHPERF001.201 Check Performance of 2.5G Wired Network Interface (Ubuntu)
    [Documentation]    This test aims to verify the performance of Ethernet connection
    ...
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Depends On    ${ETH_PERF_PAIR_2_G} != @{EMPTY}
    Depends On    ${ETH_PORTS} != @{EMPTY}

    ${eth_ports_number}=    Get Length    ${ETH_PORTS}
    IF    '${eth_ports_number}' == '2'
        Skip If    '${DUT_CONNECTION_METHOD}' != 'Telnet'
        Pause Execution
        ...    [1/6] This is semi-manual execution, in next step there will be instruction checklist of DUT setup modification.
        ${lab_network_port}=    Get Value From User
        ...    [2/6] Enter DUT ethernet port number connected to lab network.    1

        VAR    @{manual_eth_loop_setup}=
        ...    1. On DUT, disconnect lab network ethernet cable from port ${lab_network_port}
        ...    2. On DUT, connect both ethernet ports with Cat 6a patch cable.
        VAR    @{manual_eth_restore}=
        ...    1. On DUT, disconnect Cat 6a patch cable from both ethernet ports
        ...    2. On DUT, reconnect lab network ethernet cable to port ${lab_network_port}

        @{dut_setup_values}=    Get Selections From User
        ...    [3/6] Follow the steps, mark each when done, click OK when finished.
        ...    ${manual_eth_loop_setup}[0]
        ...    ${manual_eth_loop_setup}[1]
        Lists Should Be Equal    ${manual_eth_loop_setup}    ${dut_setup_values}

        Pause Execution    [4/6] Click OK to begin speed testing.
    END

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${eth_1}=    Get From List    ${ETH_PERF_PAIR_2_G}    0
    ${eth_2}=    Get From List    ${ETH_PERF_PAIR_2_G}    1
    Configure Network Interfaces For Testing    ${eth_1}    ${eth_2}

    Test Network Performance    2.35
    IF    '${eth_ports_number}' == '2'
        Pause Execution
        ...    [5/6] This is semi-manual execution, in next step there will be instruction checklist of DUT setup modification.
        @{dut_restore_values}=    Get Selections From User
        ...    [6/6] Follow the steps, mark each when done, click OK when finished.
        ...    ${manual_eth_restore}[0]
        ...    ${manual_eth_restore}[1]
        Lists Should Be Equal    ${manual_eth_restore}    ${dut_restore_values}
    END

    # Teste second pair of thernet interfaces if provided
    IF    ${ETH_PERF_2_ND_PAIR_2_G} != @{EMPTY}
        ${eth_3}=    Get From List    ${ETH_PERF_2_ND_PAIR_2_G}    0
        ${eth_4}=    Get From List    ${ETH_PERF_2_ND_PAIR_2_G}    1
        Configure Network Interfaces For Testing    ${eth_3}    ${eth_4}
        Test Network Performance    2.35
    END

ETHPERF002.201 Check Performance of 10G Wired Network Interface (Ubuntu)
    [Documentation]    This test aims to verify the performance of Ethernet connection
    ...
    [Tags]    automated
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Depends On    ${ETH_PERF_PAIR_10_G} != @{EMPTY}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${eth_1}=    Get From List    ${ETH_PERF_PAIR_10_G}    0
    ${eth_2}=    Get From List    ${ETH_PERF_PAIR_10_G}    1
    Configure Network Interfaces For Testing    ${eth_1}    ${eth_2}
    Test Network Performance    9.35
