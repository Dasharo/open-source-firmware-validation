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
Resource            ../keys.robot
Resource            ../lib/bios/menus.robot
Resource            ../lib/options/options-lib_dcu.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
# ...               Display Preparation Instructions    AND
...                     Prepare Test Suite    AND
...                     Skip If    not ${CAPSULE_UPDATE_SUPPORT}    Capsule Update not supported    AND
...                     Ensure Capsule Files Are Present    AND
...                     Prepare For Logo Persistence Test    AND
...                     Prepare For ROMHOLE Persistence Test    AND    # MSI Only
...                     Flash Firmware If Not QEMU    AND
...                     Upload Required Files    AND
...                     Get System Values    AND
...                     Set UEFI Option    MeMode    Disabled (HAP)
Suite Teardown      Run Keywords
...                     Log Out And Close Connection


*** Variables ***
${FUM_DIALOG_TOP}=                          Update Mode. All firmware write protections are disabled in this mode.
${FUM_DIALOG_BOTTOM}=                       The platform will automatically reboot and disable Firmware Update Mode
${CAPSULE_UPDATE_DISK_BOOTENTRY_NAME}=      Wilk
${CAPSULE_UPDATE_DISK_MODEL}=               USB DISK 3.0
${WRONG_KEYS_CAPSULE_STATUS}=               Capsule Status: Security Violation
${WRONG_GUID_CAPSULE_STATUS}=               Capsule Status: Not Ready


*** Test Cases ***
CUP001.001 Capsule Update With Wrong Keys
    [Documentation]    Check that DUT rejects flashing a capsule signed with invalid certificate.
    ${status}    ${version_changed}=    Perform Capsule Update And Return Status    wrong_keys.cap
    Should Contain    ${status}    ${WRONG_KEYS_CAPSULE_STATUS}
    Should Not Be True    ${version_changed}

CUP002.001 Capsule Update With Wrong GUID
    [Documentation]    Check that DUT rejects flashing a capsule with invalid GUID.
    ${status}    ${version_changed}=    Perform Capsule Update And Return Status    invalid_guid.cap
    Should Contain    ${status}    ${WRONG_GUID_CAPSULE_STATUS}
    Should Not Be True    ${version_changed}

CUP130.001 Verifying BIOS Settings Persistence After Update - PART 1
    [Documentation]    Check if BIOS settings didn't change after Capsule Update.
    IF    '${OPTIONS_LIB}' == 'options-lib_uefi-setup-menu'
        Power On
        ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
        ${boot_menu}=    Enter Dasharo Submenu    ${setup_menu}    Boot Maintenance Manager

        Set Option State    ${boot_menu}    Auto Boot Time-out    32123
        Save Changes And Reset
    ELSE IF    '${OPTIONS_LIB}' == 'options-lib_dcu'
        # no serial connection
        Power On
        Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
        ${state}=    Get UEFI Option    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
        Set Suite Variable    ${SMMSTORE_VARIABLE_PERSISTENCE_INITIAL_STATE}    ${state}
        ${new_state}=    Evaluate    not ${state}
        Set UEFI Option    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}    ${new_state}
    END

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
    IF    '${OPTIONS_LIB}' == 'options-lib_uefi-setup-menu'
        Power On
        ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
        ${boot_menu}=    Enter Dasharo Submenu    ${setup_menu}    Boot Maintenance Manager

        ${updated_state}=    Get Option State    ${boot_menu}    Auto Boot Time-out
        Should Be Equal    ${updated_state}    32123
    ELSE IF    '${OPTIONS_LIB}' == 'options-lib_dcu'
        # no serial connection
        Power On
        Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
        ${state}=    Get UEFI Option    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
        Should Not Be Equal    ${state}    ${SMMSTORE_VARIABLE_PERSISTENCE_INITIAL_STATE}
    END

CUP170.201 Verifying UUID (Ubuntu)
    [Documentation]    Check if UUID didn't change after Capsule Update.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CUP170.001 not supported
    ${tmp}=    Get Variable Value    $UPDATED_UUID
    IF    '${tmp}' == 'None'
        Go To Linux Prompt    ${ENV_ID_UBUNTU}
        Get Ubuntu System Values    $UPDATED_SERIAL    $UPDATED_UUID    $UPDATED_LOGO_SHA256
    END

    Log To Console    \n[Before Update] ${ORIGINAL_UUID}
    Log To Console    \n[After Update] ${UPDATED_UUID}

    Should Be Equal    ${ORIGINAL_UUID}    ${UPDATED_UUID}
    IF    ${ROMHOLE_SUPPORT} == ${TRUE}
        Should Be Equal    ${UPDATED_UUID}    00112233-4455-6677-8899-aabbccddeeff
    END

CUP170.301 Verifying UUID (Windows)
    [Documentation]    Check if UUID didn't change after Capsule Update.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CUP170.002 not supported
    ${tmp}=    Get Variable Value    $WIN_UPDATED_UUID
    IF    '${tmp}' == 'None'
        Go To Windows Prompt
        Get Windows System Values    $WIN_UPDATED_SERIAL    $WIN_UPDATED_UUID
    END

    Log To Console    \n[Before Update] ${ORIGINAL_UUID}
    Log To Console    \n[After Update] ${WIN_UPDATED_UUID}

    Should Be Equal    ${ORIGINAL_UUID}    ${WIN_UPDATED_UUID}
    IF    ${ROMHOLE_SUPPORT} == ${TRUE}
        Should Be Equal    ${WIN_UPDATED_UUID}    00112233-4455-6677-8899-aabbccddeeff
    END

CUP180.001 Verifying Serial Number (Ubuntu)
    [Documentation]    Check if serial number didn't change after Capsule Update.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CUP180.001 not supported
    ${tmp}=    Get Variable Value    $UPDATED_SERIAL
    IF    '${tmp}' == 'None'
        Go To Linux Prompt    ${ENV_ID_UBUNTU}
        Get Ubuntu System Values    $UPDATED_SERIAL    $UPDATED_UUID    $UPDATED_LOGO_SHA256
    END

    Log To Console    \n[Before Update] ${ORIGINAL_SERIAL}
    Log To Console    \n[After Update] ${UPDATED_SERIAL}

    Should Be Equal    ${ORIGINAL_SERIAL}    ${UPDATED_SERIAL}

CUP180.002 Verifying Serial Number (Windows)
    [Documentation]    Check if serial number didn't change after Capsule Update.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CUP180.002 not supported
    ${tmp}=    Get Variable Value    $WIN_UPDATED_SERIAL
    IF    '${tmp}' == 'None'
        Go To Windows Prompt
        Get Windows System Values    $WIN_UPDATED_SERIAL    $WIN_UPDATED_UUID
    END

    Log To Console    \n[Before Update] ${ORIGINAL_SERIAL}
    Log To Console    \n[After Update] ${WIN_UPDATED_SERIAL}

    Should Be Equal    ${ORIGINAL_SERIAL}    ${WIN_UPDATED_SERIAL}

CUP190.001 Verifying If Custom Logo Persists Across updates (Ubuntu)
    [Documentation]    Check if Logo didn't change after Capsule Update.
    Skip If    not ${CUSTOM_LOGO_SUPPORT}    CUP190.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CUP190.001 not supported
    ${tmp}=    Get Variable Value    $UPDATED_LOGO_SHA256
    IF    '${tmp}' == 'None'
        Go To Linux Prompt    ${ENV_ID_UBUNTU}
        Get System Values    $UPDATED_SERIAL    $UPDATED_UUID    $UPDATED_LOGO_SHA256
    END
    Should Be Equal    ${ORIGINAL_LOGO_SHA256}    ${UPDATED_LOGO_SHA256}

CUP250.001 Capsule Update Progress Bar - Default Logo
    [Documentation]    Verify that the Capsule Update screen looks as expected
    ...    and the progress bar is scaled properly using a default logo.
    # Ensure we're running FW with the default logo
    Flash Firmware If Not QEMU    default
    # Bump the timeout for memory training
    Set DUT Response Timeout    5m
    Set UEFI Option    MeMode    Disabled (HAP)
    Power On
    IF    '${OPTIONS_LIB}' == 'options-lib_uefi-setup-menu'
        Enter UEFI Shell
        Perform Capsule Update    valid_capsule.cap
    ELSE IF    '${OPTIONS_LIB}' == 'options-lib_dcu'
        Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
        Login To Linux With Root Privileges
        Perform Capsule Update    valid_capsule.cap    use_uefi_shell=${False}
    END
    Check The Update Screen For The Correct UX


*** Keywords ***
Perform Capsule Update And Return Status
    [Arguments]    ${capsule_file}
    IF    '${OPTIONS_LIB}' == 'options-lib_uefi-setup-menu'
        Power On
        Enter UEFI Shell
        ${original_bios_version}=    Get BIOS Version    Before update

        Perform Capsule Update    ${capsule_file}

        Enter UEFI Shell

        ${updated_bios_version}=    Get BIOS Version    After update
        Should Be Equal    ${original_bios_version}    ${updated_bios_version}

        ${logs}=    Get Capsule Update Logs
        RETURN    ${logs}
    ELSE IF    '${OPTIONS_LIB}' == 'options-lib_dcu'
        # Platform does not have a serial connection
        Power On
        Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
        Login To Linux With Root Privileges
        ${original_bios_version}=    Get BIOS Version Linux    Before update

        Perform Capsule Update    ${capsule_file}    use_uefi_shell=${False}

        Power On
        Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
        Login To Linux With Root Privileges
        ${updated_bios_version}=    Get BIOS Version Linux    After update
        ${version_changed}=    Run Keyword And Return Status
        ...    Should Be Equal
        ...    ${original_bios_version}
        ...    ${updated_bios_version}
        ${logs}=    Get Capsule Update Logs    use_uefi_shell=${False}
        RETURN    ${logs}    ${version_changed}
    END

Flash Firmware If Not QEMU
    [Tags]    robot:private
    [Arguments]    ${logo_type}=custom
    Log To Console    PREPARE: Flashing Firmware
    IF    '${MANUFACTURER}' != 'QEMU'
        IF    '${logo_type}' == 'default'
            Flash Firmware    ${FW_FILE}
        ELSE IF    '${logo_type}' == 'custom'
            Flash Firmware    ./dcu/coreboot.rom
        END
        Power On
    ELSE
        ${message}=    Catenate    SEPARATOR=
        ...    Please make sure QEMU is running firmware with
        ...    \ the ${logo_type} logo. The default logo binary should be
        ...    \ ${FW_FILE}, the custom logo binary has been prepared in
        ...    \ dcu/coreboot.rom. Afterwards, please click OK to continue.
        Log Out And Close Connection
        Pause Execution    ${message}
        Prepare To Serial Connection
    END

Check The Update Screen For The Correct UX
    [Tags]    robot:private
    ${message}=    Catenate    SEPARATOR=
    ...    Please check the platform screen now, and verify that the UX is the
    ...    \ same as expected in the docs. Most importantly, the progress bar
    ...    \ should be exactly the same width regardless of whether the default
    ...    \ Dasharo logo or a custom one is set. See the screenshot at
    ...    \ https://docs.dasharo.com/guides/capsule-update for reference.
    Execute Manual Step    ${message}

Get Key To Press
    [Tags]    robot:private
    [Arguments]    ${text}
    ${matches}=    Get Regexp Matches    ${text}    [0-9]
    ${digit}=    Set Variable    ${matches[0]}
    Log    Found digit: ${digit}
    RETURN    ${digit}

Extract BIOS Version
    [Tags]    robot:private
    [Arguments]    ${text}
    ${lines}=    Split To Lines    ${text}
    ${bios_version}=    Set Variable    None
    FOR    ${line}    IN    @{lines}
        IF    'BIOS Version' in '${line}'
            ${bios_version}=    Set Variable    ${line}
        END
    END
    IF    '${bios_version}' == 'None'
        FOR    ${line}    IN    @{lines}
            IF    'BIOSVersion' in '${line}'
                ${bios_version}=    Set Variable    ${line}
            END
        END
    END

    RETURN    ${bios_version}

Get BIOS Version
    [Tags]    robot:private
    [Arguments]    ${label}
    ${out}=    Execute UEFI Shell Command    smbiosview -t 0
    ${bios_version}=    Extract BIOS Version    ${out}
    Log To Console    \n[${label}] ${bios_version}
    RETURN    ${bios_version}

Get BIOS Version Linux
    [Tags]    robot:private
    [Arguments]    ${label}
    ${bios_version}=    Get Firmware Version From Dmidecode
    Log To Console    \n[${label}] ${bios_version}
    RETURN    ${bios_version}

Upload Required Files
    [Tags]    robot:private
    Log To Console    PREPARE: Upload Files
    ${file_name}=    Get File Name Without Extension    ${CAPSULE_FW_FILE}

    IF    ${TESTS_IN_UBUNTU_SUPPORT}
        Go To Linux Prompt    ${ENV_ID_UBUNTU}
        # Send File To DUT uses regular user, so prepare target directory in as root
        Execute Command In Terminal    rm -r /capsule_testing
        Execute Command In Terminal    mkdir /capsule_testing
        Execute Command In Terminal    chmod 777 /capsule_testing
        Log To Console    Sending ./dasharo-stability/capsule-update-files/CapsuleApp.efi
        Send File To DUT    ./dasharo-stability/capsule-update-files/CapsuleApp.efi    /capsule_testing/CapsuleApp.efi
        Log To Console    Sending ${CAPSULE_FW_FILE}
        Send File To DUT    ${CAPSULE_FW_FILE}    /capsule_testing/valid_capsule.cap
        Log To Console    Sending ./dl-cache/edk2/${file_name}_wrong_cert.cap
        Send File To DUT    ./dl-cache/edk2/${file_name}_wrong_cert.cap    /capsule_testing/wrong_cert.cap
        Log To Console    Sending ./dl-cache/edk2/${file_name}_invalid_guid.cap
        Send File To DUT    ./dl-cache/edk2/${file_name}_invalid_guid.cap    /capsule_testing/invalid_guid.cap
        # Move the directory to ESP partition so the tests work even if root
        # file-system is part of LVM
        Execute Command In Terminal    rm -r /boot/efi/capsule_testing
        Execute Command In Terminal    mv /capsule_testing /boot/efi
        # Make sure file-system data is pushed to disks before resetting a platform
        Execute Command In Terminal    sync
    ELSE IF    ${TESTS_IN_WINDOWS_SUPPORT}
        Go To Windows Prompt
        Log To Console    Sending ./dasharo-stability/capsule-update-files/CapsuleApp.efi
        SSHLibrary.Put File
        ...    ./dasharo-stability/capsule-update-files/CapsuleApp.efi
        ...    C:\\capsule_testing\\CapsuleApp.efi
        Log To Console    Sending ${CAPSULE_FW_FILE}
        SSHLibrary.Put File    ${CAPSULE_FW_FILE}    C:\\capsule_testing\\valid_capsule.cap
        Log To Console    Sending ./dl-cache/edk2/${file_name}_wrong_cert.cap
        SSHLibrary.Put File    ./dl-cache/edk2/${file_name}_wrong_cert.cap    C:\\capsule_testing\\wrong_cert.cap
        Log To Console    Sending ./dl-cache/edk2/${file_name}_invalid_guid.cap
        SSHLibrary.Put File    ./dl-cache/edk2/${file_name}_invalid_guid.cap    C:\\capsule_testing\\invalid_guid.cap
        Execute Command In Terminal    mountvol b: /s
        Set Prompt For Terminal    PS B:\\>
        Execute Command In Terminal    b:
        Execute Command In Terminal    rmdir /q .\\capsule_testing\\
        Execute Command In Terminal    mkdir capsule_testing
        Execute Command In Terminal    copy C:\\capsule_testing\\*.* B:\\capsule_testing
        Set Prompt For Terminal    PS C:\\>
        Execute Command In Terminal    c:
        Execute Command In Terminal    rmdir /q .\\capsule_testing\\
        # Make sure file-system data is pushed to disks before resetting a platform
        Execute Command In Terminal    dir
    ELSE
        Fail    No Ubuntu nor Windows support.
    END

Perform Capsule Update
    [Tags]    robot:private
    [Arguments]    ${capsule_file}    ${use_uefi_shell}=${True}
    # Submit capsule to firmware without an automatic reset and verify that it
    # was accepted without error
    IF    ${use_uefi_shell}
        Enter Capsule Testing Folder
        ${out}=    Execute UEFI Shell Command    CapsuleApp.efi ${capsule_file} -NR
        Should Not Contain    ${out}    is not recognised
        Should Not Contain    ${out}    Command Error Status
        Should Not Contain    ${out}    is not a valid capsule.
        Should Not Contain    ${out}    failed to query capsule capability
        Should Contain    ${out}    CapsuleApp: creating capsule descriptors at

        # Reset the system manually
        Write Bare Into Terminal    reset
        Press Key N Times    1    ${ENTER}

        # Confirm update by following instructions of Firmware Update Mode dialog
        Read From Terminal Until    ${FUM_DIALOG_TOP}
        ${out}=    Read From Terminal Until    ${FUM_DIALOG_BOTTOM}
        ${digit}=    Get Key To Press    ${out}
        Write Bare Into Terminal    ${digit}
    ELSE
        Power On
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
        Login To Linux With Root Privileges
        # hardcoded fatlabel of the partition, might change if not created using prepare_capsule_update_tests_drive.sh
        ${capsule_disk}=    Identify Path To USB    ${CAPSULE_UPDATE_DISK_MODEL}
        Set Startup Nsh Variable    capsule_file    fs0:\\${capsule_file}    ${capsule_disk}
        Set Startup Nsh Variable    step    0    ${capsule_disk}
        Execute Command In Terminal    sync && udisksctl unmount -b ${capsule_disk}
        # Consider giving an ENV_ID to the capsule update disk and using Boot System...
        Set Nextboot Bootentry    ${CAPSULE_UPDATE_DISK_BOOTENTRY_NAME}
        Execute Reboot Command    assume_correct_boot=${True}
        # uefi shell runs and reboots the platform
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
        Login To Linux
    END

Get File Name Without Extension
    [Tags]    robot:private
    [Arguments]    ${file_path}
    ${path_components}=    Split String    ${file_path}    /
    ${base_name}=    Get From List    ${path_components}    -1
    ${name_parts}=    Split String From Right    ${base_name}    .    1
    ${result}=    Get From List    ${name_parts}    0
    RETURN    ${result}

Ensure Capsule Files Are Present
    [Tags]    robot:private
    Variable Should Exist
    ...    ${CAPSULE_FW_FILE}
    ...    capsule_fw_file parameter missing. Please add: -v capsule_fw_file:<capsule_to_be_testes>.cap to the robot command line and try again.

    OperatingSystem.File Should Exist
    ...    ${CAPSULE_FW_FILE}
    ...    capsule_fw_file parameter incorrect. Please add: -v capsule_fw_file:<capsule_to_be_testes>.cap to the robot command line and try again.

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

Enter Capsule Testing Folder
    [Tags]    robot:private
    ${fss}=    Get FS From Uefi Shell
    FOR    ${fs}    IN    @{fss}
        Set Prompt For Terminal    ${fs}:\\>
        ${out}=    Execute UEFI Shell Command    ${fs}:
        IF    'is not a valid mapping.' in '''${out}'''
            Fail    Failed to find a file-system with capsule_testing/
        END

        Set Prompt For Terminal    \\>
        ${out}=    Execute UEFI Shell Command    cd capsule_testing
        IF    'is not a directory.' not in '''${out}'''    BREAK
    END
    Set Prompt For Terminal    ${fs}:\\capsule_testing\\>

Get FS From Uefi Shell
    [Tags]    robot:private
    ${map}=    Execute UEFI Shell Command    map
    ${fss}=    Get Regexp Matches    ${map}    FS[0-9]{,2}
    RETURN    ${fss}

Display Preparation Instructions
    [Tags]    robot:private
    Log To Console    ******************************************************************************\n
    Log To Console    To run tests first prepare a valid capsule file(*) and then use this capsule
    Log To Console    file to generate invalid capsules required by the tests by running the script:
    Log To Console    \ \ \ \ ./scripts/capsules/capsule_update_tests.sh <capsule_file>.cap
    Log To Console    then start the tests:\n
    Log To Console    \ on QEMU:
    Log To Console    \ \ \ \ robot -v snipeit:no -L TRACE -v rte_ip:127.0.0.1 -v config:qemu \\
    Log To Console    \ \ \ \ \ \ -v capsule_fw_file:dasharo.cap dasharo-stability/capsule-update.robot
    Log To Console    \n on other platforms:
    Log To Console    \ \ \ \ robot -v snipeit:no -L TRACE -v rte_ip:<rte_ip> -v config:<config> \\
    Log To Console    \ \ \ \ \ \ -v sonoff_ip:<sonoff_ip> -v pikvm_ip:<pikvm_ip> -v device_ip:<device_ip> \\
    Log To Console    \ \ \ \ \ \ -v fw_file:<fw_file.rom> -v capsule_fw_file:<capsule_file>.cap \\
    Log To Console    \ \ \ \ \ \ dasharo-stability/capsule-update.robot
    Log To Console    \ \ or:
    Log To Console    \ \ \ \ robot -L TRACE -v rte_ip:<rte_ip> -v config:<config> -v device_ip:<device_ip> \\
    Log To Console    \ \ \ \ \ \ -v fw_file:<fw_file.rom> -v capsule_fw_file:<capsule_file>.cap \\
    Log To Console    \ \ \ \ \ \ dasharo-stability/capsule-update.robot
    Log To Console    \n(*) To start tests on DUT which use PIKVM: Before preparing the capsule please
    Log To Console    edit FW to enable Console Serial Redirection. Use the guide:
    Log To Console
    ...    \ \ https://github.com/Dasharo/open-source-firmware-validation/blob/develop/docs/troubleshooting.md
    Log To Console    Without it, a successful flash of DUT will prevent tests from working
    Log To Console    correctly.
    Log To Console    \n******************************************************************************

Prepare For Logo Persistence Test
    [Tags]    robot:private
    Log To Console    PREPARE: Logo Persistence Test
    Run    cp ${FW_FILE} dcu/coreboot.rom

    IF    ${CUSTOM_LOGO_SUPPORT} == ${TRUE}
        Run    cp ${TEST_DATA_DIR}/dcu/logo.bmp dcu/logo.bmp
        ${result}=    Run Process    bash    -c    cd ./dcu; ./dcuc logo ./coreboot.rom -l ./logo.bmp
        Log    ${result.stdout}
        Log    ${result.stderr}
        Should Contain    ${result.stdout}    Success
    END

Go To Linux Prompt
    [Tags]    robot:private
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Set Suite Variable    ${DUT_CONNECTION_METHOD}    SSH
    END
    Login To Linux
    Switch To Root User

Go To Windows Prompt
    [Tags]    robot:private
    Power On
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Set Suite Variable    ${DUT_CONNECTION_METHOD}    SSH
    END
    Login To Windows

Get System Values
    [Tags]    robot:private
    IF    ${TESTS_IN_UBUNTU_SUPPORT}
        Get Ubuntu System Values    $ORIGINAL_SERIAL    $ORIGINAL_UUID    $ORIGINAL_LOGO_SHA256
    ELSE IF    ${TESTS_IN_WINDOWS_SUPPORT}
        Get Windows System Values    $ORIGINAL_SERIAL    $ORIGINAL_UUID
    ELSE
        Fail    No Windows nor Ubuntu support available
    END

Get Ubuntu System Values
    [Tags]    robot:private
    [Arguments]    ${var_serial}    ${var_uuid}    ${var_logo_sha256}

    # Disable checking for variable case. Here, the first argument to 'Set Suite
    # Variable' keyword is a _local_ variable holding the _name_ of the global
    # one. As such, it should be lower-case, but both robotidy and robocop
    # detect this as error. On top of that, 'robotidy: off' is ignored in top
    # level keywords (bug?), so dummy conditional was added to make it work.
    #
    # robocop: off=non-local-variables-should-be-uppercase
    # robotidy: off=RenameVariables

    IF    ${TRUE}
        ${serial}=    Get Firmware Serial Number
        Set Suite Variable    ${var_serial}    ${serial}

        ${uuid}=    Get Firmware UUID
        Set Suite Variable    ${var_uuid}    ${uuid}
    END

    IF    ${CUSTOM_LOGO_SUPPORT} == ${TRUE}
        ${out}=    Execute Command In Terminal
        ...    sha256sum /sys/firmware/acpi/bgrt/image
        ${unplugged}=    Run Keyword And Return Status
        ...    Should Contain    ${out}    No such file
        IF    ${unplugged} == ${TRUE}
            Fail    Please make sure that a display device is connected to the DUT
        END
        Set Suite Variable    ${var_logo_sha256}    ${out}
    END

Get Windows System Values
    [Tags]    robot:private
    [Arguments]    ${var_serial}    ${var_uuid}

    # Disable checking for variable case. Here, the first argument to 'Set Suite
    # Variable' keyword is a _local_ variable holding the _name_ of the global
    # one. As such, it should be lower-case, but both robotidy and robocop
    # detect this as error. On top of that, 'robotidy: off' is ignored in top
    # level keywords (bug?), so dummy conditional was added to make it work.
    #
    # robocop: off=non-local-variables-should-be-uppercase
    # robotidy: off=RenameVariables
    IF    ${TRUE}
        ${serial}=    Get Firmware Serial Number (Windows)
        Set Suite Variable    ${var_serial}    ${serial}

        ${uuid}=    Get Firmware UUID (Windows)
        Set Suite Variable    ${var_uuid}    ${uuid}
    END

Prepare For ROMHOLE Persistence Test
    [Documentation]    This is a part which works only on MSI platforms.
    [Tags]    robot:private
    Log To Console    PREPARE: ROMHOLE Persistence Test

    IF    ${ROMHOLE_SUPPORT} == ${TRUE}
        Run    dd if=dasharo-stability/capsule-update-files/romhole of=dcu/coreboot.rom seek=24903680 bs=1 conv=notrunc
    ELSE
        Log To Console    \ \ \ \ ROMHOLE not supported - skipping
    END

Get Firmware UUID (Windows)
    [Tags]    robot:private
    ${uuid}=    Execute Command In Terminal    wmic path win32_computersystemproduct get UUID
    @{uuid}=    Split To Lines    ${uuid}
    Set Local Variable    ${var}    ${uuid}[-1]
    ${var}=    Strip String    ${var}
    ${var}=    Convert To Lower Case    ${var}
    RETURN    ${var}

Get Firmware Serial Number (Windows)
    [Tags]    robot:private
    ${serial}=    Execute Command In Terminal    wmic bios get serialnumber
    @{serial}=    Split To Lines    ${serial}
    Set Local Variable    ${var}    ${serial}[-1]
    ${var}=    Strip String    ${var}
    RETURN    ${var}

Get Capsule Update Logs
    [Documentation]    Gets the capsule update logs from CapsuleApp.efi -S
    [Tags]    robot:private
    [Arguments]    ${use_uefi_shell}=${True}
    # Submit capsule to firmware without an automatic reset and verify that it
    # was accepted without error
    IF    ${use_uefi_shell}
        Enter Capsule Testing Folder
        ${out}=    Execute UEFI Shell Command    CapsuleApp.efi -S
        RETURN    ${out}
    ELSE
        ${capsule_disk}=    Identify Path To USB    ${CAPSULE_UPDATE_DISK_MODEL}
        Set Startup Nsh Variable    step    1    ${capsule_disk}
        Execute Command In Terminal    sync && udisksctl unmount -b ${capsule_disk}
        Set Nextboot Bootentry    ${CAPSULE_UPDATE_DISK_BOOTENTRY_NAME}
        Execute Reboot Command    assume_correct_boot=${True}
        # uefi shell runs and reboots the platform
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
        Login To Linux With Root Privileges
        ${capsule_disk}=    Identify Path To USB    ${CAPSULE_UPDATE_DISK_MODEL}>
        ${mount_point}=    Mount USB    ${capsule_disk}

        # UEFI Shell uses UTF-16LE and SSHLibrary will panic if the file is read
        # to the terminal in this form
        Execute Command In Terminal    iconv -f UTF-16LE -t UTF-8 ${mount_point}/logs.txt -o /tmp/capsule-logs.txt
        ${logs}=    Execute Command In Terminal    cat /tmp/capsule-logs.txt
        RETURN    ${logs}
    END

Mount USB
    [Documentation]    mounts the block device using udisksctl in linux
    ...    and returns the mountpoint
    [Tags]    robot:private
    [Arguments]    ${block_dev}
    # doesn't matter if mounting fails, because its already mounted
    Execute Command In Terminal    udisksctl mount -b ${block_dev}
    ${mount_point}=    Execute Command In Terminal
    ...    udisksctl info -b ${block_dev} | grep -Po '^ *MountPoints: *\\K.*'
    RETURN    ${mount_point}

Set Startup Nsh Variable
    [Documentation]    The variables that control the startup.nsh script
    ...    are written to files
    [Tags]    robot:private
    [Arguments]    ${name}    ${value}    ${capsule_disk}
    ${variable_name}=    Convert To Upper Case    ${name}
    ${file_name}=    Convert To Lower Case    ${name}
    ${mount_point}=    Mount USB    ${capsule_disk}
    ${out}=    Execute Command In Terminal
    ...    echo "set ${variable_name} ${value}" > ${mount_point}/variable_${file_name}.nsh
    Should Not Contain    ${out}    No such file
