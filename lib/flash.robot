*** Keywords ***
Make Sure That Lock The BIOS Boot Medium Is Disabled
    [Documentation]    This keywords checks that "Lock the BIOS boot medium" in
    ...    "Dasharo Security Options" is Disabled when present, so the internal
    ...    flashing can be executed.
    Skip If    not ${BIOS_LOCK_SUPPORT}    BIOS_LOCK_SUPPORT not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TESTS_IN_FIRMWARE_SUPPORT not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${security_menu}    Lock the BIOS boot medium    ${FALSE}
    Save Changes And Reset    2    4
    Sleep    10s
