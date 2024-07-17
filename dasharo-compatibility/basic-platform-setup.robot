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
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${var}=    Check If Empty    ${out}
        IF    ${var} == ${FALSE}    BREAK
        Sleep    1s
    END
    IF    ${var}    Fail    Power On Couldn't Be Detected

BPS001.002 Power Control - Power Off
    [Documentation]    This test verifies if the DUT can be powered down.
    Power On
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${var}=    Check If Empty    ${out}
        IF    ${var} == ${FALSE}    BREAK
        Sleep    1s
    END
    IF    ${var}    Fail    Power On Couldn't Be Detected
    Power Cycle Off
    Sleep    30s
    ${out}=    Read From Terminal
    FOR    ${i}    IN RANGE    30
        ${out}=    Read From Terminal
        ${var}=    Check If Empty    ${out}
        IF    ${var} == ${FALSE}    BREAK
        Sleep    1s
    END
    IF    ${var}    Fail    Power Off didn't work

BPS002.001 RTE Relay low
    Skip If    not '${POWER_CTRL}'    'RteCtrl'

BPS002.002 RTE Relay high
    Skip If    not '${POWER_CTRL}'    'RteCtrl'

BPS002.003 RTE Power On
    Skip If    not '${POWER_CTRL}'    'RteCtrl'
    RteCtrl Power Off    ${6}
    Sleep    5s
    Power Cycle On
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${out_length}=    Get Length    ${out}
        IF    ${out_length} != 0    BREAK
        Sleep    1s
    END
    IF    ${out_length} == 0    Fail    No serial output detected

BPS002.004 RTE Power Off
    Skip If    not '${POWER_CTRL}'    'RteCtrl'
    RteCtrl Power Off    ${6}
    Sleep    5s
    Power Cycle On
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${out_length}=    Get Length    ${out}
        IF    ${out_length} != 0    BREAK
        Sleep    1s
    END
    IF    ${out_length} == 0    Fail    No serial output detected
    Sleep    10s
    RteCtrl Power Off    ${6}
    ${out}=    Read From Terminal
    Should Be Empty    ${out}

BPS002.005 RTE Reset
    Skip If    not '${POWER_CTRL}'    'RteCtrl'

BPS003.001 Sonoff Power On
    Skip If    not '${POWER_CTRL}'    'sonoff'
    Sonoff Power Cycle On
    FOR    ${i}    IN RANGE    120
        ${out}=    Read From Terminal
        ${out_length}=    Get Length    ${out}
        IF    ${out_length} != 0    BREAK
        Sleep    1s
    END
    IF    ${out_length} == 0    Fail    No serial output detected

BPS003.002 Sonoff Power Off
    Skip If    not '${POWER_CTRL}'    'sonoff'
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
