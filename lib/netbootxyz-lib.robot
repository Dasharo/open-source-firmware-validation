*** Settings ***
Documentation       Collection of keywords related to netboot.xyz

Library             Collections
Library             String


*** Keywords ***
Boot To Netboot.Xyz
    [Documentation]    This keyword enters netboot.xyz menu after the platform was
    ...    powered on.
    Power On
    ${boot_menu}=    Enter Boot Menu And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    ${IPXE_BOOT_ENTRY}
    ${ipxe_menu}=    Get IPXE Boot Menu Construction
    IF    '${BIOS_LIB}' == 'seabios'
        Enter Submenu From Snapshot    ${ipxe_menu}    iPXE Shell
        Set Prompt For Terminal    iPXE>
        Read From Terminal Until Prompt
        Write Into Terminal    dhcp
        ${out}=    Read From Terminal Until Prompt
        Should Contain    ${out}    ok
        Set DUT Response Timeout    60s
        Write Bare Into Terminal    chain --autofree http://boot.netboot.xyz/ipxe/netboot.xyz.lkrn\n    0.1
        Read From Terminal Until    http://boot.netboot.xyz/ipxe/netboot.xyz.lkrn...
        Read From Terminal Until    ok
    ELSE
        Enter Submenu From Snapshot    ${ipxe_menu}    OS installation
    END
    Read From Terminal Until    netboot.xyz [ enabled: true ]
