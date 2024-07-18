*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# Library    ../osfv-scripts/osfv_cli/src/osfv/rf/rte_robot.py
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
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${var}=    Check If Empty    ${out}
        IF    ${var} == ${FALSE}    BREAK
        Sleep    1s
    END
    IF    ${var}    Fail    Power On couldn't be detected

BPS001.002 Power Control - Power Off
    [Documentation]    This test verifies if the DUT can be powered down.
    Power On
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${var}=    Check If Empty    ${out}
        IF    ${var} == ${FALSE}    BREAK
        Sleep    1s
    END
    IF    ${var}    Fail    Power On couldn't be detected
    Power Cycle Off
    Sleep    30s
    ${out}=    Read From Terminal
    FOR    ${i}    IN RANGE    30
        ${out}=    Read From Terminal
        ${var}=    Check If Empty    ${out}
        IF    ${var} == ${FALSE}    BREAK
        Sleep    1s
    END
    IF    ${var} == ${FALSE}    Fail    Power Off didn't work

BPS002.001 RTE Relay low
    [Documentation]    Verifies if RTE Relay set to low state will turn off the DUT.
    Skip If    '${POWER_CTRL}' != 'RteCtrl'    DUT doesn't use RTE
    Power On
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${var}=    Check If Empty    ${out}
        IF    ${var} == ${FALSE}    BREAK
        Sleep    1s
    END
    IF    ${var}    Fail    Power On couldn't be detected
    Rte Relay Set    off
    Sleep    30s
    ${out}=    Read From Terminal
    FOR    ${i}    IN RANGE    30
        ${out}=    Read From Terminal
        ${var}=    Check If Empty    ${out}
        IF    ${var} == ${FALSE}    BREAK
        Sleep    1s
    END
    IF    ${var} == ${FALSE}    Fail    Relay set state low didn't work

BPS002.002 RTE Relay high
    [Documentation]    Verifies if RTE Relay set to high state will turn on the DUT.
    Skip If    '${POWER_CTRL}' != 'RteCtrl'    DUT doesn't use RTE
    Power On
    Rte Relay Set    off
    Sleep    30s
    ${out}=    Read From Terminal
    FOR    ${i}    IN RANGE    30
        ${out}=    Read From Terminal
        ${var}=    Check If Empty    ${out}
        IF    ${var} == ${FALSE}    BREAK
        Sleep    1s
    END
    IF    ${var} == ${FALSE}    Fail    Relay set state low didn't work
    Rte Relay Set    on
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${var}=    Check If Empty    ${out}
        IF    ${var} == ${FALSE}    BREAK
        Sleep    1s
    END
    IF    ${var}    Fail    RTE Relay state high couldn't be detected

BPS002.003 RTE Power On
    [Documentation]    Verifies if Power Button can turn on the DUT.
    Skip If    '${POWER_CTRL}' != 'RteCtrl'    DUT doesn't use RTE
    Rte Power Off    ${6}
    Sleep    5s
    Rte Power On    ${6}
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${var}=    Check If Empty    ${out}
        IF    ${var} == ${FALSE}    BREAK
        Sleep    1s
    END
    IF    ${var}    Fail    Power On couldn't be detected

BPS002.004 RTE Power Off
    [Documentation]    Verifies if Power Button can turn off the DUT.
    Skip If    '${POWER_CTRL}' != 'RteCtrl'    DUT doesn't use RTE
    Rte Power Off    ${6}
    Sleep    10s
    Rte Power On    ${6}
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${var}=    Check If Empty    ${out}
        IF    ${var} == ${FALSE}    BREAK
        Sleep    1s
    END
    IF    ${var}    Fail    Power On couldn't be detected
    Rte Power Off    ${6}
    Sleep    30s
    ${out}=    Read From Terminal
    FOR    ${i}    IN RANGE    30
        ${out}=    Read From Terminal
        ${var}=    Check If Empty    ${out}
        IF    ${var} == ${FALSE}    BREAK
        Sleep    1s
    END
    IF    ${var} == ${FALSE}    Fail    Rte Power Off didn't work

BPS002.005 RTE Reset
    [Documentation]    Verifies if RTE Reset works
    Skip If    '${POWER_CTRL}' != 'RteCtrl'    DUT doesn't use RTE
    Power On
    Sleep    60s
    FOR    ${i}    IN RANGE    30
        ${out_temp}=    Read From Terminal
        Sleep    10s
        ${out}=    Read From Terminal
        IF    '${out_temp}' == '${out}'    BREAK
    END
    Rte Reset    ${5}
    # RteCtrl Reset
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${var}=    Check If Empty    ${out}
        IF    ${var} == ${FALSE}    BREAK
        Sleep    1s
    END
    IF    ${var}    Fail    Power On couldn't be detected

BPS003.001 Sonoff Power On
    [Documentation]    This test verifies if the DUT can be powerd on by Sonoff
    Skip If    '${POWER_CTRL}' != 'sonoff'    DUT doesn't use Sonoff
    Sonoff Power Cycle On
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${out_length}=    Get Length    ${out}
        IF    ${out_length} != 0    BREAK
        Sleep    1s
    END
    IF    ${out_length} == 0    Fail    No serial output detected

BPS003.002 Sonoff Power Off
    [Documentation]    This test verifies if the DUT can be shutdown by Sonoff
    Skip If    '${POWER_CTRL}' != 'sonoff'    DUT doesn't use Sonoff
    Sonoff Power Cycle On
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${out_length}=    Get Length    ${out}
        IF    ${out_length} != 0    BREAK
        Sleep    1s
    END
    IF    ${out_length} == 0    Fail    No serial output detected
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
    [Documentation]    This test verifies if the flash die can be detected.
    ${result}=    Run Process    osfv_cli    rte    --rte_ip    ${RTE_IP}    flash    probe
    Should Not Match    ${result.stdout}    *No EEPROM/flash device found.*
    Should Match    ${result.stdout}    *Found * flash chip * on *
    Should Be Equal As Integers    ${result.rc}    0
    Should Be Empty    ${result.stderr}

BPS005.002 Internal flashing
    [Documentation]    This test verifies if flashrom can detect the die.
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    Should Contain    ${out_flashrom}    Found chipset


*** Keywords ***
Check If Empty
    [Documentation]    Checks if string is empty. Ignores spaces and newline.
    [Arguments]    ${str}
    ${str_length}=    Get Length    ${str}
    IF    ${str_length} != 0
        @{str}=    Split String To Characters    ${str}
        FOR    ${char}    IN    @{str}
            IF    '${char.replace('\n','').strip()}' != '${SPACE}'
                RETURN    ${FALSE}
            END
        END
    END
    RETURN    ${TRUE}
