*** Keywords ***
Enter Boot Menu Tianocore
    [Documentation]    Keyword allows to enter into Tianocore Boot Menu.
    Read From Terminal Until    ${tianocore_string}
    IF    '${dut_connection_method}' == 'pikvm'
        Single Key PiKVM    ${boot_menu_key}
    ELSE
        Write Bare Into Terminal    ${boot_menu_key}
    END

Boot operating system
    [Documentation]    Keyword allows boot operating system installed on the
    ...    DUT. Takes as an argument operating system name.
    [Arguments]    ${operating_system}
    IF    '${dut_connection_method}' == 'SSH'    RETURN
    Set Local Variable    ${is_system_installed}    ${False}
    Enter Boot Menu Tianocore
    ${menu_construction}=    Get edk2 Menu Construction
    ${is_system_installed}=    Evaluate    "${operating_system}" in """${menu_construction}"""
    IF    not ${is_system_installed}
        FAIL    Test case marked as Failed\nRequested OS (${operating_system}) has not been installed
    END
    ${system_index}=    Get Index From List    ${menu_construction}    ${operating_system}
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}

Enter UEFI Shell Tianocore
    [Documentation]    Enter UEFI Shell in Tianocore by specifying its position
    ...    in the list.
    Set Local Variable    ${is_shell_available}    ${False}
    ${menu_construction}=    Get edk2 Menu Construction
    ${is_shell_available}=    Evaluate    "UEFI Shell" in """${menu_construction}"""
    IF    not ${is_shell_available}
        FAIL    Test case marked as Failed\nBoot menu does not contain position for entering UEFI Shell
    END
    ${system_index}=    Get Index From List    ${menu_construction}    UEFI Shell
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}

Boot Dasharo Tools Suite
    [Documentation]    Keyword allows to boot Dasharo Tools Suite. Takes the
    ...    boot method (from USB or from iPXE) as parameter.
    [Arguments]    ${DTS_booting_method}=${DTS_booting_default_method}
    IF    '${DTS_booting_method}'=='USB'
        Boot Dasharo Tools Suite from USB
    ELSE IF    '${DTS_booting_method}'=='iPXE'
        Boot Dasharo Tools Suite from iPXE
    ELSE
        FAIL    Unknown or improper connection method: ${DTS_booting_method}
    END
    Read From Terminal Until    ${DTS_string}

Boot Dasharo Tools Suite from USB
    [Documentation]    Keyword allows to boot Dasharo Tools Suite from USB.
    ...    Takes the boot method (from USB or from iPXE) as parameter.
    Set Local Variable    ${is_usb_dts_available}    ${False}
    ${menu_construction}=    Get edk2 Menu Construction
    ${is_usb_dts_available}=    Evaluate    "USB SanDisk 3.2Gen1" in """${menu_construction}"""
    IF    not ${is_usb_dts_available}
        FAIL    Test case marked as Failed\nBoot menu does not contain position for entering USB with DTS
    END
    ${system_index}=    Get Index From List    ${menu_construction}    USB SanDisk 3.2Gen1
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}

Get edk2 Menu Construction
    [Documentation]    Keyword allows to get and return boot menu construction.
    ...    Getting boot menu contruction is carried out in the following basis:
    ...    1. Get serial output, which shows Boot menu with all elements,
    ...    headers and whitespaces.
    ...    2. Split serial output tring and create list.
    ...    3. Create empty list for detected elements of menu.
    ...    4. Add to the new list only elements which are not whitespaces and
    ...    not menu frames.
    ...    5. Remove from new list menu header and footer (header always
    ...    occupies one line, footer -3)
    ${menu}=    Read From Terminal Until    exit
    @{menu_lines}=    Split String    ${menu}    \n
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        ${line}=    Remove String    ${line}    -    \\    \    /    |
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        IF    "${line}"!="${EMPTY}" and "${line}"!="${SPACE}"
            ${line}=    Get Substring    ${line}    1    -1
            Append To List    ${menu_construction}    ${line}
        END
    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[1:-3]
    RETURN    ${menu_construction}

Create HCL report
    [Documentation]    Keyword allows to create Dasharo Tools Suite HCL report
    Set DUT Response Timeout    180s
    Read From Terminal Until    Enter an option:
    Write Into Terminal    1
    Read From Terminal Until    N/y
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

Check DTS option Power Off
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    option for power off the DUT works correctly..
    Read From Trminal Until    Enter an option:
    Write Into Terminal    10
    Sleep    5s
    RteCtrl Power On    ${rte_session_handler}
    Read From Terminal Until    ${tianocore_string}

Check DTS option Reboot
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    option for power off the DUT works correctly..
    Read From Trminal Until    Enter an option:
    Write Into Terminal    11
    Read From Terminal Until    ${tianocore_string}

Run EC Transition
    [Documentation]    Keyword allows to run EC Transition procedure in the
    ...    Dasharo Tools Suite.
    Write Into Terminal    6
    Read From Trminal Until    Enter an option:
    Write Into Terminal    1
    ${output}=    Read From Terminal Until    shut down
    Should Contain X Times    ${output}    VERIFIED    2
    Sleep    10s

Flash firmware in DTS
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    ability for flashing firmware work correctly.
    Execute Command In Terminal
    ...    wget -0 /tmp/coreboot.rom https://3mdeb.com/open-source-firmware/Dasahro/${binary_location}
    ${output}=    Execute Command In Terminal    flashrom -p internal -w /tmp/coreboot ${flashrom_variables}
    Should Contain    ${output}    VERIFIED

Flash EC Firmware In DTS
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    ability for flashing EC firmware work correctly.
    Execute Command In Terminal
    ...    wget -0 /tmp/ec.rom https://3mdeb.com/open-source-firmware/Dasahro/${ec_binary_location}
    Write Into Terminal    system76_ectool flash ec.rom
    ${output}=    Read From Terminal Until    shut off
    Should Contain    ${output}    Successfully programmed SPI ROM
    Sleep    10s

Check Firmware Version
    [Documentation]    Keyword allows to check firmware version in the Dasharo
    ...    Tools Suite Shell.
    ${output}=    Execute Command In Terminal    dmidecode -t 0
    Should contain    ${output}    ${version}

Check EC Firmware Version
    [Documentation]    Keyword allows to check EC firmware version in the
    ...    Dasharo Tools Suite Shell.
    ${output}=    Execute Command In Terminal    system76_ectool info
    Should contain    ${output}    ${ec_version}

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
