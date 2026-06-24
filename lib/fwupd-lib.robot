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
    ${get_devices_out}=    Execute Command In Terminal    fwupdmgr get-devices --no-unreported-check
    ${device_id}=    Get Regexp Matches
    ...    ${get_devices_out}
    ...    (?s)System Firmware:.*?Device ID:\\s*(\\w+)
    ...    1
    IF    len(${device_id}) == 0
        ${device_id}=    Get Regexp Matches
        ...    ${get_devices_out}
        ...    (?s)UEFI Device Firmware:.*?Device ID:\\s*(\\w+)
        ...    1
    END
    VAR    ${FWUPDMGR_DEVICE_ID}=    ${device_id[0]}    scope=TEST

Fwupd Enable LVFS Testing Remote
    [Documentation]    Enable the LVFS Testing remote to allow access to
    ...    Dasharo Beta pre-release firmware.
    Execute Command In Terminal    yes Y | fwupdmgr enable-remote lvfs-testing --assume-yes

Fwupd Refresh Metadata Linux
    [Documentation]    Refresh fwupd metadata from all enabled remotes.
    Execute Command In Terminal    yes Y | fwupdmgr refresh

Fwupd Run Upgrade Linux
    [Documentation]    Upgrade firmware to the latest available version using
    ...    fwupdmgr update. Intended for use with the LVFS Testing remote
    ...    enabled to install Dasharo Beta releases.
    ${out}=    Execute Command In Terminal
    ...    yes Y | fwupdmgr update --assume-yes    timeout=300s
    ${efivarfs_error}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    failed to write data to efivarfs
    IF    ${efivarfs_error}
        Fail    Firmware update failed: EFI variable write error (efivarfs). Check free NVRAM space on the device.
    END
    ${no_updates}=    Run Keyword And Return Status
    ...    Should Contain Any    ${out}    Nothing to do    No upgrades for    nothing to update
    IF    ${no_updates}
        Log To Console
        ...    WARNING: fwupdmgr found no beta firmware available for this device. The LVFS Testing remote may not have a beta release for the current firmware version.
    END
    RETURN    ${out}

Fwupd Run Downgrade Linux
    [Documentation]    Downgrade firmware to the previous stable release using
    ...    `fwupdmgr downgrade`, which resolves the candidate from the stable
    ...    LVFS remote's release history (that remote, unlike lvfs-testing,
    ...    retains prior stable releases). `--no-safety-check` is passed
    ...    because the safety check can report the ESP/disk as busy on
    ...    Qubes-managed DUTs even when the downgrade is otherwise safe to
    ...    perform. The interactive device selection menu, version selection
    ...    menu, and reboot confirmation prompt are answered by piping "1",
    ...    "1", "y". fwupdmgr refuses to prompt at all (fails with "can't
    ...    prompt for devices") if its stdin isn't a real TTY, so the command
    ...    is wrapped in `script` to give it a pseudo-terminal while still
    ...    allowing the piped answers to reach it.
    ...    Unlike the upgrade flow, answering "y" to the reboot confirmation
    ...    makes the DUT reboot on its own, which may cut the current
    ...    SSH/Telnet session mid-command - callers must tolerate that
    ...    connection loss instead of treating it as a failure. Sets the test
    ...    variable ${DOWNGRADE_ALREADY_REBOOTED} to ${TRUE} in that case, so
    ...    callers know not to trigger another reboot themselves.
    ...    If no downgrade candidate is found (e.g. the stable remote hasn't
    ...    indexed a previous release for this platform yet) and a stable
    ...    cabinet path is given, falls back to `fwupdmgr local-install` with
    ...    that cabinet, which does NOT reboot on its own - in that case
    ...    ${DOWNGRADE_ALREADY_REBOOTED} is set to ${FALSE}.
    [Arguments]    ${cabinet}=${EMPTY}
    VAR    ${DOWNGRADE_ALREADY_REBOOTED}=    ${TRUE}    scope=TEST
    ${out}=    Execute Command In Terminal
    ...    printf '1\\n1\\ny\\n' | script -qec 'fwupdmgr downgrade --no-safety-check' /dev/null
    ...    timeout=300s
    ${no_downgrade}=    Run Keyword And Return Status
    ...    Should Contain Any    ${out}    No downgrades for    No downgrade available
    IF    ${no_downgrade}
        IF    '${cabinet}' == '${EMPTY}'
            Skip
            ...    No downgrade candidate found via fwupdmgr downgrade, and no stable cabinet fallback provided
        END
        Log
        ...    fwupdmgr downgrade found no candidate on the stable remote, falling back to local-install with ${cabinet}
        ...    WARN
        VAR    ${DOWNGRADE_ALREADY_REBOOTED}=    ${FALSE}    scope=TEST
        ${out}=    Execute Command In Terminal
        ...    yes Y | fwupdmgr local-install ${cabinet} --allow-reinstall --allow-older --assume-yes --force
        ...    timeout=300s
    END
    RETURN    ${out}

Fwupd Verify Update Results Linux
    [Documentation]    Verify that the last firmware update completed
    ...    successfully by checking fwupdmgr get-results.
    Depends On Variable    ${FWUPDMGR_DEVICE_ID}
    ${out}=    Execute Command In Terminal    fwupdmgr get-results ${FWUPDMGR_DEVICE_ID} --no-unreported-check
    ${state_line}=    Get Lines Containing String    ${out}    Update State:
    ${is_failed}=    Run Keyword And Return Status    Should Contain    ${state_line}    Failed
    IF    ${is_failed}
        Log To Console
        ...    WARNING: fwupdmgr reports Update State: Failed. The LVFS Testing remote may not have a beta firmware release available for this device/version.
    END
    Should Contain    ${state_line}    Success
