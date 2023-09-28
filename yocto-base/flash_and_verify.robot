*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../../sonoff-rest-api/sonoff-api.robot
Resource            ../../rtectrl-rest-api/rtectrl.robot
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot
Resource            ../sd-wire.robot

Suite Setup         Open Connection And Log In
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
Flash The Rpi and verify that it is working
    [Documentation]    This test flashes the Rpi connected to the RTE through
    ...    the SD Wire, then attempts to log into it over serial to see whether
    ...    it works.
    Variable Should Exist    ${RPI_PASSWORD}
    # flashing
    ${sd_wire_id_list}=    Get List Of SD Wire Ids
    ${length_of_sd_wire_id_list}=    Get Length    ${sd_wire_id_list}
    ${length_of_sd_wire_id_list}=    Convert To String    ${length_of_sd_wire_id_list}
    # we are currently doing this because we only expect one SD Wire
    Should Be Equal    ${length_of_sd_wire_id_list}    1
    Should Be Equal    ${sd_wire_id_list[0]}    sd-wire_01-80
    Flash SD Card Via SD Wire    ${FILE_BMAP}    ${FILE_GZ}    ${sd_wire_id_list[0]}
    # telnet
    Telnet.Set Prompt    :~#
    Telnet.Read Until    mobiqam-machine-rpb3 login:
    Telnet.Write Bare    \n
    Telnet.Login    root    ${RPI_PASSWORD}
    Telnet.Execute Command    echo "robot framework did this" > something.txt
    ${output}=    Telnet.Execute Command    cat something.txt
    ${lines}=    Split To Lines    ${output}
    Should Be Equal As Strings    ${lines[0]}    robot framework did this
    Log Out And Close Connection
