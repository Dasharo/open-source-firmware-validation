*** Settings ***
Documentation       Library for using fwupdmgr

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             SSHLibrary
Resource            ../keywords.robot


*** Keywords ***
Fwupd Get Version Linux
    [Documentation]    Retrieve version of fwupdmgr, set FWUPDMGR_VERSION
    ...    variable. FAIL if empty.
    ${fwupdmgr_out}=    Execute Command In Terminal    fwupdmgr --version | grep org.freedesktop.fwupd-efi
    ${fwupdmgr_ver}=    Get Regexp Matches    ${fwupdmgr_out}    runtime\\s+org.freedesktop.fwupd-efi\\s+(\\d+.\\d+)    1
    Should Not be Empty    ${fwupdmgr_ver}    fwupdmgr version can't be retrieved.
    VAR    ${FWUPDMGR_VERSION}=    ${fwupdmgr_ver[0]}    scope=TEST
    Should Not Be Empty    ${FWUPDMGR_VERSION}
