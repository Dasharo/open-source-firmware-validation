*** Settings ***
Documentation       Library for UEFI configuration using the UEFI setup menu
...                 app (e.g. over serial port)

Library             Collections
Library             String
Resource            ../bios/menus.robot


*** Keywords ***
Set UEFI Option
    [Documentation]    Set an UEFI option to a value.
    ...    TODO: Only works with options following the submenu/submenu/option
    ...    pattern (e.g. all Dasharo System Features options).
    [Arguments]    ${option_name}    ${value}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Can not configure UEFI settings on this platform.

    TRY
        @{option_path}=    Option Name To UEFI Path    ${option_name}
    EXCEPT
        Skip    Setting option ${option_name} is currently unimplemented.
    END

    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${submenu_l1}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    ${option_path[0]}
    ${submenu_l2}=    Enter Submenu From Snapshot And Return Construction
    ...    ${submenu_l1}
    ...    ${option_path[1]}
    ...    opt_only=${TRUE}
    Set Option State    ${submenu_l2}    ${option_path[2]}    ${value}
    Save Changes And Reset
