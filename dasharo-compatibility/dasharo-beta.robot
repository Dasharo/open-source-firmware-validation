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
Resource            ../lib/fwupd.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated    semiauto


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
    Execute Reboot Command
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Fwupd Verify Update Results Linux

DBETA002.201 Dasharo Beta LVFS Downgrade (Ubuntu)
    [Documentation]    Check whether Dasharo Beta firmware can be downgraded
    ...    back to the stable version on Ubuntu, using `fwupdmgr downgrade
    ...    --no-safety-check`. Skips if `fwupdmgr downgrade` finds no
    ...    candidate on the stable remote.
    ...    Assumes the device is currently running a Dasharo Beta release
    ...    (i.e. DBETA001.201 was run first).
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DBETA002.201 (Ubuntu) not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DBETA002.201 (Ubuntu) not supported
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Fwupd Get Version Linux
    Fwupd Get FW DeviceID Linux
    ${out}=    Run Fwupd Update With Battery Check Workaround    Fwupd Run Downgrade Linux
    Should Contain    ${out}    Successfully installed firmware    ignore_case=${True}
    Execute Reboot Command
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
    Execute Reboot Command
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Fwupd Verify Update Results Linux

DBETA002.202 Dasharo Beta LVFS Downgrade (Fedora)
    [Documentation]    Check whether Dasharo Beta firmware can be downgraded
    ...    back to the stable version on Fedora, using `fwupdmgr downgrade
    ...    --no-safety-check`. Skips if `fwupdmgr downgrade` finds no
    ...    candidate on the stable remote.
    ...    Assumes the device is currently running a Dasharo Beta release
    ...    (i.e. DBETA001.202 was run first).
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DBETA002.202 (Fedora) not supported
    Skip If
    ...    '${POWER_CTRL}'=='none' and ${INCLUDE_TAGS} and 'semiauto' not in ${INCLUDE_TAGS}
    ...    Semiauto tag not in scope (-i flag)
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Fwupd Get Version Linux
    Fwupd Get FW DeviceID Linux
    ${out}=    Run Fwupd Update With Battery Check Workaround    Fwupd Run Downgrade Linux
    Should Contain    ${out}    Successfully installed firmware    ignore_case=${True}
    Execute Reboot Command
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Fwupd Verify Update Results Linux
