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
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Fwupd Local Firmware Update Linux

FWUPD003.201 Fwupd LVFS Firmware Update (Ubuntu)
    [Documentation]    Test if a firmware update can be performed using fwupd
    ...    and a signed cabinet from LVFS
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Fwupd LVFS Firmware Update Linux

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
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Fwupd Local Firmware Update Linux

FWUPD003.202 Fwupd LVFS Firmware Update (Fedora)
    [Documentation]    Test if a firmware update can be performed using fwupd
    ...    and a signed cabinet from LVFS
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Fwupd LVFS Firmware Update Linux

FWUPD001.203 Fwupd Devices Detected (QubesOS)
    [Documentation]    Test if the supported hardware is properly detected
    ...    by fwupd
    [Tags]    semiauto
    Execute Manual Step    Power on and boot into QubesOS
    Execute Manual Step    Open dom0 terminal
    Execute Manual Step    Run `fwupdmgr get-devices | grep -B1 "Device ID"`
    Execute Manual Step    Should contain `System Firmware`
    IF    ${TPM_SUPPORTED_VERSION} != ${NONE}
        Execute Manual Step    Should contain `TPM`
    END

FWUPD002.203 Fwupd Local Firmware Update (QubesOS)
    [Documentation]    Test if a firmware update can be performed using fwupd
    ...    using local unsigned cabinet
    [Tags]    semiauto
    Execute Manual Step    Power on and boot into QubesOS
    Execute Manual Step    Open sys-net terminal
    VAR    ${msg}=    Transfer the \$FWUPD_CABINET_FILE to the `dom0`.
    ...    (For example by starting sshd in sys-net, sending the file via `scp`,
    ...    and sending it back to `dom0` using `qvm-copy` command.)
    Execute Manual Step    ${msg}
    VAR    ${msg}=    Open dom0 terminal and locate the
    ...    \$FWUPD_CABINET FILE (If using qvm-copy, it will be placed
    ...    in `~/QubesIncoming/sys-net/`)
    Execute Manual Step    ${msg}
    Execute Manual Step    Run `yes n | fwupdmgr local-install \$FWUPD_CABINET_FILE --allow-reinstall --allow-older`
    Execute Manual Step    Should print `Successfully installed firmware`

FWUPD003.203 Fwupd LVFS Firmware Update (QubesOS)
    [Documentation]    Test if a firmware update can be performed using fwupd
    ...    and a signed cabinet from LVFS
    [Tags]    semiauto
    Execute Manual Step    Power on and boot into QubesOS
    Execute Manual Step    Open dom0 terminal
    Execute Manual Step
    ...    Run `export ID=$(fwupdmgr get-devices 2>/dev/null | grep -A1 "System Firmware" | grep "Device ID" | awk '{print $NF}')`
    Execute Manual Step    Run `yes n | fwupdmgr install \$ID --allow-reinstall --allow-older`
    Execute Manual Step
    ...    Should not print any of: `failed to find`, `No updatable devices`, `No releases found`, `no devices`
    Execute Manual Step    Should print `Successfully installed firmware`


*** Keywords ***
Fwupd Devices Detected Linux
    ${out}=    Execute Command In Terminal    fwupdmgr get-devices

    VAR    @{devices}=    System Firmware    UEFI dbx

    IF    ${TPM_SUPPORTED_VERSION} != ${NONE}
        Append To List    ${devices}    TPM
    END

    Should Contain    ${out}
    ...    @{devices}

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
    ${out}=    Execute Command In Terminal    yes n | fwupdmgr local-install ${cabinet} --allow-reinstall --allow-older
    Should Contain    ${out}    Successfully installed firmware

Fwupd LVFS Firmware Update Linux
    Switch To Root User
    Execute Command In Terminal    printf '[fwupd]\\nOnlyTrusted=true\\n' | sudo tee /etc/fwupd/fwupd.conf
    Execute Command In Terminal    fwupdmgr refresh

    VAR    ${id_extract_command}=
    ...    fwupdmgr get-devices 2>/dev/null
    ...    grep -A1 "System Firmware"
    ...    grep "Device ID"
    ...    awk '{print $NF}'
    ...    separator= |
    ${firmware_id}=    Execute Command In Terminal    ${id_extract_command}
    ${out}=    Execute Command In Terminal    yes n | fwupdmgr install ${firmware_id} --allow-reinstall --allow-older

    Should Not Contain    ${out}    failed to find    ignore_case=${True}
    Should Not Contain    ${out}    No updatable devices    ignore_case=${True}
    Should Not Contain    ${out}    No releases found    ignore_case=${True}
    Should Not Contain    ${out}    no devices    ignore_case=${True}
    Should Contain    ${out}    Successfully installed firmware    ignore_case=${True}
