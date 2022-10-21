**Keywords**

Prepare Test Suite
    [Documentation]    Keyword prepares Test Suite by importing specific
    ...                platform configuration keywords and variables and
    ...                preparing connection with the DUT based on used
    ...                transmission protocol. Keyword used in all [Suite Setup]
    ...                sections.
    Import Resource    ${CURDIR}/platform-configs/${config}.robot
    IF    '${dut_connection_method}' == 'SSH'    Prepare To SSH Connection
    ...    ELSE IF    '${dut_connection_method}' == 'Telnet'    Prepare To Serial Connection
#    ...    ELSE IF    '${dut_connection_method}' == 'open-bmc'    Prepare To OBMC Connection
    ...    ELSE IF    '${dut_connection_method}' == 'pikvm'    Prepare To PiKVM Connection
    ...    ELSE    FAIL    Unknown connection method for config: ${config}

Prepare To SSH Connection
    [Documentation]    Keyword prepares Test Suite by setting current platform
    ...                and its ip to the global variables, configuring the
    ...                SSH connection, Setup RteCtrl REST API and checkout used
    ...                asset in SnipeIt . Keyword used in [Suite Setup]
    ...                sections if the communication with the platform based on
    ...                the SSH protocol.
    SSHLibrary.Set Default Configuration    timeout=60 seconds

Prepare To Serial Connection
    [Documentation]    Keyword prepares Test Suite by opening SSH connection to
    ...                the RTE, opening serial connection with the DUT, setting
    ...                current platform to the global variable and setting the
    ...                DUT to start state. Keyword used in [Suite Setup]
    ...                sections if the communication with the platform based on
    ...                the serial connection.
    Open Connection And Log In
    Get DUT To Start State

Prepare To PiKVM Connection
    [Documentation]    Keyword prepares Test Suite by opening SSH connection to
    ...                the RTE, opening serial connection with the DUT (for
    ...                gathering output from platform), configuring PiKVM,
    ...                setting current platform to the global variable and
    ...                setting the DUT to start state. Keyword used in
    ...                [Suite Setup] sections if the communication with the
    ...                platform based on the serial connection (platform
    ...                output) and PiKVM (platform input)
    Open Connection And Log In
    Get DUT To Start State

Open Connection And Log In
    [Documentation]    Open SSH connection and login to session. Setup RteCtrl
    ...                REST API, serial connection and checkout used asset in
    ...                SnipeIt
    Check Stand Address Correctness
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    SSHLibrary.Open Connection    ${rte_ip}    prompt=~#
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    REST API Setup    RteCtrl
    Serial setup    ${rte_ip}    ${rte_s2n_port}
    Return From Keyword If    '${snipeit}'=='no'
    SnipeIt API Setup    SnipeItApi
    SnipeIt Checkout    ${rte_ip}

Get DUT To Start State
    [Documentation]    Keyword clears telnet buffer and get Device Under Test
    ...                to start state (RTE Relay On).
    Telnet.Read
    ${result}=    Get Power Supply State
    IF    '${result}'=='low'    Turn On Power Supply

Turn On Power Supply
    ${pc}=    Get Variable Value    ${POWER_CTRL}
    ${state}=    IF    'sonoff' == '${pc}'    Sonoff Power On Platform
    ...          ELSE    RteCtrl Relay

Serial setup
    [Documentation]    Setup serial communication via telnet. Takes host and
    ...                ser2net port as an arguments.
    [Arguments]    ${host}    ${s2n_port}
    Telnet.Open Connection    ${host}    port=${s2n_port}    newline=LF    terminal_emulation=yes    terminal_type=vt100    window_size=80x24
    Set Timeout    30

Check provided ip
    [Documentation]    Check the correctness of the provided ip address, if the
    ...                address is not found in the RTE list, fail the test.
    ${is_address_correct}=    Check Stand Address Correctness    ${stand_ip}
    IF    ${is_address_correct}    Return From Keyword
    Fail    rte_ip:${rte_ip} not found in the hardware configuration.

Log Out And Close Connection
    [Documentation]    Keyword closes all opened SSH, serial connections and
    ...                checkin used asset in SnipeIt.
    SSHLibrary.Close All Connections
    Telnet.Close All Connections
    IF    '${snipeit}'=='yes'    SnipeIt Checkin    ${rte_ip}