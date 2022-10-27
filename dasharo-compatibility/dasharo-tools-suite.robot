*** Settings ***
Library     SSHLibrary    timeout=90 seconds
Library     Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library     Process
Library     OperatingSystem
Library     String
Library     RequestsLibrary
Library     Collections
Library     ../../lib/TestingStands.py

Suite Setup       Run Keyword    Prepare Test Suite
Suite Teardown    Run Keyword    Log Out And Close Connection

Resource    ../keywords.robot
Resource    ../rtectrl-rest-api/rtectrl.robot
Resource    ../pikvm-rest-api/pikvm_comm.robot
Resource    ../sonoff-rest-api/sonoff-api.robot

*** Test Cases ***

DTS001.001 Booting DTS from USB works correctly
    [Documentation]    Check whether the DUT can boot DTS from USB
    Skip If    not ${tests_in_firmware_support}    DTS001.001 not supported
    Skip If    not ${DTS_support}    DTS001.001 not supported
    Power On
    Boot Dasharo Tools Suite    ${DTS_booting_default_method}

DTS002.001 DTS option Creating Dasharo HCL report works correctly
    [Documentation]    Check whether the Dasharo HCL report option in DTS menu
    ...                properly creates the report.
    Skip If    not ${tests_in_firmware_support}    DTS002.001 not supported
    Skip If    not ${DTS_support}    DTS002.001 not supported
    Power On
    Boot Dasharo Tools Suite    ${DTS_booting_default_method}
    Write Into Terminal    1
    Check HCL Report Creation

DTS003.001 DTS option power-off DUT works correctly
    [Documentation]    Check whether the Power off system option in DTS menu
    ...                turns off the DUT.
    Skip If    not ${tests_in_firmware_support}    DTS003.001 not supported
    Skip If    not ${DTS_support}    DTS003.001 not supported
    Power On
    Boot Dasharo Tools Suite    ${DTS_booting_default_method}
    Write Into Terminal    10
    Check Power Off In DTS

DTS004.001 DTS option reboot DUT works correctly
    [Documentation]    Check whether the Reboot system option in DTS menu
    ...                reboots the DUT.
    Skip If    not ${tests_in_firmware_support}    DTS004.001 not supported
    Skip If    not ${DTS_support}    DTS004.001 not supported
    Power On
    Boot Dasharo Tools Suite    ${DTS_booting_default_method}
    Write Into Terminal    11
    Read From Terminal Until    ${tianocore_string}

DTS005.001 DTS drop-to-shell option works correctly
    [Documentation]    Check whether the Shell option in DTS menu opens Shell.
    Skip If    not ${tests_in_firmware_support}    DTS005.001 not supported
    Skip If    not ${DTS_support}    DTS005.001 not supported
    Power On
    Boot Dasharo Tools Suite    ${DTS_booting_default_method}
    Enter Shell In DTS

DTS006.001 Flash device from DTS shell by using flashrom works correctly
    [Documentation]    Check whether the DUT firmware can be flashed by using
    ...                flashrom in DTS.
    Skip If    not ${tests_in_firmware_support}    DTS006.001 not supported
    Skip If    not ${DTS_firmware_flashing_support}    DTS006.001 not supported
    Power On
    Boot Dasharo Tools Suite    ${DTS_booting_default_method}
    Enter Shell In DTS
    Flash firmware in DTS
    Write Into Terminal    reboot
    Boot Dasharo Tools Suite    ${DTS_booting_default_method}
    Enter Shell In DTS
    Check Firmware Version

DTS007.001 Update device firmware from DTS Shell by using fwupd works correctly
    [Documentation]    Check whether the DUT firmware can be updated by using
    ...                fwupd in DTS.
    Skip If    not ${tests_in_firmware_support}    DTS007.001 not supported
    Skip If    not ${DTS_fwupd_firmware_update_support}    DTS007.001 not supported
    Power On
    Boot Dasharo Tools Suite    ${DTS_booting_default_method}
    Enter Shell In DTS
    Fwupd Update
    Execute command In Terminal    reboot
    Boot Dasharo Tools Suite    ${DTS_booting_default_method}
    Enter Shell In DTS
    Check Firmware Version

DTS008.001 Flash device EC firmware by using DTS built-in script works correctly
    [Documentation]    Check whether the DUT EC firmware can be flashed by using
    ...                built-in script in DTS.
    Skip If    not ${tests_in_firmware_support}    DTS008.001 not supported
    Skip If    not ${DTS_ec_flashing_support}    DTS008.001 not supported
    Power On
    Boot Dasharo Tools Suite    ${DTS_booting_default_method}
    Run EC Transition
    Power On
    Boot Dasharo Tools Suite    ${DTS_booting_default_method}
    Enter Shell In DTS
    Check EC Firmware Version

DTS009.001 Update device EC firmware by using DTS works correctly
    [Documentation]    Check whether the DUT EC firmware can be updated by using
    ...                system76_ectool in DTS.
    Skip If    not ${tests_in_firmware_support}    DTS009.001 not supported
    Skip If    not ${DTS_ec_flashing_support}    DTS009.001 not supported
    Power On
    Boot Dasharo Tools Suite    ${DTS_booting_default_method}
    Enter Shell In DTS
    Flash EC Firmware
    Power On
    Boot Dasharo Tools Suite    ${DTS_booting_default_method}
    Enter Shell In DTS
    Check EC Firmware Version
