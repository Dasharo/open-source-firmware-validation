*** Settings ***
Metadata            ORDER_SENSITIVE

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
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${VERIFIED_BOOT_SUPPORT}    Vboot not supported
...                     AND
...                     Flash Firmware    ${FW_FILE}
...                     AND
...                     Make Sure That Flash Locks Are Disabled
...                     AND
...                     Prepare Tools, Keys And Binaries
Suite Teardown      Run Keywords
...                     Run Keyword If    '${SUITE_STATUS}' != 'SKIP'    Flash Firmware    ${FW_FILE}
...                     AND    Log Out And Close Connection
...                     AND    Run    rm -rf ${KEYS_DIR}
Test Setup          Run Keyword
...                     Power On

Default Tags        automated


*** Test Cases ***
VBO006.201 Verified boot support (Ubuntu)
    [Documentation]    Check whether the Verified Boot is enabled and
    ...    functional.
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}

    Login To Linux
    Switch To Root User
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    VBO006.201 not supported
    ${out_cbmem}=    Execute Command In Terminal    cbmem -l | grep VBOOT
    Should Contain    ${out_cbmem}    VBOOT WORK

VBO007.201 Booting from Slot A (Ubuntu)
    [Documentation]    Check whether the Verified Boot is proceed to boot from
    ...    Slot A/B if the signatures for firmware stored in vboot
    ...    Slot A/B are correct.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    VBO007.201 not supported
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${out_vboot}=    Execute Command In Terminal    ./dasharo-tools/vboot/workbuf_parse -1 | grep "boot mode"
    Should Contain    ${out_vboot}    Normal boot mode

VBO008.201 Booting from Recovery (Ubuntu)
    [Documentation]    Check whether the information about recovery mode will be
    ...    displayed after flash firmware with wrong vboot keys. The boot should
    ...    continue automatically after a 30s delay.
    Skip If    not ${VERIFIED_BOOT_POPUP_SUPPORT}    VBO008.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    VBO008.201 not supported

    # setting 5 minutes time-out to prevent failure on platforms with
    # either extended FW boot times, or recovery pop-up left.
    Set DUT Response Timeout    300s
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Flash RW Sections Via Internal Programmer    ${FW_FILE_RESIGNED_TARGET}
    Execute Reboot Command

    # setting 5 minutes time-out to prevent failure on platforms with
    # extended FW boot times
    Set DUT Response Timeout    300s
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    cbmem -c | grep -i recovery
    Should Contain    ${out}    Recovery requested

VBO009.001 Recovery boot popup (firmware)
    [Documentation]    Check whether the information about recovery mode will be
    ...    displayed after flash firmware with wrong vboot keys. The boot should
    ...    continue automatically after a 30s delay.
    Skip If    not ${VERIFIED_BOOT_POPUP_SUPPORT}    VBO009.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    VBO009.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    VBO009.001 not supported

    # setting 5 minutes time-out to prevent failure on platforms with
    # either extended FW boot times, or recovery pop-up left.
    Set DUT Response Timeout    300s
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Flash RW Sections Via Internal Programmer    ${FW_FILE_RESIGNED_TARGET}
    Execute Reboot Command

    # setting 5 minutes time-out to prevent failure on platforms with
    # extended FW boot times
    Set DUT Response Timeout    300s
    ${recovery_popup}=    Read From Terminal Until    Press ENTER key to continue
    # Workaround for laptops tested using sonoff & without a battery
    Should Contain    ${recovery_popup}    !!! WARNING !!!
    IF    'battery is not detected' in $recovery_popup
        Sleep    12s
        Read From Terminal
        ${recovery_popup}=    Read From Terminal Until    Press ENTER key to continue
    END
    Should Contain    ${recovery_popup}    Recovery reason code:
    Should Contain    ${recovery_popup}    Recovery reason:
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux

VBO010.001 Recovery boot popup confirmation (firmware)
    [Documentation]    Check whether the functionality of confirming the popup:
    ...    If we press Enter, we should immediately move to the next
    ...    stages of booting.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    VBO010.001 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    VBO010.001 not supported
    Skip If    not ${VERIFIED_BOOT_POPUP_SUPPORT}    VBO010.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    VBO010.001 not supported
    Read From Terminal Until    Press ENTER key to continue
    Write Into Terminal    ${ENTER}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux

VBO011.001 Recovery popup is not displayed when correctly signed firmware is flashed in RW_A
    [Documentation]    Check whether after flashing the DUT with the valid
    ...    binary, the DUT will boot correctly from the default slot.
    # Relevant issues:
    # https://github.com/Dasharo/dasharo-issues/issues/185
    # https://github.com/Dasharo/dasharo-issues/issues/269
    # https://github.com/Dasharo/dasharo-issues/issues/320
    Skip If    not ${VERIFIED_BOOT_POPUP_SUPPORT}    VBO011.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    VBO011.001 not supported
    Variable Should Exist    ${FW_FILE}
    # 1. Start with flashing of correctly signed firmware
    Set DUT Response Timeout    180s
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Flash RW Sections Via Internal Programmer    ${FW_FILE_ORIGINAL_TARGET}
    FOR    ${index}    IN RANGE    2
        Execute Reboot Command
        Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
        Login To Linux
        Switch To Root User
    END
    ${out_vboot}=    Execute Command In Terminal    ./dasharo-tools/vboot/workbuf_parse -1 | grep "boot mode"
    Should Contain    ${out_vboot}    Normal boot mode
    # 2. Flash incorrectly signed firmware and boot 2 times. Recovery popup
    # should be displayed, and recovery request should be logged in cbmem.
    Flash RW Sections Via Internal Programmer    ${FW_FILE_RESIGNED_TARGET}
    FOR    ${index}    IN RANGE    2
        Execute Reboot Command
        IF    ${TESTS_IN_FIRMWARE_SUPPORT}
            Read From Terminal Until    Press ENTER key to continue
            Write Into Terminal    ${ENTER}
        ELSE
            Sleep    15s    # Wait for the pop-up to disappear automatically
        END
        Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
        Login To Linux
        Switch To Root User
        ${out_vboot}=    Execute Command In Terminal    ./dasharo-tools/vboot/workbuf_parse -1 | grep "boot mode"
        Should Contain    ${out_vboot}    Recovery boot mode
    END
    # 3. Flash again with correctly signed firmware
    Flash RW Sections Via Internal Programmer    ${FW_FILE_ORIGINAL_TARGET}
    Execute Reboot Command
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${out_vboot}=    Execute Command In Terminal    ./dasharo-tools/vboot/workbuf_parse -1 | grep "boot mode"
    Should Contain    ${out_vboot}    Normal boot mode

VBO012.001 Self-signed binary is bootable without errors
    [Documentation]    Check whether a self-signed binary is bootable when the
    ...    entire SPI flash is flashed. This verifies that the signing scripts
    ...    used by the end users are correct and don't cause bricks.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    VBO012.001 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Flash RW Sections Via Internal Programmer    ${FW_FILE_RESIGNED_TARGET}
    Execute Reboot Command
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User


*** Keywords ***
Generate Verified Boot Keys
    ${random}=    Generate Random String    16
    VAR    ${KEYS_DIR}=    vboot_keys_${random}    scope=SUITE
    Run    git clone https://github.com/Dasharo/dasharo-tools.git
    Run    rm -rf ${KEYS_DIR}
    ${out_genkey}=    Run    ./dasharo-tools/vboot/generate_keys ${KEYS_DIR}
    Run    chmod -R a+rw ${KEYS_DIR}
    Should Contain    ${out_genkey}    The Verified Boot keys were generated into following directory
    Run    tar -czf ${KEYS_DIR}.tar.gz ${KEYS_DIR}
    Send File To DUT    ${KEYS_DIR}.tar.gz    ${KEYS_DIR}.tar.gz
    Execute Command In Terminal    tar -xzf ${KEYS_DIR}.tar.gz
    ${ls}=    Execute Command In Terminal    ls -l ${KEYS_DIR}
    Should Contain All    ${ls}    vboot    arv_root

Resign Existing Firmware Image With Generated Keys
    Send File To DUT    ${FW_FILE}    ${FW_FILE_ORIGINAL_TARGET}
    Run    rm -f ${FW_FILE_RESIGNED_SOURCE}
    ${out_resign}=    Run    ./dasharo-tools/vboot/resign ${FW_FILE} ${KEYS_DIR}
    Should Contain    ${out_resign}    successfully saved new image to
    Should Contain    ${out_resign}    ${FW_FILE_RESIGNED_SOURCE}
    Run    sync
    ${size_original}=    Run    ls -l ${FW_FILE} | cut -d ' ' -f 5
    ${size_resigned}=    Run    ls -l ${FW_FILE_RESIGNED_SOURCE} | cut -d ' ' -f 5
    Should Be Equal As Integers
    ...    ${size_original}
    ...    ${size_resigned}
    ...    msg=Size of resigned firmware is incorrect. Resigning failed.
    Send File To DUT    ${FW_FILE_RESIGNED_SOURCE}    ${FW_FILE_RESIGNED_TARGET}
    Send File To DUT    ${FW_FILE}    ${FW_FILE_ORIGINAL_TARGET}

Prepare Tools, Keys And Binaries
    Power On
    # TODO: store the disk boot entry in platform config, or figure out how
    # to handle UEFI boot entries in a reliable manner
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}

    # The fw_file_original is the fw_file received as an input to the test suite
    VAR    ${FW_FILE_ORIGINAL_TARGET}=    /home/${DEVICE_OS_USERNAME}/test-firmware.rom    scope=SUITE
    # The fw_file_resigned is the fw_file resigned with newly generated keys
    # (so booting it should trigger vboot recovery events)
    VAR    ${FW_FILE_RESIGNED_TARGET}=    /home/${DEVICE_OS_USERNAME}/test-firmware_resigned.rom    scope=SUITE
    ${filename}=    Evaluate    ".".join('${FW_FILE}'.split(".")[:-1]) + "_resigned.rom"
    VAR    ${FW_FILE_RESIGNED_SOURCE}=    ${filename}    scope=SUITE

    Login To Linux
    Switch To Root User
    Clone Git Repository    https://github.com/Dasharo/dasharo-tools.git
    Generate Verified Boot Keys
    Resign Existing Firmware Image With Generated Keys
    Execute Command In Terminal    sync
