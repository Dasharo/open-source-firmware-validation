*** Settings ***
Library     ../robot-venv/lib/python3.11/site-packages/robot/libraries/Collections.py
Resource    bios/menus.robot


*** Keywords ***
Boot Dasharo Tools Suite
    [Documentation]    Keyword allows to boot Dasharo Tools Suite. Takes the
    ...    boot method (from USB or from iPXE) as parameter.
    [Arguments]    ${dts_booting_method}
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    IF    '${dts_booting_method}'=='USB'
        ${is_pikvm}=    Run Keyword And Return Status
        ...    Should Contain Match    ${boot_menu}    *PiKVM*
        IF    ${is_pikvm} == ${TRUE}
            Enter Submenu From Snapshot    ${boot_menu}    PiKVM Composite KVM Device
            Sleep    1s
            Press Key N Times    1    ${ENTER}
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
    Sleep    40s

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
    Write Into Terminal    8
    Login To Linux Via SSH Without Password    root    root@DasharoToolsSuite:
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
    END

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
