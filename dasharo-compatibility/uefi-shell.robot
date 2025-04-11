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
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
USH001.001 UEFI Shell
    [Documentation]    Check whether the UEFI Shell is available, and whether
    ...    UEFI Shell was sourced from coreboot image, or from OS drive.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    USH001.001 not supported
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    UEFI Shell
    Read From Terminal Until    Shell>
    Write Bare Into Terminal    dh
    Press Enter
    ${shell_dump_handle}=    Read From Terminal Until    Shell>

    Should Not Contain    ${shell_dump_handle}    LoadedImage(Shell)
    ...    UEFI Shell sourced from Dasharo FW image!
    Should Contain    ${shell_dump_handle}    LoadedImage(\\EFI\\Shell\\Shell.efi)
    ...    UEFI Shell not sourced from EFI partition!
