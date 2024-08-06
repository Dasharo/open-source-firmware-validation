*** Settings ***
Library             Collections
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
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


*** Variables ***
# Assume Dasharo as a default firmware, can be overwritten by CMD parameter.
${FIRMWARE}=    dasharo


*** Test Cases ***
BPS001.001 Power Control - Power On and Serial output
    [Documentation]    Verifies if the DUT can be turned On and if the serial output can be read.
    Power On
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Power On keyword failed

BPS001.002 Power Control - Power Off
    [Documentation]    This test verifies if the DUT can be powered down.
    Power On
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Power On keyword failed

    Power Cycle Off
    ${out}=    Read From Terminal
    ${result}=    Wait For Serial Output    timeout=10
    Should Not Be True    ${result}    msg=Power Cycle Off keyword failed

BPS002.001 RTE Relay low
    [Documentation]    Verifies if RTE Relay set to low state will turn off the DUT.
    Skip If    '${POWER_CTRL}' != 'RteCtrl'    DUT doesn't use RTE relay for power control
    Power On
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Power On keyword failed

    Rte Relay Set    off
    Read From Terminal
    ${result}=    Wait For Serial Output    timeout=10
    Should Not Be True    ${result}    msg=Failed to power off DUT via relay

BPS002.002 RTE Relay high
    [Documentation]    Verifies if RTE Relay set to high state will turn on the DUT.
    Skip If    '${POWER_CTRL}' != 'RteCtrl'    DUT doesn't use RTE relay for power control
    Power On
    Rte Relay Set    off
    Read From Terminal
    ${result}=    Wait For Serial Output    timeout=10
    Should Not Be True    ${result}    msg=Failed to power off DUT via relay

    Rte Relay Set    on
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Failed to power on DUT via relay

BPS002.003 RTE Power On
    [Documentation]    Verifies if Power Button can turn on the DUT.
    # TODO: do we have platforms in the lab that might not use
    # power/reset buttons? If so, we do not have flag for it.
    Power On
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Power On keyword failed

    Rte Power Off
    Sleep    10s
    Read From Terminal
    ${result}=    Wait For Serial Output    timeout=10
    Should Not Be True    ${result}    msg=Failed to power off DUT via power button

    Rte Power On
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Failed to power on DUT via power button

BPS002.004 RTE Power Off
    [Documentation]    Verifies if Power Button can turn off the DUT.
    Power On
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Power On keyword failed

    Rte Power Off
    Sleep    10s
    Read From Terminal
    ${result}=    Wait For Serial Output    timeout=10
    Should Not Be True    ${result}    msg=Failed to power off DUT via power button

BPS002.005 RTE Reset
    [Documentation]    Verifies if RTE Reset works
    Power On
    Wait For Serial Output
    Rte Reset
    Read From Terminal
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Failed to reset DUT via reset button

BPS003.001 Sonoff Power On
    [Documentation]    This test verifies if the DUT can be powerd on by Sonoff
    Skip If    '${POWER_CTRL}' != 'sonoff'    DUT doesn't use Sonoff
    Sonoff Power Cycle On
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Failed power on DUT via Sonoff

BPS003.002 Sonoff Power Off
    [Documentation]    This test verifies if the DUT can be shutdown by Sonoff
    Skip If    '${POWER_CTRL}' != 'sonoff'    DUT doesn't use Sonoff
    Sonoff Power Cycle On
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Failed power on DUT via Sonoff
    Sonoff Power Cycle Off
    Read From Terminal
    ${result}=    Wait For Serial Output    timeout=10
    Should Not Be True    ${result}    msg=Failed power off DUT via Sonoff

BPS004.001 Boot to OS - Dasharo, Ubuntu
    [Documentation]    This test verifies if platform with Dasharo firmware can
    ...    be booted to Ubunto and if correct credentials are set.
    Skip If    '${FIRMWARE}' != 'dasharo'
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User

BPS004.002 Boot to OS - Dasharo, Windows
    [Documentation]    This test verifies if platform with Dasharo firmware can
    ...    be booted to Windows, if SSH server is enabled and if correct
    ...    credentials are set.
    Skip If    '${FIRMWARE}' != 'dasharo' and '${FIRMWARE}' != ''
    Power On
    Login To Windows

BPS004.003 Boot to OS - AMI, Ubuntu
    [Documentation]    This test verifies if platform with AMI firmware can
    ...    be booted to Ubuntu and if correct credentials are set.
    Skip If    '${FIRMWARE}' != 'ami'
    Power On
    Execute Manual Step    Boot to Ubuntu
    Login To Linux
    Switch To Root User

BPS004.004 Boot to OS - AMI, Windows
    [Documentation]    This test verifies if platform with AMI firmware can be
    ...    booted to Windows, if SSH server is enabled and if correct
    ...    credentials are set.
    Skip If    '${FIRMWARE}' != 'ami'
    Power On
    Execute Manual Step    Boot to Windows
    Login To Windows Via SSH

BPS005.001 External flashing
    [Documentation]    This test verifies if the flash die can be detected.
    ${rc}=    Rte Flash Probe
    Should Be Equal As Integers    ${rc}    0

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

Wait For Serial Output
    [Documentation]    This keywords checks every second if non-whitespace
    ...    characters had appeared on the serial output. As soon as it happens,
    ...    it returns True. If it fails to receive any non-whitespace
    ...    characters as output during period defined as ${timeout} argument,
    ...    it returns False.
    [Arguments]    ${timeout}=120

    FOR    ${i}    IN RANGE    ${timeout}
        Sleep    1s
        ${out}=    Read From Terminal
        ${result}=    Check If Empty    ${out}
        IF    ${result} == ${FALSE}    RETURN    ${TRUE}
    END
    RETURN    ${FALSE}
