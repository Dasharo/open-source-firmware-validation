*** Settings ***
Library         SSHLibrary    timeout=90 seconds
Library         Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library         Process
Library         OperatingSystem
Library         String
Library         RequestsLibrary
Library         Collections
Resource        ../sonoff-rest-api/sonoff-api.robot
Resource        ../rtectrl-rest-api/rtectrl.robot
Resource        ../variables.robot
Resource        ../keywords.robot
Resource        ../keys.robot

Suite Setup     Prepare platform


*** Keywords ***
Prepare platform
    [Documentation]    Keyword allows to flashing the device with the required
    ...    firmware version. Number of files used in the flashing procedure and
    ...    method of the flashing depends on the platform specify:
    ...    -> for the platforms that have external flashing enabled,
    ...    flashrom utility installed on the RTE is used.
    ...    -> for the platforms that have BMC, pflash utility built in OBMC is
    ...    used.
    ...    -> for the platforms that don't both don't have external flashing
    ...    enabled and OBMC, internal flashing mechanism is used.
    IF    '${config}'=='raptor-cs_talos2'
        Variable Should Exist    ${fw_file}
        Variable Should Exist    ${bootblock_file}
        Variable Should Exist    ${zImage_file}
        Prepare Test Suite
        Flash Heads From OpenBMC    ${bootblock_file}    ${fw_file}    ${zImage_file}
        ${fw_ver_file}=    Get firmware version from coreboot file    ${fw_file}
        Power On
        ${fw_ver_bootblock}    ${fw_ver_romstage}=    Get firmware version from bootlogs
        Log Out And Close Connection
        Should Be Equal    ${fw_ver_file}    ${fw_ver_bootblock}
        Should Be Equal    ${fw_ver_bootblock}    ${fw_ver_romstage}
    ELSE
        Variable Should Exist    ${fw_file}
        Prepare Test Suite
        Flash firmware    ${fw_file}
        Power Cycle On
        ${version}=    Get firmware version
        ${coreboot_version}=    Get firmware version from binary    ${fw_file}
        Log Out And Close Connection
        Should Contain    ${coreboot_version}    ${version}
    END
