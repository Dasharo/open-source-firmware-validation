*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for fwupd tests

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/performance/cpu.robot


*** Keywords ***
Run Fwupd Update With Battery Check Workaround
    [Documentation]    The battery check used by fwupd thinks that the AC is
    ...    disconnected if the battery charge threshold is reached and its
    ...    not being charged anymore. To work this around we need to discharge
    ...    the battery a bit.
    [Arguments]    ${update_keyword}    @{args}
    # BATTERY_PRESENT might not exist for non-laptop devices
    ${battery}=    Get Variable Value    ${BATTERY_PRESENT}    ${FALSE}
    # Trigger workaround if the device is battery powered
    IF    ${battery}
        FOR    ${i}    IN RANGE    5
            ${out}=    Run Keyword    ${update_keyword}    @{args}
            ${ac_ok}=    Run Keyword And Return Status    Should Not Contain Any
            ...    ${out}
            ...    AC power
            ...    AC not detected
            ...    is not currently updatable
            IF    ${ac_ok}    BREAK
            Log
            ...    AC not detected, might be caused by battery charging threshold being triggered, running a stress test
            ...    WARN
            Stress Test    30s
            Sleep    30s
            Stress Test Stop
        END
    ELSE
        ${out}=    Run Keyword    ${update_keyword}    @{args}
        Sleep    10s
    END
    RETURN    ${out}

Run Fwupd Local Install
    [Documentation]    Install firmware from a local cabinet file using
    ...    fwupdmgr local-install, allowing reinstall of the same or an
    ...    older version. Does not reboot on its own the caller reboots
    ...    explicitly to apply it.
    [Arguments]    ${cabinet}
    ${out}=    Execute Command In Terminal
    ...    yes Y | fwupdmgr local-install ${cabinet} --allow-reinstall --allow-older --no-reboot-check --force
    ...    timeout=300s
    RETURN    ${out}

Fwupd Get Version Linux
    [Documentation]    Retrieve version of fwupdmgr, set FWUPDMGR_VERSION
    ...    test variable. FAIL if empty.
    ${fwupdmgr_out}=    Execute Command In Terminal    fwupdmgr --version | grep org.freedesktop.fwupd-efi
    ${fwupdmgr_ver}=    Get Regexp Matches
    ...    ${fwupdmgr_out}
    ...    runtime\\s+org.freedesktop.fwupd-efi\\s+(\\d+\\.\\d+)
    ...    1
    Should Not Be Empty    ${fwupdmgr_ver}    fwupdmgr version can't be retrieved.
    VAR    ${FWUPDMGR_VERSION}=    ${fwupdmgr_ver[0]}    scope=TEST
    Should Not Be Empty    ${FWUPDMGR_VERSION}

Fwupd Get FW DeviceID Linux
    [Documentation]    Retrieve System Firmware Device ID. Initial version,
    ...    may need different regexes in different stages and/or fwupdmgr
    ...    versions.
    Depends On Variable    \${FWUPDMGR_VERSION}
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
    ...    enabled to install Dasharo Beta releases. Does not reboot on its
    ...    own the caller reboots explicitly to apply it.
    ${out}=    Execute Command In Terminal
    ...    yes Y | fwupdmgr update --assume-yes --no-reboot-check    timeout=300s
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
    [Documentation]    Downgrade firmware to the previous stable release via
    ...    `fwupdmgr downgrade`. Skips the test if no downgrade candidate is
    ...    found on the stable remote. Does not reboot on its own the caller
    ...    reboots explicitly to apply it.
    Depends On Variable    \${FWUPDMGR_DEVICE_ID}
    # --no-safety-check: that check can report the ESP/disk busy on
    # Qubes-managed DUTs even when the downgrade is safe.
    # ${FWUPDMGR_DEVICE_ID} is passed explicitly so downgrade targets that
    # device directly instead of prompting to choose one - fwupdmgr's device
    # list order isn't guaranteed to put the right device first.
    # --no-reboot-check: don't let fwupd reboot on its own - the caller reboots
    # explicitly so we keep control of the connection.
    # Wrapped in `script` because downgrade still prompts for the release
    # version, and fwupdmgr refuses to prompt at all without a real TTY. The
    # piped "1" picks the release; the trailing "y" answers any remaining
    # confirmation prompt.
    ${out}=    Execute Command In Terminal
    ...    printf '1\\ny\\n' | script -qec 'fwupdmgr downgrade ${FWUPDMGR_DEVICE_ID} --no-safety-check --no-reboot-check' /dev/null
    ...    timeout=300s
    ${no_downgrade}=    Run Keyword And Return Status
    ...    Should Contain Any    ${out}    No downgrades for    No downgrade available
    IF    ${no_downgrade}
        Skip    No downgrade candidate found via fwupdmgr downgrade
    END
    RETURN    ${out}

Fwupd Verify Update Results Linux
    [Documentation]    Verify that the last firmware update completed
    ...    successfully by checking fwupdmgr get-results for ${device_id},
    ...    or for ${FWUPDMGR_DEVICE_ID} if ${device_id} is not given.
    [Arguments]    ${device_id}=${EMPTY}
    IF    '${device_id}' == '${EMPTY}'
        Depends On Variable    \${FWUPDMGR_DEVICE_ID}
        VAR    ${device_id}=    ${FWUPDMGR_DEVICE_ID}
    END
    ${out}=    Execute Command In Terminal    fwupdmgr get-results ${device_id} --no-unreported-check
    ${state_line}=    Get Lines Containing String    ${out}    Update State:
    ${is_failed}=    Run Keyword And Return Status    Should Contain    ${state_line}    Failed
    IF    ${is_failed}
        Log To Console
        ...    WARNING: fwupdmgr reports Update State: Failed. The LVFS Testing remote may not have a beta firmware release available for this device/version.
    END
    Should Contain    ${state_line}    Success
