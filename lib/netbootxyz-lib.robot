*** Settings ***
Documentation       Collection of keywords related to netboot.xyz

Library             Collections
Library             String


*** Keywords ***
Get Netboot.Xyz Menu Construction
    [Documentation]    Return only selectable entries of netboot.xyz menu.
    ...    If some menu option is not selectable it will not be in the menu 
    ...    construction list.
    [Arguments]    ${checkpoint}=[ enabled: true ]    ${lines_top}=1    ${lines_bot}=0
    ${out}=    Read From Terminal Until    ${checkpoint}
    # At first, parse the menu as usual
    ${menu}=    Parse Netboot.Xyz Menu Snapshot Into Construction    ${out}
    # Remove Values From List
    #   ...    ${menu}
    #   ...    To enable Secure Boot, set Secure Boot Mode to
    #   ...    Custom and enroll the keys/PK first.
    #   ...    Enable Secure Boot [ ]
    #   ...    Enable Secure Boot [X]
    RETURN    ${menu}

Parse Netboot.Xyz Menu Snapshot Into Construction
    [Documentation]    Breaks grabbed netboot.xyz data into selectable lines.
    [Arguments]    ${menu}
    ${menu}=    Remove String    ${menu}    \r
    @{menu_lines}=    Split To Lines    ${menu}
    @{construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        # It seems that selectable entries start with 6 spaces, followed by
        # non-whitespace character
        ${match}=    Run Keyword And Return Status    Should Match Regexp    ${line}    ^ {6}\\S+.*$
        IF    ${match}
            ${line}=    Strip String    ${line}
            Append To List    ${construction}    ${line}
        END
    END
    RETURN    ${construction}

Enter Netboot.Xyz Menu
    [Documentation]    This keyword enters netboot.xyz menu after the platform was
    ...    powered on.
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

Enter Netboot.Xyz Menu And Return Construction
    [Documentation]    This keyword enters netboot.xyz menu after the platform
    ...    was powered on. Returns netboot.xyz menu construction.
    Enter Netboot.Xyz Menu
    ${nb_menu}=    Get Netboot.Xyz Menu Construction
    RETURN    ${nb_menu}
