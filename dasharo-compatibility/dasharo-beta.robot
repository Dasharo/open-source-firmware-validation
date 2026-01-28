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
Resource            ../lib/fwupd-lib.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
DBETA001.201 Dasharo Beta LVFS Upgrade
    [Documentation]    TBD
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux

DBETA002.201 Dasharo Beta LVFS Downgrade
    [Documentation]    TBD
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux

DBETA001.202 Dasharo Beta LVFS Upgrade
    [Documentation]    TBD
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Fwupd Get Version Linux
    Depends On Variable    ${FWUPDMGR_VERSION}
#    Log To Console    ${FWUPDMGR_VERSION}
    ${get_devices_out}=    Execute Command In Terminal    fwupdmgr get-devices
    Log To Console    ${get_devices_out}

DBETA002.202 Dasharo Beta LVFS Downgrade
    [Documentation]    TBD
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
