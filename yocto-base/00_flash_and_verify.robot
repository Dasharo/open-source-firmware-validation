*** Settings ***
Library             Collections
Library             OperatingSystem
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../../sonoff-rest-api/sonoff-api.robot
Resource            ../../rtectrl-rest-api/rtectrl.robot
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../lib/sd-wire.robot
Resource            ../lib/linux.robot

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
    ${version}=    Get Linux Version ID
    ${dir}    ${file_gz}=    Split Path    ${FILE_GZ}
    Should Contain    ${file_gz}    ${version}
