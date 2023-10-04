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
    # this is done to check whether the id of the SD Wire that's connected
    # to the RTE matches the expected value.
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
    Flash SD Card Via SD Wire    ${FILE_BMAP}    ${FILE_GZ}    ${SD_WIRE_SERIAL1}
    Serial Root Login Linux    ${DUT_PASSWORD}
    ${output}=    Telnet.Execute Command    sh -c "cat /etc/os-release | grep VERSION_ID | cut -d '=' -f 2"
    ${lines}=    Split To Lines    ${output}
    ${file_gz}=    Evaluate    "${FILE_GZ}".split("/")[-1]
    Should Contain    ${file_gz}    ${lines[0]}
