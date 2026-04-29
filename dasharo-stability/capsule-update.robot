*** Settings ***
Metadata            ORDER_SENSITIVE

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
...                     AND    Ensure Capsule Files Are Present
...                     AND    Ensure BtG Testing Capsule Is Present
...                     AND    Prepare For ROMHOLE Persistence Test
...                     AND    Run Keyword If    ${CUSTOM_LOGO_SUPPORT}    Prepare For Logo Persistence Test
...                     AND    Flash Firmware    ${BASE_FW_FILE}
...                     AND    Upload Required Files
...                     AND    Get System Values
Suite Teardown      Run Keywords
...                     Run Keyword If    '${SUITE_STATUS}' != 'SKIP'    Flash Firmware    ${FW_FILE}
...                     AND    Log Out And Close Connection

Default Tags        automated


*** Variables ***
${CAPSULE_UPDATE_RC0_FW_FILE_NO_LOGO}=          ${NONE}    # Set in Suite Setup "Prepare For Logo Persistence Test"

# To be read from environment variables
${CAPSULE_UPDATE_RC0_FW_FILE}=                  ${NONE}

# variables to be set by setup
${CAPSULE_UPDATE_RC0_FW_FILE_ME_HAP}=           ${NONE}
${CAPSULE_UPDATE_RC0_FW_FILE_ME_ENABLED}=       ${NONE}
# Contains the base firmware used for most tests.
# Will contain CAPSULE_UPDATE_RC0_FW_FILE or CAPSULE_UPDATE_RC0_FW_FILE_ME_HAP depending on ME support
# The LOGO will be replaced in it if CUSTOM_LOGO_SUPPORT
${BASE_FW_FILE}=                                ${NONE}

# # V2 specific variables
${V2_CAP_HAS_TEST_KEYS}=                        ${FALSE}
${CAPSULE_UPDATE_RC0_HAS_TEST_KEYS}=            ${FALSE}

# # Capsules used for testing filenames
${WRONG_KEYS_CAP}=                              ${NONE}
${INVALID_GUID_CAP}=                            ${NONE}

# Serial console markers
${FUM_DIALOG_TOP}=                              Update Mode. All firmware write protections are disabled in this mode.
${FUM_DIALOG_BOTTOM}=                           The platform will automatically reboot and disable Firmware Update Mode
# # "P" omitted as it differs in case between the fail and succeed screens
${V2_RESULT_SCREEN_BOTTOM}=
...                                             ress ENTER to reboot

# Capsule Statuses for verification of update rejection
${WRONG_KEYS_CAPSULE_STATUS}=                   Security Violation
${WRONG_GUID_CAPSULE_STATUS}=                   Not Ready

# Setup related variables
# # Paths used by SSH-only capsule updates to stage files under the EFI shell workspace
${UEFI_SHELL_BOOT_DIR}=                         /boot/efi
${CAPSULE_UPDATE_SHELL_DIR}=                    ${UEFI_SHELL_BOOT_DIR}/capsule_testing
${CAPSULE_UPDATE_SHELL_BOOTENTRY_NAME}=         UEFI Shell

# Save V2 capsules result screens for verification
# to not run the updates multiple times
&{V2_RESULT_SCREENS}=                           &{EMPTY}

# Manual UX tests messages
${T}=                                           ${SPACE}${SPACE}${SPACE}
@{MANUAL_UX_PREP_MESSAGE}=
...                                             A capsule update will be performed shortly after choosing PASS.
...                                             This might include booting an OS and UEFI Shell and can take up to a minute or two.
...                                             Observe the screen and note the results. Directly after the update
...                                             ends, you will be asked to verify the following tests:\n
@{CUP_250_MESSAGE}=
...                                             CUP250:
...                                             ${T}The width of the progress bar matches docs regardless of whether the default
...                                             ${T}Dasharo logo or a custom one is set. See the screenshot at
...                                             ${T}https://docs.dasharo.com/guides/capsule-update for reference.
@{CUP_251_MESSAGE}=
...                                             CUP251:
...                                             ${T}The Update screen should show the hardware vendor logo for supported vendors:
...                                             ${T}NovaCustom, Protectli, Tuxedo.
...                                             ${T}Other platforms should show the Dasharo logo.
...                                             ${T}The logo should fill most of the screen and look sharp.
...                                             ${T}Refer to docs.dasharo.com: https://docs.dasharo.com/guides/capsule-update/#newer-versions-v2_1
@{CUP_252_MESSAGE}=
...                                             CUP252:
...                                             ${T}The progress bar should move smoothly. It should not look like it's frozen.
...                                             ${T}The time between updates should not exceed 3 seconds.
@{CUP_253_MESSAGE}=
...                                             CUP253:
...                                             ${T}The update should result in a green "Firmware Update Succeeded" screen.
...                                             ${T}It should correctly print the firmware versions:
...                                             ${T}- From which the update was run (BASE version)
...                                             ${T}- To which the firmware was updated (FW_FILE version)

@{CUP_280_MESSAGE}=
...                                             CUP280:
...                                             ${T}The update should result in an orange "Firmware Update Failed" screen.
...                                             ${T}The result screen should say: `Status of payload: Security Violation`
...                                             ${T}Refer to docs.dasharo.com: https://docs.dasharo.com/guides/capsule-update/#newer-versions-v2_2
@{CUP_281_MESSAGE}=
...                                             CUP281:
...                                             ${T}The update should result in an orange "Firmware Update Failed" screen.
...                                             ${T}The result screen should say: `Status of payload: Not Ready`
...                                             ${T}Refer to docs.dasharo.com: https://docs.dasharo.com/guides/capsule-update/#newer-versions-v2_2


*** Test Cases ***
CUP001.001 Capsule Update With Wrong Keys
    [Documentation]    Check that DUT rejects flashing a capsule signed with invalid certificate.
    [Tags]    automated    semiauto
    ${manual_gui}=    Evaluate    ${CAPSULE_UPDATE_V2_SUPPORT} and ${SHOULD_RUN_SEMIAUTO_TESTS}
    IF    ${manual_gui}
        Manual UI Verification Prompt    ${CUP_280_MESSAGE}    prepare=${TRUE}
    END
    Set To Dictionary    ${V2_RESULT_SCREENS}    wrong_cert.cap    ${EMPTY}
    ${status}    ${version_changed}=    Perform Capsule Update And Return Status
    ...    wrong_cert.cap
    ...    v2_result_gui_manual=${manual_gui}
    Should Contain    ${status}    ${WRONG_KEYS_CAPSULE_STATUS}
    Should Not Be True    ${version_changed}

CUP280.101 Capsule Update V2 Failure Screen Wrong Keys (EDK2 UEFI)
    [Documentation]    Check whether Capsules V2 failure result screen appears
    ...    and has expected contents.
    [Tags]    semiauto
    Skip If    not ${CAPSULE_UPDATE_V2_SUPPORT}    CUP280.101 not supported
    Skip If    not ${SHOULD_RUN_SEMIAUTO_TESTS}    CUP280.101 not supported

    # Populated in CUP001.001
    ${screen}=    Get From Dictionary    ${V2_RESULT_SCREENS}    wrong_cert.cap    default=${NONE}
    IF    $screen is ${None}
        Skip    CUP280 depends on CUP001. The dependency was not run.
    END
    IF    '${OPTIONS_LIB}' == 'options-lib_uefi-setup-menu'
        Should Contain    ${screen}    ${WRONG_KEYS_CAPSULE_STATUS}
    END

    Manual UI Verification Prompt    ${CUP_280_MESSAGE}

CUP002.001 Capsule Update With Wrong GUID
    [Documentation]    Check that DUT rejects flashing a capsule with invalid GUID.
    [Tags]    automated    semiauto
    Skip If    ${CAPSULE_UPDATE_V2_SUPPORT} and not ${CAPSULE_UPDATE_RC0_HAS_TEST_KEYS}
    ...    Capsule Update V2 - the test requires base firmware with testing keys - provided production firmware
    ${manual_gui}=    Evaluate    ${CAPSULE_UPDATE_V2_SUPPORT} and ${SHOULD_RUN_SEMIAUTO_TESTS}
    IF    ${manual_gui}
        Manual UI Verification Prompt    ${CUP_281_MESSAGE}    prepare=${TRUE}
    END
    Set To Dictionary    ${V2_RESULT_SCREENS}    invalid_guid.cap    ${EMPTY}
    ${status}    ${version_changed}=    Perform Capsule Update And Return Status
    ...    invalid_guid.cap
    ...    v2_result_gui_manual=${manual_gui}
    Should Contain    ${status}    ${WRONG_GUID_CAPSULE_STATUS}
    Should Not Be True    ${version_changed}

CUP281.101 Capsule Update V2 Failure Screen Wrong GUID (EDK2 UEFI)
    [Documentation]    Check whether Capsules V2 failure result screen appears
    ...    and has expected contents.
    [Tags]    semiauto
    Skip If    not ${CAPSULE_UPDATE_V2_SUPPORT}    CUP281.101 not supported
    Skip If    not ${SHOULD_RUN_SEMIAUTO_TESTS}    CUP281.101 not supported

    # Populated in CUP002.001
    ${screen}=    Get From Dictionary    ${V2_RESULT_SCREENS}    invalid_guid.cap    default=${NONE}
    IF    $screen is ${None}
        Skip    CUP281 depends on CUP001. The dependency was not run.
    END
    IF    '${OPTIONS_LIB}' == 'options-lib_uefi-setup-menu'
        Should Contain    ${screen}    ${WRONG_GUID_CAPSULE_STATUS}
    END

    Manual UI Verification Prompt    ${CUP_281_MESSAGE}

CUP003.001 Capsule Update with wrong BtG key
    [Documentation]    Check that the DUT rejects updates signed with the wrong BtG key on a fused platform.
    [Tags]    semiauto
    Skip If    not ${INTEL_CBNT_SUPPORT}    CUP003.001 not supported on this system
    Skip If    not ${INTEL_CBNT_BOOTGUARD_FUSED}    CUP003.001 not supported on this system
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Login To Linux With Root Privileges
    Check The Update Screen For BtG Error Message    pre=${TRUE}
    Perform Capsule Update    invalid_btg_signature.cap
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
    [Documentation]    Check for a successful Capsule Update using EDK2 testing keys.
    ...    Please note that the test number is high on purpose. This test will flash FW! In future
    ...    if additional test cases will be created - when running the whole suite - It will be good
    ...    to keep the number of actual FW updates to minimum to prevent chip degradation.
    Skip If    ${CAPSULE_UPDATE_V2_SUPPORT} and not ${V2_CAP_HAS_TEST_KEYS}
    ...    Capsule Update V2 - production capsule provided, testing keys tests not supported
    ${manual_gui}=    Evaluate    ${CAPSULE_UPDATE_V2_SUPPORT} and ${SHOULD_RUN_SEMIAUTO_TESTS}
    IF    ${manual_gui}
        Manual UI Verification Prompt    ${CUP_250_MESSAGE}    prepare=${TRUE}
    END
    ${status}    ${version_changed}=    Perform Capsule Update And Return Status
    ...    valid_capsule.cap
    ...    v2_result_gui_manual=${manual_gui}
    Should Be True    ${version_changed}
    Should Contain    ${status}    CapsuleMax
    Should Not Contain    ${status}    CapsuleLast

CUP151.101 Capsule Update Production Keys (EDK2 UEFI)
    [Documentation]    Check for a successful Capsule Update using the production keys.
    ...    Please note that the test number is high on purpose. This test will flash FW! In future
    ...    if additional test cases will be created - when running the whole suite - It will be good
    ...    to keep the number of actual FW updates to minimum to prevent chip degradation.
    Skip If
    ...    not ${CAPSULE_UPDATE_V2_SUPPORT}
    ...    CAPSULE_UPDATE_V2_SUPPORT==False, Production Capsule Update keys only supported in V2 capsules
    Skip If
    ...    ${V2_CAP_HAS_TEST_KEYS}
    ...    CAPSULE_FW_FILE contains testing keys, provide production capsule to test Capsule Update with Production keys
    ${manual_gui}=    Evaluate    ${CAPSULE_UPDATE_V2_SUPPORT} and ${SHOULD_RUN_SEMIAUTO_TESTS}
    IF    ${manual_gui}
        Manual UI Verification Prompt
        ...    ${CUP_250_MESSAGE}
        ...    ${CUP_251_MESSAGE}
        ...    ${CUP_252_MESSAGE}
        ...    ${CUP_253_MESSAGE}
        ...    prepare=${TRUE}
    END
    ${status}    ${version_changed}=    Perform Capsule Update And Return Status
    ...    valid_capsule.cap
    ...    v2_result_gui_manual=${manual_gui}
    Should Be True    ${version_changed}
    Should Contain    ${status}    CapsuleMax
    Should Not Contain    ${status}    CapsuleLast

CUP250.001 Capsule Update Progress Bar - Default Logo
    [Documentation]    Verify that the Capsule Update screen looks as expected
    ...    and the progress bar is scaled properly using a default logo.
    [Tags]    semiauto
    Manual UI Verification Prompt    ${CUP_250_MESSAGE}

CUP251.101 Capsule Update V2 UX Custom Logo (EDK2 UEFI)
    [Documentation]    Verify that the Capsule Update V2 screen shows the
    ...    expected logo for a given platform.
    [Tags]    semiauto
    Skip If    not ${CAPSULE_UPDATE_V2_SUPPORT}    CUP251.101 not supported
    Manual UI Verification Prompt    ${CUP_251_MESSAGE}

CUP252.101 Capsule Update V2 UX Smooth Progress Bar (EDK2 UEFI)
    [Documentation]    Verify that the Capsule Update V2 screen progress bar
    ...    advances smoothly and doesn't freeze.
    [Tags]    semiauto
    Skip If    not ${CAPSULE_UPDATE_V2_SUPPORT}    CUP252.101 not supported
    Manual UI Verification Prompt    ${CUP_252_MESSAGE}

CUP253.101 Capsule Update V2 UX Success Screen (EDK2 UEFI)
    [Documentation]    Verify that the Capsule Update V2 success result screen appears
    ...    and has expected contents.
    [Tags]    semiauto
    Skip If    not ${CAPSULE_UPDATE_V2_SUPPORT}    CUP253.101 not supported
    Manual UI Verification Prompt    ${CUP_253_MESSAGE}

CUP160.001 Verifying BIOS Settings Persistence After Update - PART 2
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    ${state}=    Get UEFI Option    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
    Should Not Be Equal    ${state}    ${SMMSTORE_VARIABLE_PERSISTENCE_INITIAL_STATE}

CUP170.201 Verifying UUID (Ubuntu)
    [Documentation]    Check if UUID didn't change after Capsule Update.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CUP170.201 not supported
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
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CUP170.301 not supported

    Power On
    Boot And Login To OS    ${ENV_ID_WINDOWS}
    Get Windows System Values    WIN_UPDATED_SERIAL    WIN_UPDATED_UUID

    Log To Console    \n[Before Update] ${WIN_ORIGINAL_UUID}
    Log To Console    \n[After Update] ${WIN_UPDATED_UUID}

    # dmidecode reports `Not Settable` for all zeroes
    IF    '${WIN_ORIGINAL_UUID}' == 'Not Settable'
        Should Be Equal    ${WIN_UPDATED_UUID}    00000000-0000-0000-0000-000000000000
    ELSE
        Should Be Equal    ${WIN_ORIGINAL_UUID}    ${WIN_UPDATED_UUID}
    END

    IF    ${ROMHOLE_SUPPORT} == ${TRUE}
        Should Be Equal    ${WIN_UPDATED_UUID}    00112233-4455-6677-8899-aabbccddeeff
    END

CUP180.201 Verifying Serial Number (Ubuntu)
    [Documentation]    Check if serial number didn't change after Capsule Update.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CUP180.201 not supported
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
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CUP180.301 not supported
    ${tmp}=    Get Variable Value    $WIN_UPDATED_SERIAL
    IF    $tmp is None
        Power On
        Boot And Login To OS    ${ENV_ID_WINDOWS}
        Get Windows System Values    WIN_UPDATED_SERIAL    WIN_UPDATED_UUID
    END

    Log To Console    \n[Before Update] ${WIN_ORIGINAL_SERIAL}
    Log To Console    \n[After Update] ${WIN_UPDATED_SERIAL}

    Should Be Equal    ${WIN_ORIGINAL_SERIAL}    ${WIN_UPDATED_SERIAL}

CUP190.201 Verifying If Custom Logo Persists Across updates (Ubuntu)
    [Documentation]    Check if Logo didn't change after Capsule Update.
    Skip If    not ${CUSTOM_LOGO_SUPPORT}    CUP190.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CUP190.201 not supported
    Power On
    Boot And Login To OS    ${ENV_ID_UBUNTU}
    Switch To Root User
    Get Ubuntu System Values    UPDATED_SERIAL    UPDATED_UUID    UPDATED_LOGO_SHA256
    Should Be Equal    ${ORIGINAL_LOGO_SHA256}    ${UPDATED_LOGO_SHA256}

CUP240.001 Capsule Update UX Tests - Observation
    [Documentation]    Collect the observations about how the capsule update UX looks.
    ...    Use them later to confirm it looks as expected.
    [Tags]    semiauto
    # Ensure we're running FW with the default logo
    IF    ${CUSTOM_LOGO_SUPPORT}
        Flash Firmware    ${CAPSULE_UPDATE_RC0_FW_FILE_NO_LOGO}
    END
    Deploy Uefi Shell
    # Bump the timeout for memory training
    Set DUT Response Timeout    5m
    IF    ${DASHARO_INTEL_ME_MENU_SUPPORT}
        Set UEFI Option    MeMode    Disabled (HAP)
    END
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Login To Linux With Root Privileges

    VAR    @{message}=
    ...    A capsule update will be performed shortly after choosing PASS.
    ...    Observe the screen and prepare to verify the following:\n
    Append To List    ${message}    @{CUP_250_MESSAGE}
    IF    ${CAPSULE_UPDATES_V2_SUPPORT}
        Append To List    ${message}    @{CUP_251_MESSAGE}
        Append To List    ${message}    @{CUP_252_MESSAGE}
    END
    VAR    ${message}=    @{message}    separator=\n
    Run Keyword And Ignore Error    Execute Manual Step    ${message}

    Perform Capsule Update    valid_capsule.cap

CUP250.001 Capsule Update Progress Bar - Default Logo
    [Documentation]    Verify that the Capsule Update screen looks as expected
    ...    and the progress bar is scaled properly using a default logo.
    [Tags]    semiauto
    VAR    ${msg}=    @{CUP_250_MESSAGE}    separator=\n
    Execute Manual Step    ${msg}

CUP251.001 Capsule Update V2 UX Custom Logo
    [Documentation]    Verify that the Capsule Update V2 screen shows the
    ...    expected logo for a given platform.
    [Tags]    semiauto
    VAR    ${msg}=    @{CUP_251_MESSAGE}    separator=\n
    Execute Manual Step    ${msg}

CUP252.001 Capsule Update V2 UX Smooth Progress Bar
    [Documentation]    Verify that the Capsule Update V2 screen progress bar
    ...    advances smoothly and doesn't freeze.
    [Tags]    semiauto
    VAR    ${msg}=    @{CUP_252_MESSAGE}    separator=\n
    Execute Manual Step    ${msg}

CUP260.001 Capsule update in Firmware Update Mode works
    [Documentation]    Check if capsule update works when in Firmware Update
    ...    Mode
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}
    Skip If    "${OPTIONS_LIB}" == "options-lib_dcu"
    Skip If
    ...    not ${CAPSULE_UPDATE_IN_FUM_SUPPORT}
    ...    CUP260.101 requires iPXE+DTS FUM boot, not supported on this platform
    Power On
    # Enable FUM
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${security_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Enter Submenu From Snapshot    ${security_menu}    Enter Firmware Update Mode
    Read From Terminal Until    Press ENTER to continue and reboot
    Press Enter
    Handle Capsule Update Screens    expect_fum=${TRUE}
    # Stop iPXE from booting default option as it contains workaround for this
    # issue
    Read From Terminal Until    efi/FirmwareUpdateMode:hex = 01
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        VAR    @{combo}=    ControlLeft    KeyC
        Key Combination PiKVM    ${combo}
    ELSE
        Press Key N Times    1    ${CTRL_C}
    END
    Enter IPXE Shell Submenu
    Execute Command In Terminal    dhcp
    # Write Bare allows to set interval between each character which might be
    # needed on slower platforms/serial connection
    Write Bare Into Terminal    chain http://boot.dasharo.com/dts/dts-no-fum-fix.ipxe\n    interval=0.2
    # Boot into DTS shell
    Set DUT Response Timeout    5m
    Read From Terminal Until Regexp    \.cpio\.gz\.\.\.|\.efi
    Read From Terminal Until    ok
    Wait For DTS To Boot    fum=${TRUE}
    Write Into Terminal    ${DTS_FUM_MENU_OPT}
    Enter Shell In DTS
    # Upload capsule
    Execute Command In Terminal    systemctl start sshd
    VAR    ${DEVICE_OS_USERNAME}=    root    scope=Test
    VAR    ${DEVICE_OS_PASSWORD}=    ${EMPTY}    scope=Test
    Send File To DUT    ${CAPSULE_FW_FILE}    /valid_capsule.cap
    Execute Command In Terminal Should Succeed
    ...    cp /valid_capsule.cap /dev/efi_capsule_loader
    ...    Failed to queue capsule update via /dev/efi_capsule_loader
    # Verify
    ${dmesg}=    Execute Command In Terminal    dmesg | tail
    Should Contain    ${dmesg}    efi: Successfully uploaded capsule
    Write Into Terminal    reboot
    Restore Initial DUT Connection Method
    Set DUT Response Timeout    5m
    Enter Setup Menu Tianocore

CUP270.101 Automatic ME Disable Works (EDK2 UEFI)
    [Documentation]    By using on-disk capsules it is possible to automatically
    ...    disable ME prior to an update making the process much more
    ...    straightforward. The tests verifies whether a capsule update can be
    ...    performed with ME Enabled when the capsule is loaded.
    Skip If    not ${DASHARO_INTEL_ME_MENU_SUPPORT}    CUP270.101 not supported
    Skip If    not ${CAPSULE_UPDATE_V2_SUPPORT}    CUP270.101 not supported
    Flash Firmware    ${CAPSULE_UPDATE_RC0_FW_FILE_ME_ENABLED}
    ${status}    ${version_changed}=    Perform Capsule Update And Return Status    valid_capsule.cap    ondisk=${TRUE}
    Should Be True    ${version_changed}
    Should Contain    ${status}    CapsuleMax
    Should Not Contain    ${status}    CapsuleLast


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
    [Arguments]    ${capsule_file}    ${ondisk}=${FALSE}    ${v2_result_gui_manual}=${FALSE}
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Login To Linux With Root Privileges
    ${original_bios_version}=    Get BIOS Version Linux    Before update
    Deploy Uefi Shell    os_logged_in=${TRUE}
    Perform Capsule Update
    ...    ${capsule_file}
    ...    ondisk=${ondisk}
    ...    v2_result_gui_manual=${v2_result_gui_manual}

    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Login To Linux With Root Privileges
    Deploy Uefi Shell    os_logged_in=${TRUE}

    ${updated_bios_version}=    Get BIOS Version Linux    After update
    ${version_changed}=    Run Keyword And Return Status
    ...    Should Not Be Equal
    ...    ${original_bios_version}
    ...    ${updated_bios_version}
    ${logs}=    Get Capsule Update Logs
    RETURN    ${logs}    ${version_changed}

Check The Update Screen For BtG Error Message
    [Arguments]    ${pre}=${FALSE}
    VAR    ${message}=
    ...    Verify that the orange BtG
    ...    error message popup screen appears on the screen. Ensure that the
    ...    update abort reason and the fused OEM RK hash are printed, and that
    ...    the popup fits on the screen and is readable. See the screenshot at
    ...    https://docs.dasharo.com/guides/capsule-update#troubleshooting for
    ...    reference.
    ...    separator=\n
    IF    ${pre}
        VAR    ${message}=
        ...    A capsule update will be performed after choosing PASS.
        ...    Observe the screen and verify the following:
        ...    ${message}
        ...    separator=\n
    END
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
    Send File To DUT    ${WRONG_KEYS_CAP}    ${CAPSULE_UPDATE_SHELL_DIR}/wrong_cert.cap
    Send File To DUT    ${INVALID_GUID_CAP}    ${CAPSULE_UPDATE_SHELL_DIR}/invalid_guid.cap
    ${tmp}=    Get Variable Value    $BTG_CAPSULE_FW_FILE
    IF    $tmp is not None
        Send File To DUT
        ...    ./dl-cache/edk2/${BTG_CAPSULE_FW_FILE}
        ...    ${CAPSULE_UPDATE_SHELL_DIR}/invalid_btg_signature.cap
    END

Perform Capsule Update
    [Arguments]    ${capsule_file}    ${ondisk}=${FALSE}    ${v2_result_gui_manual}=${FALSE}
    # Submit capsule to firmware without an automatic reset and verify that it
    # was accepted without error
    VAR    ${capsule_fs_path}=    ${capsule_file}
    Set Startup Nsh Variable    capsule_file    ${capsule_fs_path}
    Set Startup Nsh Variable    step    0
    IF    ${ondisk}
        Set Startup Nsh Variable    ondisk    1
    ELSE
        Set Startup Nsh Variable    ondisk    0
    END
    Set Nextboot Bootentry    ${CAPSULE_UPDATE_SHELL_BOOTENTRY_NAME}
    Execute Reboot Command    assume_correct_boot=${True}
    # uefi shell runs and reboots the platform
    IF    '${OPTIONS_LIB}' == 'options-lib_uefi-setup-menu'
        # Depending on: Serial Console support, V2 capsules support, whether FUM confirmation is used
        # different screens might appear on serial after the reboot.
        # Instead of configuring a strict sequence, we will handle any screen that
        # appears until the update is finished.

        # The POST screen has to appear 2 times:
        # 1. Directly after the reboot, it should be ignored as UEFI Shell is selected as BootNext and will boot after timeout
        #    The CapsuleApp will then start immediately without a POST screen after UEFI Shell reboots the system.
        # 2. After the update finally finishes the DUT is rebooted and we are ready to continue.
        VAR    ${post_screen_counter}=    0
        FOR    ${_}    IN RANGE    5
            ${screen}=    Handle Capsule Update Screens    v2_result_gui_manual=${v2_result_gui_manual}
            IF    '${TIANOCORE_STRING}' in $screen
                ${post_screen_counter}=    Evaluate    ${post_screen_counter} + 1
            END
            IF    '${V2_RESULT_SCREEN_BOTTOM}' in $screen
                # For use in tests that verify the UI
                Set To Dictionary    ${V2_RESULT_SCREENS}    ${capsule_file}    ${screen}
            END
            IF    ${post_screen_counter} == 2    BREAK
        END
    END

Handle Capsule Update Screens
    [Arguments]    ${expect_fum}    ${v2_result_gui_manual}=${FALSE}
    # If there is no FUM screen and the update finishes, we land in the POST screen
    # If the update did not start yet as the FUM mode must be authorized
    VAR    ${potential_screens_regex}=
    ...    (${TIANOCORE_STRING})
    ...    (${FUM_DIALOG_TOP})
    ...    separator=|

    IF    ${CAPSULE_UPDATE_V2_SUPPORT}
        # Then after the update finishes, a result screen will be presented
        VAR    ${potential_screens_regex}=    ${potential_screens_regex}|(${V2_RESULT_SCREEN_BOTTOM})
    END
    ${out}=    Read From Terminal Until Regexp    ${potential_screens_regex}

    IF    '${FUM_DIALOG_TOP}' in $out
        IF    not ${expect_fum}
            Log
            ...    Unexpected FUM dialog - capsule may be corrupted, skipped by coreboot, or firmware is an older version that always enters FUM
            ...    WARN
        END
        ${fum_screen}=    Read From Terminal Until    ${FUM_DIALOG_BOTTOM}
        ${digit}=    Get Key To Press    ${fum_screen}
        Write Bare Into Terminal    ${digit}
    ELSE IF    '${TIANOCORE_STRING}' in $out
        Log    Tianocore string
    ELSE IF    '${V2_RESULT_SCREEN_BOTTOM}' in $out
        IF    ${v2_result_gui_manual}
            Execute Manual Step    message=Note the result screen
        END
        Press Enter
    END
    RETURN    ${out}

Get File Name Without Extension
    [Arguments]    ${file_path}
    ${path_components}=    Split String    ${file_path}    /
    ${base_name}=    Get From List    ${path_components}    -1
    ${name_parts}=    Split String From Right    ${base_name}    .    1
    ${result}=    Get From List    ${name_parts}    0
    RETURN    ${result}

Ensure Capsule Files Are Present
    [Documentation]    Validates that all required capsule files exist and sets up suite variables for V2 capsule testing.

    Variable Should Exist
    ...    ${CAPSULE_FW_FILE}
    ...    capsule_fw_file parameter missing. Please add: -v capsule_fw_file:<capsule_to_be_tested>.cap to the robot command line and try again.
    OperatingSystem.File Should Exist
    ...    ${CAPSULE_FW_FILE}
    ...    capsule_fw_file parameter incorrect. Please add: -v capsule_fw_file:<capsule_to_be_tested>.cap to the robot command line and try again.

    ${rc0}=    Get Environment Variable    name=CAPSULE_UPDATE_RC0_FW_FILE
    VAR    ${CAPSULE_UPDATE_RC0_FW_FILE}=    ${rc0}    scope=SUITE
    OperatingSystem.File Should Exist
    ...    ${CAPSULE_UPDATE_RC0_FW_FILE}
    ...    CAPSULE_UPDATE_RC0_FW_FILE env variable does not point to a file! CAPSULE_UPDATE_RC0_FW_FILE="${CAPSULE_UPDATE_RC0_FW_FILE}"

    IF    ${CAPSULE_UPDATE_V2_SUPPORT}
        Ensure V2 Capsule Key Variables Are Set
    END

    Ensure Derived Capsule Files Are Present    ${CAPSULE_FW_FILE}    ${CAPSULE_UPDATE_RC0_FW_FILE}

Ensure V2 Capsule Key Variables Are Set
    [Documentation]    Detects whether the provided capsule uses testing or production keys and sets
    ...    suite variables accordingly. Optionally reads TEST_KEYS_* env variables when the main
    ...    capsule uses production keys, so the GUID test can still run.
    ...
    ...    For V2 capsules, several cases are handled to keep tests backwards-compatible:
    ...    The `CAPSULE_UPDATE_RC0_FW_FILE` is always assumed to be a test variant.
    ...    The `FW_FILE` and `CAPSULE_FW_FILE` can be test or production variants.
    ...    - Setup: CAPSULE_FW_FILE is used regardless of key type. It will be repacked with test keys for CUP002.
    ...    - Update test: Run CUP150 or CUP151 depending on whether `CAPSULE_FW_FILE` uses test or prod keys.
    ...    The base `CAPSULE_UPDATE_RC0_FW_FILE` is always a testing variant to simplify usage.
    ${rc}=    Run And Return Rc    ./scripts/capsules/verify_testing_keys.sh ${CAPSULE_FW_FILE}
    IF    ${rc} == 0
        Log
        ...    Detected testing keys in the $CAPSULE_FW_FILE (${CAPSULE_FW_FILE}).
        ...    level=WARN
        VAR    ${V2_CAP_HAS_TEST_KEYS}=    ${TRUE}    scope=SUITE
    END
    ${test_rc0}=    Get Environment Variable    name=CAPSULE_UPDATE_RC0_HAS_TEST_KEYS    default=${EMPTY}
    IF    $test_rc0 == '${EMPTY}'
        VAR    ${msg}=    Assuming CAPSULE_UPDATE_RC0_FW_FILE uses test keys.
        ...    The tests won't work properly if that's not the case.
        ...    Set the CAPSULE_UPDATE_RC0_HAS_TEST_KEYS env variable to silence this warning.
        ...    separator=\n
        Log    ${msg}
        ...    WARN
    END
    # TODO verify what keys does the firmware trust when that's possible.
    VAR    ${CAPSULE_UPDATE_RC0_HAS_TEST_KEYS}=    ${TRUE}    scope=SUITE

Ensure Derived Capsule Files Are Present
    [Documentation]    Ensures wrong_cert and invalid_guid capsule variants exist for the given capsule,
    ...    generating them via capsule_update_tests.sh if not already present.
    [Arguments]    ${capsule_for_decoding}    ${base_rom}
    ${file_name}=    Get File Name Without Extension    ${capsule_for_decoding}
    ${f1}=    Run Keyword And Return Status
    ...    OperatingSystem.File Should Exist    ./dl-cache/edk2/${file_name}_wrong_cert.cap
    ${f2}=    Run Keyword And Return Status
    ...    OperatingSystem.File Should Exist    ./dl-cache/edk2/${file_name}_invalid_guid.cap

    VAR    ${WRONG_KEYS_CAP}=    ./dl-cache/edk2/${file_name}_wrong_cert.cap    scope=SUITE
    VAR    ${INVALID_GUID_CAP}=    ./dl-cache/edk2/${file_name}_invalid_guid.cap    scope=SUITE
    IF    not ${f1} or not ${f2}
        Run    ./scripts/capsules/capsule_update_tests.sh ${capsule_for_decoding}
    END

    IF    ${DASHARO_INTEL_ME_MENU_SUPPORT}
        VAR    ${CAPSULE_UPDATE_RC0_FW_FILE_ME_HAP}=    ${base_rom}_me_hap.rom    scope=SUITE
        ${rc}=    Run And Return Rc    cp -f ${base_rom} ${CAPSULE_UPDATE_RC0_FW_FILE_ME_HAP}
        Should Be Equal As Integers    ${rc}    0
        ...    Failed to copy base ROM: `cp ${base_rom} ${CAPSULE_UPDATE_RC0_FW_FILE_ME_HAP}`
        DCU Variable Set UEFI Option In File    ${CAPSULE_UPDATE_RC0_FW_FILE_ME_HAP}    MeMode    Disabled (HAP)

        VAR    ${CAPSULE_UPDATE_RC0_FW_FILE_ME_ENABLED}=    ${base_rom}_me_enabled.rom    scope=SUITE
        ${rc}=    Run And Return Rc    cp -f ${base_rom} ${CAPSULE_UPDATE_RC0_FW_FILE_ME_ENABLED}
        Should Be Equal As Integers    ${rc}    0
        ...    Failed to copy base ROM: `cp ${base_rom} ${CAPSULE_UPDATE_RC0_FW_FILE_ME_ENABLED}`
        DCU Variable Set UEFI Option In File    ${CAPSULE_UPDATE_RC0_FW_FILE_ME_ENABLED}    MeMode    Enabled
        VAR    ${BASE_FW_FILE}=    ${CAPSULE_UPDATE_RC0_FW_FILE_ME_HAP}    scope=SUITE
    ELSE
        VAR    ${BASE_FW_FILE}=    ${CAPSULE_UPDATE_RC0_FW_FILE}    scope=SUITE
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
    VAR    ${msg}=    To run tests you need to set a couple environment variables:
    ...    1. FW_FILE contains path to the `.rom` file of tested release
    ...    2. CAPSULE_FW_FILE contains path to the `.cap` file with the same
    ...    ${T}firmware version as FW_FILE
    ...    3. CAPSULE_UPDATE_RC0_FW_FILE contains path to a `.rom` file with
    ...    ${T}either a lower RC version, or to the RC0 rom in case of first RC that
    ...    ${T}supports capsule updates
    ...    ${EMPTY}
    ...    To test V2 Capsules, there are two paths depending whether the production
    ...    firmware is available:
    ...    - opt. A) - only testing firmware
    ...    ${T} Use FW_FILE, CAPSULE_FW_FILE and CAPSULE_UPDATE_RC0_FW_FILE as before.
    ...    ${T} Set all to testing keys variants.
    ...    ${T} Tests that require production firmware will be skipped.
    ...    - opt. B) - providing both variants
    ...    ${T} 1. Set FW_FILE and CAPSULE_FW_FILE to the production variants.
    ...    ${T} 2. Set CAPSULE_UPDATE_RC0_FW_FILE to the testing variant.
    ...    This way all the tests can be run at the same time.
    ...    ${EMPTY}
    ...    Be careful if the tested device needs some additional setup menu changes
    ...    to the default setup menu options to work, e.g. enabling
    ...    Serial Redirection or Power After AC Loss. These UEFI options need
    ...    to be set in all the firmware files used for these tests prior to starting.
    ...    ${EMPTY}
    ...    separator=\r\n
    Log To Console    ******************************************************************************
    Log To Console    ${msg}
    Log To Console    ******************************************************************************

Prepare For Logo Persistence Test
    Log To Console    PREPARE: Logo Persistence Test
    # Cannot flash a custom logo binary to QEMU
    IF    '${MANUFACTURER}'=='QEMU'    RETURN

    ${name}=    Evaluate    '${BASE_FW_FILE}'.split("/")[-1]

    VAR    ${CUSTOM_LOGO_RC0_FW_FILE}=    dcu/custom_logo_${name}    scope=SUITE
    Run    cp ${BASE_FW_FILE} ${CUSTOM_LOGO_RC0_FW_FILE}
    DCU Logo Set In File    ${CUSTOM_LOGO_RC0_FW_FILE}    ${TEST_DATA_DIR}/dcu/logo.bmp

    VAR    ${BASE_FW_FILE_NO_LOGO}=    ${BASE_FW_FILE}    scope=SUITE
    VAR    ${BASE_FW_FILE}=    ${CUSTOM_LOGO_RC0_FW_FILE}    scope=SUITE

Get System Values
    IF    ${TESTS_IN_UBUNTU_SUPPORT}
        Power On
        Boot And Login To OS    ${ENV_ID_UBUNTU}
        Switch To Root User
        Get Ubuntu System Values    ORIGINAL_SERIAL    ORIGINAL_UUID    ORIGINAL_LOGO_SHA256
    END
    IF    ${TESTS_IN_WINDOWS_SUPPORT}
        Power On
        Boot And Login To OS    ${ENV_ID_WINDOWS}
        Get Windows System Values    WIN_ORIGINAL_SERIAL    WIN_ORIGINAL_UUID
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
    Power On
    Boot And Login To OS    ${DEFAULT_BOOT_OS_ID}
    Switch To Root User
    ${tmp}=    Get Variable Value    $BTG_CAPSULE_FW_FILE
    IF    $tmp is not None
        ${btg_caps_filename}=    Get File Name Without Extension    ${BTG_CAPSULE_FW_FILE}
        Send File To Dut    ${BTG_CAPSULE_FW_FILE}    /root/${btg_caps_filename}.cap
        Execute Command In Terminal    export BTG_CAPSULE_FW_FILE=/root/${btg_caps_filename}.cap
    END

    Prepare Capsule Shell Workspace
    Copy Capsule Files To Shell Workspace

Prepare For ROMHOLE Persistence Test
    [Documentation]    This is a part which works only on MSI platforms.
    Log To Console    PREPARE: ROMHOLE Persistence Test

    IF    ${ROMHOLE_SUPPORT} == ${TRUE}
        Run    dd if=dasharo-stability/capsule-update-files/romhole of=dcu/coreboot.rom seek=24903680 bs=1 conv=notrunc
    ELSE
        Log To Console    ${T}ROMHOLE not supported - skipping
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

    # There are some sync issues with this file.
    # Might be that the partition is not fully mounted immediately after logging in,
    # or a dirty bit might have been set in FAT32.
    Execute Command In Terminal    until mountpoint -q /boot/efi; do sleep 1; done

    # UEFI Shell uses UTF-16LE and SSHLibrary will panic if the file is read
    # to the terminal in this form.
    # The UTF BOM bytes (EF BB FB) can be misinterpreted by the RF telnet library.
    # They need to be stripped from the output
    ${logs}=    Execute Command In Terminal    iconv -f UTF-16LE -t UTF-8 ${logs_path} | sed '1s/^\\xef\\xbb\\xbf//'
    RETURN    ${logs}

Set Startup Nsh Variable
    [Documentation]    The variables that control the startup.nsh script
    ...    are written to files located in the EFI shell workspace.
    [Arguments]    ${name}    ${value}
    ${variable_name}=    Convert To Upper Case    ${name}
    ${file_name}=    Convert To Lower Case    ${name}
    VAR    ${target}=    ${CAPSULE_UPDATE_SHELL_DIR}/variable_${file_name}.nsh
    Execute Command In Terminal    echo "set ${variable_name} ${value}" > '${target}' && sync

Manual UI Verification Prompt
    [Arguments]    @{messages}    ${prepare}=${False}
    VAR    @{msg}=    @{EMPTY}
    IF    ${prepare}    Append To List    ${msg}    @{MANUAL_UX_PREP_MESSAGE}

    FOR    ${message}    IN    @{messages}
        Append To List    ${msg}    @{message}
    END
    VAR    ${msg}=    @{msg}    separator=\n
    IF    ${prepare}
        Run Keyword And Ignore Error    Execute Manual Step    ${msg}
    ELSE
        Execute Manual Step    ${msg}
    END
