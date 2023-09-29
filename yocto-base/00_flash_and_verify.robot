*** Settings ***
Library             Collections
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../../sonoff-rest-api/sonoff-api.robot
Resource            ../../rtectrl-rest-api/rtectrl.robot
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../lib/sd-wire.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
Verify number of connected SD Wire devices
    [Documentation]    Test confirms the number of connected SD Wire devices to
    ...    the DUT platform.
    ${sd_wire_id_list}=    Get List Of SD Wire Ids
    ${length_of_sd_wire_id_list}=    Get Length    ${sd_wire_id_list}
    # we are currently doing this because we only expect one SD Wire
    Should Be Equal    ${length_of_sd_wire_id_list}    ${SD_WIRES_CONNECTED}
    FOR    ${index}    IN RANGE    0    ${SD_WIRES_CONNECTED}
        Should Be Equal    ${sd_wire_id_list[${index}]}    ${SD_WIRE_SERIAL1}
    END

Flash platform and verify
    [Documentation]    This test flashes the DUT connected to the RTE through
    ...    the SD Wire, then attempts to log into it over serial to see whether
    ...    it works.
    IF    '${PREV_TEST_STATUS}' == 'FAIL'
        Fail    'Incorrect number of connected SD Wire devices.'
    END
    Variable Should Exist    ${DUT_PASSWORD}
    # flashing
    Flash SD Card Via SD Wire    ${FILE_BMAP}    ${FILE_GZ}    ${SD_WIRE_SERIAL1}
    # telnet
    Telnet.Set Prompt    :~#
    Telnet.Read Until    mobiqam-machine-rpb3 login:
    Telnet.Write Bare    \n
    Telnet.Login    root    ${DUT_PASSWORD}
    ${output}=    Telnet.Execute Command    sh -c "cat /etc/os-release | grep VERSION_ID"
    ${lines}=    Split To Lines    ${output}
    ${actual_version}=    Evaluate    "${lines[0]}".split("=")[-1]
    # get version from file name
    ${gz_name}=    Evaluate    "${FILE_GZ}".split("/")[-1]
    ${flashed_version}=    Replace String    ${gz_name}    .gz    ${EMPTY}
    Should Be Equal As Strings    ${actual_version}    ${flashed_version}
