*** Settings ***
Library             Collections
Library             DateTime
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
WOL001.201 Wake On LAN works (Ubuntu)
    [Documentation]    Verify Wake-on-LAN functionality by suspending the system
    ...    and waking it using a magic packet sent from the local machine.
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    WOL001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${iface}=    Execute Command In Terminal    ls /sys/class/net | grep -E '^(en|eth)' | head -n1
    ${iface}=    Strip String    ${iface}
    Log To Console    Interface: ${iface}
    ${mac}=    Get Interface MAC    ${iface}
    Log To Console    Interface MAC: ${mac}
    Enable WOL    ${iface}
    Suspend Remote System
    Send WOL Packet From Local    ${mac}
    Wait For System After WOL


*** Keywords ***
Get Interface MAC
    [Arguments]    ${iface}
    ${output}=    Execute Command In Terminal    cat /sys/class/net/${iface}/address
    ${mac}=    Strip String    ${output}
    RETURN    ${mac}

Enable WOL
    [Arguments]    ${iface}
    Execute Command In Terminal    ethtool -s ${iface} wol g
    ${verify}=    Execute Command In Terminal    ethtool ${iface} | grep Wake-on
    Should Contain    ${verify}    g

Suspend Remote System
    [Documentation]    Put system into suspend state.
    Execute Command In Terminal    systemctl suspend
    Sleep    15s

Send WOL Packet From Local
    [Arguments]    ${mac}
    ${result}=    Run Process
    ...    wakeonlan
    ...    ${mac}
    ...    shell=True
    ...    stdout=TRUE
    ...    stderr=TRUE
    Log    ${result.stdout}

Wait For System After WOL
    [Documentation]    Wait until system responds to ping after WoL.
    Wait Until Keyword Succeeds
    ...    2 min
    ...    10 sec
    ...    Ping Remote Host

Ping Remote Host
    ${result}=    Run Process
    ...    ping
    ...    -c
    ...    1
    ...    ${DEVICE_IP}
    ...    shell=True
    Should Be Equal As Integers    ${result.rc}    0
