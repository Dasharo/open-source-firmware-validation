*** Settings ***
Library             Collections
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../keywords.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite    AND
...                     Skip If    not ${CAPSULE_UPDATE_SUPPORT}
...                     AND    Set UEFI Option    MeMode    Disabled (Soft)
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Variables ***
${CABINET_ENVVAR}=      FWUPD_CABINET_FILE


*** Test Cases ***
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
    [Tags]    semiauto
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Fwupd Local Firmware Update Linux

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
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Fwupd Local Firmware Update Linux

FWUPD001.203 Fwupd Devices Detected (QubesOS)
    [Documentation]    Test if the supported hardware is properly detected
    ...    by fwupd
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    Fwupd Devices Detected Linux

FWUPD002.203 Fwupd Local Firmware Update (QubesOS)
    [Documentation]    Test if a firmware update can be performed using fwupd
    ...    using local unsigned cabinet
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    Fwupd Local Firmware Update Linux


*** Keywords ***
Fwupd Devices Detected Linux
    ${out}=    Execute Command In Terminal    fwupdmgr get-devices --assume-yes

    VAR    @{devices}=    System Firmware    UEFI dbx

    IF    ${TPM_SUPPORTED_VERSION} != ${NONE}
        Append To List    ${devices}    TPM
    END

    Should Contain All    ${out}    @{devices}

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
    ${out}=    Execute Command In Terminal
    ...    yes Y | fwupdmgr local-install ${cabinet} --allow-reinstall --allow-older --assume-yes --force
    ...    timeout=300s
    Should Not Contain
    ...    ${out}
    ...    AC power
    ...    AC is disconnected, connect AC. (Or its a bug - AC it not detected if internal battery is full. Discharge the battery a bit and try again.)\n\n
    Should Contain    ${out}    Successfully installed firmware
    IF    "${POWER_CTRL}"=="none"
        Execute Manual Step    The laptop might stay powered off after update. Power it back on.
    END
    Boot System Or From Connected Disk    ${BOOTED_OS_ID}
    Login To Linux
