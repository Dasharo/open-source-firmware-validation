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
Resource            ../lib/fwupd.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    Tests in Windows not supported
...                     AND    Skip If    not ${CAPSULE_UPDATE_V2_SUPPORT}    Capsule Update V2 not supported
...                     AND    Ensure RC0 Firmware Is Present
...                     AND    Flash Firmware    ${CAPSULE_UPDATE_RC0_FW_FILE}
...                     AND    Run Keyword If    ${DASHARO_INTEL_ME_MENU_SUPPORT}
...                     Set UEFI Option    MeMode    Disabled (HAP)
...                     AND    Install Fwupd Windows If Provided
Suite Teardown      Run Keywords
...                     Run Keyword If    '${SUITE_STATUS}' != 'SKIP'    Flash Firmware    ${FW_FILE}
...                     AND    Log Out And Close Connection

Default Tags        automated


*** Variables ***
${CABINET_ENVVAR}=                  FWUPD_CABINET_FILE
${MSI_ENVVAR}=                      FWUPD_MSI_FILE

# To be read from environment variables
${CAPSULE_UPDATE_RC0_FW_FILE}=      ${NONE}


*** Test Cases ***
FWUPD004.301 Fwupd Installed (Windows)
    [Documentation]    Check if fwupd is installed by verifying version output
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    FWUPD004.301 not supported
    Power On
    Boot And Login To OS    ${ENV_ID_WINDOWS}
    Fwupd Installed Windows

FWUPD001.301 Fwupd Devices Detected (Windows)
    [Documentation]    Test if the supported hardware is properly detected
    ...    by fwupd
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    FWUPD001.301 not supported
    Power On
    Boot And Login To OS    ${ENV_ID_WINDOWS}
    Fwupd Devices Detected Windows

FWUPD002.301 Fwupd Local Firmware Update (Windows)
    [Documentation]    Test if a firmware update can be performed using fwupd
    ...    using local unsigned cabinet
    [Tags]    automated    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    FWUPD002.301 not supported
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    Power On
    Boot And Login To OS    ${ENV_ID_WINDOWS}
    Fwupd Local Firmware Update Windows

FWUPD006.301 Fwupd Check Update Results (Windows)
    [Documentation]    Verify result of the firmware update using the ESRT
    [Tags]    automated    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    FWUPD006.301 not supported
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    Power On
    Boot And Login To OS    ${ENV_ID_WINDOWS}
    Fwupd Check Update Results Windows


*** Keywords ***
Fwupd Installed Windows
    ${out}=    Execute Command In Terminal    fwupdtool --version
    Should Contain    ${out}    org.freedesktop.fwupd

Fwupd Devices Detected Windows
    Fwupd Get FW DeviceID Windows
    ${esrt}=    Get System Firmware ESRT Entry Windows
    Should Not Be Equal    ${esrt}[version]    00000000

Fwupd Local Firmware Update Windows
    ${cabinet_given}=    Run Keyword And Return Status
    ...    Get Environment Variable    ${CABINET_ENVVAR}
    IF    not ${cabinet_given}
        Skip    ${CABINET_ENVVAR} environment variable not defined
    END
    ${fwupd_cabinet}=    Get Environment Variable    ${CABINET_ENVVAR}

    ${cabinet}=    Get Windows Home Path    fwupd_cabinet.cab
    SSHLibrary.Put File    ${fwupd_cabinet}    ${cabinet}    scp=ALL
    Fwupd Clear History Windows
    ${esrt}=    Get System Firmware ESRT Entry Windows
    VAR    ${ESRT_VERSION_BEFORE_UPDATE}=    ${esrt}[version]    scope=SUITE

    ${out}=    Run Fwupd Local Install Windows    ${cabinet}
    Should Contain    ${out}    Successfully installed firmware
    IF    '${INITIAL_DUT_CONNECTION_METHOD}' == 'SSH'
        ${booted}=    Run Keyword And Return Status    Boot And Login To OS    ${DEFAULT_BOOT_OS_ID}
        IF    not ${booted}
            Recover From Capsule Failure Screen
            Fail    DUT did not boot after the update, the capsule was most likely rejected
        END
    ELSE
        Execute Reboot Command    ${ENV_ID_WINDOWS}
        Restore Initial DUT Connection Method
        ${prev_timeout}=    Set DUT Response Timeout    500s
        ${screen}=    Read From Terminal Until    ENTER to reboot
        Set DUT Response Timeout    ${prev_timeout}
        Sleep    3s
        Press Key N Times    1    ${ENTER}
        Should Contain    ${screen}    Firmware Update Succeeded
    END

Recover From Capsule Failure Screen
    [Documentation]    A failed update stops on a result screen that waits
    ...    for ENTER. Power cycle the DUT, or ask to press ENTER without
    ...    power control.
    IF    '${POWER_CTRL}'=='none'
        Execute Manual Step
        ...    DUT did not boot after the update. Note the result screen on the DUT and press ENTER there.
    ELSE
        Power On
    END

Fwupd Check Update Results Windows
    ${esrt}=    Get System Firmware ESRT Entry Windows
    Should Not Be Equal    ${esrt}[version]    ${ESRT_VERSION_BEFORE_UPDATE}
    ...    msg=ESRT version is still the RC0 version 0x${ESRT_VERSION_BEFORE_UPDATE}, the capsule was not applied

Ensure RC0 Firmware Is Present
    ${rc0}=    Get Environment Variable    name=CAPSULE_UPDATE_RC0_FW_FILE
    VAR    ${CAPSULE_UPDATE_RC0_FW_FILE}=    ${rc0}    scope=SUITE
    OperatingSystem.File Should Exist
    ...    ${CAPSULE_UPDATE_RC0_FW_FILE}
    ...    CAPSULE_UPDATE_RC0_FW_FILE env variable does not point to a file! CAPSULE_UPDATE_RC0_FW_FILE="${CAPSULE_UPDATE_RC0_FW_FILE}"

Install Fwupd Windows If Provided
    ${msi_given}=    Run Keyword And Return Status
    ...    Get Environment Variable    ${MSI_ENVVAR}
    IF    not ${msi_given}    RETURN
    ${fwupd_msi}=    Get Environment Variable    ${MSI_ENVVAR}

    Power On
    Boot And Login To OS    ${ENV_ID_WINDOWS}
    ${msi}=    Get Windows Home Path    fwupd-setup.msi
    SSHLibrary.Put File    ${fwupd_msi}    ${msi}    scp=ALL
    ${msi}=    Replace String    ${msi}    /    \\
    ${exit_code}=    Execute Command In Terminal
    ...    (Start-Process msiexec -ArgumentList '/i','${msi}','/qn','/norestart','/l*v','${msi}.log' -Wait -PassThru).ExitCode
    ...    timeout=300s
    ${installed}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${exit_code}    (?m)^\\s*(0|3010)\\s*$
    IF    not ${installed}
        ${msi_log}=    Execute Command In Terminal
        ...    Select-String -Path '${msi}.log' -Pattern 'Return value 3' -Context 20,0 | Out-String -Width 400
        Fail    fwupd MSI install failed with exit code ${exit_code}:\n${msi_log}
    END
    Boot And Login To OS    ${DEFAULT_BOOT_OS_ID}

Get Windows Home Path
    [Arguments]    ${file_name}
    RETURN    C:/Users/${DEVICE_OS_USERNAME}/${file_name}
