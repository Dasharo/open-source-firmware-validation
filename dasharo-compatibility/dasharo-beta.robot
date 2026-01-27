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
Resource            ../fwupd-lib.robot

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

DBETA002.202 Dasharo Beta LVFS Downgrade
    [Documentation]    TBD
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
