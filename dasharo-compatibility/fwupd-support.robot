*** Settings ***
Metadata            ORDER_SENSITIVE

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             TelnetLibrary    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../keywords.robot
Resource            ../lib/performance/cpu.robot
Resource            ../lib/fwupd.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite    AND
...                     Skip If    not ${CAPSULE_UPDATE_SUPPORT}    AND
...                     Run Keyword If    "${DASHARO_INTEL_ME_MENU_SUPPORT}" == "${TRUE}"
...                     Set UEFI Option    MeMode    Disabled (HAP)
...                     AND    Check Power Supply
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Variables ***
${CABINET_ENVVAR}=      FWUPD_CABINET_FILE


*** Test Cases ***
FWUPD004.201 Fwupd Installed (Ubuntu)
    [Documentation]    Check if fwupd is installed by verifying version output
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Fwupd Installed Linux

FWUPD005.201 Fwupd Check For Updates (Ubuntu)
    [Documentation]    Check for availability of a new firmware version using fwupd
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Fwupd Check For Updates Linux

FWUPD001.201 Fwupd Devices Detected (Ubuntu)
    [Documentation]    Test if the supported hardware is properly detected
    ...    by fwupd
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Fwupd Devices Detected Linux

FWUPD002.201 Fwupd Local Firmware Update (Ubuntu)
    [Documentation]    Test if a firmware update can be performed using fwupd
    ...    using local unsigned cabinet
    [Tags]    automated    semiauto
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Fwupd Local Firmware Update Linux

FWUPD006.201 Fwupd Check Update Results (Ubuntu)
    [Documentation]    Verify result of the firmware update using fwupd
    [Tags]    automated    semiauto
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Fwupd Check Update Results Linux

FWUPD007.201 Fwupd DBX Update (Ubuntu)
    [Documentation]    Replace dbx with a single non-Microsoft hash, which fwupd
    ...    reports as version 0, then install the dbx update from LVFS and
    ...    verify the firmware stored it. Ubuntu's secureboot-db service puts
    ...    the Microsoft dbx back on every boot, so it is disabled first.
    [Tags]    automated    semiauto
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Skip If    not ${SECURE_BOOT_SUPPORT}    Secure Boot menu is required to replace dbx
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Execute Command In Terminal    systemctl disable secureboot-db.service
    IF    ${TESTS_IN_FIRMWARE_SUPPORT}
        Seed Empty Dbx In Setup Menu
    ELSE
        Seed Empty Dbx Manually
    END

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Fwupd Dbx Update Linux

FWUPD004.202 Fwupd Installed (Fedora)
    [Documentation]    Check if fwupd is installed by verifying version output
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Fwupd Installed Linux

FWUPD005.202 Fwupd Check For Updates (Fedora)
    [Documentation]    Check for availability of a new firmware version using fwupd
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Fwupd Check For Updates Linux

FWUPD001.202 Fwupd Devices Detected (Fedora)
    [Documentation]    Test if the supported hardware is properly detected
    ...    by fwupd
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Fwupd Devices Detected Linux

FWUPD002.202 Fwupd Local Firmware Update (Fedora)
    [Documentation]    Test if a firmware update can be performed using fwupd
    ...    using local unsigned cabinet
    [Tags]    automated    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Fwupd Local Firmware Update Linux

FWUPD006.202 Fwupd Check Update Results (Fedora)
    [Documentation]    Verify result of the firmware update using fwupd
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Fwupd Check Update Results Linux

FWUPD004.203 Fwupd Installed (Qubes OS)
    [Documentation]    Check if fwupd is installed by verifying version output
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    Fwupd Installed Linux

FWUPD005.203 Fwupd Check For Updates (Qubes OS)
    [Documentation]    Check for availability of a new firmware version using fwupd
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    Fwupd Check For Updates Linux

FWUPD001.203 Fwupd Devices Detected (Qubes OS)
    [Documentation]    Test if the supported hardware is properly detected
    ...    by fwupd
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    Fwupd Devices Detected Linux

FWUPD002.203 Fwupd Local Firmware Update (Qubes OS)
    [Documentation]    Test if a firmware update can be performed using fwupd
    ...    using local unsigned cabinet
    [Tags]    automated    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    Fwupd Local Firmware Update Linux

FWUPD006.203 Fwupd Check Update Results (Qubes OS)
    [Documentation]    Verify result of the firmware update using fwupd
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    Fwupd Check Update Results Linux


*** Keywords ***
Fwupd Devices Detected Linux
    ${out}=    Execute Command In Terminal    fwupdmgr get-devices --assume-yes
    VAR    @{alternative_firmware_names}=    System Firmware    Device Firmware
    Should Contain Any    ${out}    @{alternative_firmware_names}

    IF    ${TPM_SUPPORTED_VERSION} != ${NONE}    Should Contain    ${out}    TPM
    Should Contain    ${out}    UEFI dbx

Fwupd Local Firmware Update Linux
    ${cabinet_given}=    Run Keyword And Return Status
    ...    Get Environment Variable    ${CABINET_ENVVAR}
    IF    not ${cabinet_given}
        Skip    ${CABINET_ENVVAR} environment variable not defined
    END
    ${fwupd_cabinet}=    Get Environment Variable    ${CABINET_ENVVAR}

    VAR    ${cabinet}=    ~/fwupd_cabinet.cab
    Switch To Root User
    Send File To DUT    ${fwupd_cabinet}    target_path=${cabinet}
    Execute Command In Terminal    printf '[fwupd]\\nOnlyTrusted=false\\n' | sudo tee /etc/fwupd/fwupd.conf

    ${out}=    Run Fwupd Update With Battery Check Workaround    Run Fwupd Local Install    ${cabinet}
    Should Contain    ${out}    Successfully installed firmware
    Execute Reboot Command
    Boot System Or From Connected Disk    ${BOOTED_OS_ID}
    Login To Linux

Fwupd Installed Linux
    ${out}=    Execute Command In Terminal    fwupdmgr --version
    Should Contain    ${out}    org.freedesktop.fwupd

Fwupd Check For Updates Linux
    Execute Command In Terminal    fwupdmgr refresh
    # yes for situations where interactive prompt for uploading results
    # appears after an update in the previous reboot.
    ${out}=    Execute Command In Terminal    yes n | fwupdmgr get-updates
    Should Not Contain    ${out}    failed to connect    ignore_case=${True}
    Should Not Contain    ${out}    timed out    ignore_case=${True}
    Should Contain    ${out}    Devices with    ignore_case=${True}

Fwupd Check Update Results Linux
    VAR    ${id_extract_command}=
    ...    fwupdmgr get-devices 2>/dev/null
    ...    grep -A1 -E "(System Firmware)|(Device Firmware)"
    ...    grep "Device ID"
    ...    awk '{print $NF}'
    ...    separator= |
    ${firmware_id}=    Execute Command In Terminal    ${id_extract_command}
    Fwupd Verify Update Results Linux    ${firmware_id}

Load Json From Command
    [Documentation]    Run a command that prints JSON and return the parsed object.
    [Arguments]    ${cmd}    ${timeout}=60
    ${out}=    Execute Command In Terminal    ${cmd}    ${timeout}
    ${data}=    Evaluate
    ...    json.loads($out[$out.find('{'):$out.rfind('}') + 1])
    ...    json
    RETURN    ${data}

Get Dbx Device
    [Documentation]    Return the fwupd JSON entry of the UEFI dbx device.
    ${data}=    Load Json From Command    fwupdmgr get-devices --json
    ${devices}=    Get From Dictionary    ${data}    Devices    default=@{EMPTY}
    FOR    ${device}    IN    @{devices}
        ${plugin}=    Get From Dictionary    ${device}    Plugin    default=${EMPTY}
        IF    '${plugin}' == 'uefi_dbx'    RETURN    ${device}
    END
    ${dbx_size}=    Get Dbx Variable Size
    Fail    fwupd does not expose a UEFI dbx device (dbx variable: ${dbx_size})

Get Dbx Variable Size
    [Documentation]    Return the size of the dbx variable in efivarfs
    ${out}=    Execute Command In Terminal
    ...    stat --format=%s /sys/firmware/efi/efivars/dbx-d719b2cb-3d3a-4596-a3bc-dad00e67656f
    RETURN    ${out}

Get Dbx Version
    [Documentation]    Return the fwupd-reported dbx version
    ${device}=    Get Dbx Device
    ${version}=    Get From Dictionary    ${device}    Version    default=${NONE}
    RETURN    ${version}

Fwupd Dbx Should Be Empty
    [Documentation]    fwupd reports version 0 for a dbx holding a single
    ...    entry with the zero owner GUID.
    ${version}=    Get Dbx Version
    ${dbx_size}=    Get Dbx Variable Size
    Should Be Equal As Strings    ${version}    0
    ...    msg=dbx still contains Microsoft entries (fwupd version ${version}, dbx variable ${dbx_size} bytes)

Seed Empty Dbx In Setup Menu
    [Documentation]    Delete every dbx entry and enroll a single
    ...    zero owner GUID hash which fwupd treats as an empty dbx.
    ...    The binary hashed must be signed, because FWUPD does not support SHA512.
    ...    The firmware hashes with SHA512 by default, and with the same algo
    ...    as the signature if its present.
    Mount USB Disk Image    ${TEST_DATA_DIR}/secure-boot/sb_test_data.img    file    TRUE
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    ${sb_menu}=    Delete All DBX Signatures    ${advanced_menu}
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Enter Enroll Signature Using File In Options    ${advanced_menu}    DBX Options
    Enter Volume In File Explorer    BAD_INFLUE
    Select File In File Explorer    hello-dasharo-signed-no-ts.efi

Seed Empty Dbx Manually
    VAR    ${msg}=    [1/4] Write ${TEST_DATA_DIR}/secure-boot/sb_test_data.img to a USB stick,
    ...    plug it into the DUT and boot into the setup menu.
    Execute Manual Step    ${msg}
    VAR    ${msg}=    [2/4] Device Manager > Secure Boot Configuration:
    ...    set Secure Boot Mode to Custom Mode, then Advanced Secure Boot Keys Management
    ...    > DBX Options > Delete Signature > Delete All Signature List, confirm with Y.
    ...    The Delete Signature form must show no signature list afterwards.
    Execute Manual Step    ${msg}
    VAR    ${msg}=    [3/4] Go back to DBX Options > Enroll Signature
    ...    > Enroll Signature Using File, pick hello-dasharo-signed-no-ts.efi
    ...    (the signed one, an unsigned image gets a SHA512 hash fwupd cannot parse)
    ...    from the BAD_INFLUE volume, leave Signature GUID empty
    ...    and select Commit Changes and Exit.
    Execute Manual Step    ${msg}
    Execute Manual Step    [4/4] Boot Ubuntu.

Fwupd Dbx Update Linux
    [Documentation]    Assuming starting with an empty dbx: install the newest dbx
    ...    release, reboot and verify the update.
    Fwupd Dbx Should Be Empty
    ${size_before}=    Get Dbx Variable Size
    Fwupd Refresh Metadata Linux
    ${dbx}=    Get Dbx Device
    ${out}=    Run Fwupd Update With Battery Check Workaround    Run Fwupd Dbx Install    ${dbx}[DeviceId]
    Should Contain    ${out}    Successfully installed firmware
    Execute Reboot Command
    Boot System Or From Connected Disk    ${BOOTED_OS_ID}
    Login To Linux
    Switch To Root User
    ${size_after}=    Get Dbx Variable Size
    Should Be True    ${size_after} > ${size_before}
    ...    msg=firmware did not store the dbx update (dbx variable ${size_before} -> ${size_after} bytes)
    Fwupd Refresh Metadata Linux
    ${version}=    Wait Until Keyword Succeeds    2 min    10 s    Get Recognised Dbx Version
    Should Be True    ${version} > 0    msg=fwupd still reports an empty dbx
    Log    dbx grew from ${size_before} to ${size_after} bytes, fwupd reports version ${version}

Get Recognised Dbx Version
    [Documentation]    Return the dbx version
    ${version}=    Get Dbx Version
    Should Not Be Equal    ${version}    ${NONE}    msg=fwupd does not recognise the dbx release after the update
    RETURN    ${version}
