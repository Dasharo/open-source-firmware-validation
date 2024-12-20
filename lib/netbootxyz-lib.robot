*** Settings ***
Documentation       Collection of keywords related to netboot.xyz

Library             Collections
Library             String

# Nomenclature:
# - Netboot.Xyz Menu - netboot.xyz main menu
# - Netboot.Xyz Linux Install Menu - submenu of Netboot.Xyz Menu behind Linux
# Network Installs (64-bit) (aka Linux Installers - Current Arch [ x86_64 ])
# - Netboot.Xyz Linux Distro Install Menu - submenu of Netboot.Xyz Linux Install
# Menu of each distribtuion, those may vary depending on distro contain various
# releases and submenus

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

Enter Netboot.Xyz Linux Install Menu And Return Construction
    [Documentation]    Return only selectable entries of netboot.xyz Linux
    ...    Install submenu. If some menu option is not selectable it will not
    ...    be in the menu construction list.
    Enter Netboot.Xyz Menu
    ${nb_menu}=    Get Netboot.Xyz Menu Construction
    ${index}=    Get Index Of Matching Option In Menu    ${nb_menu}    Linux Network Installs (64-bit)
    Select Option    ${index}    ${ARROW_DOWN}
    Press Enter
    ${out}=    Read From Terminal
    ${menu}=    Parse Netboot.Xyz Linux Install Menu Snapshot Into Construction    ${out}
    RETURN    ${menu}

Enter Netboot.Xyz Utilities Menu And Return Construction
    [Documentation]    Return only selectable entries of netboot.xyz Utilities
    ...    submenu. If some menu option is not selectable it will not
    ...    be in the menu construction list.
    Enter Netboot.Xyz Menu
    ${nb_menu}=    Get Netboot.Xyz Menu Construction
    ${index}=    Get Index Of Matching Option In Menu    ${nb_menu}    Utilities (64-bit)
    Select Option    ${index}    ${ARROW_DOWN}
    Press Enter
    ${out}=    Read From Terminal
    ${menu}=    Parse Netboot.Xyz Linux Distro Install Menu Snapshot Into Construction    ${out}
    RETURN    ${menu}

Enter Netboot.Xyz Linux Distro Install Menu And Return Construction
    [Documentation]    Return only selectable entries of netboot.xyz Linux
    ...    Install submenu for provided Linux distribution. If some menu option
    ...    is not selectable it will not be in the menu construction list.
    [Arguments]    ${distro}
    Enter Netboot.Xyz Menu
    ${nb_menu}=    Get Netboot.Xyz Menu Construction
    ${index}=    Get Index Of Matching Option In Menu    ${nb_menu}    Linux Network Installs (64-bit)
    Select Option    ${index}    ${ARROW_DOWN}
    Press Enter
    Select Option    1    ${ARROW_DOWN}
    ${out}=    Read From Terminal
    ${menu}=    Parse Netboot.Xyz Linux Install Menu Snapshot Into Construction    ${out}

    ${index}=    Get Index Of Matching Option In Menu    ${menu}    ${distro}    ${TRUE}
    Should Not Be Equal    '${index}'    -1    The option was not found in menu
    ${index}=    Evaluate    ${index}-1
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}
    ${out}=    Read From Terminal
    ${menu}=    Parse Netboot.Xyz Linux Distro Install Menu Snapshot Into Construction    ${out}
    RETURN    ${menu}

Parse Netboot.Xyz Linux Distro Install Menu Snapshot Into Construction
    [Documentation]    Breaks grabbed netboot.xyz Linux distro install menu data
    ...    into selectable lines.
    [Arguments]    ${menu}
    ${menu}=    Remove String    ${menu}    \r
    @{menu_lines}=    Split To Lines    ${menu}
    @{construction}=    Create List
    ${nextpage}=    Set Variable    ${FALSE}
    FOR    ${line}    IN    @{menu_lines}
        ${match}=    Run Keyword And Return Status    Should Match Regexp    ${line}    ^ {6}\\S+(?: \\S+)*$
        IF    ${match}
            ${line}=    Strip String    ${line}
            # If the resulting line is not empty, add it as a menu entry
            ${length}=    Get Length    ${line}
            IF    ${length} > 0    Append To List    ${construction}    ${line}
        END
    END
    Remove Values From List
    ...    ${construction}
    ...    Latest Release
    ...    Older Releases
    ...    Testing Releases
    ...    .* - amd64
    ...    netboot.xyz tools:
    ...    Utilities:
    ${nextpage}=    Strip String    ${menu_lines[-1]}
    IF    "${nextpage}" == "..."
        ${keypress}=    Get Length    ${construction}
        Press Key N Times    ${keypress}    ${ARROW_DOWN}
        ${out}=    Read From Terminal
        ${out}=    Fetch From Right    ${out}    ...
        ${menu}=    Parse Netboot.Xyz Linux Distro Install Menu Snapshot Into Construction    ${out}
        ${construction}=    Combine Lists   ${construction}    ${menu}
        # We have to get back to top of the list to no confuse user
        Press Key N Times    ${keypress}    ${ARROW_UP}
    END
    RETURN    ${construction}

Parse Netboot.Xyz Linux Install Menu Snapshot Into Construction
    [Documentation]    Breaks grabbed netboot.xyz Linux install menu data into
    ...    selectable lines.
    [Arguments]    ${menu}
    ${menu}=    Remove String    ${menu}    \r
    @{menu_lines}=    Split To Lines    ${menu}
    @{construction}=    Create List
    ${nextpage}=    Set Variable    ${FALSE}
    FOR    ${line}    IN    @{menu_lines}
        ${match}=    Run Keyword And Return Status    Should Match Regexp    ${line}    \\w+( \\w+)*$
        IF    ${match}
            ${line}=    Strip String    ${line}
            # If the resulting line is not empty, add it as a menu entry
            ${length}=    Get Length    ${line}
            IF    ${length} > 0    Append To List    ${construction}    ${line}
        END
    END
    Remove Values From List
    ...    ${construction}
    ...    Linux Installers - Current Arch [ x86_64 ]
    ...    Linux Distros:
    ${nextpage}=    Strip String    ${menu_lines[-1]}
    IF    "${nextpage}" == "..."
        ${keypress}=    Get Length    ${construction}
        Press Key N Times    ${keypress}    ${ARROW_DOWN}
        ${out}=    Read From Terminal
        ${out}=    Fetch From Right    ${out}    ...
        ${menu}=    Parse Netboot.Xyz Linux Install Menu Snapshot Into Construction    ${out}
        ${construction}=    Combine Lists   ${construction}    ${menu}
        # We have to get back to top of the list to no confuse user
        Press Key N Times    ${keypress}    ${ARROW_UP}
    END
    RETURN    ${construction}

Enter Netboot.Xyz And Set Kernel Cmdline Params
    [Documentation]    Enter Netboot.Xyz Utilities and set kernel cmdline params
    [Arguments]    ${params}
    ${menu}=    Enter Netboot.Xyz Utilities Menu And Return Construction
    ${index}=    Get Index Of Matching Option In Menu    ${menu}    Kernel cmdline params: []    ${TRUE}
    Should Not Be Equal    '${index}'    -1    The option was not found in menu
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}
    ${out}=    Read From Terminal
    Write Bare Into Terminal    ${params}\n    0.1
    ${out}=    Read From Terminal
    Press Key N Times    2    ${ESC}
