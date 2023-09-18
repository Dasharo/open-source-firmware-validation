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
Suite Setup         Run Keywords    Prepare Test Suite    AND    Flash firmware    ${fw_file}    AND    Prepare Tools, Keys and Binaries
Suite Teardown      Run Keyword    Log Out And Close Connection
Test Setup          Run Keyword    Power On


*** Variables ***
# TODO: Here we cannot yet use variables from platform config, as these are loaded
# only when Prepare Test Suite is called. We could source them sooner, with robot invocation.
# The fw_file_original is the fw_file received as an input to the test suite
${fw_file_original}=    /home/user/test-firmware.rom
# # The fw_file_resigned is the fw_file resigned with newly generated keys (so
# # booting it should trigger vboot recovery events)
${fw_file_resigned}=    /home/user/test-firmware_resigned.rom


*** Test Cases ***
VBO006.002 Check whether the verstage was run
    [Documentation]    Check whether the Verified Boot is enabled and
    ...    functional.
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Skip If    not ${verified_boot_support}    VBO006.002 not supported
    Skip If    not ${tests_in_ubuntu_support}    VBO006.002 not supported
    ${out_cbmem}=    Execute Command In Terminal    cbmem -1 | grep VBOOT
    Should Contain    ${out_cbmem}    VBOOT WORK

VBO007.002 Boot from RW when correctly signed firmware is flashed
    [Documentation]    Check whether the Verified Boot is proceed to boot from
    ...    Slot A/B if the signatures for firmware stored in vboot
    ...    Slot A/B are correct.
    Skip If    not ${verified_boot_support}    VBO007.002 not supported
    Skip If    not ${tests_in_ubuntu_support}    VBO007.002 not supported
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out_cbmem}=    Execute Command In Terminal    cbmem -1 | grep "is selected"
    Should Contain Any    ${out_cbmem}    Slot A is selected    Slot B is selected

VBO009.001 Recovery boot popup is displayed when incorrectly signed firmware is flashed in RW_A
    [Documentation]    Check whether the information about recovery mode will be
    ...    displayed after flash firmware with wrong vboot keys. The boot should
    ...    continue automatically after a 30s delay.
    Skip If    not ${verified_boot_popup_support}    VBO009.001 not supported
    Skip If    not ${tests_in_firmware_support}    VBO009.001 not supported
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Flash RW Sections via Internal Programmer    ${fw_file_resigned}
    Execute Reboot Command
    Set DUT Response Timeout    180s
    ${recovery_popup}=    Read From Terminal Until    Press ENTER key to continue
    Should Contain    ${recovery_popup}    !!! WARNING !!!
    Should Contain    ${recovery_popup}    Recovery reason code:
    Should Contain    ${recovery_popup}    Recovery reason:
    Boot system or from connected disk    ubuntu
    Login to Linux

VBO010.001 Recovery boot popup can be skipped
    [Documentation]    Check whether the functionality of confirming the popup:
    ...    If we press Enter, we should immediately move to the next
    ...    stages of booting.
    Skip If    not ${verified_boot_popup_support}    VBO010.001 not supported
    Skip If    not ${tests_in_firmware_support}    VBO010.001 not supported
    Read From Terminal Until    Press ENTER key to continue
    Write into terminal    ${ENTER}
    Boot system or from connected disk    ubuntu
    Login to Linux

VBO011.001 Recovery popup is not displayed when correctly signed firmware is flashed in RW_A
    [Documentation]    Check whether after flashing the DUT with the valid
    ...    binary, the DUT will boot correctly from the default slot.
    # Relevant issues:
    # https://github.com/Dasharo/dasharo-issues/issues/185
    # https://github.com/Dasharo/dasharo-issues/issues/269
    # https://github.com/Dasharo/dasharo-issues/issues/320
    Skip If    not ${verified_boot_support}    VBO011.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    VBO011.001 not supported
    Variable Should Exist    ${fw_file}
    # 1. Start with flashing of correctly signed firmware
    Set DUT Response Timeout    180s
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Flash RW Sections via Internal Programmer    ${fw_file_original}
    FOR    ${index}    IN RANGE    2
        Execute Reboot Command
        Boot system or from connected disk    ubuntu
        Login to Linux
        Switch to root user
    END
    ${out_cbmem}=    Execute Command In Terminal    cbmem -1 | grep "is selected"
    Should Contain Any    ${out_cbmem}    Slot A is selected    Slot B is selected
    # 2. Flash incorrectly signed firmware and boot 2 times. Recovery popup
    # should be displayed, and recovery request should be logged in cbmem.
    Flash RW Sections via Internal Programmer    ${fw_file_resigned}
    FOR    ${index}    IN RANGE    2
        Execute Reboot Command
        Read From Terminal Until    Press ENTER key to continue
        Write into terminal    ${ENTER}
        Boot system or from connected disk    ubuntu
        Login to Linux
        Switch to root user
        ${out_cbmem}=    Execute Command In Terminal    cbmem -1 | grep Recovery
        Should Contain    ${out_cbmem}    Recovery requested
    END
    # 3. Flash again with correctly signed firmware
    Flash RW Sections via Internal Programmer    ${fw_file_original}
    Execute Reboot Command
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out_cbmem}=    Execute Command In Terminal    cbmem -1 | grep Recovery
    Should Contain    ${out_cbmem}    Recovery reason from previous boot: 0x0
    Should Not Contain    ${out_cbmem}    Recovery requested


*** Keywords ***
Generate Verified Boot keys
    Clone git repository    https://github.com/Dasharo/dasharo-tools.git
    Execute Command In Terminal    rm -rf vboot_keys
    ${out_genkey}=    Execute Command In Terminal    ./dasharo-tools/vboot/generate_keys vboot_keys    timeout=5m
    Should Contain    ${out_genkey}    The Verified Boot keys were generated into following directory

Resign existing firmware image with generated keys
    Send File To DUT    ${fw_file}    ${fw_file_original}
    Execute Command In Terminal    rm -f ${fw_file_resigned}
    ${out_resign}=    Execute Command In Terminal    ./dasharo-tools/vboot/resign ${fw_file_original} vboot_keys
    Should Contain    ${out_resign}    successfully saved new image to

Prepare Tools, Keys and Binaries
    Power On
    # TODO: store the disk boot entry in platform config, or figure out how
    # to handle UEFI boot entries in a reliable manner
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Get coreboot tools from cloud
    Install Docker Packages
    Generate Verified Boot keys
    Resign existing firmware image with generated keys
