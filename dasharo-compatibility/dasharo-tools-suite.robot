*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
Library             ../../lib/TestingStands.py
Resource            ../keys-and-keywords/setup-keywords.robot
Resource            ../keys-and-keywords/firmware-keywords.robot
Resource            ../keys-and-keywords/keys.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../lib/secure-boot-lib.robot
Resource            ../lib/dts-lib.robot
Resource    ../variables.robot

Suite Setup         Run Keywords    Prepare Test Suite    AND    Enable Network Boot    AND    Disable Secure Boot
Suite Teardown      Run Keyword    Log Out And Close Connection

*** Test Cases ***
DTS001.001 Booting DTS from USB works correctly
    [Documentation]    This test aims to verify that DTS is properly booting
    ...    from USB.
    Skip If    not ${tests_in_firmware_support}    DTS001.001 not supported
    Skip If    not ${DTS_support}    DTS001.001 not supported
    Power On
    Boot Dasharo Tools Suite    USB_emulated

DTS002.001 DTS option Creating Dasharo HCL report works correctly
    [Documentation]    This test aims to verify that the option Dasharo HCL
    ...    report in the DTS menu properly creates the report.
    Skip If    not ${tests_in_firmware_support}    DTS002.001 not supported
    Skip If    not ${DTS_support}    DTS002.001 not supported
    Power On
    Boot Dasharo Tools Suite    USB_emulated
    Check HCL Report Creation

DTS003.001 DTS option power-off DUT works correctly
    [Documentation]    This test aims to verify that the option Power off
    ...    system in the DTS menu turns off the DUT.
    Skip If    not ${tests_in_firmware_support}    DTS003.001 not supported
    Skip If    not ${DTS_support}    DTS003.001 not supported
    Power On
    Boot Dasharo Tools Suite    USB_emulated
    Write Into Terminal    10
    Check Power Off In DTS

DTS004.001 DTS option reboot DUT works correctly
    [Documentation]    This test aims to verify that the option Reboot system
    ...    in the DTS menu reboots the DUT.
    Skip If    not ${tests_in_firmware_support}    DTS004.001 not supported
    Skip If    not ${DTS_support}    DTS004.001 not supported
    Power On
    Boot Dasharo Tools Suite    USB_emulated
    Write Into Terminal    11
    Read From Terminal Until    ${tianocore_string}

DTS005.001 DTS drop-to-shell option works correctly
    [Documentation]    This test aims to verify that the option Shell in the
    ...    DTS menu opens Shell.
    Skip If    not ${tests_in_firmware_support}    DTS005.001 not supported
    Skip If    not ${DTS_support}    DTS005.001 not supported
    Power On
    Boot Dasharo Tools Suite    USB_emulated
    Enable SSH In DTS
    Log into DTS via SSH

DTS006.001 Flash device from DTS shell by using flashrom works correctly
    [Documentation]    This test aims to verify whether is the possibility to
    ...    flash the DUT firmware by using flashrom in DTS Shell.
    Skip If    not ${tests_in_firmware_support}    DTS006.001 not supported
    #Skip If    not ${DTS_firmware_flashing_support}    DTS006.001 not supported
    Power On
    Boot Dasharo Tools Suite    USB_emulated
    Enter Shell In DTS
    Set Global Variable    ${dut_connection_method}    SSH
    Flash firmware in DTS
    Power On
    Set DUT Response Timeout    320s
    Enable Network Boot
    Boot Dasharo Tools Suite    USB_emulated
    Enter Shell In DTS
    Set Global Variable    ${dut_connection_method}    SSH
    Check Firmware Version

DTS007.001 Update device firmware from DTS Shell by using fwupd works correctly
    [Documentation]    This test aims to verify whether there is the
    ...    possibility to update the DUT firmware by using fwupd in DTS.
    Skip If    not ${tests_in_firmware_support}    DTS007.001 not supported
    Skip If    not ${DTS_fwupd_firmware_update_support}    DTS007.001 not supported
    Power On
    Boot Dasharo Tools Suite    USB_emulated
    Enter Shell In DTS
    Fwupd Update
    Execute command In Terminal    reboot
    Set DUT Response Timeout    320s
    Boot Dasharo Tools Suite    USB_emulated
    Enter Shell In DTS
    Check Firmware Version

DTS008.001 Flash device EC firmware by using DTS built-in script works correctly
    [Documentation]    This test aims to verify whether there is the
    ...    possibility to flash the DUT EC firmware by using the built-in
    ...    script in DTS.
    Skip If    not ${tests_in_firmware_support}    DTS008.001 not supported
    Skip If    not ${DTS_ec_flashing_support}    DTS008.001 not supported
    Power On
    Boot Dasharo Tools Suite    USB_emulated
    Run EC Transition
    Power On
    Boot Dasharo Tools Suite    USB_emulated
    Enter Shell In DTS
    Check EC Firmware Version

DTS009.001 Update device EC firmware by using DTS works correctly
    [Documentation]    This test aims to verify whether there is the
    ...    possibility to update the DUT EC firmware by using system76_ectool
    ...    in DTS.
    Skip If    not ${tests_in_firmware_support}    DTS009.001 not supported
    Skip If    not ${DTS_ec_flashing_support}    DTS009.001 not supported
    Power On
    Boot Dasharo Tools Suite    USB_emulated
    Enter Shell In DTS
    Flash EC Firmware
    Set DUT Response Timeout    320s
    Power On
    Boot Dasharo Tools Suite    USB_emulated
    Enter Shell In DTS
    Check EC Firmware Version

