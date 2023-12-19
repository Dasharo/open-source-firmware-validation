*** Settings ***
Library    Collections

Resource    ../keywords.robot

*** Keywords ***
Get Linux Version ID
    [Documentation]    This keyword return the linux version
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        ${output}=    SSHLibrary.Execute Command    sh -c "cat /etc/os-release | grep VERSION_ID | cut -d '=' -f 2"
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        ${output}=    Telnet.Execute Command    sh -c "cat /etc/os-release | grep VERSION_ID | cut -d '=' -f 2"
        ${output}=    Get Line    ${output}    0
    ELSE
        FAIL    Connection method not supported for checking version
    END
    RETURN    ${output}

Check Unexpected Boot Errors
    [Documentation]    This keyword checks if any unexpected boot messages
    ...    appear in kernel logs. Messages with loglevel 3 (error) or lower
    ...    (more critical) are considered.
    @{dmesg_err_allowlist}=    Create List
    # Harmless error on Bluetooth modules
    Append To List    ${dmesg_err_allowlist}    Bluetooth: hci0: Malformed MSFT vendor event: 0x02
    # dmesg -J requires util-linux v2.38 or newer
    ${dmesg_err_txt}=    Execute Linux Command    dmesg -t -l err,crit,alert,emerg
    @{dmesg_err_list}=    Split To Lines    ${dmesg_err_txt}
    FOR    ${error}    IN    @{dmesg_err_list}
        Should Contain    @{dmesg_err_allowlist}    ${error}
    END
