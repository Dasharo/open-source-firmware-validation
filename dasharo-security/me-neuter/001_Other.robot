*** Settings ***
Resource            common.resource

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
MNE001.001 Intel ME mode option is available and has the correct default state
    [Documentation]    Check whether the Intel ME mode state after flashing the
    ...    platform with the Dasharo firmware is correct.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    MNE001.001 not supported
    Power On Ex    force_reboot=${TRUE}
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${me_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Intel Management Engine Options
    ${state}=    Get Option State    ${me_menu}    Intel ME mode
    Should Be Equal    ${state}    Enabled
