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
Resource            ../lib/performance/cpu.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite    AND
...                     Skip If    not ${CAPSULE_UPDATE_SUPPORT}
...                     AND    Set UEFI Option    MeMode    Disabled (HAP)
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
    [Tags]    semiauto
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Fwupd Local Firmware Update Linux

FWUPD006.201 Fwupd Check Update Results (Ubuntu)
    [Documentation]    Verify result of the firmware update using fwupd
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Fwupd Check Update Results Linux

# FWUPD003 reserved for LVFS update in util/fwupd-support-lvfs.robot

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
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Fwupd Local Firmware Update Linux

FWUPD006.202 Fwupd Check Update Results (Fedora)
    [Documentation]    Verify result of the firmware update using fwupd
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Fwupd Check Update Results Linux

FWUPD004.203 Fwupd Installed (QubesOS)
    [Documentation]    Check if fwupd is installed by verifying version output
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    Fwupd Installed Linux

FWUPD005.203 Fwupd Check For Updates (QubesOS)
    [Documentation]    Check for availability of a new firmware version using fwupd
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    Fwupd Check For Updates Linux

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

FWUPD006.203 Fwupd Check Update Results (QubesOS)
    [Documentation]    Verify result of the firmware update using fwupd
    Execute Manual Step    Power on and boot into QubesOS
    Execute Manual Step    Open dom0 terminal
    Execute Manual Step
    ...    Run `ID=$(fwupdmgr get-devices 2>/dev/null | grep -A1 "System Firmware" | grep "Device ID" | awk '{print $NF}')`
    Execute Manual Step    Run `fwupdmgr get-results $ID`
    Execute Manual Step    Should print `Update State:` with value `Success`


*** Keywords ***
Fwupd Devices Detected Linux
    ${out}=    Execute Command In Terminal    fwupdmgr get-devices --assume-yes

    VAR    @{devices}=    System Firmware    UEFI dbx

    IF    ${TPM_SUPPORTED_VERSION} != ${NONE}
        Append To List    ${devices}    TPM
    END

    Should Contain All    ${out}    @{devices}

Run Fwupd Local Update
    [Arguments]    ${cabinet}
    ${out}=    Execute Command In Terminal
    ...    yes Y | fwupdmgr local-install ${cabinet} --allow-reinstall --allow-older --assume-yes
    ...    timeout=300s
    RETURN    ${out}

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

    IF    ${BATTERY_PRESENT}
        FOR    ${i}    IN RANGE    5
            ${out}=    Run Fwupd Local Update    ${cabinet}
            ${ac_ok}=    Run Keyword And Return Status    Should Not Contain
            ...    ${out}
            ...    AC power
            ...    AC not detected,
            IF    ${ac_ok}    BREAK
            Log
            ...    AC not detected, might be caused by battery charging threshold being triggered, running a stress test
            ...    WARN
            Stress Test    10s
            Sleep    10s
            Stress Test Stop
        END
    ELSE
        ${out}=    Run Fwupd Local Update    ${cabinet}
    END

    Should Contain    ${out}    Successfully installed firmware
    IF    "${POWER_CTRL}"=="none"
        Execute Manual Step    The laptop might stay powered off after update. Power it back on.
    END
    Boot System Or From Connected Disk    ${BOOTED_OS_ID}
    Login To Linux

Fwupd Installed Linux
    ${out}=    Execute Command In Terminal    fwupdmgr --version
    Should Contain    ${out}    org.freedesktop.fwupd

Fwupd Check For Updates Linux
    Execute Command In Terminal    fwupdmgr refresh
    ${out}=    Execute Command In Terminal    fwupdmgr get-updates
    Should Not Contain    ${out}    failed to connect    ignore_case=${True}
    Should Not Contain    ${out}    timed out    ignore_case=${True}
    Should Contain    ${out}    Devices with    ignore_case=${True}

Fwupd Check Update Results Linux
    VAR    ${id_extract_command}=
    ...    fwupdmgr get-devices 2>/dev/null
    ...    grep -A1 "System Firmware"
    ...    grep "Device ID"
    ...    awk '{print $NF}'
    ...    separator= |
    ${firmware_id}=    Execute Command In Terminal    ${id_extract_command}
    ${out}=    Execute Command In Terminal    fwupdmgr get-results ${firmware_id}
    ${state_line}=    Get Lines Containing String    ${out}    Update State:
    Should Contain    ${state_line}    Success
