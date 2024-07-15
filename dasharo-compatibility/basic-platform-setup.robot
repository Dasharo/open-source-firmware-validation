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
BPS001.001 Power Control
    [Documentation]    This test verifies if the power control
    ...    works, depending on the power control method
#    IF    '${POWER_CTRL}' == 'RteCtrl'
#        IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
#        Sleep    2s
#        RteCtrl Power Off
#        Sleep    10s
#        Telnet.Read
#        RteCtrl Power On

#    ELSE IF    '${POWER_CTRL}' == 'sonoff'
#        IF    "${POWER_CTRL}"=="none"    RETURN
#        Restore Initial DUT Connection Method
#        Power Cycle On
#        Sleep    2s
#        RteCtrl Set OC GPIO    12    low
#        Sleep    1s
#        RteCtrl Set OC GPIO    12    high-z

#    ELSE IF    '${POWER_CTRL}' == 'obmcutil'
#        Variable Should Exist    ${OPENBMC_HOST}
#        Set Global Variable    ${AUTH_URI}    https://${OPENBMC_HOST}${AUTH_SUFFIX}
#        ${host_state}=    Get Host State
#        IF    '${host_state}' != 'Off'    Initiate Host PowerOff
#        ${host_state}=    Get Host State
#        Should Be True    '${host_state}' == 'Off'
#        Read From Terminal
#        Initiate Host Boot    0
#
#    ELSE
#        FAIL    Unknown Power Control Method
#    END

    Power On
    Sleep    30s
    IF    '${SETUP_MENU_KEY}' == '${DELETE}'
        ${option}    Set Variable    DEL
    ELSE IF    '${SETUP_MENU_KEY}' == '${F2}'
        ${option}    Set Variable    F2
    ELSE
        ${option}    Set Variable    Boot
    END

    ${out}=    Read From Terminal Until    ${option}    

BPS002.001 Serial
    [Documentation]
    Power On

BPS003.001 External flashing
    [Documentation]
    Power On

BPS004.001 Boot to OS
    [Documentation]
    Power On
