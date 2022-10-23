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
Resource    ../pikvm-rest-api/pikvm_comm.robot

*** Test Cases ***

TEST CASE 1
    ${cpuid}=    Get Rte Cpuid    192.168.4.233

DTS001.001 Booting DTS from USB works correctly
    [Documentation]    Check whether the DUT can boot DTS from USB
    Power On
    Boot from    ${usb_with_dts}
    Check DTS Menu Appears

DTS002.001 DTS option Creating Dasharo HCL report works correctly
    [Documentation]    Check whether the Dasharo HCL report option in DTS menu
    ...                properly creates the report.
    Power On
    Boot from    ${usb_with_dts}
    Check DTS Menu Appears
    Wirte Into Terminal    1
    Check HCL Report Creation

DTS003.001 DTS option power-off DUT works correctly
    [Documentation]    Check whether the Power off system option in DTS menu
    ...                turns off the DUT.
    Power On
    Boot from    ${usb_with_dts}
    Check DTS Menu Appears
    Wirte Into Terminal    10
    Read From Terminal Until    shut down

DTS004.001 DTS option reboot DUT works correctly
    [Documentation]    Check whether the Reboot system option in DTS menu
    ...                reboots the DUT.
    Power On
    Boot from    ${usb_with_dts}
    Check DTS Menu Appears
    Wirte Into Terminal    11
    Boot from    ${usb_with_dts}

DTS005.001 DTS drop-to-shell option works correctly
    [Documentation]    Check whether the Shell option in DTS menu opens Shell.
    Power On
    Boot from    ${usb_with_dts}
    Check DTS Menu Appears
    Enter Shell In DTS

DTS006.001 Flash device from DTS shell by using flashrom works correctly
    [Documentation]    Check whether the DUT firmware can be flashed by using
    ...                flashrom in DTS.
    Power On
    Boot from    ${usb_with_dts}
    Check DTS Menu Appears
    Enter Shell In DTS
    Execute Command In Terminal    wget -0 /tmp/coreboot.rom https://3mdeb.com/open-source-firmware/Dasahro/${binary_location}
    ${output}=    Execute Command In Terminal    flashrom -p internal -w /tmp/coreboot ${flashrom_variables}
    Should Contain    ${output}    VERIFIED
    Write Into Terminal    reboot
    Boot from    ${usb_with_dts}
    Check DTS Menu Appears
    Enter Shell In DTS
    ${output}=    Execute Command In Terminal    dmidecode -t 0
    Should contain    ${output}    ${version}

# DTS007.001 Update device firmware from DTS Shell by using fwupd works correctly
#     [Documentation]    Check whether the DUT firmware can be updated by using
#     ...                fwupd in DTS.
#     Power On
#     Boot from    ${usb_with_dts}
#     Check DTS Menu Appears
#     Enter Shell In DTS
#     ${output}=    Execute Command In Terminal    fwupdmgr refresh
#     Should Contatin    ${output}    Successfully
#     ${output}=    Execute Command In Terminal    fwupdmgr update
#     Should Contatin    ${output}    Successfully installed firmware
#     Execute command In Terminal    reboot
#     Boot from    ${usb_with_dts}
#     Check DTS Menu Appears
#     Enter Shell In DTS
#     ${output}=    Execute Command In Terminal    dmidecode -t 0
#     Should contain    ${output}    ${version}

# DTS008.001 Flash device EC firmware by using DTS built-in script works correctly
#     [Documentation]    Check whether the DUT EC firmware can be flashed by using
#     ...                built-in script in DTS.
#     Power On
#     Boot from    ${usb_with_dts}
#     Check DTS Menu Appears
#     Wirte Into Terminal    6
#     Read From Trminal Until     Enter an option:
#     Wirte Into Terminal    1
#     Should Contain X Times    ${output}    VERIFIED    2
#     # Read Until shut down
#     Sleep    10s
#     Power On
#     Boot from    ${usb_with_dts}
#     Check DTS Menu Appears
#     Enter Shell In DTS
#     ${output}=    Execute Command In Terminal    system76_ectool info
#     Should contain    ${output}    ${ec_version}

# DTS009.001 Update device EC firmware by using DTS works correctly
#     [Documentation]    Check whether the DUT EC firmware can be updated by using
#     ...                system76_ectool in DTS.
#     Power On
#     Boot from    ${usb_with_dts}
#     Check DTS Menu Appears
#     Enter Shell In DTS
#     ${output1}=    Execute Command In Terminal    system76_ectool info
#     Execute Command In Terminal    wget -0 /tmp/ec.rom https://3mdeb.com/open-source-firmware/Dasahro/TBD
#     ${output}=    Execute Command In Terminal    system76_ectool flash ec.rom
#     # Read Until shut down
#     Sleep    10s
#     Power On
#     Boot from    ${usb_with_dts}
#     Check DTS Menu Appears
#     Enter Shell In DTS
#     ${output2}=    Execute Command In Terminal    system76_ectool info
#     Should Not Be Equal    ${output1}    ${output2}
