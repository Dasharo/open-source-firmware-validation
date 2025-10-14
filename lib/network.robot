*** Settings ***
Documentation       Collection of network-related keywords

Library             String
Library             SSHLibrary
Resource            ../keywords.robot


*** Variables ***
${GET_IP_INTERVAL}=     30s


*** Keywords ***
Send File To DUT Directly
    [Documentation]    Same as Send File To DUT but without any checks,
    ...    permission changes, and temporary files. Can be used to send files
    ...    that won't fit in RAM or /tmp/ directly to e.g. device.
    [Arguments]    ${source_path}    ${target_path}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        IF    '${MANUFACTURER}' == 'QEMU'
            VAR    ${ip_address}=    localhost
            VAR    ${port}=    5222
        ELSE
            Wait Until Keyword Succeeds    5x    ${GET_IP_INTERVAL}
            ...    Get Hostname Ip
            ${ip_address}=    Get Hostname Ip
            VAR    ${port}=    22
        END
        SSHLibrary.Open Connection    ${ip_address}    port=${port}
        SSHLibrary.Login    ${DEVICE_OS_USERNAME}    ${DEVICE_OS_PASSWORD}
        SSHLibrary.Put File    ${source_path}    ${target_path}
        SSHLibrary.Close Connection
    ELSE
        SSHLibrary.Put File    ${source_path}    ${target_path}
    END

Send File To DUT
    [Documentation]    Sends file DUT and saves it at given location
    [Arguments]    ${source_path}    ${target_path}    ${switch_root}=${TRUE}
    ${filename}=    Evaluate    os.path.basename(r"${target_path}")
    VAR    ${tmp_target}=    /tmp/${filename}
    ${hash_source}=    Run    md5sum ${source_path} | cut -d ' ' -f 1
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        IF    '${MANUFACTURER}' == 'QEMU'
            VAR    ${ip_address}=    localhost
            VAR    ${port}=    5222
        ELSE
            Wait Until Keyword Succeeds    5x    ${GET_IP_INTERVAL}
            ...    Get Hostname Ip
            ${ip_address}=    Get Hostname Ip
            VAR    ${port}=    22
        END
        Execute Command In Terminal    rm -f ${target_path}
        SSHLibrary.Open Connection    ${ip_address}    port=${port}
        SSHLibrary.Login    ${DEVICE_OS_USERNAME}    ${DEVICE_OS_PASSWORD}
        SSHLibrary.Put File    ${source_path}    ${tmp_target}
        SSHLibrary.Close Connection
    ELSE
        SSHLibrary.Put File    ${source_path}    ${tmp_target}
    END
    ${hash_target}=    Execute Command In Terminal    md5sum ${tmp_target} | cut -d ' ' -f 1
    ${hash_target}=    Strip String    ${hash_target}
    Should Be Equal    ${hash_source}    ${hash_target}    msg=File was not correctly sent to DUT

    ${issuer}=    Execute Command In Terminal    whoami
    IF    '${issuer}' != 'root' and ${switch_root}    Switch To Root User
    Execute Command In Terminal    mv --force ${tmp_target} ${target_path}
    Execute Command In Terminal    chown ${issuer}:${issuer} ${target_path}
    IF    '${issuer}' != 'root' and ${switch_root}    Exit From Root User

Get File From DUT
    [Documentation]    Downloads a file from DUT and saves it at given location
    ...
    ...    === Requirements ===
    ...    Keyword has to be called when in OS shell
    ...    DUT OS has to have sshd service or socket enabled
    [Arguments]    ${source_path}    ${target_path}    ${verify}=${TRUE}
    Run    rm -f ${target_path}
    ${hash_source}=    Execute Command In Terminal    md5sum ${source_path} | cut -d ' ' -f 1

    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        IF    '${MANUFACTURER}' == 'QEMU'
            VAR    ${ip_address}=    localhost
            VAR    ${port}=    5222
        ELSE
            Wait Until Keyword Succeeds    5x    ${GET_IP_INTERVAL}
            ...    Get Hostname Ip
            ${ip_address}=    Get Hostname Ip
            VAR    ${port}=    22
        END
        SSHLibrary.Open Connection    ${ip_address}    port=${port}
        SSHLibrary.Login    ${DEVICE_OS_USERNAME}    ${DEVICE_OS_PASSWORD}
        SSHLibrary.Get File    ${source_path}    ${target_path}
        SSHLibrary.Close Connection
    ELSE
        SSHLibrary.Get File    ${source_path}    ${target_path}
    END
    IF    ${verify}
        ${hash_target}=    Run    md5sum ${target_path} | cut -d ' ' -f 1
        ${hash_target}=    Strip String    ${hash_target}
        Should Be Equal    ${hash_source}    ${hash_target}    msg=File was not correctly sent to DUT
    END

Get Hostname Ip
    [Documentation]    Returns local IP address of the DUT.
    VAR    ${ip_regexp}=    \\b(?:192\\.168|10\\.0)\\.\\d{1,3}\\.\\d{1,3}\\b
    TRY
        ${out_hostname}=    Execute Command In Terminal    hostname -I
        Should Not Contain    ${out_hostname}    link is not ready
        ${ip_address}=    String.Get Regexp Matches    ${out_hostname}    ${ip_regexp}
        Should Not Be Empty    ${ip_address}
    EXCEPT
        ${out_hostname}=    Execute Command In Terminal    ip a
        ${ip_address}=    String.Get Regexp Matches    ${out_hostname}    ${ip_regexp}
        Should Not Be Empty    ${ip_address}
    END
    RETURN    ${ip_address[0]}

Check Internet Connection On Linux
    [Documentation]    Check internet connection on Linux.
    Wait Until Keyword Succeeds    5x    ${GET_IP_INTERVAL}
    ...    Get Hostname Ip
    ${out}=    Execute Command In Terminal    ping -c 4 google-public-dns-a.google.com
    Should Contain    ${out}    , 0% packet loss

Check Internet Connection On Windows
    [Documentation]    Check internet connection on Windows.
    ${out}=    Execute Command In Terminal    ping google-public-dns-a.google.com
    Should Contain    ${out}    (0% loss)

Scan For Wi-Fi In Linux
    [Documentation]    Turn on Wi-Fi then scan in search of company network.
    Execute Command In Terminal    nmcli radio wifi on
    Execute Command In Terminal    nmcli device wifi rescan
    Read From Terminal
    ${out}=    Execute Command In Terminal    nmcli --fields SSID device wifi list | cat
    Should Contain    ${out}    ${3_MDEB_WIFI_NETWORK}

Scan For Bluetooth In Linux
    [Documentation]    Turn on Bluetooth then scan in search of company network.
    ${out}=    Execute Command In Terminal    bluetoothctl power on
    Should Contain    ${out}    Changing power on succeeded
    ${out}=    Execute Command In Terminal    bluetoothctl --timeout 60 scan on    timeout=70s
    Should Contain Any    ${out}    Discovery started    SetDiscoveryFilter success
