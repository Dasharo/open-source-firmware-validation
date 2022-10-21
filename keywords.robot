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
    ...    ELSE IF    '${dut_connection_method}' == 'open-bmc'    Prepare To OBMC Connection
    ...    ELSE IF    '${dut_connection_method}' == 'pikvm'    Prepare To PiKVM Connection
    ...    ELSE    FAIL    Unknown connection method for config: ${config}

Log Out And Close Connection
    [Documentation]    Keyword closes all opened SSH, serial connections and
    ...                checkin used asset in SnipeIt.
    SSHLibrary.Close All Connections
    Telnet.Close All Connections
    Return From Keyword If    '${platform}'=='talosII'
    IF    '${snipeit}'=='yes'    SnipeIt Checkin    ${rte_ip}