*** Settings ***
Documentation       Collection of keywords related to Wake-on-LAN functionality

Library             Process
Library             String
Resource            ../keywords.robot
Resource            ../keys.robot


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
    # Write Into Terminal (fire-and-forget) — no prompt returns after suspend.
    # systemctl suspend fails over SSH (no logind seat session); write directly to kernel.
    Write Into Terminal    echo mem > /sys/power/state
    Sleep    15s

Send WOL Packet From Local
    [Arguments]    ${mac}
    # Send magic packet as unicast to DEVICE_IP — unicast is routed so it crosses
    # subnet boundaries, unlike broadcast. Relies on ARP entry being fresh in the
    # router cache (typically valid for minutes, enough for a 15s suspend).
    ${result}=    Run Process
    ...    wakeonlan    -i    ${DEVICE_IP}    ${mac}
    ...    shell=True
    Log    ${result.stdout}
    Should Be Equal As Integers    ${result.rc}    0    msg=wakeonlan failed: ${result.stderr}

Wait For System After WOL
    [Documentation]    Wait until system responds to ping after WoL, then verify shell prompt
    ...    is restored. An empty line on the terminal (no prompt) indicates incomplete wake-up
    ...    and would be a false positive if only ping were checked.
    Wait Until Keyword Succeeds
    ...    2 min
    ...    10 sec
    ...    Ping Remote Host
    Read From Terminal
    Write Bare Into Terminal    ${ENTER}
    Read From Terminal Until Prompt

Ping Remote Host
    ${result}=    Run Process
    ...    ping
    ...    -c
    ...    1
    ...    ${DEVICE_IP}
    ...    shell=True
    Should Be Equal As Integers    ${result.rc}    0
