*** Settings ***
Documentation       Collection of keywords related to netboot.xyz

Library             Collections
Library             String
Resource            ./bios/menus.robot


*** Keywords ***
Boot To Netboot.Xyz
    [Documentation]    This keyword enters netboot.xyz menu after the platform was
    ...    powered on.
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    ${IPXE_BOOT_ENTRY}
    ${ipxe_menu}=    Get IPXE Boot Menu Construction
    Enter Submenu From Snapshot    ${ipxe_menu}    OS installation
