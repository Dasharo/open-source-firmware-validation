*** Settings ***
Metadata            ORDER_SENSITIVE

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
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
