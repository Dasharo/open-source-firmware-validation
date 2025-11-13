*** Settings ***
Resource            common.resource

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
SAT001.001 SATA support in firmware
    [Documentation]    This test aims to verify that SATA is detected from FW
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Depends On    ${SATA_SUPPORT}

    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${boot_manager_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Boot Maintenance Manager

    ${bff_manager_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${boot_manager_menu}
    ...    Boot From File

    Count Arrows Down To Reach The Option    /Sata    # this KWD return error if string not found
