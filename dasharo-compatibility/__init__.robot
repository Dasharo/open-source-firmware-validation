*** Settings ***
Library         SSHLibrary    timeout=90 seconds
Library         Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library         Process
Library         OperatingSystem
Library         String
Library         RequestsLibrary
Library         Collections
Library         ../../lib/TestingStands.py
Resource        ../keys-and-keywords/setup-keywords.robot
Resource        ../keys-and-keywords/keys.robot
Resource        ../rtectrl-rest-api/rtectrl.robot
Resource        ../pikvm-rest-api/pikvm_comm.robot
Resource        ../sonoff-rest-api/sonoff-api.robot

Suite Setup     Prepare platform    ${fw_file}


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
