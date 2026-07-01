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
Resource            ../lib/wol-lib.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
WOL001.201 Wake On LAN works (Ubuntu)
    [Documentation]    Verify Wake-on-LAN functionality by suspending the system
    ...    and waking it using a magic packet sent from the local machine.
    Depends On    ${WAKE_ON_LAN_SUPPORT}
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    WOL001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${net_ls}=    Execute Command In Terminal    ls -1 /sys/class/net
    # Filter in Python: keep en/eth interfaces, exclude SFP ports (np appears after position 3)
    ${iface}=    Evaluate    [i for i in """${net_ls}""".split() if i.startswith('en') and 'np' not in i[3:]][0]
    Log To Console    Interface: ${iface}
    ${mac}=    Get Interface MAC    ${iface}
    Log To Console    Interface MAC: ${mac}
    Enable WOL    ${iface}
    Suspend Remote System
    Send WOL Packet From Local    ${mac}
    Wait For System After WOL
