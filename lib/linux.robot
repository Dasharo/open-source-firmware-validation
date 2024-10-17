*** Settings ***
Library     Collections
Resource    ../keywords.robot


*** Keywords ***
Get Linux Version ID
    [Documentation]    This keyword returns the linux version.
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        ${output}=    SSHLibrary.Execute Command    sh -c "cat /etc/os-release | grep VERSION_ID | cut -d '=' -f 2"
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        ${output}=    Telnet.Execute Command    sh -c "cat /etc/os-release | grep VERSION_ID | cut -d '=' -f 2"
        ${output}=    Get Line    ${output}    0
    ELSE
        FAIL    Connection method not supported for checking version
    END
    RETURN    ${output}

Get Utility Version
    [Documentation]    This keyword checks whether a utility is available in the
    ...    system and logs it's version.
    [Arguments]    ${utility}
    ${output}=    Telnet.Execute Command    ${utility} --version
    Log    ${output}
    ${output}=    Telnet.Execute Command    echo $?
    ${output}=    Get Line    ${output}    0
    Should Be Equal As Strings    ${output}    0

Check Unexpected Boot Errors
    [Documentation]    This keyword checks if any unexpected boot messages
    ...    appear in kernel logs. Messages with loglevel 3 (error) or lower
    ...    (more critical) are considered.
    @{dmesg_err_allowlist}=    Create List
    # Harmless error on Bluetooth modules
    Append To List    ${dmesg_err_allowlist}    Bluetooth: hci0: Malformed MSFT vendor event: 0x02
    # Not a critical error, appears on many machines
    Append To List    ${dmesg_err_allowlist}    tpm tpm0: [Firmware Bug]: TPM interrupt not working, polling instead
    # Intel AX-series WiFi+BT adapters throw these when debug features are disabled
    Append To List    ${dmesg_err_allowlist}    Bluetooth: hci0: No support for _PRR ACPI method
    Append To List    ${dmesg_err_allowlist}    iwlwifi 0000:00:14.3: WRT: Invalid buffer destination
    Append To List
    ...    ${dmesg_err_allowlist}
    ...    iwlwifi 0000:00:14.3: Not valid error log pointer 0x0027B0C0 for RT uCode
    # GSC firmware loading via MEI fails when ME is disabled - not our bug
    Append To List
    ...    ${dmesg_err_allowlist}
    ...    i915 0000:00:02.0: [drm] *ERROR* GT1: GSC proxy component didn't bind within the expected timeout
    Append To List    ${dmesg_err_allowlist}    i915 0000:00:02.0: [drm] *ERROR* GT1: GSC proxy handler failed to init
    # Not our bug
    Append To List    ${dmesg_err_allowlist}    proc_thermal_pci 0000:00:04.0: error: proc_thermal_add, will continue
    ${dmesg_err_txt}=    Execute Linux Command    dmesg -t -l err,crit,alert,emerg
    @{dmesg_err_list}=    Split To Lines    ${dmesg_err_txt}
    FOR    ${error}    IN    @{dmesg_err_list}
        Should Contain    ${dmesg_err_allowlist}    ${error}
    END
