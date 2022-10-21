*** Settings ***
Library     SSHLibrary    timeout=90 seconds
Library     Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library     Process
Library     OperatingSystem
Library     String
Library     RequestsLibrary
Library     Collections

Suite Setup       Run Keyword    Prepare Test Suite
Suite Teardown    Run Keyword    Log Out And Close Connection

Resource    ../lib/sonoffctrl.robot
Resource    ../rtectrl-rest-api/rtectrl.robot
Resource    ../snipeit-rest-api/snipeit-api.robot
Resource    ../variables.robot
Resource    ../keywords.robot
Resource    ../keys.robot

*** Test Cases ***

DTS001.001 Booting DTS from USB works correctly
    [Documentation]    Check whether the DUT can boot DTS from USB
    Power On
    Boot from    ${usb_with_dts}
    Read From Terminal Until    Enter an option:

DTS002.001 DTS option Creating Dasharo HCL report works correctly
    [Documentation]    Check whether the Dasharo HCL report option in DTS menu
    ...                properly creates the report.
    Power On
    Enter Boot Menu
    Select USB
    Read Until Enter an option
    Wirte 1
    Write y
    Read Until

DTS003.001 DTS option power-off DUT works correctly
    [Documentation]    Check whether the Power off system option in DTS menu
    ...                turns off the DUT.
    Power On
    Enter Boot Menu
    Select USB
    Read Until Enter an option
    Write 10
    How check Power off???

DTS004.001 DTS option reboot DUT works correctly
    [Documentation]    Check whether the Reboot system option in DTS menu
    ...                reboots the DUT.
    Power On
    Enter Boot Menu
    Select USB
    Read Until Enter an option
    Write 11
    Read Until Boot menu

DTS005.001 DTS drop-to-shell option works correctly
    [Documentation]    Check whether the Shell option in DTS menu opens Shell.
    Power On
    Enter Boot Menu
    Select USB
    Read Until Enter an option
    Write 9
    Read Until bash-5.1#

DTS006.001 Flash device from DTS shell by using flashrom works correctly
    [Documentation]    Check whether the DUT firmware can be flashed by using
    ...                flashrom in DTS.
    Power On
    Enter Boot Menu
    Select USB
    Read Until Enter an option
    Write 9
    Read Until bash-5.1#
    Execute command wget binary
    Execute command flashrom
    Reboot
    Enter Boot Menu
    Select USB
    Read Until Enter an option
    Write 9
    Read Until bash-5.1#
    Execute command dmidecode
    Should contain version

DTS007.001 Update device firmware from DTS Shell by using fwupd works correctly
    [Documentation]    Check whether the DUT firmware can be updated by using
    ...                fwupd in DTS.
    Power On
    Enter Boot Menu
    Select USB
    Read Until Enter an option
    Write 9
    Read Until bash-5.1#
    Execute command fwupdmgr refresh
    Should contatin Successfully
    Execute command fwupdmgr update
    Should contatin Successfully installed firmware
    Reboot
    Enter Boot Menu
    Select USB
    Read Until Enter an option
    Write 9
    Read Until bash-5.1#
    Execute command dmidecode or fwupdmgr get-results
    Should contain version

DTS008.001 Flash device EC firmware by using DTS built-in script works correctly
    [Documentation]    Check whether the DUT EC firmware can be flashed by using
    ...                built-in script in DTS.
    Power On
    Enter Boot Menu
    Select USB
    Read Until Enter an option
    Write 6
    Read Until EC tranistion
    Write 1
    Should Contain 2 Times Verified
    Read Intil shut down
    Sleep 10s
    Power On
    Enter Boot Menu
    Select USB
    Read Until Enter an option
    Write 9
    Read Until bash-5.1#
    Execute command system76_ectool info
    Should contain version

DTS009.001 Update device EC firmware by using DTS works correctly
    [Documentation]    Check whether the DUT EC firmware can be updated by using
    ...                system76_ectool in DTS.
    Power On
    Enter Boot Menu
    Select USB
    Read Until Enter an option
    Write 9
    Read Until bash-5.1#
    Execute command system76_ectool info
    output1 = version
    Execute command wget binary
    Execute command system76_ectool flash ec_file.rom
    Read Intil shut down
    Sleep 10s
    Power On
    Enter Boot Menu
    Select USB
    Read Until Enter an option
    Write 9
    Read Until bash-5.1#
    Execute command system76_ectool info
    output2 = version
    output1 != output2
