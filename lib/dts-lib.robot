*** Keywords ***
Boot Dasharo Tools Suite
    [Documentation]    Keyword allows to boot Dasharo Tools Suite. Takes the
    ...    boot method (from USB or from iPXE) as parameter.
    [Arguments]    ${dts_booting_method}
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    IF    '${dts_booting_method}'=='USB'
        IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
            Enter Submenu From Snapshot    ${boot_menu}    PiKVM Composite KVM Device
        ELSE IF    '${MANUFACTURER}' == 'QEMU'
            Enter Submenu From Snapshot    ${boot_menu}    QEMU
        ELSE
            # Requires specifying the USB model in the platform's config
            Enter Submenu From Snapshot    ${boot_menu}    ${USB_MODEL}
        END
    ELSE IF    '${dts_booting_method}'=='iPXE'
        Enter Submenu From Snapshot    ${boot_menu}    ${IPXE_BOOT_ENTRY}
        ${ipxe_menu}=    Get IPXE Boot Menu Construction
        Enter Submenu From Snapshot    ${ipxe_menu}    Dasharo Tools Suite
        Set DUT Response Timeout    5m
    ELSE
        FAIL    Unknown or improper connection method: ${dts_booting_method}
    END

    # For PiKVM devices, we have only input on serial, not output. The video and serial consoles are
    # two different console in case of Linux, they are not in sync anymore as in case of firmware.
    # We have to switch to SSH connection to continue test execution on such devices.
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        # Wait for the menu to be loaded on serial
        Read From Terminal Until    Enter an option:
        # Enable SSH server and switch to SSH connection by writing on video console "in blind"
        Write Into Terminal    8
        Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
        Login To Linux Via SSH Without Password    root    root@DasharoToolsSuite
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
    Execute Command In Terminal
    ...    wget -O /tmp/coreboot.rom ${FW_DOWNLOAD_LINK}
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
