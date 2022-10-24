*** Settings ***
Library     SSHLibrary    timeout=90 seconds
Library     Telnet    timeout=20 seconds
Library     Process
Library     OperatingSystem
Library     String
Library     RequestsLibrary
Library     Collections

Suite Setup       Prepare platform    ${fw_file}

Resource    ../lib/sonoffctrl.robot
Resource    ../rtectrl-rest-api/rtectrl.robot
Resource    ../snipeit-rest-api/snipeit-api.robot
Resource    ../variables.robot
Resource    ../keywords.robot

*** Keywords ***

Prepare platform
    [Documentation]    Keyword allows to initialize connections and flash
    ...    firmware by using default method. Takes firmware file (${fw_file})
    ...    as an argument.
    [Arguments]    ${fw_file}
    Variable Should Exist    ${fw_file}
    Prepare Test Suite
    Flash firmware    ${fw_file}
    ${coreboot_version}=    Get firmware version from binary    /tmp/coreboot.rom
    ${version}=    Get firmware version
    Log Out And Close Connection
    Should Contain    ${coreboot_version}    ${version}
