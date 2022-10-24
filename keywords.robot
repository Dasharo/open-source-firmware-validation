*** Keywords ***
Prepare Test Suite
    [Documentation]    Keyword prepares Test Suite by importing specific
    ...    platform configuration keywords and variables and
    ...    preparing connection with the DUT based on used
    ...    transmission protocol. Keyword used in all [Suite Setup]
    ...    sections.
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
    ...    REST API, serial connection and checkout used asset in
    ...    SnipeIt
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    SSHLibrary.Open Connection    ${stand_ip}    prompt=~#
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    REST API Setup    RteCtrl
    Serial setup    ${stand_ip}    ${rte_s2n_port}
    IF    '${snipeit}'=='no'    RETURN
    SnipeIt API Setup    SnipeItApi
    SnipeIt Checkout    ${stand_ip}

Get DUT To Start State
    [Documentation]    Keyword clears telnet buffer and get Device Under Test
    ...    to start state (RTE Relay On).
    Telnet.Read
    ${result}=    Get Power Supply State
    IF    '${result}'=='low'    Turn On Power Supply

Get Power Supply State
    [Documentation]    Returns the power supply state.
    ${pc}=    Get Power Control Method    ${stand_ip}
    IF    '${pc}'=='sonoff'
        ${state}=    Get Sonoff State
    ELSE IF    '${pc}'=='rte'
        ${state}=    Get RTE Relay State
    ELSE
        FAIL    Unknown connection method for stand ip: ${stand_ip}
    END
    RETURN    ${state}

Get RTE Relay State
    [Documentation]    Returns the RTE relay state through REST API.
    ${state}=    RteCtrl Get GPIO State    0
    [Return]    ${state}

Turn On Power Supply
    ${pc}=    Get Power Control Method    ${stand_ip}
    IF    'sonoff' == '${pc}'
        Sonoff Power On Platform
    ELSE IF    '${pc}'=='rte'
        RteCtrl Relay
    ELSE
        FAIL    Unknown connection method for stand ip: ${stand_ip}
    END

Serial setup
    [Documentation]    Setup serial communication via telnet. Takes host and
    ...    ser2net port as an arguments.
    [Arguments]    ${host}    ${s2n_port}
    Telnet.Open Connection
    ...    ${host}
    ...    port=${s2n_port}
    ...    newline=LF
    ...    terminal_emulation=yes
    ...    terminal_type=vt100
    ...    window_size=80x24
    Set Timeout    30

Check Stand Address Correctness
    [Documentation]    Check the correctness of the provided ip address, if the
    ...    address is not found in the RTE list, fail the test.
    IF    '${dut_connection_method}' == 'SSH'
        ${is_address_correct}=    Check Platform Provided ip    ${stand_ip}
    ELSE IF    '${dut_connection_method}' == 'Telnet'
        ${is_address_correct}=    Check RTE Provided ip    ${stand_ip}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        ${is_address_correct}=    Check RTE Provided ip    ${stand_ip}
    ELSE
        FAIL    Unknown connection method for config: ${config}
    END
    IF    ${is_address_correct}    RETURN
    FAIL    stand_ip:${stand_ip} not found in the hardware configuration.

Log Out And Close Connection
    [Documentation]    Keyword closes all opened SSH, serial connections and
    ...    checkin used asset in SnipeIt.
    SSHLibrary.Close All Connections
    Telnet.Close All Connections
    IF    '${snipeit}'=='yes'    SnipeIt Checkin    ${stand_ip}

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

Press key n times
    [Documentation]    Enter specified in the first argument times the specified
    ...                in the second argument key.
    [Arguments]    ${n}   ${key}
    FOR    ${INDEX}    IN RANGE    0    ${n}
        IF    '${dut_connection_method}' == 'pikvm'    Single Key PiKVM    ${key}
        ...    ELSE    Write Bare Into Terminal    ${key}
    END

Check DTS Menu Appears
    [Documentation]    Check whatever the DTS menu will appear.
    ${output}=    Read From Terminal Until    Enter an option:

Check HCL Report Creation
    [Documentation]    Check whatever the HCL report was generated correctly.
    Read From Terminal Until    [N/y]
    Write Into Terminal    y
    ${output}=    Read From Terminal Until    Thank you for supporting Dasharo!
    Should Contain    ${output}    Done! Logs saved
    Should Contain    ${output}    exited without errors
    Should Contain    ${output}    send completed

Enter Shell In DTS
    [Documentation]    Enter Shell in DTS using the appropriate option.
    Write Into Terminal    9
    Read From Terminal Until     bash-5.1#

Run EC Transition
    [Documentation]    Proceed full EC transiotion in DTS.
    Write Into Terminal    6
    Read From Trminal Until     Enter an option:
    Write Into Terminal    1
    ${output}=    Read From Terminal Until    shut down
    Should Contain X Times    ${output}    VERIFIED    2
    Sleep    10s

Check Power Off In DTS
    [Documentation]    Check whatever the DUT will turns off after choosing
    ...                Power Off option in DTS menu.
    Sleep    5s
    ${output}=    Read From Terminal
    Should Be Empty    ${output}

Flash firmware in DTS
    [Documentation]    Flash firmware using flashrom in DTS.
    Execute Command In Terminal    wget -0 /tmp/coreboot.rom https://3mdeb.com/open-source-firmware/Dasahro/${binary_location}
    ${output}=    Execute Command In Terminal    flashrom -p internal -w /tmp/coreboot ${flashrom_variables}
    Should Contain    ${output}    VERIFIED

Flash EC Firmware In DTS
    [Documentation]    Flash EC firmware using system76_ectool in DTS.
    Execute Command In Terminal    wget -0 /tmp/ec.rom https://3mdeb.com/open-source-firmware/Dasahro/${ec_binary_location}
    Write Into Terminal    system76_ectool flash ec.rom
    ${output}=    Read From Terminal Until    shut off
    Should Contain    ${output}    Successfully programmed SPI ROM
    Sleep    10s

Check Firmware Version
    [Documentation]    Check whatever the firmware has the correct version.
    ${output}=    Execute Command In Terminal    dmidecode -t 0
    Should contain    ${output}    ${version}

Check EC Firmware Version
    [Documentation]    Check whatever the EC firmware has the correct version.
    ${output}=    Execute Command In Terminal    system76_ectool info
    Should contain    ${output}    ${ec_version}

Fwupd Update
    [Documentation]    Check whatever the firmware can be updated by fwupd.
    ${output}=    Execute Command In Terminal    fwupdmgr refresh
    Should Contatin    ${output}    Successfully
    ${output}=    Execute Command In Terminal    fwupdmgr update
    Should Contatin    ${output}    Successfully installed firmware
