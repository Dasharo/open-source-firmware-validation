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
    # dmesg -J requires util-linux v2.38 or newer
    ${dmesg_err_txt}=    Execute Linux Command    dmesg -t -l err,crit,alert,emerg
    @{dmesg_err_list}=    Split To Lines    ${dmesg_err_txt}
    FOR    ${error}    IN    @{dmesg_err_list}
        Should Contain    @{dmesg_err_allowlist}    ${error}
    END

Stop Logging To Terminal
    [Documentation]    This keyword stops all unwanted logging to the terminal
    ...    we're using for the shell. This prevents garbage from being logged.
    Execute Linux Command    sed -i 's/#ForwardToConsole=no/ForwardToConsole=no/g' /etc/systemd/journald.conf
    Execute Linux Command    echo 0 > /proc/sys/kernel/printk
    Execute Linux Command    systemctl restart systemd-journald
