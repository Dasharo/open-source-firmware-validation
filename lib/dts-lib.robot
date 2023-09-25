*** Keywords ***
Enable SSH In DTS
    Write Into Terminal    8

Enable Network Boot
    Power On
    Enter Dasharo System Features
    Read From Terminal Until    Networking Options
    Press Key N Times And Enter    1    ${ARROW_DOWN}
    Sleep    1s
    ${out}=    Read From Terminal Until    ]
    ${is_selected}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    X
    IF    not ${is_selected}
        Press Key N Times    1    ${ENTER}
    END
    Save Changes And Reset    2    4

Boot Dasharo Tools Suite
    [Documentation]    Keyword allows to boot Dasharo Tools Suite. Takes the
    ...    boot method (from USB or from iPXE) as parameter.
    [Arguments]    ${dts_booting_method}
    Enter Boot Menu Tianocore
    IF    '${dts_booting_method}'=='USB'
        Enter Submenu In Tianocore    USB SanDisk 3.2Gen1
    ELSE IF    '${dts_booting_method}'=='USB_emulated'
        Enter Submenu In Tianocore    PiKVM Composite KVM Device
        Sleep    1s
        Press Key N Times    1    ${ENTER}
    ELSE IF    '${dts_booting_method}'=='iPXE'
        Enter Submenu In Tianocore    iPXE Network Boot
        Read From Terminal Until    Auto
        Press Key N Times And Enter    1    ${ARROW_DOWN}
    ELSE
        FAIL    Unknown or improper connection method: ${dts_booting_method}
    END
    Read From Terminal Until    Enter an option:

Check DTS Menu Appears
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite menu
    ...    has appeared in the Terminal.
    ${output}=    Read From Terminal Until    Enter an option:

Check HCL Report Creation
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    option for creating HCL report works correctly.
    Enter Shell In DTS
    Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
    Set DUT Response Timeout    210s
    Execute Command In Terminal    cd /
    ${logs}=    Execute Command In Terminal
    ...    /usr/bin/env DEPLOY_REPORT=false SEND_LOGS=true /usr/sbin/dasharo-hcl-report
    Should Contain    ${logs}    Thank you
    Should Contain    ${logs}    exited without errors
    Should Contain    ${logs}    send completed

Enter Shell In DTS
    [Documentation]    Keyword allows to drop to Shell in the Dasharo Tools
    ...    Suite.
    Enable SSH In DTS
    Login To Linux Via SSH Without Password    root    root@DasharoToolsSuite:~#

Run EC Transition
    [Documentation]    Keyword allows to run EC Transition procedure in the
    ...    Dasharo Tools Suite.
    Write Into Terminal    6
    Read From Trminal Until    Enter an option:
    Write Into Terminal    1
    ${output}=    Read From Terminal Until    shut down
    Should Contain X Times    ${output}    VERIFIED    2
    Sleep    10s

Check Power Off In DTS
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    option for power off the DUT works correctly..
    Sleep    5s
    ${output}=    Read From Terminal
    Length Should Be    ${output}    1

Flash Firmware In DTS
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    ability for flashing firmware work correctly.
    Execute Command In Terminal
    ...    wget -O /tmp/coreboot.rom ${FW_DOWNLOAD_LINK}
    Write Into Terminal
    ...    flashrom --ifd -i bios -p internal -w /tmp/coreboot.rom --noverify-all
    Set DUT Response Timeout    320s
    Read From Terminal Until    VERIFIED

Flash EC Firmware In DTS
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    ability for flashing EC firmware work correctly.
    Execute Command In Terminal
    ...    wget -0 /tmp/ec.rom https://3mdeb.com/open-source-firmware/Dasahro/${EC_BINARY_LOCATION}
    Write Into Terminal    system76_ectool flash ec.rom
    ${output}=    Read From Terminal Until    shut off
    Should Contain    ${output}    Successfully programmed SPI ROM
    Sleep    10s

Check Firmware Version
    [Documentation]    Keyword allows to check firmware version in the Dasharo
    ...    Tools Suite Shell.
    ${output}=    Execute Command In Terminal    dmidecode -t 0
    Should Contain    ${output}    ${FW_VERSION}

Check EC Firmware Version
    [Documentation]    Keyword allows to check EC firmware version in the
    ...    Dasharo Tools Suite Shell.
    ${output}=    Execute Command In Terminal    system76_ectool info
    Should Contain    ${output}    ${EC_VERSION}

Fwupd Update
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    ability for update firmware with the use of fwupd works correctly.
    ${output}=    Execute Command In Terminal    fwupdmgr refresh
    Should Contatin    ${output}    Successfully
    ${output}=    Execute Command In Terminal    fwupdmgr update
    Should Contatin    ${output}    Successfully installed firmware

Get Firmware Version From Tianocore Setup Menu
    [Documentation]    Keyword allows to read firmware version from Tianocore
    ...    Setup menu header.
    Enter Setup Menu Tianocore
    ${output}=    Read From Terminal Until    Select Entry
    ${firmware_line}=    Get Lines Containing String    ${output}    Dasharo (coreboot+UEFI)
    ${firmware_version}=    Get Regexp Matches    ${firmware_line}    v\\d{1,}\.\\d{1,}\.\\d{1,}
    RETURN    ${firmware_version}
