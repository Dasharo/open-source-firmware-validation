*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${IPXE_BOOT_SUPPORT}    iPXE Network Boot not supported
# ...    AND
# ...    Make Sure That Network Boot Is Enabled
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
# TODO: It should be In Suite Setup, not in Test Setup. But when it is, at least
# the QEMU run hangs in the first occurrence of Power On keyword in the first
# test executed, never returning from this keyword.
Test Setup          Run Keyword If    ${DASHARO_NETWORKING_MENU_SUPPORT}
...                     Make Sure That Network Boot Is Enabled


*** Test Cases ***
PXE001.001 Dasharo Network Boot is available
    [Documentation]    This test aims to verify, that the iPXE Network boot
    ...    is bootable in the boot menu and whether, after selecting this boot
    ...    option, Dasharo Network Boot Menu is displayed.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PXE001.001 not supported
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    ${IPXE_BOOT_ENTRY}
    ${out}=    Read From Terminal Until    ${EDK2_IPXE_CHECKPOINT}
    Should Contain    ${out}    Dasharo Network Boot Menu

PXE002.001 Dasharo network boot menu boot options order is correct
    [Documentation]    This test aims to verify that Dasharo Network Boot Menu
    ...    contains all of the needed options which are in the correct order.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PXE002.001 not supported
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    ${IPXE_BOOT_ENTRY}
    ${ipxe_menu}=    Get IPXE Boot Menu Construction
    Should Contain    ${ipxe_menu}[0]    Autoboot (DHCP)
    Should Contain    ${ipxe_menu}[1]    Dasharo Tools Suite
    Should Contain    ${ipxe_menu}[2]    OS installation (netboot.xyz official server)
    Should Contain    ${ipxe_menu}[3]    iPXE Shell

PXE003.001 Autoboot option is available and works correctly
    [Documentation]    This test aims to verify that the Autoboot option in
    ...    Dasharo Network Boot Menu works correctly.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PXE003.001 not supported
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    ${IPXE_BOOT_ENTRY}
    ${ipxe_menu}=    Get IPXE Boot Menu Construction
    Enter Submenu From Snapshot    ${ipxe_menu}    Autoboot (DHCP)
    ${out}=    Read From Terminal Until    ${IPXE_BOOT_ENTRY}
    Should Contain    ${out}    Please select boot device

PXE004.001 DTS option is available and works correctly
    [Documentation]    This test aims to verify that the Dasharo Tools Suite
    ...    option in Dasharo Network Boot Menu allows booting into DTS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PXE004.001 not supported
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    ${IPXE_BOOT_ENTRY}
    ${ipxe_menu}=    Get IPXE Boot Menu Construction
    Enter Submenu From Snapshot    ${ipxe_menu}    Dasharo Tools Suite
    Set DUT Response Timeout    5m
    ${out}=    Read From Terminal Until    Enter an option
    Should Contain    ${out}    Dasharo HCL report
    # TODO:
    # On some targets (such as QEMU), we get option to install, not to update
    Should Contain Any    ${out}    Install Dasharo firmware    Update Dasharo firmware
    Should Contain    ${out}    Load your DES keys
    Should Contain    ${out}    Start SSH server
    Should Contain    ${out}    Shell
    Should Contain    ${out}    Power off system
    Should Contain    ${out}    Reboot system

PXE005.001 OS installation option is available and works correctly
    [Documentation]    This test aims to verify that the OS installation option
    ...    in Dasharo Network Boot Menu allows booting into netboot.xyz server.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PXE005.001 not supported
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    ${IPXE_BOOT_ENTRY}
    ${ipxe_menu}=    Get IPXE Boot Menu Construction
    Enter Submenu From Snapshot    ${ipxe_menu}    OS installation
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
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PXE006.001 not supported
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    ${IPXE_BOOT_ENTRY}
    ${ipxe_menu}=    Get IPXE Boot Menu Construction
    Enter Submenu From Snapshot    ${ipxe_menu}    iPXE Shell
    Read From Terminal Until    iPXE>
