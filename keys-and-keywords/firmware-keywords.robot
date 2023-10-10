*** Keywords ***
Enter Boot Menu Tianocore
    [Documentation]    Keyword allows to enter into Tianocore Boot Menu.
    Read From Terminal Until    ${TIANOCORE_STRING}
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Single Key PiKVM    ${BOOT_MENU_KEY}
    ELSE
        Write Bare Into Terminal    ${BOOT_MENU_KEY}
    END

Enter Setup Menu Tianocore
    [Documentation]    Keyword allows to enter into Tianocore Setup Menu.
    Read From Terminal Until    ${TIANOCORE_STRING}
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Single Key PiKVM    ${SETUP_MENU_KEY}
    ELSE
        Write Bare Into Terminal    ${SETUP_MENU_KEY}
    END

Enter Submenu In Tianocore
    [Documentation]    Keyword allows to enter into any Tianocore submenu.
    [Arguments]    ${option}    ${checkpoint}=ESC to exit    ${description_lines}=1
    ${rel_pos}=    Get Relative Menu Position    ${option}    ${checkpoint}    ${description_lines}
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Press Key N Times And Enter    ${rel_pos}    ArrowDown
    ELSE
        Press Key N Times And Enter    ${rel_pos}    ${ARROW_DOWN}
    END

Get Relative Menu Position
    [Documentation]    Keyword evaluates and returns relative menu entry
    ...    position described in the argument.
    [Arguments]    ${entry}    ${checkpoint}    ${bias}
    ${output}=    Read From Terminal Until    ${checkpoint}
    ${output}=    Strip String    ${output}
    ${reference}=    Get Menu Reference Tianocore    ${output}    ${bias}
    @{lines}=    Split To Lines    ${output}
    ${iterations}=    Set Variable    0
    FOR    ${line}    IN    @{lines}
        IF    '${reference}' in '${line}\\n'
            ${start}=    Set Variable    ${iterations}
            BREAK
        END
        ${iterations}=    Evaluate    ${iterations} + 1
    END
    ${iterations}=    Set Variable    0
    FOR    ${line}    IN    @{lines}
        IF    '${entry}' in '${line}\\n'
            ${end}=    Set Variable    ${iterations}
        END
        ${iterations}=    Evaluate    ${iterations} + 1
    END
    ${rel_pos}=    Evaluate    ${end} - ${start}
    RETURN    ${rel_pos}

Get Menu Reference Tianocore
    [Documentation]    Keyword evaluates and returns first menu position.
    [Arguments]    ${raw_menu}    ${bias}
    ${lines}=    Get Lines Matching Pattern    ${raw_menu}    *[qwertyuiopasdfghjklzxcvbnm]*
    ${lines}=    Split To Lines    ${lines}
    ${bias}=    Convert To Integer    ${bias}
    ${first_entry}=    Get From List    ${lines}    ${bias}
    ${first_entry}=    Strip String    ${first_entry}    characters=1234567890()
    ${first_entry}=    Strip String    ${first_entry}
    RETURN    ${first_entry}

Press Key N Times And Enter
    [Documentation]    Keyword allows to write into terminal certain key
    ...    certain number of times and then press Enter key. As the arguments
    ...    takes requested number of entering the key and requested key.
    [Arguments]    ${n}    ${key}
    Press Key N Times    ${n}    ${key}
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Single Key PiKVM    ${key}
    ELSE
        Write Bare Into Terminal    ${key}
    END

Press Key N Times
    [Documentation]    Keyword allows to write into terminal certain key
    ...    certain number of times. As the arguments takes requested number
    ...    of entering the key and requested key.
    [Arguments]    ${n}    ${key}
    FOR    ${index}    IN RANGE    0    ${n}
        IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
            Single Key PiKVM    ${key}
        ELSE
            Write Bare Into Terminal    ${key}
        END
    END

Boot Dasharo Tools Suite
    [Documentation]    Keyword allows to boot Dasharo Tools Suite. Takes the
    ...    boot method (from USB or from iPXE) as parameter.
    [Arguments]    ${dts_booting_method}
    Enter Boot Menu Tianocore
    IF    '${dts_booting_method}'=='USB'
        Enter Submenu In Tianocore    USB SanDisk 3.2Gen1
    ELSE IF    '${dts_booting_method}'=='USB'
        No Operation
    ELSE
        FAIL    Unknown or improper connection method: ${dts_booting_method}
    END
    Read From Terminal Until    ${DTS_STRING}

Check DTS Menu Appears
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite menu
    ...    has appeared in the Terminal.
    ${output}=    Read From Terminal Until    Enter an option:

Check HCL Report Creation
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    option for creating HCL report works correctly.
    Read From Terminal Until    [N/y]
    Write Into Terminal    y
    ${output}=    Read From Terminal Until    Thank you for supporting Dasharo!
    Should Contain    ${output}    Done! Logs saved
    Should Contain    ${output}    exited without errors
    Should Contain    ${output}    send completed

Enter Shell In DTS
    [Documentation]    Keyword allows to drop to Shell in the Dasharo Tools
    ...    Suite.
    Write Into Terminal    9
    Read From Terminal Until    bash-5.1#

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
    Should Be Empty    ${output}

Flash Firmware In DTS
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    ability for flashing firmware work correctly.
    Execute Command In Terminal
    ...    wget -0 /tmp/coreboot.rom https://3mdeb.com/open-source-firmware/Dasahro/${BINARY_LOCATION}
    ${output}=    Execute Command In Terminal    flashrom -p internal -w /tmp/coreboot ${FLASHROM_VARIABLES}
    Should Contain    ${output}    VERIFIED

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
    Should Contain    ${output}    ${VERSION}

Check EC Firmware Version
    [Documentation]    Keyword allows to check EC firmware version in the
    ...    Dasharo Tools Suite Shell.
    ${output}=    Execute Command In Terminal    system76_ectool info
    Should Contain    ${output}    ${EC_VERSION}

Fwupd Update
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    ability for update firmware with the use of fwupd works correctly.
    ${output}=    Execute Command In Terminal    fwupdmgr refresh
    Should Contain    ${output}    Successfully
    ${output}=    Execute Command In Terminal    fwupdmgr update
    Should Contain    ${output}    Successfully installed firmware

Get Firmware Version From Tianocore Setup Menu
    [Documentation]    Keyword allows to read firmware version from Tianocore
    ...    Setup menu header.
    Enter Setup Menu Tianocore
    ${output}=    Read From Terminal Until    Select Entry
    ${firmware_line}=    Get Lines Containing String    ${output}    Dasharo (coreboot+UEFI)
    ${firmware_version}=    Get Regexp Matches    ${firmware_line}    v\\d{1,}\.\\d{1,}\.\\d{1,}
    RETURN    ${firmware_version}
