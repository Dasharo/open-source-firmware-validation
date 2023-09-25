*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Library             ../../lib/TestingStands.py
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../variables.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Enable Network Boot
...                     AND
...                     Disable Secure Boot
...                     AND
...                     Upload And Mount DTS Flash ISO
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
DTS001.001 Booting DTS from USB works correctly
    [Documentation]    This test aims to verify that DTS is properly booting
    ...    from USB.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS001.001 not supported
    Skip If    not ${DTS_SUPPORT}    DTS001.001 not supported
    Power On
    Boot Dasharo Tools Suite    USB_emulated

# DTS002.001 DTS option Creating Dasharo HCL report works correctly
#    [Documentation]    This test aims to verify that the option Dasharo HCL
#    ...    report in the DTS menu properly creates the report.
#    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS002.001 not supported
#    Skip If    not ${DTS_SUPPORT}    DTS002.001 not supported
#    Power On
#    Boot Dasharo Tools Suite    iPXE
#    #Not supported due to SSH authorization error while sending the report
#    Check HCL Report Creation

DTS003.001 DTS option power-off DUT works correctly
    [Documentation]    This test aims to verify that the option Power off
    ...    system in the DTS menu turns off the DUT.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS003.001 not supported
    Skip If    not ${DTS_SUPPORT}    DTS003.001 not supported
    Power On
    Boot Dasharo Tools Suite    iPXE
    Sleep    3s
    Write Into Terminal    10
    Check Power Off In DTS

DTS004.001 DTS option reboot DUT works correctly
    [Documentation]    This test aims to verify that the option Reboot system
    ...    in the DTS menu reboots the DUT.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS004.001 not supported
    Skip If    not ${DTS_SUPPORT}    DTS004.001 not supported
    Power On
    Boot Dasharo Tools Suite    iPXE
    Sleep    3s
    Write Into Terminal    11
    Read From Terminal Until    ${TIANOCORE_STRING}

DTS005.001 DTS drop-to-shell option works correctly
    [Documentation]    This test aims to verify that Shell can be accessed via
    ...    enabling SSH in the menu.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS005.001 not supported
    Skip If    not ${DTS_SUPPORT}    DTS005.001 not supported
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enable SSH In DTS
    Login To Linux Via SSH Without Password    root    root@DasharoToolsSuite:~#

DTS006.001 Flash device from DTS shell by using flashrom works correctly
    [Documentation]    This test aims to verify whether is the possibility to
    ...    flash the DUT firmware by using flashrom in DTS Shell.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS006.001 not supported
    Skip If    not ${DTS_FIRMWARE_FLASHING_SUPPORT}    DTS006.001 not supported
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
    Set DUT Response Timeout    320s
    Flash Firmware In DTS
    Power On
    Enable Network Boot
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
    Check Firmware Version

DTS007.001 Update device firmware from DTS Shell by using fwupd works correctly
    [Documentation]    This test aims to verify whether there is the
    ...    possibility to update the DUT firmware by using fwupd in DTS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS007.001 not supported
    Skip If    not ${DTS_FWUPD_FIRMWARE_UPDATE_SUPPORT}    DTS007.001 not supported
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Fwupd Update
    Execute Command In Terminal    reboot
    Set DUT Response Timeout    320s
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check Firmware Version

DTS008.001 Flash device EC firmware by using DTS built-in script works correctly
    [Documentation]    This test aims to verify whether there is the
    ...    possibility to flash the DUT EC firmware by using the built-in
    ...    script in DTS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS008.001 not supported
    Skip If    not ${DTS_EC_FLASHING_SUPPORT}    DTS008.001 not supported
    Power On
    Boot Dasharo Tools Suite    iPXE
    Run EC Transition
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check EC Firmware Version

DTS009.001 Update device EC firmware by using DTS works correctly
    [Documentation]    This test aims to verify whether there is the
    ...    possibility to update the DUT EC firmware by using system76_ectool
    ...    in DTS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS009.001 not supported
    Skip If    not ${DTS_EC_FLASHING_SUPPORT}    DTS009.001 not supported
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Flash EC Firmware
    Set DUT Response Timeout    320s
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check EC Firmware Version
