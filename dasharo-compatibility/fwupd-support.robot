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
Resource            ../lib/dcu.robot

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
${CABINET_ENVVAR}=          FWUPD_CABINET_FILE
# Older official Microsoft DBXUpdate.bin used to seed an out-of-date dbx before the
# firmware update (default: committed asset; override with DBX_OLD_DBXUPDATE).
${DBX_OLD_DBXUPDATE}=       ${TEST_DATA_DIR}/dbx/DBXUpdate_28-10-2022.bin


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

FWUPD007.201 Fwupd firmware update updates dbx (Ubuntu)
    [Documentation]    Seed an older UEFI dbx, perform a full firmware update via
    ...    fwupd, and verify the update advanced dbx too - dbx is updated as part of
    ...    the whole-firmware update.
    [Tags]    automated    semiauto
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    # Required only because DBX updates are bundled with firmware updates.
    # DBX can only be done by updating the firmware, which won't update if
    # the firmware is up to date.
    # Remove flashing when standalone DBX updates will be supported
    ${base_fw}=    Get Environment Variable    CAPSULE_UPDATE_RC0_FW_FILE
    Flash Firmware    ${base_fw}
    Set UEFI Option    MeMode    Disabled (HAP)

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    ${version_before}=    Get Dbx Version
    ${size_before}=    Get Dbxdefault Size
    Log    Old DBX: version: ${version_before}, size: ${size_before}
    Fwupd Local Firmware Update Linux
    ${version_after}=    Get Dbx Version
    ${size_after}=    Get Dbxdefault Size
    Log    Updated DBX: version: ${version_after}, size: ${size_after}

    ${dbx_changed}=    Run Keyword And Return Status    Should Not Be Equal    ${version_before}    ${version_after}
    ${dbx_default_changed}=    Run Keyword And Return Status    Should Not Be Equal    ${size_before}    ${size_after}

    Should Be True    ${dbx_default_changed}    DBX was not updated.
    IF    not ${dbx_changed}
        Log
        ...    The update only updated the dbxDefault. To use the new DBX the user needs to manually reset SB keys to defaults.
        ...    WARN
    END

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
    ...    json.loads(r'''${out}'''[r'''${out}'''.find('{'):r'''${out}'''.rfind('}') + 1])
    ...    json
    RETURN    ${data}

Get Dbx Version
    [Documentation]    Return the fwupd-reported UEFI dbx version as an integer (a date
    ...    such as 20250902).
    ${data}=    Load Json From Command    fwupdmgr get-devices --json
    ${devices}=    Get From Dictionary    ${data}    Devices    default=@{EMPTY}
    FOR    ${d}    IN    @{devices}
        ${name}=    Get From Dictionary    ${d}    Name    default=${EMPTY}
        IF    'dbx' in '''${name}'''.lower()
            ${version}=    Get From Dictionary    ${d}    Version    default="None"
            ${version}=    Convert To Integer    ${version}
            RETURN    ${version}
        END
    END
    Fail    fwupd does not expose a UEFI dbx device

Get Dbxdefault Size
    ${size}=    Execute Command In Terminal
    ...    stat --format=%s /sys/firmware/efi/efivars/dbxDefault-8be4df61-93ca-11d2-aa0d-00e098032b8c
    RETURN    ${size}
