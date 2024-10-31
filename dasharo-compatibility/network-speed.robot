# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

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
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
ETHPERF001.001 Check Performance of 2.5G Wired Network Interface (Ubuntu)
    [Documentation]    This test aims to verify the performance of Ethernet connection
    Depends On    ${ETH_PERF_PAIR_2_G}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    iperf3

    ${eth_1}=    Get From List    ${ETH_PERF_PAIR_2_G}    0
    ${eth_2}=    Get From List    ${ETH_PERF_PAIR_2_G}    1
    Configure Network Interfaces For Testing    ${eth_1}    ${eth_2}
    Test Network Performance    2.35

ETHPERF002.001 Check Performance of 10G Wired Network Interface (Ubuntu)
    [Documentation]    This test aims to verify the performance of Ethernet connection
    Depends On    ${ETH_PERF_PAIR_10_G}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    iperf3

    ${eth_1}=    Get From List    ${ETH_PERF_PAIR_10_G}    0
    ${eth_2}=    Get From List    ${ETH_PERF_PAIR_10_G}    1
    Configure Network Interfaces For Testing    ${eth_1}    ${eth_2}
    Test Network Performance    9.35


*** Keywords ***
Test Network Performance
    [Documentation]    Tests network performance between two previously configured interfaces and compare with the given target bitrate
    [Arguments]    ${target_bitrate}
    Execute Command In Terminal    killall iperf3
    Execute Command In Terminal    ip netns exec ns_server iperf3 -s &
    ${out}=    Execute Command In Terminal    ip netns exec ns_client iperf3 -c 10.1.1.1
    ${bitrate}=    Extract Bitrate From Iperf Log    ${out}
    Should Be True    ${bitrate} >= ${target_bitrate}

    Execute Command In Terminal    killall iperf3
    Execute Command In Terminal    ip netns exec ns_client iperf3 -s &
    ${out}=    Execute Command In Terminal    ip netns exec ns_server iperf3 -c 10.1.1.2
    ${bitrate}=    Extract Bitrate From Iperf Log    ${out}
    Should Be True    ${bitrate} >= ${target_bitrate}

    Execute Command In Terminal    killall iperf3
    Execute Command In Terminal    ip netns del ns_server
    Execute Command In Terminal    ip netns del ns_client

Configure Network Interfaces For Testing
    [Documentation]    Configures network interfaces for iperf test
    [Arguments]    ${eth_1}    ${eth_2}
    Execute Command In Terminal    ip link set ${eth_1} mtu 9000
    Execute Command In Terminal    ip link set ${eth_2} mtu 9000
    Execute Command In Terminal    ip netns add ns_server
    Execute Command In Terminal    ip netns add ns_client
    Execute Command In Terminal    ip link set ${eth_1} netns ns_server
    Execute Command In Terminal    ip link set ${eth_2} netns ns_client
    Execute Command In Terminal    ip netns exec ns_server ip addr add dev ${eth_1} 10.1.1.1/24
    Execute Command In Terminal    ip netns exec ns_client ip addr add dev ${eth_2} 10.1.1.2/24
    Execute Command In Terminal    ip netns exec ns_server ip link set dev ${eth_1} up
    Execute Command In Terminal    ip netns exec ns_client ip link set dev ${eth_2} up

Extract Bitrate From Iperf Log
    [Documentation]    Extracts average bitrate from iperf3 network performance test log
    [Arguments]    ${iperf_log}
    ${bitrate}=    Get Regexp Matches    ${iperf_log}    .*GBytes\\s+(\\d+\\.\\d+)\\s+Gbits\\/sec.*sender    1
    Should Not Be Empty    ${bitrate}
    Log    The bitrate is: ${bitrate}[0]
    RETURN    ${bitrate}[0]
