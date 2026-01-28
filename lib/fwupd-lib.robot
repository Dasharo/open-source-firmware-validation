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
    ...    test variable. FAIL if empty.
    ${fwupdmgr_out}=    Execute Command In Terminal    fwupdmgr --version | grep org.freedesktop.fwupd-efi
    ${fwupdmgr_ver}=    Get Regexp Matches
    ...    ${fwupdmgr_out}
    ...    runtime\\s+org.freedesktop.fwupd-efi\\s+(\\d+.\\d+)
    ...    1
    Should Not Be Empty    ${fwupdmgr_ver}    fwupdmgr version can't be retrieved.
    VAR    ${FWUPDMGR_VERSION}=    ${fwupdmgr_ver[0]}    scope=TEST
    Should Not Be Empty    ${FWUPDMGR_VERSION}

Fwupd Get FW DeviceID Linux
    [Documentation]    Retrieve System Firmware Device ID. Initial version,
    ...    may need different regexes in different stages and/or fwupdmgr
    ...    versions.
    Depends On Variable    ${FWUPDMGR_VERSION}
    ${get_devices_out}=    Execute Command In Terminal    fwupdmgr get-devices
    ${device_id}=    Get Regexp Matches
    ...    ${get_devices_out}
    ...    System Firmware:\\r\\n.*Device ID:\\s*(\\w+)\\r\\n
    ...    1
    VAR    ${FWUPDMGR_DEVICE_ID}=    ${device_id[0]}    scope=TEST
