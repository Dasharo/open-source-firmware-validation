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
Flash platform and verify
    [Documentation]    This test flashes the DUT connected to the RTE through
    ...    the SD Wire, then attempts to log into it over serial to see whether
    ...    it works.
    Variable Should Exist    ${DUT_PASSWORD}
    Variable Should Exist    ${FILE_BMAP}
    Variable Should Exist    ${FILE_GZ}
    Flash SD Card Via SD Wire    ${FILE_BMAP}    ${FILE_GZ}    ${SD_WIRE_SERIAL1}
    Serial Root Login Linux    ${DUT_PASSWORD}
    ${output}=    Telnet.Execute Command    sh -c "cat /etc/os-release | grep VERSION_ID | cut -d '=' -f 2"
    ${lines}=    Split To Lines    ${output}
    ${file_gz}=    Evaluate    "${FILE_GZ}".split("/")[-1]
    Should Contain    ${file_gz}    ${lines[0]}
