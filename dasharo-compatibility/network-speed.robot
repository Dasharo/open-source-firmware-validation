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
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Variables ***
${SCRIPT_TEXT}=     \#/bin/bash${ENTER}
...                 ${BACKSPACE}${ENTER}
...                 ${BACKSPACE}\#echo $1${ENTER}
...                 ${BACKSPACE}\#echo $2${ENTER}
...                 ${BACKSPACE}${ENTER}
...                 ${BACKSPACE}\# Use ip -d link list to see maxmtu value of interface${ENTER}
...                 ${BACKSPACE}\# maximum transmission unit (MTU) is a measurement representing the
...                 ${BACKSPACE}largest data packet that a network-connected device will accept.${ENTER}
...                 ${BACKSPACE}\#ip link set $1 mtu 9000${ENTER}
...                 ${BACKSPACE}\#ip link set $2 mtu 9000${ENTER}
...                 ${BACKSPACE}\# ----${ENTER}
...                 ${BACKSPACE}${ENTER}
...                 ${BACKSPACE}${ENTER}
...                 ${BACKSPACE}\#echo Thanks${ENTER}
...                 ${BACKSPACE}ip netns add ns_server${ENTER}
...                 ${BACKSPACE}ip netns add ns_client${ENTER}
...                 ${BACKSPACE}ip link set $1 netns ns_server${ENTER}
...                 ${BACKSPACE}ip link set $2 netns ns_client${ENTER}
...                 ${BACKSPACE}ip netns exec ns_server ip addr add dev $1 10.1.1.1/24${ENTER}
...                 ${BACKSPACE}ip netns exec ns_client ip addr add dev $2 10.1.1.2/24${ENTER}
...                 ${BACKSPACE}ip netns exec ns_server ip link set dev $1 up${ENTER}
...                 ${BACKSPACE}ip netns exec ns_client ip link set dev $2 up${ENTER}
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
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    iperf3
    Create Iperf3 Script File
    ${working_nic_desc}=    Execute Command In Terminal
    ...    ip addr | grep -B 2 "global dynamic noprefixroute" | grep -v "link/ether" | grep -v "dynamic noprefixroute"
    ${working_nic_desc}=    Extract Nic Name    ${working_nic_desc}
    ${out}=    Execute Command In Terminal    ip addr | grep -v ${working_nic_desc} | grep -v "NO-CARRIER" | grep "enp"
    ${splitted_lines}=    Split String    ${out}    \n
    ${nic_name_1}=    Extract Nic Name    ${splitted_lines}[0]
    ${nic_name_2}=    Extract Nic Name    ${splitted_lines}[1]
    Log To Console    \n1st NIC name identified as: ${nic_name_1}
    Log To Console    2nd NIC name identified as: ${nic_name_2}
    ${out}=    Execute Command In Terminal    source /home/ubuntu/Desktop/iperf-test.sh ${nic_name_1} ${nic_name_2}
    Log    ${out}


*** Keywords ***
Create Iperf3 Script File
    ${out}=    Execute Command In Terminal    ls /home/ubuntu/Desktop/iperf-test.sh
    ${condition}=    Run Keyword And Return Status    Should Contain    ${out}    No such file or directory
    IF    ${condition} == ${FALSE}
        Log To Console    /home/ubuntu/Desktop/iperf-test.sh file found and removed to be replaced.
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
    Log To Console    ${file_name} file created.

Extract Nic Name
    [Arguments]    ${str}
    ${words}=    Split String    ${str}    ${SPACE}
    ${out}=    Get From List    ${words}    1
    ${out}=    Get Substring    ${out}    0    -1
    RETURN    ${out}
