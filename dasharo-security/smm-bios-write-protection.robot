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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
SMM001.001 SMM BIOS write protection enabling (Ubuntu 22.04)
    [Documentation]    SMM BIOS write protection is the method to prevent a
    ...    specific region of the firmware from being flashed - when enabled
    ...    allows only SMM code (the privileged code installed by the firmware
    ...    in the system memory) to write to BIOS flash. This test aims to
    ...    verify that, the SMM BIOS protection option is available in the
    ...    Dasharo Security Options and, if the mechanism works correctly -
    ...    during the attempt of firmware flashing information about the
    ...    SMM protection is returned.
    Skip If    not ${smm_write_protection_support}
    Skip If    not ${tests_in_ubuntu_support}
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features submenu    Dasharo Security Options
    Refresh serial screen in BIOS editable settings menu
    ${menu_construction}=    Get Setup Submenu Construction    description_lines=2
    Enable Option in submenu    ${menu_construction}    Enable SMM BIOS write
    Save changes and reset    2    4
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    Should Contain    ${out_flashrom}    SMM protection is enabled

SMM002.001 SMM BIOS write protection disabling (Ubuntu 22.04)
    [Documentation]    SMM BIOS write protection is the method to prevent a
    ...    specific region of the firmware from being flashed - when enabled
    ...    allows only SMM code (the privileged code installed by the firmware
    ...    in the system memory) to write to BIOS flash. This test aims to
    ...    verify that, the SMM BIOS protection option is available in the
    ...    Dasharo Security Options and, if the mechanism works correctly -
    ...    during the attempt of firmware flashing information about the
    ...    SMM protection is returned.
    Skip If    not ${smm_write_protection_support}
    Skip If    not ${tests_in_ubuntu_support}
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo System Features submenu    Dasharo Security Options
    Refresh serial screen in BIOS editable settings menu
    ${menu_construction}=    Get Setup Submenu Construction    description_lines=3
    Disable Option in submenu    ${menu_construction}    Enable SMM BIOS write
    Save changes and reset    2    4
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    Should Not Contain    ${out_flashrom}    SMM protection is enabled
