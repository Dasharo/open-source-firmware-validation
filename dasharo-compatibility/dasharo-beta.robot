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
Resource            ../lib/fwupd-lib.robot
Resource            ../lib/fwupd.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated    semiauto


*** Variables ***
${STABLE_CABINET_ENVVAR}=       DASHARO_STABLE_CABINET_FILE


*** Test Cases ***
DBETA001.201 Dasharo Beta LVFS Upgrade (Ubuntu)
    [Documentation]    Check whether Dasharo Beta firmware can be updated from
    ...    the LVFS Testing remote using fwupdmgr on Ubuntu. Enables the
    ...    lvfs-testing remote, refreshes metadata, then runs fwupdmgr update
    ...    and verifies the update was applied successfully after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DBETA001.201 (Ubuntu) not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DBETA001.201 (Ubuntu) not supported
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Fwupd Get Version Linux
    Fwupd Enable LVFS Testing Remote
    Fwupd Refresh Metadata Linux
    Fwupd Get FW DeviceID Linux
    ${out}=    Run Fwupd Update With Battery Check Workaround    Fwupd Run Upgrade Linux
    Should Contain    ${out}    Successfully installed firmware    ignore_case=${True}
    IF    "${POWER_CTRL}"=="none"
        Execute Manual Step    The laptop might stay powered off after update. Power it back on.
    END
    Write Bare    systemctl reboot\n
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Fwupd Verify Update Results Linux

DBETA002.201 Dasharo Beta LVFS Downgrade (Ubuntu)
    [Documentation]    Check whether Dasharo Beta firmware can be downgraded
    ...    back to the stable version on Ubuntu, using `fwupdmgr downgrade
    ...    --no-safety-check`. If a known-good stable cabinet file is provided
    ...    via ${STABLE_CABINET_ENVVAR}, it is sent to the DUT and used as a
    ...    `fwupdmgr local-install` fallback in case `fwupdmgr downgrade`
    ...    finds no candidate on the stable remote.
    ...    Assumes the device is currently running a Dasharo Beta release
    ...    (i.e. DBETA001.201 was run first).
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DBETA002.201 (Ubuntu) not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DBETA002.201 (Ubuntu) not supported
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    ${cabinet_given}=    Run Keyword And Return Status
    ...    Get Environment Variable    ${STABLE_CABINET_ENVVAR}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Fwupd Get Version Linux
    Fwupd Get FW DeviceID Linux
    VAR    ${cabinet}=    ${EMPTY}
    IF    ${cabinet_given}
        ${stable_cabinet}=    Get Environment Variable    ${STABLE_CABINET_ENVVAR}
        VAR    ${cabinet}=    ~/dasharo_stable.cab
        Send File To DUT    ${stable_cabinet}    target_path=${cabinet}
    END
    # fwupdmgr downgrade may reboot the DUT on its own (see Fwupd Run
    # Downgrade Linux), cutting this connection before or after the success
    # message - either is fine, we just don't Fail on the lost connection.
    ${status}    ${out}=    Run Keyword And Ignore Error
    ...    Run Fwupd Update With Battery Check Workaround    Fwupd Run Downgrade Linux    ${cabinet}
    IF    '${status}' == 'PASS'
        Should Contain    ${out}    Successfully installed firmware    ignore_case=${True}
    ELSE
        Log
        ...    fwupdmgr downgrade lost the connection, assuming it triggered its own reboot: ${out}
        ...    WARN
    END
    IF    "${POWER_CTRL}"=="none"
        Execute Manual Step    The laptop might stay powered off after downgrade. Power it back on.
    END
    IF    not ${DOWNGRADE_ALREADY_REBOOTED}    Write Bare    systemctl reboot\n
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Fwupd Verify Update Results Linux

DBETA001.202 Dasharo Beta LVFS Upgrade (Fedora)
    [Documentation]    Check whether Dasharo Beta firmware can be updated from
    ...    the LVFS Testing remote using fwupdmgr on Fedora. Enables the
    ...    lvfs-testing remote, refreshes metadata, then runs fwupdmgr update
    ...    and verifies the update was applied successfully after reboot.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DBETA001.202 (Fedora) not supported
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Fwupd Get Version Linux
    Fwupd Enable LVFS Testing Remote
    Fwupd Refresh Metadata Linux
    Fwupd Get FW DeviceID Linux
    ${out}=    Run Fwupd Update With Battery Check Workaround    Fwupd Run Upgrade Linux
    Should Contain    ${out}    Successfully installed firmware    ignore_case=${True}
    IF    "${POWER_CTRL}"=="none"
        Execute Manual Step    The laptop might stay powered off after update. Power it back on.
    END
    Write Bare    systemctl reboot\n
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Fwupd Verify Update Results Linux

DBETA002.202 Dasharo Beta LVFS Downgrade (Fedora)
    [Documentation]    Check whether Dasharo Beta firmware can be downgraded
    ...    back to the stable version on Fedora, using `fwupdmgr downgrade
    ...    --no-safety-check`. If a known-good stable cabinet file is provided
    ...    via ${STABLE_CABINET_ENVVAR}, it is sent to the DUT and used as a
    ...    `fwupdmgr local-install` fallback in case `fwupdmgr downgrade`
    ...    finds no candidate on the stable remote.
    ...    Assumes the device is currently running a Dasharo Beta release
    ...    (i.e. DBETA001.202 was run first).
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DBETA002.202 (Fedora) not supported
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    ${cabinet_given}=    Run Keyword And Return Status
    ...    Get Environment Variable    ${STABLE_CABINET_ENVVAR}
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Fwupd Get Version Linux
    Fwupd Get FW DeviceID Linux
    VAR    ${cabinet}=    ${EMPTY}
    IF    ${cabinet_given}
        ${stable_cabinet}=    Get Environment Variable    ${STABLE_CABINET_ENVVAR}
        VAR    ${cabinet}=    ~/dasharo_stable.cab
        Send File To DUT    ${stable_cabinet}    target_path=${cabinet}
    END
    # fwupdmgr downgrade may reboot the DUT on its own (see Fwupd Run
    # Downgrade Linux), cutting this connection before or after the success
    # message - either is fine, we just don't Fail on the lost connection.
    ${status}    ${out}=    Run Keyword And Ignore Error
    ...    Run Fwupd Update With Battery Check Workaround    Fwupd Run Downgrade Linux    ${cabinet}
    IF    '${status}' == 'PASS'
        Should Contain    ${out}    Successfully installed firmware    ignore_case=${True}
    ELSE
        Log
        ...    fwupdmgr downgrade lost the connection, assuming it triggered its own reboot: ${out}
        ...    WARN
    END
    IF    "${POWER_CTRL}"=="none"
        Execute Manual Step    The laptop might stay powered off after downgrade. Power it back on.
    END
    IF    not ${DOWNGRADE_ALREADY_REBOOTED}    Write Bare    systemctl reboot\n
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Fwupd Verify Update Results Linux
