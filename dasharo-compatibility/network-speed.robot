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
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
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
...                     Skip If    not ${NIC_LOOP_SUPPORT}    NIC Loop not installed
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Variables ***
${SCRIPT_TEXT}=     \#/bin/bash${ENTER}
...                 ${BACKSPACE}ip netns add ns_server${ENTER}
...                 ${BACKSPACE}ip netns add ns_client${ENTER}
...                 ${BACKSPACE}ip link set $1 netns ns_server${ENTER}
...                 ${BACKSPACE}ip link set $2 netns ns_client${ENTER}
...                 ${BACKSPACE}ip netns exec ns_server ip addr add dev $1 10.1.1.1/24${ENTER}
...                 ${BACKSPACE}ip netns exec ns_client ip addr add dev $2 10.1.1.2/24${ENTER}
...                 ${BACKSPACE}ip netns exec ns_server ip link set dev $1 up${ENTER}
...                 ${BACKSPACE}ip netns exec ns_client ip link set dev $2 up${ENTER}
...                 ${BACKSPACE}${ENTER}
...                 ${BACKSPACE}ip netns exec ns_server iperf3 -s &${ENTER}
...                 ${BACKSPACE}ip netns exec ns_client iperf3 -c 10.1.1.1${ENTER}
...                 ${BACKSPACE}${ENTER}
...                 ${BACKSPACE}killall iperf3${ENTER}
...                 ${BACKSPACE}${ENTER}
...                 ${BACKSPACE}ip netns exec ns_client iperf3 -s &${ENTER}
...                 ${BACKSPACE}ip netns exec ns_server iperf3 -c 10.1.1.2${ENTER}
...                 ${BACKSPACE}${ENTER}
...                 ${BACKSPACE}killall iperf3${ENTER}
...                 ${BACKSPACE}${ENTER}
...                 ${BACKSPACE}ip netns del ns_server${ENTER}
...                 ${BACKSPACE}ip netns del ns_client


*** Test Cases ***
NETSPD001.001 Check Network Speed (Ubuntu)
    [Documentation]    This test aims to verify the speed of ethernet connection
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    iperf3
    Create Iperf3 Script File
    ${working_nic_desc}=    Execute Command In Terminal
    ...    ip addr | grep -B 2 "noprefixroute" | grep -v "link/ether" | grep -v "noprefixroute"
    ${working_nic_desc}=    Extract Nic Name    ${working_nic_desc}
    ${out}=    Execute Command In Terminal    ip addr | grep -v ${working_nic_desc} | grep -v "NO-CARRIER" | grep "enp"
    ${splitted_lines}=    Split String    ${out}    \n
    ${nic_name_1}=    Extract Nic Name    ${splitted_lines}[0]
    ${nic_name_2}=    Extract Nic Name    ${splitted_lines}[1]
    ${out}=    Execute Command In Terminal    source /home/ubuntu/Desktop/iperf-test.sh ${nic_name_1} ${nic_name_2}

    Sleep    5s
    Detect Or Install Package    ethtool
    ${speed_out}=    Execute Command In Terminal    ethtool ${nic_name_1} | grep baseT    
    ${nic_1_max_supported_speed}=    Extract Nic Max Speed    ${speed_out}
    ${speed_out}=    Execute Command In Terminal    ethtool ${nic_name_2} | grep baseT
    ${nic_2_max_supported_speed}=    Extract Nic Max Speed    ${speed_out}  
    
    ${nic_1_max_aprooved_speed}=    Evaluate    (${nic_1_max_supported_speed} * ${ACCEPTED_NET_SPEED_FACTOR}) / 1000
    ${nic_2_max_aprooved_speed}=    Evaluate    (${nic_2_max_supported_speed} * ${ACCEPTED_NET_SPEED_FACTOR}) / 1000

    ${sender_speed}=    Extract Nic Speed    ${out}    sender
    ${sender_speed}=    Convert To Number    ${sender_speed}
    ${result}=    Should Be Larger Than    ${sender_speed}    ${nic_1_max_aprooved_speed}
    Should Be True    ${result}
    Log    NIC_1 speed: ${sender_speed}

    ${receiver_speed}=    Extract Nic Speed    ${out}    receiver
    ${receiver_speed}=    Convert To Number    ${receiver_speed}
    ${result}=    Should Be Larger Than    ${receiver_speed}    ${nic_2_max_aprooved_speed}
    Should Be True    ${result}
    Log    NIC_2 speed: ${receiver_speed}

NETXXX Check Network Speed (Ubuntu)
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User


*** Keywords ***
Create Iperf3 Script File
    ${out}=    Execute Command In Terminal    ls /home/ubuntu/Desktop/iperf-test.sh
    ${condition}=    Run Keyword And Return Status    Should Contain    ${out}    No such file or directory
    IF    ${condition} == ${FALSE}
        Execute Command In Terminal    rm /home/ubuntu/Desktop/iperf-test.sh
    END
    Create File    /home/ubuntu/Desktop/iperf-test.sh    ${SCRIPT_TEXT}

Create File
    [Arguments]    ${file_name}    ${file_contents}
    Write Into Terminal    vi ${file_name}
    Press Key N Times    1    ${ENTER}
    Press Key N Times    1    i
    Write Into Terminal    ${file_contents}
    Press Key N Times    1    ${ESC}
    Execute Command In Terminal    :wq

Extract Nic Name
    [Arguments]    ${str}
    ${words}=    Split String    ${str}    ${SPACE}
    ${out}=    Get From List    ${words}    1
    ${out}=    Get Substring    ${out}    0    -1
    RETURN    ${out}

Extract Nic Speed
    [Arguments]    ${str}    ${search_for}
    ${out}=    Get Lines Containing String    ${str}    ${search_for}
    ${out}=    Split To Lines    ${out}    -1
    ${out}=    Convert To String    ${out}
    ${out}=    Split String    ${out}    ${SPACE}
    ${out}=    Get From List    ${out}    12
    RETURN    ${out}

Extract Nic Max Speed
    [Arguments]    ${str}
    ${out}=    Split String    ${str}
    ${out}=    Get From List    ${out}    -1
    ${out}=    Extract Number From Line    ${out}
    ${out}=    Convert To Number    ${out}
    RETURN    ${out}

Extract Number From Line
    [Arguments]    ${str}
    @{str}=    Split String To Characters    ${str}
    ${digits}=    Create List
    FOR    ${char}    IN    @{str}
        ${is_digit}=    Evaluate    '${char}'.isdigit()
        IF    ${is_digit}
            Append To List    ${digits}    ${char}
        END
    END
    ${out}=    Evaluate    ''.join(${digits})
    [Return]    ${out}

Should Be Larger Than
    [Arguments]    ${value_1}    ${value_2}
    IF    ${value_1} <= ${value_2}
        Fail    ${value_1} is not larger than ${value_2}
        RETURN    ${FALSE}
    ELSE
        RETURN    ${TRUE}
    END
