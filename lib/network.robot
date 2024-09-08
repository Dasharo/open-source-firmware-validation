*** Settings ***
Documentation       Collection of network-related keywords

Library             String
Library             SSHLibrary
Resource            ../keywords.robot


*** Keywords ***
Send File To DUT
    [Documentation]    Sends file DUT and saves it at given location
    [Arguments]    ${source_path}    ${target_path}
    ${hash_source}=    Run    md5sum ${source_path} | cut -d ' ' -f 1
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        IF    '${CONFIG}' == 'qemu'
            Set Local Variable    ${ip_address}    localhost
            Set Local Variable    ${port}    5222
        ELSE
            ${ip_address}=    Get Hostname Ip
            Set Local Variable    ${port}    22
        END
        Execute Command In Terminal    rm -f ${target_path}
        SSHLibrary.Open Connection    ${ip_address}    port=${port}
        SSHLibrary.Login    ${DEVICE_UBUNTU_USERNAME}    ${DEVICE_UBUNTU_PASSWORD}
        SSHLibrary.Put File    ${source_path}    ${target_path}
        SSHLibrary.Close Connection
    ELSE
        SSHLibrary.Put File    ${source_path}    ${target_path}
    END
    ${hash_target}=    Execute Command In Terminal    md5sum ${target_path} | cut -d ' ' -f 1
    ${hash_target}=    Strip String    ${hash_target}
    Should Be Equal    ${hash_source}    ${hash_target}    msg=File was not correctly sent to DUT

Get Hostname Ip
    [Documentation]    Returns local IP address of the DUT.
    # TODO: We do not necessarily need Internet to be reachable for the internal
    # addresses to be assigned. But if it is, the local IPs are definitely
    # already in place.
    Wait Until Keyword Succeeds    5x    1s
    ...    Check Internet Connection On Linux
    ${out_hostname}=    Execute Command In Terminal    hostname -I
    Should Not Contain    ${out_hostname}    link is not ready
    ${ip_address}=    String.Get Regexp Matches    ${out_hostname}    \\b(?:192\\.168|10\\.0)\\.\\d{1,3}\\.\\d{1,3}\\b
    Should Not Be Empty    ${ip_address}
    RETURN    ${ip_address[0]}

Check Internet Connection On Linux
    [Documentation]    Check internet connection on Linux.
    ${out}=    Execute Linux Command    ping -c 4 google-public-dns-a.google.com
    Should Contain    ${out}    , 0% packet loss

Check Internet Connection On Windows
    [Documentation]    Check internet connection on Windows.
    ${out}=    Execute Command In Terminal    ping google-public-dns-a.google.com
    Should Contain    ${out}    (0% loss)

Scan For Wi-Fi In Linux
    [Documentation]    Turn on Wi-Fi then scan in search of company network.
    Execute Linux Command Without Output    nmcli radio wifi on
    Write Into Terminal    nmcli device wifi rescan
    Set DUT Response Timeout    60 seconds
    Write Into Terminal    nmcli device wifi list
    Read From Terminal Until    ${3_MDEB_WIFI_NETWORK}
    Write Into Terminal    q

Scan For Bluetooth In Linux
    [Documentation]    Turn on Bluetooth then scan in search of company network.
    ${out}=    Execute Linux Command    bluetoothctl power on
    Should Contain    ${out}    Changing power on succeeded
    Set DUT Response Timeout    60 seconds
    Write Into Terminal    bluetoothctl scan on
    Sleep    60s
    Write Bare Into Terminal    ${CTRL_C}
    ${out}=    Read From Terminal Until Prompt
    Should Contain    ${out}    Discovery started
