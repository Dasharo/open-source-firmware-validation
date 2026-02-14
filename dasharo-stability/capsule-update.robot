*** Settings ***
Library             Collections
Library             Dialogs
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
Resource            ../lib/dcu.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${CAPSULE_UPDATE_SUPPORT}    Capsule Update not supported
...                     AND    Display Preparation Instructions
...                     AND    Get CUP Environment Variables
...                     AND    Ensure Capsule Files Are Present
...                     AND    Ensure BtG Testing Capsule Is Present
...                     AND    Prepare For ROMHOLE Persistence Test    # MSI Only
...                     AND    Run Keyword If    ${CUSTOM_LOGO_SUPPORT}    Prepare For Logo Persistence Test
...                     AND    Run Keyword If    ${CUSTOM_LOGO_SUPPORT}    Flash Firmware    ${CUSTOM_LOGO_RC0_FW_FILE}
...                     AND    Run Keyword If    not ${CUSTOM_LOGO_SUPPORT}    Flash Firmware    ${CAPSULE_UPDATE_RC0_FW_FILE}
...                     AND    Set UEFI Option    MeMode    Disabled (HAP)
...                     AND    Deploy Uefi Shell
...                     AND    Upload Required Files
...                     AND    Get System Values
Suite Teardown      Run Keywords
...                     Run Keyword If    '${SUITE_STATUS}' != 'SKIP'    Flash Firmware    ${FW_FILE}
...                     AND    Log Out And Close Connection

Default Tags        automated


*** Variables ***
${FUM_DIALOG_TOP}=                          Update Mode. All firmware write protections are disabled in this mode.
${FUM_DIALOG_BOTTOM}=                       The platform will automatically reboot and disable Firmware Update Mode
${WRONG_KEYS_CAPSULE_STATUS}=               Capsule Status: Security Violation
${WRONG_GUID_CAPSULE_STATUS}=               Capsule Status: Not Ready
# Paths used by SSH-only capsule updates to stage files under the EFI shell workspace
${UEFI_SHELL_BOOT_DIR}=                     /boot/efi
${CAPSULE_UPDATE_SHELL_DIR}=                ${UEFI_SHELL_BOOT_DIR}/capsule_testing
${CAPSULE_UPDATE_SHELL_BOOTENTRY_NAME}=     UEFI Shell


*** Test Cases ***
CUP001.001 Capsule Update With Wrong Keys
    [Documentation]    Check that DUT rejects flashing a capsule signed with invalid certificate.
    ${status}    ${version_changed}=    Perform Capsule Update And Return Status    wrong_cert.cap
    Should Contain    ${status}    ${WRONG_KEYS_CAPSULE_STATUS}
    Should Not Be True    ${version_changed}

CUP002.001 Capsule Update With Wrong GUID
    [Documentation]    Check that DUT rejects flashing a capsule with invalid GUID.
    ${status}    ${version_changed}=    Perform Capsule Update And Return Status    invalid_guid.cap
    Should Contain    ${status}    ${WRONG_GUID_CAPSULE_STATUS}
    Should Not Be True    ${version_changed}

CUP003.001 Capsule Update with wrong BtG key
    [Documentation]    Check that the DUT rejects updates signed with the wrong BtG key on a fused platform.
    Skip If    not ${INTEL_CBNT_SUPPORT}    CUP003.001 not supported on this system
    Skip If    not ${INTEL_CBNT_BOOTGUARD_FUSED}    CUP003.001 not supported on this system
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Login To Linux With Root Privileges
    Perform Capsule Update    invalid_btg_signature.cap    use_uefi_shell=${False}
    Check The Update Screen For BtG Error Message

CUP130.001 Verifying BIOS Settings Persistence After Update - PART 1
    [Documentation]    Check if BIOS settings didn't change after Capsule Update.
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    ${state}=    Get UEFI Option    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
    VAR    ${SMMSTORE_VARIABLE_PERSISTENCE_INITIAL_STATE}=    ${state}    scope=SUITE
    ${new_state}=    Evaluate    not ${state}
    Set UEFI Option    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}    ${new_state}

CUP150.001 Capsule Update
    [Documentation]    Check for a successful Capsule Update.
    ...    Please note that the test number is high on purpose. This test will flash FW! In future
    ...    if additional test cases will be created - when running the whole suite - It will be good
    ...    to keep the number of actual FW updates to minimum to prevent chip degradation.
    ${status}    ${version_changed}=    Perform Capsule Update And Return Status    valid_capsule.cap
    Should Be True    ${version_changed}
    Should Contain    ${status}    CapsuleMax
    Should Not Contain    ${status}    CapsuleLast

CUP160.001 Verifying BIOS Settings Persistence After Update - PART 2
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    ${state}=    Get UEFI Option    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
    Should Not Be Equal    ${state}    ${SMMSTORE_VARIABLE_PERSISTENCE_INITIAL_STATE}

CUP170.201 Verifying UUID (Ubuntu)
    [Documentation]    Check if UUID didn't change after Capsule Update.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CUP170.001 not supported
    Power On
    Boot And Login To OS    ${ENV_ID_UBUNTU}
    Switch To Root User
    Get Ubuntu System Values    UPDATED_SERIAL    UPDATED_UUID    UPDATED_LOGO_SHA256

    Log To Console    \n[Before Update] ${ORIGINAL_UUID}
    Log To Console    \n[After Update] ${UPDATED_UUID}

    Should Be Equal    ${ORIGINAL_UUID}    ${UPDATED_UUID}
    IF    ${ROMHOLE_SUPPORT} == ${TRUE}
        Should Be Equal    ${UPDATED_UUID}    00112233-4455-6677-8899-aabbccddeeff
    END

CUP170.301 Verifying UUID (Windows)
    [Documentation]    Check if UUID didn't change after Capsule Update.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CUP170.002 not supported

    Power On
    Boot And Login To OS    ${ENV_ID_WINDOWS}
    Get Windows System Values    WIN_UPDATED_SERIAL    WIN_UPDATED_UUID

    Log To Console    \n[Before Update] ${ORIGINAL_UUID}
    Log To Console    \n[After Update] ${WIN_UPDATED_UUID}

    # dmidecode reports `Not Settable` for all zeroes
    IF    '${ORIGINAL_UUID}' == 'Not Settable'
        Should Be Equal    ${WIN_UPDATED_UUID}    00000000-0000-0000-0000-000000000000
    ELSE
        Should Be Equal    ${ORIGINAL_UUID}    ${WIN_UPDATED_UUID}
    END

    IF    ${ROMHOLE_SUPPORT} == ${TRUE}
        Should Be Equal    ${WIN_UPDATED_UUID}    00112233-4455-6677-8899-aabbccddeeff
    END

CUP180.201 Verifying Serial Number (Ubuntu)
    [Documentation]    Check if serial number didn't change after Capsule Update.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CUP180.001 not supported
    ${tmp}=    Get Variable Value    $UPDATED_SERIAL
    IF    $tmp is None
        Power On
        Boot And Login To OS    ${ENV_ID_UBUNTU}
        Switch To Root User
        Get Ubuntu System Values    UPDATED_SERIAL    UPDATED_UUID    UPDATED_LOGO_SHA256
    END

    Log To Console    \n[Before Update] ${ORIGINAL_SERIAL}
    Log To Console    \n[After Update] ${UPDATED_SERIAL}

    Should Be Equal    ${ORIGINAL_SERIAL}    ${UPDATED_SERIAL}

CUP180.301 Verifying Serial Number (Windows)
    [Documentation]    Check if serial number didn't change after Capsule Update.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CUP180.002 not supported
    ${tmp}=    Get Variable Value    $WIN_UPDATED_SERIAL
    IF    $tmp is None
        Power On
        Boot And Login To OS    ${ENV_ID_WINDOWS}
        Get Windows System Values    WIN_UPDATED_SERIAL    WIN_UPDATED_UUID
    END

    Log To Console    \n[Before Update] ${ORIGINAL_SERIAL}
    Log To Console    \n[After Update] ${WIN_UPDATED_SERIAL}

    Should Be Equal    ${ORIGINAL_SERIAL}    ${WIN_UPDATED_SERIAL}

CUP190.201 Verifying If Custom Logo Persists Across updates (Ubuntu)
    [Documentation]    Check if Logo didn't change after Capsule Update.
    Skip If    not ${CUSTOM_LOGO_SUPPORT}    CUP190.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CUP190.001 not supported
    Power On
    Boot And Login To OS    ${ENV_ID_UBUNTU}
    Switch To Root User
    Get Ubuntu System Values    UPDATED_SERIAL    UPDATED_UUID    UPDATED_LOGO_SHA256
    Should Be Equal    ${ORIGINAL_LOGO_SHA256}    ${UPDATED_LOGO_SHA256}

CUP250.001 Capsule Update Progress Bar - Default Logo
    [Documentation]    Verify that the Capsule Update screen looks as expected
    ...    and the progress bar is scaled properly using a default logo.
    [Tags]    semiauto
    # Ensure we're running FW with the default logo
    Flash Firmware    ${FW_FILE}
    # Bump the timeout for memory training
    Set DUT Response Timeout    5m
    Set UEFI Option    MeMode    Disabled (HAP)
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Login To Linux With Root Privileges
    Perform Capsule Update    valid_capsule.cap
    Check The Update Screen For The Correct UX


*** Keywords ***
Check Platform Fused
    [Documentation]    Check if the platform FPFs are committed and set a
    ...    variable for use by other keywords.
    IF    not ${INTEL_CBNT_BOOTGUARD_FUSING_SUPPORT}
        Log To Console    Platform cannot be fused. Will skip tests that depend
        ...    on platform fusing.
        VAR    ${INTEL_CBNT_BOOTGUARD_FUSED}=    ${FALSE}    scope=GLOBAL
        RETURN
    END
    Boot And Login To OS    ${DEFAULT_BOOT_OS_ID}
    Switch To Root User
    ${out_cbmem}=    Execute Command In Terminal    cbmem -1 | grep ME
    VAR    ${INTEL_CBNT_BOOTGUARD_FUSED}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${out_cbmem}    FPFs Committed\\s+:\\s+YES\n
    ...    scope=GLOBAL
    Exit From Root User

Perform Capsule Update And Return Status
    [Arguments]    ${capsule_file}
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Login To Linux With Root Privileges
    ${original_bios_version}=    Get BIOS Version Linux    Before update

    Perform Capsule Update    ${capsule_file}

    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Login To Linux With Root Privileges
    ${updated_bios_version}=    Get BIOS Version Linux    After update
    ${version_changed}=    Run Keyword And Return Status
    ...    Should Not Be Equal
    ...    ${original_bios_version}
    ...    ${updated_bios_version}
    ${logs}=    Get Capsule Update Logs
    RETURN    ${logs}    ${version_changed}

Check The Update Screen For The Correct UX
    VAR    ${message}=
    ...    Please check the platform screen now, and verify that the UX is the
    ...    \ same as expected in the docs. Most importantly, the progress bar
    ...    \ should be exactly the same width regardless of whether the default
    ...    \ Dasharo logo or a custom one is set. See the screenshot at
    ...    \ https://docs.dasharo.com/guides/capsule-update for reference.
    ...    separator=${EMPTY}
    Execute Manual Step    ${message}

Check The Update Screen For BtG Error Message
    VAR    ${message}=
    ...    Please check the platform screen now, verify that the orange BtG
    ...    \ error message popup screen appears on the screen. Ensure that the
    ...    \ update abort reason and the fused OEM RK hash are printed, and that
    ...    \ the popup fits on the screen and is readable. See the screenshot at
    ...    \ https://docs.dasharo.com/guides/capsule-update#troubleshooting for
    ...    \ reference.
    ...    separator=${EMPTY}
    Execute Manual Step    ${message}

Get Key To Press
    [Arguments]    ${text}
    ${matches}=    Get Regexp Matches    ${text}    [0-9]
    VAR    ${digit}=    ${matches[0]}
    Log    Found digit: ${digit}
    RETURN    ${digit}

Extract BIOS Version
    [Arguments]    ${text}
    ${lines}=    Split To Lines    ${text}
    VAR    ${bios_version}=    None
    FOR    ${line}    IN    @{lines}
        IF    'BIOS Version' in '${line}'
            VAR    ${bios_version}=    ${line}
        END
    END
    IF    '${bios_version}' == 'None'
        FOR    ${line}    IN    @{lines}
            IF    'BIOSVersion' in '${line}'
                VAR    ${bios_version}=    ${line}
            END
        END
    END

    RETURN    ${bios_version}

Get BIOS Version
    [Arguments]    ${label}
    ${out}=    Execute UEFI Shell Command    smbiosview -t 0
    ${bios_version}=    Extract BIOS Version    ${out}
    Log To Console    \n[${label}] ${bios_version}
    RETURN    ${bios_version}

Get BIOS Version Linux
    [Arguments]    ${label}
    ${bios_version}=    Get Firmware Version From Dmidecode
    Log To Console    \n[${label}] ${bios_version}
    RETURN    ${bios_version}

Prepare Capsule Shell Workspace
    Execute Command In Terminal    rm -rf ${CAPSULE_UPDATE_SHELL_DIR}
    Execute Command In Terminal    mkdir -p ${CAPSULE_UPDATE_SHELL_DIR}
    Execute Command In Terminal    chmod 755 ${CAPSULE_UPDATE_SHELL_DIR}

Copy Capsule Files To Shell Workspace
    [Arguments]    ${capsule_basename}
    Log To Console    Staging capsule files at ${CAPSULE_UPDATE_SHELL_DIR}
    # Logic
    Send File To DUT
    ...    dasharo-stability/capsule-update-files/CapsuleApp.efi
    ...    ${UEFI_SHELL_BOOT_DIR}/CapsuleApp.efi
    Send File To DUT
    ...    dasharo-stability/capsule-update-files/capsule-update-startup.nsh
    ...    ${UEFI_SHELL_BOOT_DIR}/startup.nsh
    # Variables
    Send File To DUT    dasharo-stability/capsule-update-files/variable_capsule_file.nsh
    ...    ${CAPSULE_UPDATE_SHELL_DIR}/variable_capsule_file.nsh
    Send File To DUT    dasharo-stability/capsule-update-files/variable_step.nsh
    ...    ${CAPSULE_UPDATE_SHELL_DIR}/variable_step.nsh

    # Capsules
    Send File To DUT    ${CAPSULE_FW_FILE}    ${CAPSULE_UPDATE_SHELL_DIR}/valid_capsule.cap
    Send File To DUT
    ...    ./dl-cache/edk2/${capsule_basename}_wrong_cert.cap
    ...    ${CAPSULE_UPDATE_SHELL_DIR}/wrong_cert.cap
    Send File To DUT
    ...    ./dl-cache/edk2/${capsule_basename}_invalid_guid.cap
    ...    ${CAPSULE_UPDATE_SHELL_DIR}/invalid_guid.cap
    ${tmp}=    Get Variable Value    $BTG_CAPSULE_FW_FILE
    IF    $tmp is not None
        Send File To DUT
        ...    ./dl-cache/edk2/${BTG_CAPSULE_FW_FILE}
        ...    ${CAPSULE_UPDATE_SHELL_DIR}/invalid_btg_signature.cap
    END

Perform Capsule Update
    [Arguments]    ${capsule_file}    ${use_uefi_shell}=${True}
    # Submit capsule to firmware without an automatic reset and verify that it
    # was accepted without error
    VAR    ${capsule_fs_path}=    ${capsule_file}
    Set Startup Nsh Variable    capsule_file    ${capsule_fs_path}
    Set Startup Nsh Variable    step    0
    Set Nextboot Bootentry    ${CAPSULE_UPDATE_SHELL_BOOTENTRY_NAME}
    Execute Reboot Command    assume_correct_boot=${True}
    # uefi shell runs and reboots the platform
    IF    '${OPTIONS_LIB}' == 'options-lib_uefi-setup-menu'
        # If serial console supported, then FUM dialog will be shown
        # Confirm update by following instructions of Firmware Update Mode dialog
        Read From Terminal Until    ${TIANOCORE_STRING}    # booting UEFI Shell
        Handle FUM Screen
    END
    Boot And Login To OS    ${DEFAULT_BOOT_OS_ID}

Handle FUM Screen
    ${out}=    Read From Terminal Until Regexp    (${TIANOCORE_STRING})|(${FUM_DIALOG_TOP})
    IF    '${FUM_DIALOG_TOP}' in $out
        ${fum_screen}=    Read From Terminal Until    ${FUM_DIALOG_BOTTOM}
        ${digit}=    Get Key To Press    ${fum_screen}
        Write Bare Into Terminal    ${digit}
    ELSE
        Log    FUM screen did not appear    WARN
    END

Get File Name Without Extension
    [Arguments]    ${file_path}
    ${path_components}=    Split String    ${file_path}    /
    ${base_name}=    Get From List    ${path_components}    -1
    ${name_parts}=    Split String From Right    ${base_name}    .    1
    ${result}=    Get From List    ${name_parts}    0
    RETURN    ${result}

Ensure Capsule Files Are Present
    Variable Should Exist
    ...    ${CAPSULE_FW_FILE}
    ...    capsule_fw_file parameter missing. Please add: -v capsule_fw_file:<capsule_to_be_tested>.cap to the robot command line and try again.

    OperatingSystem.File Should Exist
    ...    ${CAPSULE_FW_FILE}
    ...    capsule_fw_file parameter incorrect. Please add: -v capsule_fw_file:<capsule_to_be_tested>.cap to the robot command line and try again.

    ${file_name}=    Get File Name Without Extension    ${CAPSULE_FW_FILE}
    ${f1}=    Run Keyword And Return Status
    ...    OperatingSystem.File Should Exist
    ...    ./dl-cache/edk2/${file_name}_wrong_cert.cap
    ${f2}=    Run Keyword And Return Status
    ...    OperatingSystem.File Should Exist
    ...    ./dl-cache/edk2/${file_name}_invalid_guid.cap

    IF    not ${f1} or not ${f2}
        Run    ./scripts/capsules/capsule_update_tests.sh ${CAPSULE_FW_FILE}
    END

Ensure BtG Testing Capsule Is Present
    IF    ${INTEL_CBNT_BOOTGUARD_FUSED}
        Variable Should Exist
        ...    ${BTG_CAPSULE_FW_FILE}
        ...    btg_capsule_fw_file parameter missing. Please add: -v btg_capsule_fw_file:<capsule_to_be_tested>.cap to the robot command line and try again.

        OperatingSystem.File Should Exist
        ...    ${BTG_CAPSULE_FW_FILE}
        ...    btg_capsule_fw_file parameter incorrect. Please add: -v btg_capsule_fw_file:<capsule_to_be_tested>.cap to the robot command line and try again.
    END

Display Preparation Instructions
    VAR    ${t}=    ${SPACE}${SPACE}${SPACE}
    VAR    ${msg}=    To run tests you need to set a couple environment variables:
    ...    1. FW_FILE contains path to the `.rom` file of tested release
    ...    2. CAPSULE_FW_FILE contains path to the `.cap` file with the same firmware version as FW_FILE
    ...    3. CAPSULE_UPDATE_RC0_FW_FILE contains path to a `.rom` file with either a lower RC version, or to
    ...    ${t}the RC0 rom in case of first RC that supports capsule updates
    ...    ${EMPTY}
    ...    Be careful if the tested device needs some additional setup menu changes to the default setup menu
    ...    options to work, e.g. enabling Serial Redirection or Power After AC Loss.
    ...    These UEFI options need to be set in all the firmware files used for these tests prior to starting.
    ...    separator=\r\n
    Log To Console    ******************************************************************************
    Log To Console    ${msg}
    Log To Console    ******************************************************************************

Prepare For Logo Persistence Test
    Log To Console    PREPARE: Logo Persistence Test
    ${name}=    Evaluate    '${CAPSULE_UPDATE_RC0_FW_FILE}'.split("/")[-1]
    VAR    ${CUSTOM_LOGO_RC0_FW_FILE}=    dcu/custom_logo_${name}    scope=SUITE
    Run    cp ${CAPSULE_UPDATE_RC0_FW_FILE} ${CUSTOM_LOGO_RC0_FW_FILE}
    DCU Logo Set In File    ${CUSTOM_LOGO_RC0_FW_FILE}    ${TEST_DATA_DIR}/dcu/logo.bmp

Get System Values
    IF    ${TESTS_IN_UBUNTU_SUPPORT}
        Power On
        Boot And Login To OS    ${ENV_ID_UBUNTU}
        Switch To Root User
        Get Ubuntu System Values    ORIGINAL_SERIAL    ORIGINAL_UUID    ORIGINAL_LOGO_SHA256
    ELSE IF    ${TESTS_IN_WINDOWS_SUPPORT}
        Power On
        Boot And Login To OS    ${ENV_ID_WINDOWS}
        Get Windows System Values    ORIGINAL_SERIAL    ORIGINAL_UUID
    ELSE
        Fail    No Windows nor Ubuntu support available
    END

Get Ubuntu System Values
    [Arguments]    ${var_serial}    ${var_uuid}    ${var_logo_sha256}
    ${serial}=    Get Firmware Serial Number
    VAR    ${${var_serial}}=    ${serial}    scope=SUITE

    ${uuid}=    Get Firmware UUID
    VAR    ${${var_uuid}}=    ${uuid}    scope=SUITE

    IF    ${CUSTOM_LOGO_SUPPORT} == ${TRUE}
        ${out}=    Execute Command In Terminal
        ...    sha256sum /sys/firmware/acpi/bgrt/image
        ${unplugged}=    Run Keyword And Return Status
        ...    Should Contain    ${out}    No such file
        IF    ${unplugged} == ${TRUE}
            Fail    Please make sure that a display device is connected to the DUT
        END
        VAR    ${${var_logo_sha256}}=    ${out}    scope=SUITE
    END

Get Windows System Values
    [Arguments]    ${var_serial}    ${var_uuid}
    ${serial}=    Get Firmware Serial Number (Windows)
    VAR    ${${var_serial}}=    ${serial}    scope=SUITE

    ${uuid}=    Get Firmware UUID (Windows)
    VAR    ${${var_uuid}}=    ${uuid}    scope=SUITE

Upload Required Files
    ${fw_filename}=    Get File Name Without Extension    ${FW_FILE}
    ${caps_filename}=    Get File Name Without Extension    ${CAPSULE_FW_FILE}
    ${tmp}=    Get Variable Value    $BTG_CAPSULE_FW_FILE
    IF    $tmp is not None
        ${btg_caps_filename}=    Get File Name Without Extension    ${BTG_CAPSULE_FW_FILE}
    END
    ${tmp}=    Get Variable Value    $BTG_CAPSULE_FW_FILE
    IF    $tmp is not None
        Send File To Dut    ${BTG_CAPSULE_FW_FILE}    /root/${btg_caps_filename}.cap
    END
    ${tmp}=    Get Variable Value    $BTG_CAPSULE_FW_FILE
    IF    $tmp is not None
        Execute Command In Terminal    export BTG_CAPSULE_FW_FILE=/root/${btg_caps_filename}.cap
    END

    Prepare Capsule Shell Workspace
    Copy Capsule Files To Shell Workspace    ${caps_filename}

Prepare For ROMHOLE Persistence Test
    [Documentation]    This is a part which works only on MSI platforms.
    Log To Console    PREPARE: ROMHOLE Persistence Test

    IF    ${ROMHOLE_SUPPORT} == ${TRUE}
        Run    dd if=dasharo-stability/capsule-update-files/romhole of=dcu/coreboot.rom seek=24903680 bs=1 conv=notrunc
    ELSE
        Log To Console    \ \ \ \ ROMHOLE not supported - skipping
    END

Get Firmware UUID (Windows)
    ${uuid}=    Execute Command In Terminal    Get-CimInstance Win32_ComputerSystemProduct | Select-Object UUID
    @{uuid}=    Split To Lines    ${uuid}
    VAR    ${var}=    ${uuid}[-1]
    ${var}=    Strip String    ${var}
    ${var}=    Convert To Lower Case    ${var}
    RETURN    ${var}

Get Firmware Serial Number (Windows)
    ${serial}=    Execute Command In Terminal    Get-CimInstance Win32_BIOS | Select-Object SerialNumber
    @{serial}=    Split To Lines    ${serial}
    VAR    ${var}=    ${serial}[-1]
    ${var}=    Strip String    ${var}
    RETURN    ${var}

Get Capsule Update Logs
    [Documentation]    Gets the capsule update logs from CapsuleApp.efi -S
    # Submit capsule to firmware without an automatic reset and verify that it
    # was accepted without error
    Set Startup Nsh Variable    step    1
    Set Nextboot Bootentry    ${CAPSULE_UPDATE_SHELL_BOOTENTRY_NAME}
    Execute Reboot Command    assume_correct_boot=${True}
    IF    '${OPTIONS_LIB}' == 'options-lib_uefi-setup-menu'
        Read From Terminal Until    ${TIANOCORE_STRING}
    END
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Login To Linux With Root Privileges
    VAR    ${logs_path}=    ${CAPSULE_UPDATE_SHELL_DIR}/logs.txt

    # UEFI Shell uses UTF-16LE and SSHLibrary will panic if the file is read
    # to the terminal in this form
    Execute Command In Terminal    iconv -f UTF-16LE -t UTF-8 ${logs_path} -o /tmp/capsule-logs.txt
    ${logs}=    Execute Command In Terminal    cat /tmp/capsule-logs.txt
    RETURN    ${logs}

Set Startup Nsh Variable
    [Documentation]    The variables that control the startup.nsh script
    ...    are written to files located in the EFI shell workspace.
    [Arguments]    ${name}    ${value}
    ${variable_name}=    Convert To Upper Case    ${name}
    ${file_name}=    Convert To Lower Case    ${name}
    VAR    ${target}=    ${CAPSULE_UPDATE_SHELL_DIR}/variable_${file_name}.nsh
    Execute Command In Terminal    echo "set ${variable_name} ${value}" > '${target}'

Get CUP Environment Variables
    [Documentation]    Saves the env variables to robot variables that might be different
    ...    depending on the configuration used during testing
    ${rc0}=    Get Environment Variable    name=CAPSULE_UPDATE_RC0_FW_FILE
    VAR    ${CAPSULE_UPDATE_RC0_FW_FILE}=    ${rc0}    scope=SUITE
