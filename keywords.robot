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

Read From Terminal
    [Documentation]    Universal keyword to read the console output regardless 
    ...                of the used method of connection to the DUT 
    ...                (Telnet or SSH).
    ${output}=    IF    '${dut_connection_method}' == 'Telnet'    Telnet.Read
    ...    ELSE IF    '${dut_connection_method}' == 'SSH'    SSHLibrary.Read
    ...    ELSE IF    '${dut_connection_method}' == 'open-bmc'    SSHLibrary.Read
    ...    ELSE IF    '${dut_connection_method}' == 'pikvm'    Telnet.Read
    ...    ELSE    FAIL    Unknown connection method: ${dut_connection_method}
    [Return]    ${output}

Read From Terminal Until
    [Documentation]    Universal keyword to read the console output until the 
    ...                defined text occurs regardless of the used method of
    ...                connection to the DUT (Telnet or SSH).
    [Arguments]    ${expected}
    ${output}=    IF    '${dut_connection_method}' == 'Telnet'    Telnet.Read Until    ${expected}
    ...    ELSE IF    '${dut_connection_method}' == 'SSH'    SSHLibrary.Read Until    ${expected}
    ...    ELSE IF    '${dut_connection_method}' == 'open-bmc'    SSHLibrary.Read Until    ${expected}
    ...    ELSE IF    '${dut_connection_method}' == 'pikvm'    Telnet.Read Until    ${expected}
    ...    ELSE    FAIL    Unknown connection method: ${dut_connection_method}
    [Return]    ${output}

Write Into Terminal
    [Documentation]    Universal keyword to write text to console regardless of 
    ...                the used method of connection to the DUT (Telnet, PiKVM or SSH).
    [Arguments]    ${text}
    IF    '${dut_connection_method}' == 'Telnet'    Telnet.Write    ${text}
    ...    ELSE IF    '${dut_connection_method}' == 'SSH'    SSHLibrary.Write    ${text}
    ...    ELSE IF    '${dut_connection_method}' == 'open-bmc'    SSHLibrary.Write    ${text}
    ...    ELSE IF    '${dut_connection_method}' == 'pikvm'    Write PiKVM    ${text}
    ...    ELSE    FAIL    Unknown connection method: ${dut_connection_method}

Write Bare Into Terminal
    [Documentation]    Universal keyword to write bare text (without new line 
    ...                mark) to console regardless of the used method of
    ...                connection to the DUT (Telnet, PiKVM or SSH).
    [Arguments]    ${text}
    IF    '${dut_connection_method}' == 'Telnet'    Telnet.Write Bare    ${text}
    ...    ELSE IF    '${dut_connection_method}' == 'SSH'    SSHLibrary.Write Bare    ${text}
    ...    ELSE IF    '${dut_connection_method}' == 'open-bmc'    SSHLibrary.Write Bare    ${text}
    ...    ELSE IF    '${dut_connection_method}' == 'pikvm'    Write Bare PiKVM    ${text}
    ...    ELSE    FAIL    Unknown connection method: ${dut_connection_method}

Execute Command In Terminal
    [Documentation]    Universal keyword to execute command regardless of the 
    ...                used method of connection to the DUT (Telnet or SSH).
    [Arguments]    ${command}
    ${output}=    IF    '${dut_connection_method}' == 'Telnet'    Telnet.Execute Command    ${command}    strip_prompt=True
    ...    ELSE    SSHLibrary.Execute Command    ${command}
    [Return]    ${output}

Boot from
    [Documentation]    Keyword choose provided option in boot menu.
    [Arguments]    ${option}
    IF    '${payload}' == 'tianocore'      Enter Boot Menu Tianocore
    ...    ELSE    FAIL    ${payload} - payload isn't supported
    Enter submenu in Tianocore    ${option}

Enter Boot Menu Tianocore
    [Documentation]    Enter boot menu tianocore edk2.
    Read From Terminal Until    ${tianocore_string}
    IF    '${dut_connection_method}' == 'pikvm'    Single Key PiKVM    ${boot_menu_key}
    ...    ELSE     Write Bare Into Terminal    ${boot_menu_key}

Enter submenu in Tianocore
    [Documentation]    Enter chosen option. Generic keyword.
    [Arguments]    ${option}    ${checkpoint}=ESC to exit    ${description_lines}=1
    ${rel_pos}=    Get relative menu position    ${option}    ${checkpoint}    ${description_lines}
    IF    '${dut_connection_method}' == 'pikvm'    Press key n times and enter    ${rel_pos}    ArrowDown
    ...    ELSE    Press key n times and enter    ${rel_pos}    ${ARROW_DOWN}

Get relative menu position
    [Documentation]    Evaluate and return relative menu entry position
    ...                described in the argument.
    [Arguments]    ${entry}    ${checkpoint}    ${bias}
    ${output}=    Read From Terminal Until    ${checkpoint}
    ${output}=    Strip String    ${output}
    ${reference}=    Get Menu Reference Tianocore    ${output}    ${bias}
    @{lines}=    Split To Lines    ${output}
    ${iterations}=    Set Variable    0
    FOR    ${line}    IN    @{lines}
        IF    '${reference}' in '${line}\\n'
            ${start}=    Set Variable    ${iterations}
            BREAK
        END
        ${iterations}=    Evaluate    ${iterations} + 1
    END
    ${iterations}=    Set Variable    0
    FOR    ${line}    IN    @{lines}
        IF    '${entry}' in '${line}\\n'
            ${end}=    Set Variable    ${iterations}
        END
        ${iterations}=    Evaluate    ${iterations} + 1
    END
    ${rel_pos}=    Evaluate    ${end} - ${start}
    [Return]    ${rel_pos}

Get Menu Reference Tianocore
    [Documentation]    Get first entry from Tianocore Boot Manager menu.
    [Arguments]    ${raw_menu}    ${bias}
    ${lines}=    Get Lines Matching Pattern    ${raw_menu}    *[qwertyuiopasdfghjklzxcvbnm]*
    ${lines}=    Split To Lines    ${lines}
    ${bias}=    Convert To Integer    ${bias}
    ${first_entry}=    Get From List    ${lines}    ${bias}
    ${first_entry}=    Strip String    ${first_entry}    characters=1234567890()
    ${first_entry}=    Strip String    ${first_entry}
    [Return]    ${first_entry}

Press key n times and enter
    [Documentation]    Enter specified in the first argument times the specified
    ...                in the second argument key and then press Enter.
    [Arguments]    ${n}    ${key}
    Press key n times    ${n}    ${key}
    IF    '${dut_connection_method}' == 'pikvm'    Single Key PiKVM    Enter
    ...    ELSE    Write Bare Into Terminal    ${ENTER}

Check DTS Menu Appears
    [Documentation]    Check whatever the DTS menu will appear.
    ${output}=    Read From Terminal Until    Enter an option:

Enter Shell In DTS
    [Documentation]    Enter Shell in DTS using the appropriate option.
    Wirte Into Terminal    9
    Read From Terminal Until     bash-5.1#
