*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
BPS001.001 Power Control - Power On and Serial output
    [Documentation]    Verifies if the DUT can be turned On and if the serial output can be read.
    Power On
    Sleep    60s
    ${out}=    Read From Terminal
    Should Not Be Empty    ${out}

BPS001.002 Power Control - Power Off
    [Documentation]    This test verifies if the DUT can be powered down.
    Power On
    Sleep    60s
    ${out}=    Read From Terminal
    Should Not Be Empty    ${out}
    Power Cycle Off
    Sleep    30s
    ${out}=    Read From Terminal
    Should Be Empty    ${out}


BPS002.001 RTE Relay low
    [Documentation]
    Skip If    not '${POWER_CTRL}'    'RteCtrl'


BPS002.002 RTE Relay high
    [Documentation]
    Skip If    not '${POWER_CTRL}'    'RteCtrl'


BPS002.003 RTE Power On
    [Documentation]
    Skip If    not '${POWER_CTRL}'    'RteCtrl'
    RteCtrl Power Off    ${6}
    Sleep    5s
    Power Cycle On
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${out_length}=    Get Length    ${out}
        Exit For Loop If    ${out_length} != 0
        Sleep    1s
    END
    IF    ${out_length} == 0
        Fail    No serial output detected
    END

BPS002.004 RTE Power Off
    [Documentation]
    Skip If    not '${POWER_CTRL}'    'RteCtrl'
    RteCtrl Power Off    ${6}
    Sleep    5s
    Power Cycle On
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${out_length}=    Get Length    ${out}
        Exit For Loop If    ${out_length} != 0
        Sleep    1s
    END
    IF    ${out_length} == 0
        Fail    No serial output detected
    END
    Sleep    10s
    RteCtrl Power Off    ${6}
    ${out}=    Read From Terminal
    Should Be Empty    ${out}


BPS002.005 RTE Reset
    [Documentation]
    Skip If    not '${POWER_CTRL}'    'RteCtrl'


BPS003.001 Sonoff Power On
    [Documentation]
    Skip If    not '${POWER_CTRL}'    'sonoff'
    Sonoff Power Cycle On
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${out_length}=    Get Length    ${out}
        Exit For Loop If    ${out_length} != 0
        Sleep    1s
    END
    IF    ${out_length} == 0
        Fail    No serial output detected
    END

BPS003.002 Sonoff Power Off
    [Documentation]
    Skip If    not '${POWER_CTRL}'    'sonoff'
    Sonoff Power Cycle On
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${out_length}=    Get Length    ${out}
        Exit For Loop If    ${out_length} != 0
        Sleep    1s
    END
    IF    ${out_length} == 0
        Fail    No serial output detected
    END
    Sleep    10s
    Sonoff Power Cycle Off
    ${out}=    Read From Terminal
    Should Be Empty    ${out}

BPS004.001 Boot to OS - Ubuntu
    [Documentation]    This test verifies if platform can be booted to Ubunto and if correct credentials are set.
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User

BPS004.002 Boot to OS - Windows
    [Documentation]    This test verifies if platform can be booted to Windows, if SSH server is enabled and if correct credentials are set.
    Power On
    Login To Windows

BPS005.001 External flashing
    [Documentation]    This test verifies if flashrom can detect the die.

    ${result}=    Run Process    osfv_cli    rte    --rte_ip    ${rte_ip}    flash    probe
    Should Not Match    ${result.stdout}    *No EEPROM/flash device found.*
    Should Match    ${result.stdout}    *Found * flash chip * on *
    Should Be Equal As Integers    ${result.rc}    0
    Should Be Empty    ${result.stderr}

BPS005.002 Internal flashing
    [Documentation]

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    Should Contain    ${out_flashrom}    Found chipset




Power On
    RteCtrl Power Off    ${6}
    Sleep    5s
    Power Cycle On

Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    Sleep    2s
    RteCtrl Power Off
    Sleep    10s
    Telnet.Read
    # After RteCtrl Power Off, the platform cannot be powered back using the power button.
    # Possibly bug in HW or FW.
    Power Cycle On

Power On
    [Documentation]    Keyword clears SSH buffer and sets Device Under Test
    ...    into Power On state from Mechanical Off. (coldboot) For example:
    ...    sonoff, RTE relays.
    IF    "${POWER_CTRL}"=="none"    RETURN
    Restore Initial DUT Connection Method
    Power Cycle On
    Sleep    2s
    RteCtrl Set OC GPIO    12    low
    Sleep    1s
    RteCtrl Set OC GPIO    12    high-z


Power On
    [Documentation]    Keyword sets Device Under Test into Power On state using
    ...    openbmc-test-automation library and opens console client.
    ...    Implementation must be compatible with the theory of
    ...    operation of a specific platform.
    Variable Should Exist    ${OPENBMC_HOST}
    Set Global Variable    ${AUTH_URI}    https://${OPENBMC_HOST}${AUTH_SUFFIX}
    ${host_state}=    Get Host State
    IF    '${host_state}' != 'Off'    Initiate Host PowerOff
    ${host_state}=    Get Host State
    Should Be True    '${host_state}' == 'Off'
    # Flush any output from previous boot
    Read From Terminal
    Initiate Host Boot    0