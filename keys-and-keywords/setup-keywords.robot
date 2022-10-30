*** Keywords ***
Prepare Test Suite
    [Documentation]    Keyword allows to prepare Test Suite by importing
    ...    specific platform configuration keywords and variables and preparing
    ...    connection with the DUT based on used transmission protocol.
    ...    Keyword used in all [Suite Setup] sections.
    Import Needed Resources
    Check Stand Address Correctness
    Prepare Devices For Power Control
    IF    '${dut_connection_method}' == 'SSH'
        SSHLibrary.Set Default Configuration    timeout=60 seconds
    ELSE IF    '${dut_connection_method}' == 'Telnet'
        Open Connection And Log In
        Get DUT To Start State
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        No Operation
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        ${pikvm_address}=    Get Pikvm Ip    ${stand_ip}
        Set Global Variable    ${pikvm_ip}    ${pikvm_address}
        Open Connection And Log In
        Get DUT To Start State
    ELSE
        FAIL    Unknown or improper connection method: ${dut_connection_method}
    END

Import Needed Resources
    [Documentation]    Keyword allows to prepare test suite by importing
    ...    specific resources dedicated for the testing stand and tested
    ...    platform.
    Import Resource    ${CURDIR}/platform-configs/${config}.robot
    IF    ${tests_in_firmware_support}
        Import Resource    ${CURDIR}/firmware-keywords.robot
    END
    IF    ${tests_in_ubuntu_support}
        Import Resource    ${CURDIR}/keys-and-keywords/ubuntu-keywords.robot
    END

Prepare Devices For Power Control
    [Documentation]    Keyword allows to prepare devices for power control on
    ...    the stand. Depends on stand configuration, keyword starts
    ...    RTE REST API and/or Sonoff REST API sessions and sets global variable
    ...    ${power _control} used during preparing DUT to start state
    ${rte_presence}=    Check RTE Presence on Stand    ${stand_ip}
    ${sonoff_presence}=    Check Sonoff Presence on Stand    ${stand_ip}
    IF    ${rte_presence}
        Set Global Variable    ${rte_ip}    ${stand_ip}
        Set Global Variable    ${pc}    rte
        REST API Setup    RteCtrl
    END
    IF    ${sonoff_presence}
        ${sonoff_ip}=    Get Sonoff Ip    ${stand_ip}
        Set Global Variable    ${pc}    sonoff
        Set Global Variable    ${sonoff_session_handler}    SonoffCtrl
        Sonoff API Setup    ${sonoff_session_handler}    ${sonoff_ip}
    END

Open Connection And Log In
    [Documentation]    Keyword allows to prepare test suite by initializing
    ...    SSH and Telnet connections.
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    SSHLibrary.Open Connection    ${stand_ip}    prompt=~#
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    Serial setup    ${rte_ip}    ${rte_s2n_port}
    IF    '${snipeit}'=='no'    RETURN
    SnipeIt API Setup    SnipeItApi
    SnipeIt Checkout    ${stand_ip}

Get DUT To Start State
    [Documentation]    Keyword allows to prepare DUT to start state - clears
    ...    Terminal and sets Device Under Test to start state (RTE Relay On).
    Read From Terminal
    ${result}=    Get Power Supply State
    IF    '${result}'=='low'    Turn On Power Supply

Get Power Supply State
    [Documentation]    Keyword allows to obtain current power supply state.
    IF    '${pc}'=='sonoff'
        ${state}=    Get Sonoff State    ${sonoff_session_handler}
    ELSE IF    '${pc}'=='rte'
        ${state}=    Get RTE Relay State
    ELSE
        FAIL    Unknown power control method for stand: ${stand_ip}
    END
    RETURN    ${state}

Get RTE Relay State
    [Documentation]    Keyword allows to obtain the RTE relay state through
    ...    REST API.
    ${state}=    RteCtrl Get GPIO State    0
    RETURN    ${state}

Turn On Power Supply
    [Documentation]    Keyword allows to turn on the power supply connected to
    ...    the DUT.
    IF    'sonoff' == '${pc}'
        Sonoff Power On    ${sonoff_session_handler}
    ELSE IF    '${pc}'=='rte'
        RteCtrl Relay
    ELSE
        FAIL    Unknown power control method for stand: ${stand_ip}
    END

Power Cycle On
    [Documentation]    Keyword allows to perform the DUT full power on cycle -
    ...    clears Terminal and sets Device Under Test to start state.
    IF    'sonoff' == '${pc}'
        Telnet.Read
        Sonoff Power Off    ${sonoff_session_handler}
        Sleep    1s
        Sonoff Power On    ${sonoff_session_handler}
        Sleep    15s
        Power On
    ELSE IF    '${pc}'=='rte'
        Telnet.Read
        ${result}=    RteCtrl Relay
        IF    ${result} == 0
            Run Keywords    Sleep    4s    AND    Telnet.Read    AND    RteCtrl Relay
        END
    ELSE
        FAIL    Unknown power control method for stand: ${stand_ip}
    END

Power Cycle Off
    [Documentation]    Keyword allows to perform the DUT full power on cycle -
    ...    closes serial connection and sets Device Under Test to off state.
    Telnet.Close All Connections
    IF    'sonoff' == '${pc}'
        Sonoff Power On    ${sonoff_session_handler}
        Sleep    1s
        Sonoff Power Off    ${sonoff_session_handler}
    ELSE IF    '${pc}'=='rte'
        Sleep    1s
        ${result}=    Get RTE Relay State
        IF    '${result}' == 'high'    RteCtrl Relay
    ELSE
        FAIL    Unknown power control method for stand: ${stand_ip}
    END
    Serial setup    ${rte_ip}    ${rte_s2n_port}

Serial setup
    [Documentation]    Keyword allows to setup serial connection between DUT
    ...    and RTE via telnet. Takes host and ser2net port as arguments.
    [Arguments]    ${host}    ${s2n_port}
    Telnet.Open Connection
    ...    ${host}
    ...    port=${s2n_port}
    ...    newline=LF
    ...    terminal_emulation=yes
    ...    terminal_type=vt100
    ...    window_size=80x24
    Set Timeout    60s

Check Stand Address Correctness
    [Documentation]    Keyword allows to check the correctness of the provided
    ...    stand ip address, no matter if the testing stand contains RTE or not.
    ...    If the address is not found in the list, fails the test.
    IF    '${dut_connection_method}' == 'SSH'
        ${is_address_correct}=    Check Platform Provided ip    ${stand_ip}
    ELSE IF    '${dut_connection_method}' == 'Telnet'
        ${is_address_correct}=    Check RTE Provided ip    ${stand_ip}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        ${is_address_correct}=    Check RTE Provided ip    ${stand_ip}
    ELSE
        FAIL    Unknown or improper connection method: ${dut_connection_method}
    END
    IF    ${is_address_correct}    RETURN
    FAIL    stand_ip:${stand_ip} not found in the hardware configuration.

Log Out And Close Connection
    [Documentation]    Keyword allows to close all opened SSH, serial
    ...    connections and checkin used asset in SnipeIt.
    SSHLibrary.Close All Connections
    Telnet.Close All Connections
    IF    '${snipeit}'=='yes'    SnipeIt Checkin    ${stand_ip}

Flash firmware
    [Documentation]    Keyword allows to flash platform with selected firmware
    ...    by using default flashing method. Takes firmware file (${fw_file})
    ...    as an argument. Keyword fails if file size doesn't match target
    ...    chip size.
    [Arguments]    ${fw_file}
    ${file_size}=    Run    ls -l ${fw_file} | awk '{print $5}'
    IF    '${file_size}'!='${flash_size}'
        FAIL    Image size doesn't match the flash chip's size!
    END
    IF    '${default_flashing_method}'=='external programmer'
        Flash firmware with external programmer    ${fw_file}
    ELSE
        FAIL    Unsupported flashing method: ${default_flashing_method}
    END

Get firmware version from binary
    [Documentation]    Keyword allows to obtain the firmware version from the
    ...    binary file. Takes binary file path as an argument.
    [Arguments]    ${binary_path}
    ${coreboot_version1}=    SSHLibrary.Execute Command
    ...    strings ${binary_path}|grep COREBOOT_ORIGIN_GIT_TAG|cut -d" " -f 3|tr -d '"'
    ${coreboot_version2}=    SSHLibrary.Execute Command
    ...    strings ${binary_path}|grep CONFIG_LOCALVERSION|cut -d"=" -f 2|tr -d '"'
    ${coreboot_version3}=    SSHLibrary.Execute Command
    ...    strings ${binary_path}|grep -w COREBOOT_VERSION|cut -d" " -f 3|tr -d '"'
    ${version_length1}=    Get Length    ${coreboot_version1}
    ${coreboot_version}=    Set Variable If    ${version_length1} == 0    ${coreboot_version2}    ${coreboot_version1}
    ${version_length}=    Get Length    ${coreboot_version}
    ${coreboot_version}=    Set Variable If    ${version_length} == 0    ${coreboot_version3}    ${coreboot_version}
    ${firmware_version}=    Split To Lines    ${coreboot_version}
    RETURN    ${firmware_version[0]}

Get firmware version
    [Documentation]    Keyword allows to obtain the firmware version by
    ...    using method defined in the configuration. Takes binary file path
    ...    as an argument.
    Set DUT Response Timeout    120s
    IF    '${flash_verify_method}'=='iPXE-boot'
        No Operation
    ELSE IF    '${flash_verify_method}'=='tianocore-setup-menu'
        ${firmware_version}=    Get Firmware Version From Tianocore Setup Menu
    ELSE
        FAIL    Unsupported flash verify method: ${flash_verify_method}
    END
    Set DUT Response Timeout    30s
    RETURN    ${firmware_version[0]}

Read From Terminal
    [Documentation]    Universal keyword to read the console output regardless
    ...    of the used method of connection to the DUT
    ...    (Telnet or SSH).
    IF    '${dut_connection_method}' == 'Telnet'
        ${output}=    Telnet.Read
    ELSE IF    '${dut_connection_method}' == 'SSH'
        ${output}=    SSHLibrary.Read
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        ${output}=    SSHLibrary.Read
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        ${output}=    Telnet.Read
    ELSE
        FAIL    Unknown or improper connection method: ${dut_connection_method}
    END
    RETURN    ${output}

Read From Terminal Until
    [Documentation]    Universal keyword to read the console output until the
    ...    defined text occurs regardless of the used method of connection to
    ...    the DUT (Telnet or SSH).
    [Arguments]    ${expected}
    IF    '${dut_connection_method}' == 'Telnet'
        ${output}=    Telnet.Read Until    ${expected}
    ELSE IF    '${dut_connection_method}' == 'SSH'
        ${output}=    SSHLibrary.Read Until    ${expected}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        ${output}=    SSHLibrary.Read Until    ${expected}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        ${output}=    Telnet.Read Until    ${expected}
    ELSE
        FAIL    Unknown or improper connection method: ${dut_connection_method}
    END
    RETURN    ${output}

Read From Terminal Until Prompt
    [Documentation]    Universal keyword to read the console output until the
    ...    defined prompt occurs regardless of the used method of connection to
    ...    the DUT (Telnet or SSH).
    IF    '${dut_connection_method}' == 'Telnet'
        ${output}=    Telnet.Read Until Prompt    strip_prompt=${True}
    ELSE IF    '${dut_connection_method}' == 'SSH'
        ${output}=    SSHLibrary.Read Until Prompt    strip_prompt=${True}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        ${output}=    SSHLibrary.Read Until Prompt    strip_prompt=${True}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        ${output}=    Telnet.Read Until Prompt    strip_prompt=${True}
    ELSE
        FAIL    Unknown or improper connection method: ${dut_connection_method}
    END
    RETURN    ${output}

Read From Terminal Until Regexp
    [Documentation]    Universal keyword to read the console output until the
    ...    defined regexp occurs regardless of the used method of connection to
    ...    the DUT (Telnet or SSH).
    [Arguments]    ${regexp}
    IF    '${dut_connection_method}' == 'Telnet'
        ${output}=    Telnet.Read Until Regexp    ${regexp}
    ELSE IF    '${dut_connection_method}' == 'SSH'
        ${output}=    SSHLibrary.Read Until Regexp    ${regexp}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        ${output}=    SSHLibrary.Read Until Regexp    ${regexp}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        ${output}=    Telnet.Read Until Regexp    ${regexp}
    ELSE
        FAIL    Unknown or improper connection method: ${dut_connection_method}
    END
    RETURN    ${output}

Set Prompt For Terminal
    [Documentation]    Universal keyword to set the prompt (used in Read Until
    ...    prompt keyword) regardless of the used method of connection to
    ...    the DUT (Telnet or SSH).
    [Arguments]    ${prompt}
    IF    '${dut_connection_method}' == 'Telnet'
        Telnet.Set Prompt    ${prompt}    prompt_is_regexp=False
    ELSE IF    '${dut_connection_method}' == 'SSH'
        SSHLibrary.Set Client Configuration    prompt=${prompt}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        SSHLibrary.Set Client Configuration    prompt=${prompt}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        Telnet.Set Prompt    ${prompt}
    ELSE
        FAIL    Unknown or improper connection method: ${dut_connection_method}
    END

Set DUT Response Timeout
    [Documentation]    Universal keyword to set the timeout (used for operations
    ...    that expect some output to appear) regardless of the used method of
    ...    connection to the DUT (Telnet or SSH).
    [Arguments]    ${timeout}
    IF    '${dut_connection_method}' == 'Telnet'
        Telnet.Set Timeout    ${timeout}
    ELSE IF    '${dut_connection_method}' == 'SSH'
        SSHLibrary.Set Client Configuration    timeout=${timeout}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        SSHLibrary.Set Client Configuration    timeout=${timeout}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        Telnet.Set Timeout    ${timeout}
    ELSE
        FAIL    Unknown or improper connection method: ${dut_connection_method}
    END

Write Into Terminal
    [Documentation]    Universal keyword to write text to console regardless of
    ...    the used method of connection to the DUT (Telnet, PiKVMor SSH).
    [Arguments]    ${text}
    IF    '${dut_connection_method}' == 'Telnet'
        Telnet.Write    ${text}
    ELSE IF    '${dut_connection_method}' == 'SSH'
        SSHLibrary.Write    ${text}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        SSHLibrary.Write    ${text}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        Write PiKVM    ${text}
    ELSE
        FAIL    Unknown or improper connection method: ${dut_connection_method}
    END

Write Bare Into Terminal
    [Documentation]    Universal keyword to write bare text (without new line
    ...    mark) to console regardless of the used method of connection to
    ...    the DUT (Telnet, PiKVM or SSH).
    [Arguments]    ${text}
    IF    '${dut_connection_method}' == 'Telnet'
        Telnet.Write Bare    ${text}
    ELSE IF    '${dut_connection_method}' == 'SSH'
        SSHLibrary.Write Bare    ${text}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        SSHLibrary.Write Bare    ${text}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        Write Bare PiKVM    ${text}
    ELSE
        FAIL    Unknown or improper connection method: ${dut_connection_method}
    END

Execute Command In Terminal
    [Documentation]    Universal keyword to execute command regardless of the
    ...    used method of connection to the DUT (Telnet or SSH).
    [Arguments]    ${command}
    IF    '${dut_connection_method}' == 'Telnet'
        ${output}=    Telnet.Execute Command    ${command}    strip_prompt=True
    ELSE IF    '${dut_connection_method}' == 'SSH'
        ${output}=    SSHLibrary.Execute Command    ${command}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        ${output}=    SSHLibrary.Execute Command    ${command}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        Write PiKVM    ${command}
        ${output}=    Telnet.Read Until Prompt
    ELSE
        FAIL    Unknown or improper connection method: ${dut_connection_method}
    END
    RETURN    ${output}

Boot Operating System
    [Documentation]    Keyword allows to boot the system to perform test on OS
    ...    level. How system will be started depends on: connection method and
    ...    platform type.
    [Arguments]    ${operating_system}
    Enter Boot Menu Tianocore
    Enter submenu in Tianocore    ${operating_system}

Login to System with Root Privileges
    [Documentation]    Keyword allows to login to system with root privileges
    ...    to perform test on OS level.
    [Arguments]    ${operating_system}
    IF    '${operating_system}'=='ubuntu'
        Login to System    ${username_ubuntu}    ${password_ubuntu}    ${prompt_ubuntu}
        Switch to root user
    ELSE
        FAIL    Unsupported in test environment OS: ${operating_system}
    END

Login to System
    [Documentation]    Keyword allows to login to system to perform test on
    ...    OS level. Which login method will be used depends on the connection
    ...    method.
    [Arguments]    ${username}    ${password}    ${prompt}
    IF    '${dut_connection_method}' == 'Telnet'
        Telnet.Login    ${username}    ${password}
    ELSE IF    '${dut_connection_method}' == 'SSH'
        SSHLibrary.Login    ${username}    ${password}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        Set DUT Response Timeout    300s
        Read From Terminal Until    login:
        Write Into Terminal    ${username}
        Read From Terminal Until    Password:
        Write Into Terminal    ${password}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        Set DUT Response Timeout    120s
        Read From Terminal Until    login:
        Write Into Terminal    ${username}
        Read From Terminal Until    Password:
        Write Into Terminal    ${password}
    ELSE
        FAIL    Unknown or improper connection method: ${dut_connection_method}
    END
    Set Prompt For Terminal    ${prompt}
    Read From Terminal Until Prompt
    Read From Terminal Until Prompt

Switch to root user
    [Documentation]    Keyword allows to switch to the root environment to
    ...    perform in the OS tasks reserved for user with high priveleges.
    Write Into Terminal    sudo su
    Read From Terminal Until    [sudo] password for ${device_ubuntu_username}:
    Write Into Terminal    ${device_ubuntu_password}
    Set Prompt For Terminal    ${device_ubuntu_root_prompt}
    Read From Terminal Until Prompt
