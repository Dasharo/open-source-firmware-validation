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
Resource            ../lib/custom_bootentries.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    UEFI Shell not supported on this platform
...                     AND
...                     Deploy Uefi Shell
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
USH001.106 UEFI Shell Support (UEFI Shell)
    [Documentation]    Check whether the UEFI Shell is available, and whether
    ...    UEFI Shell was sourced from coreboot image, or from OS drive.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    USH001.106 not supported
    Power On
    Enter UEFI Shell
    # Server platforms have a lot more devices, so more handles will be printed
    # by dh command. With serial console it takes a lot of time to print everything
    # due to slow screen scrolling on the graphical display. Give it 3 minutes
    ${shell_dump_handle}=    Execute UEFI Shell Command    dh    180s

    Should Not Contain    ${shell_dump_handle}    LoadedImage(Shell)
    ...    UEFI Shell sourced from Dasharo FW image!
    Should Contain    ${shell_dump_handle}    LoadedImage(\\EFI\\Shell\\Shell.efi)
    ...    UEFI Shell not sourced from EFI partition!
