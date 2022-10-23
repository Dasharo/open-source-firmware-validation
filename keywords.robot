**Keywords**

Prepare Test Suite
    [Documentation]    Keyword prepares Test Suite by importing specific
    ...                platform configuration keywords and variables and
    ...                preparing connection with the DUT based on used
    ...                transmission protocol. Keyword used in all [Suite Setup]
    ...                sections.
    Import Resource    ${CURDIR}/platform-configs/${config}.robot
    Check Stand Address Correctness
    IF    '${dut_connection_method}' == 'SSH'
        SSHLibrary.Set Default Configuration    timeout=60 seconds
    ELSE IF    '${dut_connection_method}' == 'Telnet'
        Open Connection And Log In
        Get DUT To Start State
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        No Operation
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        Open Connection And Log In
        Get DUT To Start State
    ELSE
        FAIL    Unknown connection method for config: ${config}
    END

Open Connection And Log In
    [Documentation]    Open SSH connection and login to session. Setup RteCtrl
    ...                REST API, serial connection and checkout used asset in
    ...                SnipeIt
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    SSHLibrary.Open Connection    ${stand_ip}    prompt=~#
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    REST API Setup    RteCtrl
    Serial setup    ${stand_ip}    ${rte_s2n_port}
    Return From Keyword If    '${snipeit}'=='no'
    SnipeIt API Setup    SnipeItApi
    SnipeIt Checkout    ${stand_ip}

Get DUT To Start State
    [Documentation]    Keyword clears telnet buffer and get Device Under Test
    ...                to start state (RTE Relay On).
    Telnet.Read
    ${result}=    Get Power Supply State
    IF    '${result}'=='low'    Turn On Power Supply

Get Power Supply State
    [Documentation]    Returns the power supply state.
    ${pc}=    Check Power Control Method    ${stand_ip}
    IF    '${pc}'=='sonoff'
        ${state}=    Get Sonoff State
    ELSE
        ${state}=    Get Relay State
    END
    [Return]    ${state}

Turn On Power Supply
    ${pc}=    Check Power Control Method    ${stand_ip}
    IF    'sonoff' == '${pc}'
        Sonoff Power On Platform
    ELSE
        RteCtrl Relay
    END

Serial setup
    [Documentation]    Setup serial communication via telnet. Takes host and
    ...                ser2net port as an arguments.
    [Arguments]    ${host}    ${s2n_port}
    Telnet.Open Connection    ${host}    port=${s2n_port}    newline=LF    terminal_emulation=yes    terminal_type=vt100    window_size=80x24
    Set Timeout    30

Check Stand Address Correctness
    [Documentation]    Check the correctness of the provided ip address, if the
    ...                address is not found in the RTE list, fail the test.
    IF    '${dut_connection_method}' == 'SSH'
        ${is_address_correct}=    Check Platform Provided ip
    ELSE IF    '${dut_connection_method}' == 'Telnet'
        ${is_address_correct}=    Check RTE Provided ip
    ELSE
        FAIL    Unknown connection method for config: ${config}
    END
    IF    ${is_address_correct}    Return From Keyword
    FAIL    stand_ip:${stand_ip} not found in the hardware configuration.

Log Out And Close Connection
    [Documentation]    Keyword closes all opened SSH, serial connections and
    ...                checkin used asset in SnipeIt.
    SSHLibrary.Close All Connections
    Telnet.Close All Connections
    IF    '${snipeit}'=='yes'    SnipeIt Checkin    ${rte_ip}