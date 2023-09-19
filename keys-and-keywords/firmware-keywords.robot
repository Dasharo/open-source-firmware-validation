*** Keywords ***
Enter Setup Menu Tianocore
    [Documentation]    Enter Setup Menu with key specified in platform-configs.
    Read From Terminal Until    ${tianocore_string}
    IF    '${dut_connection_method}' == 'pikvm'    Single Key PiKVM    ${setup_menu_key}
    ...    ELSE     Write Bare Into Terminal    ${setup_menu_key}
    # wait for setup menu to appear
    # Read From Terminal Until    Continue

Enter submenu in Tianocore
    [Documentation]    Keyword allwos to enter into any Tianocore submenu.
    [Arguments]    ${option}    ${checkpoint}=ESC to exit    ${description_lines}=1
    ${rel_pos}=    Get relative menu position    ${option}    ${checkpoint}    ${description_lines}
    IF    '${dut_connection_method}' == 'pikvm'
        Press key n times and enter    ${rel_pos}    ArrowDown
    ELSE
        Press key n times and enter    ${rel_pos}    ${ARROW_DOWN}
    END

Get relative menu position
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

Enter Boot Menu Tianocore
    [Documentation]    Enter Boot Menu with tianocore boot menu key mapped in
    ...                keys list.
    Read From Terminal Until    ${tianocore_string}
    IF    '${dut_connection_method}' == 'pikvm'    Single Key PiKVM    ${boot_menu_key}
    ...    ELSE     Write Bare Into Terminal    ${boot_menu_key}

Enter UEFI Shell Tianocore
    [Documentation]    Enter UEFI Shell in Tianocore by specifying its position
    ...                in the list.
    Set Local Variable    ${is_shell_available}    ${False}
    ${menu_construction}=    Get Boot Menu Construction
    ${is_shell_available}=    Evaluate    "UEFI Shell" in """${menu_construction}"""
    IF    not ${is_shell_available}
        FAIL    Test case marked as Failed\nBoot menu does not contain position for entering UEFI Shell
    END
    ${system_index}=    Get Index From List    ${menu_construction}    UEFI Shell
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}

Press key n times and enter
    [Documentation]    Enter specified in the first argument times the specified
    ...                in the second argument key and then press Enter.
    [Arguments]    ${n}    ${key}
    Press key n times    ${n}    ${key}
    IF    '${dut_connection_method}' == 'pikvm'    Single Key PiKVM    Enter
    ...    ELSE    Write Bare Into Terminal    ${ENTER}

Save changes and reset
    [Arguments]    ${nesting_level}=2    ${main_menu_steps_to_reset}=5
    [Documentation]    Saves current UEFI settings and restarts. ${nesting_level}
    ...                is how deep user is currently in the settings.
    ...                ${main_menu_steps_to_reset} means how many times should
    ...                arrow down be pressed to get to the Reset option in main
    ...                settings menu
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Press key n times    ${nesting_level}   ${ESC}
    Press key n times and enter    ${main_menu_steps_to_reset}    ${ARROW_DOWN}

Press key n times
    [Documentation]    Keyword allows to write into terminal certain key
    ...    certain number of times. As the arguments takes requested number
    ...    of entering the key and requested key.
    [Arguments]    ${n}    ${key}
    FOR    ${INDEX}    IN RANGE    0    ${n}
        IF    '${dut_connection_method}' == 'pikvm'
            Single Key PiKVM    ${key}
        ELSE
            Write Bare Into Terminal    ${key}
        END
    END

Boot Dasharo Tools Suite
    [Documentation]    Keyword allows to boot Dasharo Tools Suite. Takes the
    ...    boot method (from USB or from iPXE) as parameter.
    [Arguments]    ${DTS_booting_method}
    Enter Boot Menu Tianocore
    IF    '${DTS_booting_method}'=='USB'
        Enter submenu in Tianocore    USB SanDisk 3.2Gen1
    ELSE IF    '${DTS_booting_method}'=='USB'
        No Operation
    ELSE
        FAIL    Unknown or improper connection method: ${DTS_booting_method}
    END
    Read From Terminal Until    ${DTS_string}

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

Enter Custom Secure Boot Options
    [Documentation]    Sets the Secure Boot Mode to Custom Mode from
    ...                the Secure Boot Configuration menu and enters
    ...                the Custom Secure Boot Options menu
    ...

    ${out}=    Get Secure Boot Configuration Submenu Construction
    ${is_standardmode}=    Run Keyword And Return Status
    ...    Should Contain Any    ${out}    Secure Boot Mode Standard Mode
    IF    ${is_standardmode}
        Press key n times and enter    2    ${ARROW_DOWN}
        Read From Terminal Until    Custom Mode
        Press key n times and enter    1    ${ARROW_DOWN}
        Read From Terminal
        Press key n times and enter    1    ${ARROW_DOWN}
    ELSE
        Press key n times and enter    3    ${ARROW_DOWN}
    END

Mount Image
    [Documentation]    Mounts the image with the given name on the PiKVM.
    [Arguments]    ${ip}    ${img_name}
    Mount Image On PiKVM    ${ip}    ${img_name}

Upload Image
    [Documentation]    Mounts the image from the given URL on the PiKVM.
    [Arguments]    ${ip}    ${img_url}
    Upload Image To PiKVM    ${ip}    ${img_url}

Enroll Certificate
    [Arguments]    ${cert_filename}    ${fileformat}=GOOD
    [Documentation]    Enrolls the certificate with given filename
    ...                from a USB stick. If fileformat is not set
    ...                to GOOD, checks for Unsupported file type
    ...                error.
    ...

    Read From Terminal Until    PK Options
    Press key n times and enter    2    ${ARROW_DOWN}
    Read From Terminal Until    Enroll Signature
    Press key n times    1    ${ENTER}
    Read From Terminal Until    Enroll Signature Using File
    Press key n times    1    ${ENTER}
    Read From Terminal Until    NO FILE SYSTEM INFO

    Press key n times and enter    1    ${ARROW_UP}

    Read From Terminal
    ${out}=    Get File Explorer Submenu Construction
    Should Contain Match    ${out}    *${cert_filename}*
    ${index}=    Get Index From List    ${out}    ${cert_filename}
    Press key n times and enter    ${index}+2    ${ARROW_DOWN}
    Read From Terminal
    Read From Terminal Until    Enroll
    ${enroll_menuconstr}=    Get Enroll Signature Submenu Construction
    ${index}=    Get Index From List    ${enroll_menuconstr}    Commit Changes and Exit
    Press key n times and enter    ${index}-1    ${ARROW_DOWN}
    ${format_eval}=    Run Keyword And Return Status
    ...    Should Be Equal As Strings    ${fileformat}    GOOD
    IF    ${format_eval}
        Save changes and reset    3    5
    ELSE
        Read From Terminal Until    ERROR
    END

Select Attempt Secure Boot Option
    [Documentation]    Selects the Attempt Secure Boot Option
    ...    in the Secure Boot Configuration Submenu
    Press key n times    1    ${ARROW_DOWN}
    ${out}=    Read From Terminal
    ${is_selected}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    X
    IF    not ${is_selected}
        Press key n times    1    ${ENTER}
    END

Clear Attempt Secure Boot Option
    [Documentation]    Deselects the Attempt Secure Boot Option
    ...    in the Secure Boot Configuration Submenu
    Press key n times    1    ${ARROW_DOWN}
    ${out}=    Read From Terminal
    ${is_selected}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    X
    IF    ${is_selected}
        Press key n times    1    ${ENTER}
    END

Restore Initial DUT Connection Method
    [Documentation]    We need to go back to pikvm control when going back from OS to firmware
    ${initial_method_defined}=    Get Variable Value    ${initial_dut_connection_method}
    Return From Keyword If    '${initial_method_defined}' == 'None'
    IF    '${initial_dut_connection_method}' == 'pikvm'
        Set Global Variable    ${dut_connection_method}    pikvm
        # We need this when going back from SSH to PiKVM
        Remap keys variables to PiKVM
    END

Enter Device Manager Submenu
    [Documentation]    Enter to the Device Manager submenu which should be
    ...                located in the Setup Menu.
    ${menu_construction}=    Get Setup Menu Construction
    ${index}=    Get Index From List    ${menu_construction}    Device Manager
    Press key n times and enter    ${index}    ${ARROW_DOWN}

Enter Secure Boot Configuration Submenu
    [Documentation]    Enter to the Secure Boot Configuration submenu which
    ...                should be located in the Setup Menu.

    ${menu_construction}=    Get Setup Menu Construction
    ${index}=    Get Index From List    ${menu_construction}    Secure Boot Configuration
    Press key n times and enter    2    ${ARROW_DOWN}

Boot .EFI File From UEFI shell
    [Arguments]    ${filename}    ${expected_result}
    [Documentation]    Boots given efi file in UEFI shell using PiKVM,
    ...                and checks the result
    Sleep    3s
    Write Bare Into Terminal    fs0:
    Write Bare Into Terminal    \n
    Sleep    1s
    Write Bare Into Terminal    ${filename}
    Write Bare Into Terminal    \n
    Read From Terminal Until    ${expected_result}

Get Boot Menu Construction
   [Documentation]    Keyword allows to get and return boot menu construction.
   ...    Getting boot menu contruction is carried out in the following basis:
   ...    1. Get serial output, which shows Boot menu with all elements,
   ...    headers and whitespaces.
   ...    2. Split serial output string and create list.
   ...    3. Create empty list for detected elements of menu.
   ...    4. Add to the new list only elements which are not whitespaces
   ...    5. Remove from new list menu header and footer (header always
   ...    occupies three lines, footer -4)
    ${menu}=    Read From Terminal Until    exit
    ${menu}=    Remove String    ${menu}    \r
    @{menu_lines}=    Split String    ${menu}    \n
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        # Replace multiple spaces with a single one
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        # Remove leading and trailing spaces
        ${line}=   Strip String    ${line}
        # Drop leading and trailing pipes
        ${line}=   Strip String    ${line}    characters=|
        # Remove leading and trailing spaces
        ${line}=   Strip String    ${line}
        # If the resulting line is not empty, add it as a bootable entry
        ${length}=    Get Length    ${line}
        Run Keyword If    ${length} > 0    Append To List    ${menu_construction}    ${line}
    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[3:-4]
    [Return]    ${menu_construction}


Get Setup Menu Construction
    [Arguments]    ${checkpoint}=Select Entry
   [Documentation]    Keyword allows to get and return setup menu construction.
   ...    Getting setup menu contruction is carried out in the following basis:
   ...    1. Get serial output, which shows Boot menu with all elements,
   ...    headers and whitespaces.
   ...    2. Split serial output tring and create list.
   ...    3. Create empty list for detected elements of menu.
   ...    4. Add to the new list only elements which are not whitespaces and
   ...    not menu frames.
   ...    5. Remove from new list menu header and footer (header always
   ...    occupies one line, footer -3)
    ${menu}=    Read From Terminal Until    ${checkpoint}
    @{menu_lines}=    Split String    ${menu}    \n
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        ${line}=    Strip String    ${line}
        ${line}=    Remove String    ${line}    -    \\    \    /    |    <    >
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        IF    "${line}"!="${EMPTY}" and "${line}"!="${SPACE}"
            ${line}=    Get Substring    ${line}    1
            Append To List    ${menu_construction}    ${line}
        END
    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[3:-1]
    [Return]    ${menu_construction}

Get Setup Submenu Construction
   [Documentation]    Keyword allows to get and return setup menu construction.
   ...    Getting setup menu contruction is carried out in the following basis:
   ...    1. Get serial output, which shows Boot menu with all elements,
   ...    headers and whitespaces.
   ...    2. Split serial output tring and create list.
   ...    3. Create empty list for detected elements of menu.
   ...    4. Add to the new list only elements which are not whitespaces and
   ...    not menu frames.
   ...    5. Remove from new list menu header and footer (header always
   ...    occupies one line, footer -3)
   [Arguments]    ${checkpoint}=Press ESC to exit.    ${description_lines}=1
    ${menu}=    Read From Terminal Until    ${checkpoint}
    @{menu_lines}=    Split String    ${menu}    \n
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        ${line}=    Strip String    ${line}
        ${line}=    Remove String    ${line}    -    \\    \    /    |    <    >
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        IF    "${line}"!="${EMPTY}" and "${line}"!="${SPACE}"
            ${line}=    Get Substring    ${line}    1
            Append To List    ${menu_construction}    ${line}
        END
    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[${description_lines}:-1]
    [Return]    ${menu_construction}

Remove Entry From List
    [Arguments]    ${input_list}    ${regexp}
    @{output_list}=    Create List
    FOR    ${item}    IN    @{input_list}
        ${is_match}=    Run Keyword And Return Status    Should Not Match Regexp    ${item}    ${regexp}
        Run Keyword If    ${is_match}    Append To List    ${output_list}    ${item}
    END
    [Return]    ${output_list}

Get Secure Boot Configuration Submenu Construction
   [Documentation]    Keyword allows to get and return Secure Boot menu construction.
    ${menu}=    Read From Terminal Until    Reset Secure Boot Keys
    @{menu_lines}=    Split To Lines    ${menu}
    # TODO: make it a generic keyword, to remove all possible control strings
    # from menu constructions
    @{menu_lines}=    Remove Entry From List    ${menu_lines}    .*Move Highlight.*
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        ${line}=    Remove String    ${line}    -    \\    \    /    |    <    >
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        IF    "${line}"!="${EMPTY}" and "${line}"!=" "
            ${line}=    Strip String    ${line}
            Append To List    ${menu_construction}    ${line}
        END
    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[1:]
    [Return]    ${menu_construction}

Get File Explorer Submenu Construction
   [Documentation]    Keyword allows to get and return File Explorer menu construction.
    Read From Terminal Until    NEW FILE
    ${menu}=    Read From Terminal Until    Move Highlight
    @{menu_lines}=    Split To Lines    ${menu}
    # TODO: make it a generic keyword, to remove all possible control strings
    # from menu constructions
    @{menu_lines}=    Remove Entry From List    ${menu_lines}    .*Move Highlight.*
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        ${line}=    Remove String    ${line}    -    \\    \    /    |    <    >
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        IF    "${line}"!="${EMPTY}" and "${line}"!=" "
            ${line}=    Strip String    ${line}
            Append To List    ${menu_construction}    ${line}
        END

    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[1:]
    [Return]    ${menu_construction}

Get Enroll Signature Submenu Construction
    [Documentation]    Keyword allows to get and return File Explorer menu construction.
    ${menu}=    Read From Terminal Until    Discard Changes and Exit
    @{menu_lines}=    Split To Lines    ${menu}
    # TODO: make it a generic keyword, to remove all possible control strings
    # from menu constructions
    @{menu_lines}=    Remove Entry From List    ${menu_lines}    .*Move Highlight.*
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        ${line}=    Remove String    ${line}    -    \\    \    /    |    <    >
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        IF    "${line}"!="${EMPTY}" and "${line}"!=" "
            ${line}=    Strip String    ${line}
            Append To List    ${menu_construction}    ${line}
        END

    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[1:]
    [Return]    ${menu_construction}

Get Index of Matching option in menu
    [Documentation]    This keyword returns the index of element that matches
    ...    one in given menu
    [Arguments]    ${menu_construction}    ${option}
    FOR    ${element}    IN    @{menu_construction}
        ${matches}=    Run Keyword And Return Status    Should Match    ${element}    *${option}*
        IF    ${matches}
            ${option}=    Set Variable    ${element}
            BREAK
        END
    END
    ${index}=    Get Index From List    ${menu_construction}    ${option}
    [Return]    ${index}

Reenter menu
    [Documentation]    Returns to the previous menu and enters the same one
    ...                again
    [Arguments]    ${forward}=${False}
    IF    ${forward} == True
        Press key n times    1    ${ENTER}
        Sleep    1s
        Press key n times    1    ${ESC}
    ELSE
        Press key n times    1    ${ESC}
        Sleep    1s
        Press key n times    1    ${ENTER}
    END

Type in the password
    [Documentation]    Operation for typing in the password
    [Arguments]    @{keys_password}
    FOR    ${key}    IN    @{keys_password}
        Write Bare Into Terminal    ${key}
        Sleep    0.5s
    END
    Press key n times    1    ${ENTER}

Type in new disk password
    [Documentation]    Types in new disk password when prompted. The actual
    ...                password is passed as list of keys.
    [Arguments]    @{keys_password}
    Read From Terminal Until    your new password
    Sleep    0.5s
    # FIXME: Often the TCG OPAL test fails to enter Setup Menu after typing
    # password, and the default boot path proceeds instead. Pressing Setup Key
    # at this point allows to enter Setup Menu much more reliably.
    Press key n times    1    ${setup_menu_key}
    FOR    ${i}    IN RANGE    0    2
        Type in the password    @{keys_password}
        Sleep    1s
    END

Type in BIOS password
    [Documentation]    Types in password in general BIOS prompt
    [Arguments]    @{keys_password}
    Read From Terminal Until    password
    Sleep    0.5s
    Type in the password    @{keys_password}

Type in disk password
    [Documentation]    Types in the disk password
    [Arguments]    @{keys_password}
    Read From Terminal Until    Unlock
    Sleep    0.5s
    # FIXME: See a comment in: Type in new disk password
    Press key n times    1    ${setup_menu_key}
    Type in the password    @{keys_password}
    Press key n times    1    ${ENTER}

Remove disk password
    [Documentation]    Removes disk password
    [Arguments]    @{keys_password}
    Enter Device Manager Submenu
    Enter TCG Drive Management Submenu
    # if we want to remove password, we can assume that it is turned on so, we
    # don't have to check all the options
    Log    Select entry: Admin Revert to factory default and Disable
    Press key n times    1    ${ENTER}
    Press key n times and enter    4    ${ARROW_DOWN}
    Save changes and reset    3
    Read From Terminal Until    Unlock
    FOR    ${i}    IN RANGE    0    2
        Type in the password    @{keys_password}
        Sleep   0.5s
    END
    Press key n times    1    ${setup_menu_key}

Go back and select menu
    [Arguments]    ${menu}
    [Documentation]    Returns to the previous menu and enters the one defined
    ...                in the argument
    Press key n times    1    ${ESC}
    Enter submenu in Tianocore    ${menu}

Change to next option in setting
    [Arguments]    ${setting}
    [Documentation]    Changes given setting option to next in the list of
    ...                possible options.
    Enter submenu in Tianocore    ${setting}
    Press key n times and enter    1    ${ARROW_DOWN}

Change numeric value of setting
    [Arguments]    ${setting}    ${value}
    [Documentation]    Changes numeric value of ${setting} present in menu to
    ...                ${value}
    Enter submenu in Tianocore    ${setting}    description_lines=2
    Write Bare Into Terminal    ${value}
    Press key n times    1    ${ENTER}

Skip if menu option not available
    [Arguments]    ${submenu}
    [Documentation]    Skips the test if given submenu is not available in the
    ...                menu
    ${res}=    Check if submenu exists Tianocore    ${submenu}
    Skip If    not ${res}
    Reenter menu
    Sleep    1s
    Telnet.Read Until    Esc=Exit

Get Option Value
    [Arguments]    ${option}    ${checkpoint}=ESC to exit
    [Documentation]    Reads given ${option} in Tianocore menu and returns its
    ...                value
    ${out}=    Read From Terminal Until    ${checkpoint}
    ${option_value}=    Get Option Value From Output    ${out}    ${option}
    [Return]    ${option_value}

Save changes and boot to OS
    [Arguments]    ${nesting_level}=2
    [Documentation]    Saves current UEFI settings and continues booting to OS.
    ...                ${nesting_level} is crucial, because it depicts where
    ...                Continue button is located.
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Press key n times    ${nesting_level}   ${ESC}
    Enter submenu in Tianocore    Continue    checkpoint=Continue    description_lines=6


Boot operating system
    [Documentation]    Keyword allows boot operating system installed on the
    ...    DUT. Takes as an argument operating system name.
    [Arguments]    ${operating_system}
    IF    '${dut_connection_method}' == 'SSH'    Return From Keyword
    Set Local Variable    ${is_system_installed}    ${False}
    Enter Boot Menu Tianocore
    ${menu_construction}=    Get Boot Menu Construction
    ${is_system_installed}=    Evaluate    "${operating_system}" in """${menu_construction}"""
    IF    not ${is_system_installed}
        FAIL    Test case marked as Failed\nRequested OS (${operating_system}) has not been installed
    END
    ${system_index}=    Get Index From List    ${menu_construction}    ${operating_system}
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}

Boot system or from connected disk
    [Arguments]    ${system_name}
    [Documentation]    Tries to boot ${system_name}. If it is not possible then it tries
    ...    to boot from connected disk set up in config
    IF    '${dut_connection_method}' == 'SSH'    Return From Keyword
    Enter Boot Menu Tianocore
    ${menu_construction}=    Get Boot Menu Construction
    ${is_system_present}=    Evaluate    "${system_name}" in """${menu_construction}"""
    IF    not ${is_system_present}
        ${ssd_list}=    Get Current CONFIG list param    Storage_SSD    boot_name
        ${ssd_list_length}=    Get Length    ${ssd_list}
        IF    ${ssd_list_length} == 0
            ${hdd_list}=    Get Current CONFIG list param    HDD_Storage    boot_name
            ${hdd_list_length}=    Get Length    ${hdd_list}
            IF    ${hdd_list_length} == 0
                FAIL    "System was not found and there are no disk connected"
            END
            ${disk_name}=    Set Variable    ${hdd_list[0]}
        ELSE
            ${disk_name}=    Set Variable    ${ssd_list[0]}
        END
        ${system_index}=    Get Index From List    ${menu_construction}    ${disk_name}
        Run Keyword If    ${system_index} == -1    Fail    Disk: ${disk_name} not found in Boot Menu
    ELSE
        ${system_index}=    Get Index From List    ${menu_construction}    ${system_name}
    END
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}

Login to Linux
    [Documentation]    Universal login to one of the supported linux systems:
    ...                Ubuntu or Debian.
    IF    '${dut_connection_method}' == 'pikvm'
        Read From Terminal Until    login:
        Set Global Variable    ${dut_connection_method}    SSH
    END
    IF    '${dut_connection_method}' == 'SSH'
        Login to Linux via SSH    ${device_ubuntu_username}    ${device_ubuntu_password}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        Login to Linux via OBMC    root    root
    ELSE
        Login to Linux over serial console    ${device_ubuntu_username}    ${device_ubuntu_password}
    END

Login to Linux via OBMC
    [Documentation]    Login to Linux via OBMC
    [Arguments]    ${username}    ${password}    ${timeout}=180
    Set DUT Response Timeout  300s
    Read From Terminal Until    debian login:
    Write Into Terminal    ${username}
    Read From Terminal Until    Password:
    Write Into Terminal    ${password}
    Set Prompt For Terminal    root@debian:~#
    Read From Terminal Until Prompt

Login to Windows
    [Documentation]    Universal login to Windows.
    IF    '${dut_connection_method}' == 'pikvm'
        Set Global Variable    ${dut_connection_method}    SSH
    END
    IF    '${dut_connection_method}' == 'SSH'
        Login to Windows via SSH    ${device_windows_username}    ${device_windows_password}
    END

Serial root login Linux
    [Documentation]    Universal telnet login to one of supported linux systems:
    ...                Ubuntu, Voyage, Xen or Debian.
    [Arguments]    ${password}
    Telnet.Set Timeout    300
    Telnet.Set Prompt    \~#
    ${output}=    Telnet.Read Until    login:
    ${status1}=    Evaluate   "voyage" in """${output}"""
    ${status2}=    Evaluate   "debian login" in """${output}"""
    ${status3}=    Evaluate   "ubuntu login" in """${output}"""
    ${passwd}=    Set Variable If    ${status1}    voyage
    ...    ${status2}    debian
    ...    ${status3}    ubuntu
    ...    ${password}
    Telnet.Write Bare    \n
    Telnet.Login    root    ${passwd}

Serial user login Linux
    [Documentation]    Universal telnet login to Linux system
    [Arguments]    ${password}
    Telnet.Set Prompt   :~$
    Telnet.Set Timeout    300
    Telnet.Login    user    ${password}

Serial root login Linux and reboot
    [Documentation]    Telnet login to supported Linux system and reboot after
    ...                10 seconds.
    [Arguments]    ${password}
    Serial root login Linux    ${password}
    Sleep    10s
    Telnet.Write Bare    reboot\n
    # some services somtimes take too long,
    # leave the keyword when reboot has been completed
    Telnet.Read Until    reboot: Restarting system

# To Do: unify with keyword: Serial root login Linux
Login to Linux over serial console
    [Documentation]    Login to Linux over serial console, using provided
    ...                arguments as username and password respectively. The
    ...                optional timeout parameter can be used to specify how
    ...                long we want to wait for the login prompt.
    [Arguments]    ${username}    ${password}    ${device_ubuntu_user_prompt}=${device_ubuntu_user_prompt}    ${timeout}=180
    Set DUT Response Timeout    ${timeout} seconds
    Telnet.Read Until    login:
    Telnet.Write    ${username}
    Telnet.Read Until    Password:
    Telnet.Write    ${password}
    Telnet.Set Prompt    ${device_ubuntu_user_prompt}    prompt_is_regexp=False
    Telnet.Read Until Prompt

Login to Linux via SSH
    [Documentation]    Login to Linux via SSH by using provided arguments as
    ...                username and password respectively. The optional timeout
    ...                parameter can be used to specify how long we want to
    ...                wait for the login prompt.
    [Arguments]    ${username}    ${password}    ${timeout}=180    ${prompt}=${device_ubuntu_user_prompt}
    # We need this when switching from PiKVM to SSH
    Remap keys variables from PiKVM
    SSHLibrary.Open Connection    ${device_ip}    prompt=${prompt}
    SSHLibrary.Set Client Configuration    timeout=${timeout}    term_type=vt100    width=400    height=100    escape_ansi=True    newline=LF
    Wait Until Keyword Succeeds    12x    10s    SSHLibrary.Login    ${username}    ${password}

Login to Windows via SSH
    [Documentation]    Login to Windows via SSH by using provided arguments as
    ...                username and password respectively. The optional timeout
    ...                parameter can be used to specify how long we want to
    ...                wait for the login prompt.
    [Arguments]    ${username}    ${password}    ${timeout}=180
    SSHLibrary.Open Connection    ${device_ip}    prompt=${device_windows_user_prompt}
    SSHLibrary.Set Client Configuration    timeout=${timeout}    term_type=vt100    width=400    height=100    escape_ansi=True    newline=CRLF
    Wait Until Keyword Succeeds    12x    10s    SSHLibrary.Login    ${device_windows_username}    ${device_windows_password}

Login to Linux via SSH without password
    [Documentation]    Login to Linux via SSH without password
    [Arguments]    ${username}    ${prompt}
    Login to Linux via SSH    ${username}    ${EMPTY}    prompt=${prompt}

Setup SSH Connection On Windows
    [Documentation]    Try to login to Windows via SSH.
    FOR    ${INDEX}    IN RANGE    1    31
        TRY
            Login to Windows
            BREAK
        EXCEPT
            Log To Console    \n${INDEX} attempt to setup connection with test stand failed.
            IF    '${INDEX}' == '30'
                FAIL    Failed to establish ssh connection
            END
            Sleep    3s
        END
    END
