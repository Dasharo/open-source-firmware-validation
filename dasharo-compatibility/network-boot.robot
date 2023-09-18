*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../keywords.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
PXE001.001 Dasharo Network Boot is available
    [Documentation]    This test aims to verify, that the iPXE Network boot
    ...    is bootable in the boot menu and whether, after selecting this boot
    ...    option, Dasharo Network Boot Menu is displayed.
    Skip If    not ${ipxe_boot_support}    PXE001.001 not supported
    Skip If    not ${tests_in_firmware_support}    PXE001.001 not supported
    Power On
    Enter Boot Menu Tianocore
    Enter Submenu in Tianocore    option=${edk2_ipxe_string}
    ${out}=    Read From Terminal Until    ${edk2_ipxe_checkpoint}
    Should Contain    ${out}    Dasharo Network Boot Menu

PXE002.001 Dasharo network boot menu boot options order is correct
    [Documentation]    This test aims to verify that Dasharo Network Boot Menu
    ...    contains all of the needed options which are in the correct order.
    Skip If    not ${ipxe_boot_support}    PXE002.001 not supported
    Skip If    not ${tests_in_firmware_support}    PXE002.001 not supported
    Power On
    Enter Boot Menu Tianocore
    Enter Submenu in Tianocore    option=${edk2_ipxe_string}
    ${ipxe_menu}=    Get iPXE Boot Menu Construction
    Should Contain    ${ipxe_menu}[0]    Dasharo Network Boot Menu
    Should Contain    ${ipxe_menu}[1]    Autoboot (DHCP)
    Should Contain    ${ipxe_menu}[2]    Dasharo Tools Suite
    Should Contain    ${ipxe_menu}[3]    OS installation (netboot.xyz official server)
    Should Contain    ${ipxe_menu}[4]    iPXE Shell

PXE003.001 Autoboot option is available and works correctly
    [Documentation]    This test aims to verify that the Autoboot option in
    ...    Dasharo Network Boot Menu works correctly.
    Skip If    not ${ipxe_boot_support}    PXE003.001 not supported
    Skip If    not ${tests_in_firmware_support}    PXE003.001 not supported
    Power On
    Enter Boot Menu Tianocore
    Enter Submenu in Tianocore    option=${edk2_ipxe_string}
    Enter Submenu in Tianocore    option=Autoboot (DHCP)    checkpoint=${edk2_ipxe_checkpoint}
    ${out}=    Read From Terminal Until    ESC to exit
    Should Contain    ${out}    Please select boot device

PXE004.001 DTS option is available and works correctly
    [Documentation]    This test aims to verify that the Dasharo Tools Suite
    ...    option in Dasharo Network Boot Menu allows booting into DTS.
    Skip If    not ${ipxe_boot_support}    PXE004.001 not supported
    Skip If    not ${tests_in_firmware_support}    PXE004.001 not supported
    Power On
    Enter Boot Menu Tianocore
    Enter Submenu in Tianocore    option=${edk2_ipxe_string}
    Enter Submenu in Tianocore    option=Dasharo Tools Suite    checkpoint=${edk2_ipxe_checkpoint}
    Set DUT Response Timeout    5m
    ${out}=    Read From Terminal Until    Enter an option
    Should Contain    ${out}    boot.3mdeb.com
    Should Contain    ${out}    Dasharo HCL report
    Should Contain    ${out}    Update Dasharo firmware
    Should Contain    ${out}    Shell
    Should Contain    ${out}    Power off
    Should Contain    ${out}    Reboot

PXE005.001 OS installation option is available and works correctly
    [Documentation]    This test aims to verify that the OS installation option
    ...    in Dasharo Network Boot Menu allows booting into netboot.xyz server.
    Skip If    not ${ipxe_boot_support}    PXE005.001 not supported
    Skip If    not ${tests_in_firmware_support}    PXE005.001 not supported
    Power On
    Enter Boot Menu Tianocore
    Enter Submenu in Tianocore    option=${edk2_ipxe_string}
    Enter Submenu in Tianocore    option=OS installation    checkpoint=${edk2_ipxe_checkpoint}
    ${out}=    Read From Terminal Until    netboot.xyz [ enabled: true ]
    Should Contain    ${out}    netboot.xyz
    Should Contain    ${out}    Distributions:
    Should Contain    ${out}    Linux Network Installs
    Should Contain    ${out}    Live CDs
    Should Contain    ${out}    Windows
    Should Contain    ${out}    Tools:

PXE006.001 iPXE shell option is available and works correctly
    [Documentation]    This test aims to verify that the iPXE Shell option in
    ...    Dasharo Network Boot Menu works correctly.
    Skip If    not ${ipxe_boot_support}    PXE006.001 not supported
    Skip If    not ${tests_in_firmware_support}    PXE006.001 not supported
    Power On
    Enter Boot Menu Tianocore
    Enter Submenu in Tianocore    option=${edk2_ipxe_string}
    Enter Submenu in Tianocore    option=iPXE Shell    checkpoint=${edk2_ipxe_checkpoint}
    Read From Terminal Until    iPXE>
