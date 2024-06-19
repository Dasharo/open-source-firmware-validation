*** Settings ***
Resource    terminal.robot


*** Keywords ***
Boot Dasharo Tools Suite Via IPXE Shell
    Enter IPXE
    Write Into Terminal    dhcp net0
    ${out}=    Read From Terminal Until Prompt
    Should Contain    ${out}    ok
    Set DUT Response Timeout    60s
    Write Bare Into Terminal    chain http://boot.dasharo.com/dts/dts.ipxe\n    0.1
    Read From Terminal Until    http://boot.dasharo.com/dts/dts.ipxe...
    Read From Terminal Until    ok
    Set DUT Response Timeout    5m

Boot Dasharo Tools Suite
    [Documentation]    Keyword allows to boot Dasharo Tools Suite. Takes the
    ...    boot method (from USB or from iPXE) as parameter.
    [Arguments]    ${dts_booting_method}
    IF    '${dts_booting_method}'=='USB'
        ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
        IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
            Enter Submenu From Snapshot    ${boot_menu}    PiKVM Composite KVM Device
        ELSE IF    '${MANUFACTURER}' == 'QEMU'
            Enter Submenu From Snapshot    ${boot_menu}    QEMU
        ELSE
            # Requires specifying the USB model in the platform's config
            Enter Submenu From Snapshot    ${boot_menu}    ${USB_MODEL}
        END
    ELSE IF    '${dts_booting_method}'=='iPXE'
        IF    ${NETBOOT_UTILITIES_SUPPORT} == ${TRUE}
            Boot Dasharo Tools Suite Via IPXE Shell
        ELSE
            ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
            Enter Submenu From Snapshot    ${boot_menu}    ${IPXE_BOOT_ENTRY}
            ${ipxe_menu}=    Get IPXE Boot Menu Construction
            Enter Submenu From Snapshot    ${ipxe_menu}    Dasharo Tools Suite
            Set DUT Response Timeout    5m
            Read From Terminal Until    .cpio.gz...
            Read From Terminal Until    ok
        END
    ELSE
        FAIL    Unknown or improper connection method: ${dts_booting_method}
    END

    # For PiKVM devices, we have only input on serial, not output. The video and serial consoles are
    # two different console in case of Linux, they are not in sync anymore as in case of firmware.
    # We have to switch to SSH connection to continue test execution on such devices.
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        # Should be long enough so that DTS can boot
        ${old_timeout}=    Set Timeout    20s
        Run Keyword And Ignore Error
        ...    Read From Terminal Until    Enter an option:
        Set Timeout    ${old_timeout}
        # Enable SSH server and switch to SSH connection by writing on video console "in blind"
        Write Into Terminal    8
        ${dut_connection_method}=    Set Variable    SSH
        Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
        Login To Linux Via SSH Without Password    root    root@DasharoToolsSuite:~#
        # Spawn DTS menu on SSH console
        Write Into Terminal    dts
    END

    Read From Terminal Until    Enter an option:
    Sleep    5s

Check HCL Report Creation
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    option for creating HCL report works correctly.
    Enter Shell In DTS
    Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
    Execute Command In Terminal    cd /
    ${logs}=    Execute Command In Terminal
    ...    command=/usr/bin/env DEPLOY_REPORT=false SEND_LOGS=true /usr/sbin/dasharo-hcl-report
    ...    timeout=210s
    Should Contain    ${logs}    Thank you
    Should Contain    ${logs}    exited without errors
    Should Contain    ${logs}    send completed

Enter Shell In DTS
    [Documentation]    Keyword allows to drop to Shell in the Dasharo Tools
    ...    Suite.
    Write Into Terminal    9
    Set Prompt For Terminal    bash-5.1#
    # These could be removed once routes priorities in DTS are resolved.
    Sleep    10
    Press Enter
    ${out}=    Read From Terminal
    Log    ${out}
    Remove Extra Default Route

Run EC Transition
    [Documentation]    Keyword allows to run EC Transition procedure in the
    ...    Dasharo Tools Suite.
    Write Into Terminal    6
    Read From Trminal Until    Enter an option:
    Write Into Terminal    1
    ${output}=    Read From Terminal Until    shut down
    Should Contain X Times    ${output}    VERIFIED    2
    Sleep    10s

Flash Firmware In DTS
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    ability for flashing firmware work correctly.
    [Arguments]    ${fw_dl_link}=${FW_DOWNLOAD_LINK}
    Execute Command In Terminal
    ...    wget -O /tmp/coreboot.rom ${fw_dl_link}
    ${out}=    Execute Command In Terminal
    ...    command=flashrom --ifd -i bios -p internal -w /tmp/coreboot.rom --noverify-all
    ...    timeout=320s
    ${verified}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    VERIFIED
    IF    ${verified} == ${FALSE}
        ${out}=    Execute Command In Terminal
        ...    command=flashrom --ifd -i bios -p internal -w /tmp/coreboot.rom --noverify-all
        ...    timeout=320s
        Should Contain    ${out}    identical
    END

Remove Extra Default Route
    [Documentation]    If two default routes are present in Linux, remove
    ...    the one NOT pointing to the gateway in test network (192.168.10.1)
    ${route_info}=    Execute Command In Terminal    ip route | grep ^default
    ${devname}=    String.Get Regexp Matches    ${route_info}
    ...    ^default via 172\.16\.0\.1 dev (?P<devname>\\w+)    devname
    ${length}=    Get Length    ${devname}
    IF    ${length} > 0
        Execute Command In Terminal    ip route del default via 172.16.0.1 dev ${devname[0]}
        ${route_info}=    Execute Command In Terminal    ip route | grep ^default
        Log    Default route via 172.16.0.1 dev ${devname[0]} removed
    END
