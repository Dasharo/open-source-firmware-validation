*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

*** Test Cases ***
Flash The Rpi and verify that it is working
    [Documentation]    This test flashes the Rpi connected to the RTE through
    ...    the SD Wire, then attempts to log into it over serial to see whether
    ...    it works.
    Open Connection And Log In
    ${sd_wire_id_list} =    Get List Of SD Wire Ids
    ${length_of_sd_wire_id_list} =    Get Length    ${sd_wire_id_list}
    ${length_of_sd_wire_id_list} =    Convert To String    ${length_of_sd_wire_id_list}
    # we are currently doing this because we only expect one SD Wire
    Should Be Equal    ${length_of_sd_wire_id_list}    1
    Should Be Equal    ${sd_wire_id_list[0]}    sd-wire_01-80
    Flash SD Card Via SD Wire    ${file_bmap}    ${file_gz}    ${sd_wire_id_list[0]}
    # telnet???
    Serial Setup    192.168.4.241    13541
    Telnet.Set Prompt    :~$
    Telnet.Login    root    hjznTZAL4b
    Telnet.Execute Command    echo "robot framework did this" > something.txt
    Log Out And Close Connection
