*** Keywords ***
Prepare Test Suite
    [Documentation]    Keyword allows to prepare Test Suite by importing
    ...    specific platform configuration keywords and variables and preparing
    ...    connection with the DUT based on used transmission protocol.
    ...    Keyword used in all [Suite Setup] sections.
    Import Needed Resources
    Check Stand Address Correctness
    Prepare Devices For Power Control
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        SSHLibrary.Set Default Configuration    timeout=60 seconds
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Open Connection And Log In
        Get DUT To Start State
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        No Operation
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        ${pikvm_address}=    Get Pikvm Ip    ${STAND_IP}
        Set Global Variable    ${PIKVM_IP}    ${pikvm_address}
        Open Connection And Log In
        Get DUT To Start State
    ELSE
        FAIL    Unknown or improper connection method: ${DUT_CONNECTION_METHOD}
    END

Import Needed Resources
    [Documentation]    Keyword allows to prepare test suite by importing
    ...    specific resources dedicated for the testing stand and tested
    ...    platform.
    Import Resource    ${CURDIR}/platform-configs/${CONFIG}.robot
    IF    ${TESTS_IN_FIRMWARE_SUPPORT}
        Import Resource    ${CURDIR}/firmware-keywords.robot
    END
    IF    ${TESTS_IN_UBUNTU_SUPPORT}
        Import Resource    ${CURDIR}/keys-and-keywords/ubuntu-keywords.robot
    END

Prepare Devices For Power Control
    [Documentation]    Keyword allows to prepare devices for power control on
    ...    the stand. Depends on stand configuration, keyword starts
    ...    RTE REST API and/or Sonoff REST API sessions and sets global variable
    ...    ${power _control} used during preparing DUT to start state
    ${rte_presence}=    Check RTE Presence On Stand    ${STAND_IP}
    ${sonoff_presence}=    Check Sonoff Presence On Stand    ${STAND_IP}
    IF    ${rte_presence}
        Set Global Variable    ${RTE_IP}    ${STAND_IP}
        Set Global Variable    ${PC}    rte
        REST API Setup    RteCtrl
    END
    IF    ${sonoff_presence}
        ${sonoff_ip}=    Get Sonoff Ip    ${STAND_IP}
        Set Global Variable    ${PC}    sonoff
        Set Global Variable    ${SONOFF_SESSION_HANDLER}    SonoffCtrl
        Sonoff API Setup    ${SONOFF_SESSION_HANDLER}    ${sonoff_ip}
    END

Open Connection And Log In
    [Documentation]    Keyword allows to prepare test suite by initializing
    ...    SSH and Telnet connections.
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    SSHLibrary.Open Connection    ${STAND_IP}    prompt=~#
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    Serial Setup    ${RTE_IP}    ${RTE_S2_N_PORT}
    IF    '${SNIPEIT}'=='no'    RETURN
    SnipeIt API Setup    SnipeItApi
    SnipeIt Checkout    ${STAND_IP}

Get DUT To Start State
    [Documentation]    Keyword allows to prepare DUT to start state - clears
    ...    Terminal and sets Device Under Test to start state (RTE Relay On).
    Read From Terminal
    ${result}=    Get Power Supply State
    IF    '${result}'=='low'    Turn On Power Supply

Get Power Supply State
    [Documentation]    Keyword allows to obtain current power supply state.
    IF    '${PC}'=='sonoff'
        ${state}=    Get Sonoff State    ${SONOFF_SESSION_HANDLER}
    ELSE IF    '${PC}'=='rte'
        ${state}=    Get RTE Relay State
    ELSE
        FAIL    Unknown power control method for stand: ${STAND_IP}
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
    IF    'sonoff' == '${PC}'
        Sonoff Power On    ${SONOFF_SESSION_HANDLER}
    ELSE IF    '${PC}'=='rte'
        RteCtrl Relay
    ELSE
        FAIL    Unknown power control method for stand: ${STAND_IP}
    END

Power Cycle On
    [Documentation]    Keyword allows to perform the DUT full power on cycle -
    ...    clears Terminal and sets Device Under Test to start state.
    IF    'sonoff' == '${PC}'
        Telnet.Read
        Sonoff Power Off    ${SONOFF_SESSION_HANDLER}
        Sleep    1s
        Sonoff Power On    ${SONOFF_SESSION_HANDLER}
        Sleep    15s
        Power On
    ELSE IF    '${PC}'=='rte'
        Telnet.Read
        ${result}=    RteCtrl Relay
        IF    ${result} == 0
            Run Keywords
            ...    Sleep    4s
            ...    AND
            ...    Telnet.Read
            ...    AND
            ...    RteCtrl Relay
        END
    ELSE
        FAIL    Unknown power control method for stand: ${STAND_IP}
    END

Power Cycle Off
    [Documentation]    Keyword allows to perform the DUT full power on cycle -
    ...    closes serial connection and sets Device Under Test to off state.
    Telnet.Close All Connections
    IF    'sonoff' == '${PC}'
        Sonoff Power On    ${SONOFF_SESSION_HANDLER}
        Sleep    1s
        Sonoff Power Off    ${SONOFF_SESSION_HANDLER}
    ELSE IF    '${PC}'=='rte'
        Sleep    1s
        ${result}=    Get RTE Relay State
        IF    '${result}' == 'high'    RteCtrl Relay
    ELSE
        FAIL    Unknown power control method for stand: ${STAND_IP}
    END
    Serial Setup    ${RTE_IP}    ${RTE_S2_N_PORT}

Serial Setup
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
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        ${is_address_correct}=    Check Platform Provided Ip    ${STAND_IP}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        ${is_address_correct}=    Check RTE Provided Ip    ${STAND_IP}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        ${is_address_correct}=    Check RTE Provided Ip    ${STAND_IP}
    ELSE
        FAIL    Unknown or improper connection method: ${DUT_CONNECTION_METHOD}
    END
    IF    ${is_address_correct}    RETURN
    FAIL    stand_ip:${STAND_IP} not found in the hardware configuration.

Log Out And Close Connection
    [Documentation]    Keyword allows to close all opened SSH, serial
    ...    connections and checkin used asset in SnipeIt.
    SSHLibrary.Close All Connections
    Telnet.Close All Connections
    IF    '${SNIPEIT}'=='yes'    SnipeIt Checkin    ${STAND_IP}

Flash Firmware
    [Documentation]    Keyword allows to flash platform with selected firmware
    ...    by using default flashing method. Takes firmware file (${fw_file})
    ...    as an argument. Keyword fails if file size doesn't match target
    ...    chip size.
    [Arguments]    ${fw_file}
    ${file_size}=    Run    ls -l ${fw_file} | awk '{print $5}'
    IF    '${file_size}'!='${FLASH_SIZE}'
        FAIL    Image size doesn't match the flash chip's size!
    END
    IF    '${DEFAULT_FLASHING_METHOD}'=='external programmer'
        Flash Firmware With External Programmer    ${fw_file}
    ELSE
        FAIL    Unsupported flashing method: ${DEFAULT_FLASHING_METHOD}
    END

Get Firmware Version From Binary
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

Get Firmware Version
    [Documentation]    Keyword allows to obtain the firmware version by
    ...    using method defined in the configuration. Takes binary file path
    ...    as an argument.
    Set DUT Response Timeout    120s
    IF    '${FLASH_VERIFY_METHOD}'=='iPXE-boot'
        No Operation
    ELSE IF    '${FLASH_VERIFY_METHOD}'=='tianocore-setup-menu'
        ${firmware_version}=    Get Firmware Version From Tianocore Setup Menu
    ELSE
        FAIL    Unsupported flash verify method: ${FLASH_VERIFY_METHOD}
    END
    Set DUT Response Timeout    30s
    RETURN    ${firmware_version[0]}

Read From Terminal
    [Documentation]    Universal keyword to read the console output regardless
    ...    of the used method of connection to the DUT
    ...    (Telnet or SSH).
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        ${output}=    Telnet.Read
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        ${output}=    SSHLibrary.Read
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        ${output}=    SSHLibrary.Read
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        ${output}=    Telnet.Read
    ELSE
        FAIL    Unknown or improper connection method: ${DUT_CONNECTION_METHOD}
    END
    RETURN    ${output}

Read From Terminal Until
    [Documentation]    Universal keyword to read the console output until the
    ...    defined text occurs regardless of the used method of connection to
    ...    the DUT (Telnet or SSH).
    [Arguments]    ${expected}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        ${output}=    Telnet.Read Until    ${expected}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        ${output}=    SSHLibrary.Read Until    ${expected}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        ${output}=    SSHLibrary.Read Until    ${expected}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        ${output}=    Telnet.Read Until    ${expected}
    ELSE
        FAIL    Unknown or improper connection method: ${DUT_CONNECTION_METHOD}
    END
    RETURN    ${output}

Read From Terminal Until Prompt
    [Documentation]    Universal keyword to read the console output until the
    ...    defined prompt occurs regardless of the used method of connection to
    ...    the DUT (Telnet or SSH).
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        ${output}=    Telnet.Read Until Prompt    strip_prompt=${TRUE}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        ${output}=    SSHLibrary.Read Until Prompt    strip_prompt=${TRUE}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        ${output}=    SSHLibrary.Read Until Prompt    strip_prompt=${TRUE}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        ${output}=    Telnet.Read Until Prompt    strip_prompt=${TRUE}
    ELSE
        FAIL    Unknown or improper connection method: ${DUT_CONNECTION_METHOD}
    END
    RETURN    ${output}

Read From Terminal Until Regexp
    [Documentation]    Universal keyword to read the console output until the
    ...    defined regexp occurs regardless of the used method of connection to
    ...    the DUT (Telnet or SSH).
    [Arguments]    ${regexp}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        ${output}=    Telnet.Read Until Regexp    ${regexp}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        ${output}=    SSHLibrary.Read Until Regexp    ${regexp}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        ${output}=    SSHLibrary.Read Until Regexp    ${regexp}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        ${output}=    Telnet.Read Until Regexp    ${regexp}
    ELSE
        FAIL    Unknown or improper connection method: ${DUT_CONNECTION_METHOD}
    END
    RETURN    ${output}

Set Prompt For Terminal
    [Documentation]    Universal keyword to set the prompt (used in Read Until
    ...    prompt keyword) regardless of the used method of connection to
    ...    the DUT (Telnet or SSH).
    [Arguments]    ${prompt}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Telnet.Set Prompt    ${prompt}    prompt_is_regexp=False
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        SSHLibrary.Set Client Configuration    prompt=${prompt}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        SSHLibrary.Set Client Configuration    prompt=${prompt}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Telnet.Set Prompt    ${prompt}
    ELSE
        FAIL    Unknown or improper connection method: ${DUT_CONNECTION_METHOD}
    END

Set DUT Response Timeout
    [Documentation]    Universal keyword to set the timeout (used for operations
    ...    that expect some output to appear) regardless of the used method of
    ...    connection to the DUT (Telnet or SSH).
    [Arguments]    ${timeout}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Telnet.Set Timeout    ${timeout}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        SSHLibrary.Set Client Configuration    timeout=${timeout}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        SSHLibrary.Set Client Configuration    timeout=${timeout}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Telnet.Set Timeout    ${timeout}
    ELSE
        FAIL    Unknown or improper connection method: ${DUT_CONNECTION_METHOD}
    END

Write Into Terminal
    [Documentation]    Universal keyword to write text to console regardless of
    ...    the used method of connection to the DUT (Telnet, PiKVMor SSH).
    [Arguments]    ${text}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Telnet.Write    ${text}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        SSHLibrary.Write    ${text}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        SSHLibrary.Write    ${text}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Write PiKVM    ${text}
    ELSE
        FAIL    Unknown or improper connection method: ${DUT_CONNECTION_METHOD}
    END

Write Bare Into Terminal
    [Documentation]    Universal keyword to write bare text (without new line
    ...    mark) to console regardless of the used method of connection to
    ...    the DUT (Telnet, PiKVM or SSH).
    [Arguments]    ${text}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Telnet.Write Bare    ${text}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        SSHLibrary.Write Bare    ${text}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        SSHLibrary.Write Bare    ${text}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Write Bare PiKVM    ${text}
    ELSE
        FAIL    Unknown or improper connection method: ${DUT_CONNECTION_METHOD}
    END

Execute Command In Terminal
    [Documentation]    Universal keyword to execute command regardless of the
    ...    used method of connection to the DUT (Telnet or SSH).
    [Arguments]    ${command}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        ${output}=    Telnet.Execute Command    ${command}    strip_prompt=True
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        ${output}=    SSHLibrary.Execute Command    ${command}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        ${output}=    SSHLibrary.Execute Command    ${command}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Write PiKVM    ${command}
        ${output}=    Telnet.Read Until Prompt
    ELSE
        FAIL    Unknown or improper connection method: ${DUT_CONNECTION_METHOD}
    END
    RETURN    ${output}

Boot Operating System
    [Documentation]    Keyword allows to boot the system to perform test on OS
    ...    level. How system will be started depends on: connection method and
    ...    platform type.
    [Arguments]    ${operating_system}
    Enter Boot Menu Tianocore
    Enter Submenu In Tianocore    ${operating_system}

Login To System With Root Privileges
    [Documentation]    Keyword allows to login to system with root privileges
    ...    to perform test on OS level.
    [Arguments]    ${operating_system}
    IF    '${operating_system}'=='ubuntu'
        Login To System    ${USERNAME_UBUNTU}    ${PASSWORD_UBUNTU}    ${PROMPT_UBUNTU}
        Switch To Root User
    ELSE
        FAIL    Unsupported in test environment OS: ${operating_system}
    END

Login To System
    [Documentation]    Keyword allows to login to system to perform test on
    ...    OS level. Which login method will be used depends on the connection
    ...    method.
    [Arguments]    ${username}    ${password}    ${prompt}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Telnet.Login    ${username}    ${password}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        SSHLibrary.Login    ${username}    ${password}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        Set DUT Response Timeout    300s
        Read From Terminal Until    login:
        Write Into Terminal    ${username}
        Read From Terminal Until    Password:
        Write Into Terminal    ${password}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Set DUT Response Timeout    120s
        Read From Terminal Until    login:
        Write Into Terminal    ${username}
        Read From Terminal Until    Password:
        Write Into Terminal    ${password}
    ELSE
        FAIL    Unknown or improper connection method: ${DUT_CONNECTION_METHOD}
    END
    Set Prompt For Terminal    ${prompt}
    Read From Terminal Until Prompt
    Read From Terminal Until Prompt

Switch To Root User
    [Documentation]    Keyword allows to switch to the root environment to
    ...    perform in the OS tasks reserved for user with high privileges.
    Write Into Terminal    sudo su
    Read From Terminal Until    [sudo] password for ${DEVICE_UBUNTU_USERNAME}:
    Write Into Terminal    ${DEVICE_UBUNTU_PASSWORD}
    Set Prompt For Terminal    ${DEVICE_UBUNTU_ROOT_PROMPT}
    Read From Terminal Until Prompt
