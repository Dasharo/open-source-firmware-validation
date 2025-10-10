*** Settings ***
Library     Collections
Resource    ../keywords.robot
Resource    ../lib/platform/power.robot


*** Keywords ***
Boot OpenWrt
    [Documentation]    Boot OpenWrt using Boot From File, kernel -> /efi/boot/bootx64.efi
    Enter Boot From File
    Enter Volume In File Explorer    kernel
    Execute File In File Explorer    efi
    Execute File In File Explorer    boot
    Execute File In File Explorer    bootx64.efi
    Read From Terminal Until    Link is Up
    Sleep    2
    Press Enter
    VAR    ${BOOTED_OS_ID}=    ${ENV_ID_OPENWRT}    scope=GLOBAL
    Import Variables    ${CURDIR}/../os-config/${BOOTED_OS_ID}-credentials.py
    Telnet.Set Prompt    ${DEVICE_OS_ROOT_PROMPT}    prompt_is_regexp=False

Detect Or Install Package OpenWrt
    [Documentation]    Check if package is installed using apk, attempt to install
    ...    otherwise. Requires working internet connection.
    [Arguments]    ${package}
    ${apk_info_grep}=    Execute Command In Terminal    apk info | grep ${package}
    # This double filtering is dirty fix for random 'apk' errors on output.
    ${apk_info_grep_second}=    Get Lines Containing String    ${apk_info_grep}    ${package}
    IF    $apk_info_grep_second != $package
        ${apk_add_package}=    Execute Command In Terminal    apk add ${package}
        Should Contain    ${apk_add_package}    OK
    END

Enable WiFi OpenWrt
    [Documentation]    Enabling WiFi in OpenWrt with uci. Setting it up and
    ...    waiting for wifi status output to be "up".
    ...    Number of attempts defined in OPENWRT_WIFI_UP_ATTEMPTS.
    Variable Should Exist    ${OPENWRT_WIFI_UP_ATTEMPTS}
    ${out_show}=    Execute Command In Terminal    uci show wireless
    Should Contain    ${out_show}    wireless.radio0=wifi-device
    Execute Command In Terminal    uci set wireless.radio0.country='PL'
    Execute Command In Terminal    uci set wireless.radio0.disabled='0'
    Execute Command In Terminal    uci commit wireless
    Execute Command In Terminal    wifi reload
    Execute Command In Terminal    wifi up
    Press Enter
    FOR    ${index}    IN RANGE    0    ${OPENWRT_WIFI_UP_ATTEMPTS}
        TRY
            ${up_out}=    Execute Command In Terminal    wifi status | grep '"up":'
        EXCEPT
            Log To Console    No prompt, sending Enter.
            Press Enter
        END
        ${contains}=    Run Keyword And Return Status    Should Contain    ${up_out}    "up": true,
        IF    ${contains} == ${TRUE}    BREAK
    END

Scan WiFi For Network OpenWrt
    [Documentation]    Sanning for WiFi network named by ESSID. Interface name extracted
    ...    from wifi status command output. Number of attempts defined in OPENWRT_WIFI_SCAN_ATTEMPTS.
    [Arguments]    ${essid}
    Variable Should Exist    ${OPENWRT_WIFI_SCAN_ATTEMPTS}
    VAR    @{empty_list}=    @{EMPTY}
    ${ifname_grep}=    Execute Command In Terminal    wifi status | grep "ifname"
    ${re_search}=    Get Regexp Matches    ${ifname_grep}    (\\s*)(\"ifname\":\\s*)\"([^"]*)\",    3
    Should Not Be Equal    ${re_search}    ${empty_list}
    FOR    ${index}    IN RANGE    0    ${OPENWRT_WIFI_SCAN_ATTEMPTS}
        ${iwinfo_scan_out}=    Execute Command In Terminal    iwinfo ${re_search}[0] scanning | grep ${essid}
        ${contains}=    Run Keyword And Return Status    Should Contain    ${iwinfo_scan_out}    ${essid}
        Pass Execution If    ${contains} == ${TRUE}    ${essid} network found in ${index} attempt(s).
    END
    Fail    Searching for ${essid} network failed in ${OPENWRT_WIFI_SCAN_ATTEMPTS} attempts.

Download File OpenWrt
    [Documentation]    Download file from the given URL.
    [Arguments]    ${remote_url}    ${local_path}    ${timeout}=30
    Wait Until Keyword Succeeds    5x    1s
    ...    Check Internet Connection On Linux
    ${out}=    Execute Linux Command
    ...    wget --no-check-certificate -O ${local_path} ${remote_url}
    ...    ${timeout}
    Should Contain    ${out}    ${local_path}
    Should Not Contain    ${out}    failed
