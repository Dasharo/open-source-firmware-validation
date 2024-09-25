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
Suite Setup         Run Keywords
...                     Display Preparation Instructions
...                     AND
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${CAPSULE_UPDATE_SUPPORT}    Capsule Update not supported
...                     AND
...                     Check If CAPSULE FW FILE Is Present
...                     AND
...                     Prepare For Logo Persistence Test
...                     AND
...                     Flash Firmware If Not QEMU
...                     AND
...                     Upload Required Files
...                     AND
...                     Get System Values
...                     AND
...                     Turn Off Active ME
Suite Teardown      Run Keywords
...                     Log Out And Close Connection


*** Variables ***
${FUM_DIALOG_TOP}=          Update Mode. All firmware write protections are disabled in this mode.
${FUM_DIALOG_BOTTOM}=       The platform will automatically reboot and disable Firmware Update Mode
${CUSTOM_LOGO_SUPPORT}=     ${FALSE}


*** Test Cases ***
CUP001.001 Capsule Update With Wrong Keys
    [Documentation]    Check that DUT rejects flashing a capsule signed with invalid certificate.
    Boot Into UEFI Shell
    ${original_bios_version}=    Get BIOS Version    before update

    Perform Capsule Update    wrong_cert.cap

    Select UEFI Shell Boot Option
    ${updated_bios_version}=    Get BIOS Version    after update
    Should Be Equal    ${original_bios_version}    ${updated_bios_version}

    Enter Capsule Testing Folder
    ${out}=    Execute UEFI Shell Command    CapsuleApp.efi -S
    Should Contain    ${out}    Capsule Status: Security Violation

CUP002.001 Capsule Update With Wrong GUID
    [Documentation]    Check that DUT rejects flashing a capsule with invalid GUID.
    Boot Into UEFI Shell
    ${original_bios_version}=    Get BIOS Version    before update

    Perform Capsule Update    invalid_guid.cap

    Select UEFI Shell Boot Option
    ${updated_bios_version}=    Get BIOS Version    after update
    Should Be Equal    ${original_bios_version}    ${updated_bios_version}

    Enter Capsule Testing Folder
    ${out}=    Execute UEFI Shell Command    CapsuleApp.efi -S
    Should Contain    ${out}    Capsule Status: Not Ready

CUP130.001 Verifying BIOS Settings Persistence After Update - PART 1
    [Documentation]    Check if BIOS settings didn't change after Capsule Update.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${boot_menu}=    Enter Dasharo Submenu    ${setup_menu}    Boot Maintenance Manager

    Set Option State    ${boot_menu}    Auto Boot Time-out    32123
    Save Changes And Reset

CUP150.001 Capsule Update
    [Documentation]    Check for a successful Capsule Update.
    ...    Please note that the test number is high on purpose. This test will flash FW! In future
    ...    if additional test cases will be created - when running the whole suite - It will be good
    ...    to keep the number of actual FW updates to minimum to prevent chip degradation.
    Boot Into UEFI Shell
    ${original_bios_version}=    Get BIOS Version    before update

    Perform Capsule Update    max_fw_ver.cap

    Select UEFI Shell Boot Option
    ${updated_bios_version}=    Get BIOS Version    after update
    Should Not Be Equal    ${original_bios_version}    ${updated_bios_version}

    Enter Capsule Testing Folder
    ${out}=    Execute UEFI Shell Command    CapsuleApp.efi -S
    Should Contain    ${out}    CapsuleMax
    Should Not Contain    ${out}    CapsuleLast

CUP160.001 Verifying UUID
    [Documentation]    Check if UUID didn't change after Capsule Update.
    Go To Ubuntu Prompt
    ${updated_uuid}=    Get Firmware UUID
    Log To Console    \n[UUID After Update] ${updated_uuid}

    Should Be Equal    ${ORIGINAL_UUID}    ${updated_uuid}

CUP170.001 Verifying Serial Number
    [Documentation]    Check if serial number didn't change after Capsule Update.
    Go To Ubuntu Prompt
    ${updated_serial}=    Get Firmware Serial Number
    Log To Console    \n[Serial Number After Update] ${updated_serial}

    Should Be Equal    ${ORIGINAL_SERIAL}    ${updated_serial}

CUP180.001 Verifying BIOS Settings Persistence After Update - PART 2
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${boot_menu}=    Enter Dasharo Submenu    ${setup_menu}    Boot Maintenance Manager

    ${updated_state}=    Get Option State    ${boot_menu}    Auto Boot Time-out
    Should Be Equal    ${updated_state}    32123

CUP190.001 Verifying If Custom Logo Persists Across updates
    [Documentation]    Check if Logo didn't change after Capsule Update.
    Skip If    not ${CUSTOM_LOGO_SUPPORT}    not supported

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User

    ${out}=    Execute Command In Terminal
    ...    sha256sum /sys/firmware/acpi/bgrt/image
    ${unplugged}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    No such file
    IF    ${unplugged} == ${TRUE}
        Fail    Please make sure that a display device is connected to the DUT
    END
    Should Contain    ${out}    ${CUSTOM_LOGO_SHA}


*** Keywords ***
Flash Firmware If Not QEMU
    Log To Console    PREPARE: Flashing Firmware
    IF    '${MANUFACTURER}' != 'QEMU'
        Flash Firmware    ./dcu/coreboot.rom
        Power Cycle On
    END

Get Key To Press
    [Arguments]    ${text}
    ${matches}=    Get Regexp Matches    ${text}    [0-9]
    ${digit}=    Set Variable    ${matches[0]}
    Log    Found digit: ${digit}
    RETURN    ${digit}

Select UEFI Shell Boot Option
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    UEFI Shell
    Read From Terminal Until    Shell>

Boot Into UEFI Shell
    Power On
    Select UEFI Shell Boot Option

Extract BIOS Version
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
    [Arguments]    ${label}
    ${out}=    Execute UEFI Shell Command    smbiosview -t 0
    ${bios_version}=    Extract BIOS Version    ${out}
    Log To Console    \n[${label}] ${bios_version}
    RETURN    ${bios_version}

Upload Required Files
    Log To Console    PREPARE: Upload Files

    ${file_name}=    Get File Name Without Extension    ${CAPSULE_FW_FILE}

    Check If Capsule File Exists    ./dl-cache/edk2/${file_name}_max_fw_ver.cap
    Check If Capsule File Exists    ./dl-cache/edk2/${file_name}_wrong_cert.cap
    Check If Capsule File Exists    ./dl-cache/edk2/${file_name}_invalid_guid.cap

    Set DUT Response Timeout    5m
    Power On
    Boot System Or From Connected Disk    ubuntu

    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
    END

    Login To Linux
    Switch To Root User

    # Send File To DUT uses regular user, so prepare target directory in as root
    Execute Command In Terminal    rm -r /capsule_testing
    Execute Command In Terminal    mkdir /capsule_testing
    Execute Command In Terminal    chmod 777 /capsule_testing

    Log To Console    Sending ./dasharo-stability/capsule-update-files/CapsuleApp.efi
    Send File To DUT    ./dasharo-stability/capsule-update-files/CapsuleApp.efi    /capsule_testing/CapsuleApp.efi
    Log To Console    Sending ${CAPSULE_FW_FILE}
    Send File To DUT    ${CAPSULE_FW_FILE}    /capsule_testing/valid_capsule.cap
    Log To Console    Sending ./dl-cache/edk2/${file_name}_max_fw_ver.cap
    Send File To DUT    ./dl-cache/edk2/${file_name}_max_fw_ver.cap    /capsule_testing/max_fw_ver.cap
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

Perform Capsule Update
    [Arguments]    ${capsule_file}
    # Submit capsule to firmware without an automatic reset and verify that it
    # was accepted without error
    Enter Capsule Testing Folder
    ${out}=    Execute UEFI Shell Command    CapsuleApp.efi ${capsule_file} -NR
    Should Not Contain    ${out}    is not recognised
    Should Not Contain    ${out}    Command Error Status
    Should Not Contain    ${out}    is not a valid capsule.
    Should Not Contain    ${out}    failed to query capsule capability
    Should Contain    ${out}    CapsuleApp: creating capsule descriptors at
    Should Contain    ${out}    :\\capsule_testing\\>

    # Reset the system manually
    Execute UEFI Shell Command    reset    5m

    # Confirm update by following instructions of Firmware Update Mode dialog
    Read From Terminal Until    ${FUM_DIALOG_TOP}
    ${out}=    Read From Terminal Until    ${FUM_DIALOG_BOTTOM}
    ${digit}=    Get Key To Press    ${out}
    Write Bare Into Terminal    ${digit}

Get File Name Without Extension
    [Arguments]    ${file_path}
    ${path_components}=    Split String    ${file_path}    /
    ${base_name}=    Get From List    ${path_components}    -1
    ${name_parts}=    Split String From Right    ${base_name}    .    1
    ${result}=    Get From List    ${name_parts}    0
    RETURN    ${result}

Check If Capsule File Exists
    [Arguments]    ${file_path}
    ${file_exists}=    OperatingSystem.File Should Exist    ${file_path}
    IF    '${file_exists}' == 'False'
        Fail
        ...    File ${file_path} does not exist!/nTo create capsule files required for this test run: 'sudo bash
        ...    ./scripts/capsules/capsule_update_tests.sh ${CAPSULE_FW_FILE}' and start the test again.
    END

Check If CAPSULE FW FILE Is Present
    IF    '${CAPSULE_FW_FILE}' == '${EMPTY}'
        Log To Console    capsule_fw_file parameter missing.
        ...    Please add: -v capsule_fw_file:<capsule_to_be_testes>.cap to the robot command line and try again.
        Fail
    END

Enter Capsule Testing Folder
    ${fss}=    Get FS From Uefi Shell
    FOR    ${fs}    IN    @{fss}
        ${out}=    Execute UEFI Shell Command    ${fs}:
        IF    'is not a valid mapping.' in '''${out}'''
            Fail    Failed to find a file-system with capsule_testing/
        END

        ${out}=    Execute UEFI Shell Command    cd capsule_testing
        IF    'is not a directory.' not in '''${out}'''    BREAK
    END

Get FS From Uefi Shell
    ${map}=    Execute UEFI Shell Command    map
    ${fss}=    Get Regexp Matches    ${map}    FS[0-9]{,2}
    RETURN    ${fss}

Turn Off Active ME
    Log To Console    PREPARE: Turn Off Active ME
    IF    ${DASHARO_INTEL_ME_MENU_SUPPORT} == ${TRUE}
        Power On
        ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
        ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
        ${me_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Intel Management Engine Options
        Set Option State    ${me_menu}    Intel ME mode    Disabled (HAP)
        Save Changes And Reset
    END

Display Preparation Instructions
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
    Log To Console    PREPARE: Logo persistence test

    Run    rm -rf dcu
    Run    git clone https://github.com/Dasharo/dcu
    Run    cp ${FW_FILE} dcu/coreboot.rom

    ${out}=    Run
    ...    cbfstool ./dcu/coreboot.rom layout -w | grep BOOTSPLASH > /dev/null && echo "Custom logo supported" || echo "Custom logo not supported"

    IF    'Custom logo supported' in '${out}'
        Set Global Variable    ${CUSTOM_LOGO_SUPPORT}    ${TRUE}
        Download To Host Cache
        ...    logo.bmp
        ...    https://cloud.3mdeb.com/index.php/s/rsjCdz4wSNesLio/download
        ...    6e5a6722955e4f78d947654630f27ff833703fbc04776ffed963c96617f6bb2a

        ${local_path}=    Join Path    ${DL_CACHE_DIR}    logo.bmp
        Run    cp ${local_path} dcu/logo.bmp

        ${result}=    Run Process    bash    -c    cd ./dcu; ./dcuc logo ./coreboot.rom -l ./logo.bmp

        Log    ${result.stdout}
        Log    ${result.stderr}
        Should Contain    ${result.stdout}    Success
    END

Go To Ubuntu Prompt
    Power On
    Boot System Or From Connected Disk    ubuntu
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Set Suite Variable    ${DUT_CONNECTION_METHOD}    SSH
    END
    Login To Linux
    Switch To Root User

Get System Values
    Log To Console    PREPARE: Get System Values

    ${temp_serial}=    Get Firmware Serial Number
    Set Suite Variable    ${ORIGINAL_SERIAL}    ${temp_serial}
    Log To Console    \n[Serial Number Before Update] ${ORIGINAL_SERIAL}

    ${temp_uuid}=    Get Firmware UUID
    Set Suite Variable    ${ORIGINAL_UUID}    ${temp_uuid}
    Log To Console    [UUID Before Update] ${ORIGINAL_UUID}\n

    ${out}=    Execute Command In Terminal
    ...    sha256sum /sys/firmware/acpi/bgrt/image
    ${unplugged}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    No such file
    IF    ${unplugged} == ${TRUE}
        Fail    Please make sure that a display device is connected to the DUT
    END
    Set Suite Variable    ${CUSTOM_LOGO_SHA}    ${out}