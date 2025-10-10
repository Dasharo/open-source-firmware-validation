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
...                     Skip If    not ${CAPSULE_UPDATE_SUPPORT}    AND
...                     Set UEFI Option    MeMode    Disabled (HAP)
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        semiauto


*** Variables ***
${CABINET_ENVVAR}=      FWUPD_CABINET_FILE


*** Test Cases ***
FWUPD003.201 Fwupd LVFS Firmware Update (Ubuntu)
    [Documentation]    Test if a firmware update can be performed using fwupd
    ...    and a signed cabinet from LVFS
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Fwupd LVFS Firmware Update Linux

FWUPD003.202 Fwupd LVFS Firmware Update (Fedora)
    [Documentation]    Test if a firmware update can be performed using fwupd
    ...    and a signed cabinet from LVFS
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Fwupd LVFS Firmware Update Linux

FWUPD003.203 Fwupd LVFS Firmware Update (QubesOS)
    [Documentation]    Test if a firmware update can be performed using fwupd
    ...    and a signed cabinet from LVFS
    Execute Manual Step    Power on and boot into QubesOS
    Execute Manual Step    Open dom0 terminal
    Execute Manual Step
    ...    Run `export ID=$(fwupdmgr get-devices 2>/dev/null | grep -A1 "System Firmware" | grep "Device ID" | awk '{print $NF}')`
    Execute Manual Step    Run `yes n | fwupdmgr install \$ID --allow-reinstall --allow-older`
    Execute Manual Step
    ...    Should not print any of: `failed to find`, `No updatable devices`, `No releases found`, `no devices`
    Execute Manual Step    Should print `Successfully installed firmware`


*** Keywords ***
Fwupd LVFS Firmware Update Linux
    ${username}=    Get Environment Variable    LVFS_USERNAME    default=${EMPTY}
    ${password}=    Get Environment Variable    LVFS_PASSWORD    default=${EMPTY}
    IF    "${username}" != "${EMPTY}" and "${password}" != "${EMPTY}"
        VAR    ${use_embargo}=    ${TRUE}
        Log    WARNING: LVFS credentials WILL BE VISIBLE in test logs. Don't share them with anyone.    level=WARN
    ELSE
        VAR    ${use_embargo}=    ${FALSE}
    END
    Switch To Root User
    IF    ${use_embargo}
        Setup Fwupd Embargo Config Linux    ${username}    ${password}
        Execute Command In Terminal    printf '[fwupd]\\nOnlyTrusted=true\\n' > /etc/fwupd/fwupd.conf
    END
    Execute Command In Terminal    fwupdmgr refresh
    VAR    ${id_extract_command}=
    ...    fwupdmgr get-devices 2>/dev/null
    ...    grep -A1 "System Firmware"
    ...    grep "Device ID"
    ...    awk '{print $NF}'
    ...    separator= |
    ${firmware_id}=    Execute Command In Terminal    ${id_extract_command}
    ${out}=    Execute Command In Terminal
    ...    yes Y | fwupdmgr install ${firmware_id} --allow-reinstall --allow-older --assume-yes
    ...    timeout=300s
    Should Not Contain
    ...    ${out}
    ...    AC power
    ...    AC is disconnected, connect AC. (Or its a bug - AC it not detected if internal battery is full. Discharge the battery a bit and try again.)\n\n
    IF    "${POWER_CTRL}"=="none"
        Execute Manual Step    The laptop might stay powered off after update. Power it back on.
    END
    Set DUT Response Timeout    300s
    Boot System Or From Connected Disk    ${BOOTED_OS_ID}
    Login To Linux
    IF    ${use_embargo}    Clean Up Fwupd Embargo Config Linux

    Should Not Contain    ${out}    failed to find    ignore_case=${True}
    Should Not Contain    ${out}    No updatable devices    ignore_case=${True}
    Should Not Contain    ${out}    No releases found    ignore_case=${True}
    Should Not Contain    ${out}    no devices    ignore_case=${True}
    Should Contain    ${out}    Successfully installed firmware    ignore_case=${True}

Setup Fwupd Embargo Config Linux
    [Arguments]    ${username}    ${password}
    VAR    ${embargo_config}=    [fwupd Remote]\\n
    ...    Enabled=true\\n
    ...    Title=Embargoed for 3mdeb\\n
    ...    RefreshInterval=3600\\n
    ...    MetadataURI=https://fwupd.org/downloads/firmware-3c81bfdc9db5c8a42c09d38091944bc1a05b27b0.xml.gz\\n
    ...    ReportURI=https://fwupd.org/lvfs/firmware/report\\n
    ...    OrderBefore=lvfs,fwupd\\n
    ...    Username=${username}
    ...    Password=${password}
    ...    separator=${EMPTY}

    Execute Command In Terminal    printf "${embargo_config}" > /etc/fwupd/remotes.d/3mdeb-embargo.conf

Clean Up Fwupd Embargo Config Linux
    Execute Command In Terminal    rm -f /etc/fwupd/remotes.d/3mdeb-embargo.conf
