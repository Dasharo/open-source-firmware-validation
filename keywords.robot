*** Settings ***
Library         keywords.py
Library         osfv-scripts/snipeit/snipeit_robot.py
Library         Collections
Variables       platform-configs/fan-curve-config.yaml
Resource        pikvm-rest-api/pikvm_comm.robot
Resource        keys-and-keywords/flashrom.robot
Resource        pikvm-rest-api/pikvm_comm.robot


*** Keywords ***
# TODO: split this file into some manageable modules

Serial setup
    [Documentation]    Setup serial communication via telnet. Takes host and
    ...    ser2net port as an arguments.
    [Arguments]    ${host}    ${s2n_port}
    # provide ser2net port where serial was redirected
    Telnet.Open Connection
    ...    ${host}
    ...    port=${s2n_port}
    ...    newline=LF
    ...    terminal_emulation=True
    ...    terminal_type=vt100
    ...    window_size=400x100
    # remove encoding setup for terminal emulator pyte
    # Telnet.Set Encoding    errors=ignore
    Telnet.Set Timeout    180s

iPXE dhcp
    [Documentation]    Request IP address in iPXE shell. Takes network port
    ...    number as an argument. Default: request IP for all ports.
    [Arguments]    ${net_port}=${null}
    Write Bare Into Terminal    \n
    # make sure we are inside iPXE shell
    Read From Terminal Until    iPXE>

iPXE DTS
    [Documentation]    Enter DTS via iPXE.
    Set DUT Response Timeout    180s
    Wait Until Keyword Succeeds    3x    2s    iPXE dhcp
    Write Bare Into Terminal    chain http://boot.3mdeb.com/dts.ipxe\n    0.1

Check iPXE appears only once
    [Documentation]    Check the iPXE oprion appears only once in the boot
    ...    option list.
    ${menu_construction}=    Get Boot Menu Construction
    TRY
        Should Contain X Times    ${menu_construction}    ${ipxe_boot_entry}    1
    EXCEPT
        FAIL    Test case marked as Failed\nRequested boot option: (${ipxe_boot_entry}) appears not only once.
    END

Launch to DTS Shell
    [Documentation]    Launch to DTS via iPXE and open Shell.
    Enter iPXE
    iPXE DTS
    Set DUT Response Timeout    120s
    Read From Terminal Until    Enter an option
    Set DUT Response Timeout    30s
    Write Into Terminal    9
    Set Prompt For Terminal    bash-5.1#
    Read From Terminal Until Prompt
    # These could be removed once routes priorities in DTS are resolved.
    Sleep    10
    Remove Extra Default Route

Replace logo in firmware
    [Documentation]    Swap to custom logo in firmware on DUT using cbfstool according
    ...    to: https://docs.dasharo.com/guides/logo-customization
    [Arguments]    ${logo_file}
    Read FMAP and BOOTSPLASH regions internally    /tmp/firmware.rom
    # Remove the existing logo from the firmware image
    ${out}=    Execute Linux command    cbfstool /tmp/firmware.rom remove -r BOOTSPLASH -n logo.bmp
    # Add your desired bootlogo to the firmware image
    ${out}=    Execute Linux command
    ...    cbfstool /tmp/firmware.rom add -f ${logo_file} -r BOOTSPLASH -n logo.bmp -t raw -c lzma
    Should Not Contain    ${out}    Image is missing 'BOOTSPLASH' region
    Write BOOTSPLASH region internally    /tmp/firmware.rom

Read FMAP and BOOTSPLASH regions internally
    [Documentation]    Read BOOTSPLASH firmware on DUT using flashrom.
    [Arguments]    ${fw_file}
    ${out}=    Execute Linux command    flashrom -p internal --fmap -i FMAP -i BOOTSPLASH -r ${fw_file}    180
    Should contain    ${out}    Reading flash... done

Write BOOTSPLASH region internally
    [Documentation]    Flash BOOTSPLASH firmware region on DUT using flashrom.
    [Arguments]    ${fw_file}
    ${out}=    Execute Linux command    flashrom -p internal --fmap -i BOOTSPLASH -N -w ${fw_file}    180
    Should Contain Any    ${out}    VERIFIED    Chip content is identical to the requested image

Login to Linux
    [Documentation]    Universal login to one of the supported linux systems:
    ...    Ubuntu or Debian.
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
    Set DUT Response Timeout    300s
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
    ...    Ubuntu, Voyage, Xen or Debian.
    [Arguments]    ${password}
    Telnet.Set Timeout    300
    Telnet.Set Prompt    \~#
    ${output}=    Telnet.Read Until    login:
    ${status1}=    Evaluate    "voyage" in """${output}"""
    ${status2}=    Evaluate    "debian login" in """${output}"""
    ${status3}=    Evaluate    "ubuntu login" in """${output}"""
    ${passwd}=    Set Variable If    ${status1}    voyage
    ...    ${status2}    debian
    ...    ${status3}    ubuntu
    ...    ${password}
    Telnet.Write Bare    \n
    Telnet.Login    root    ${passwd}

Serial user login Linux
    [Documentation]    Universal telnet login to Linux system
    [Arguments]    ${password}
    Telnet.Set Prompt    :~$
    Telnet.Set Timeout    300
    Telnet.Login    user    ${password}

# To Do: unify with keyword: Serial root login Linux

Login to Linux over serial console
    [Documentation]    Login to Linux over serial console, using provided
    ...    arguments as username and password respectively. The
    ...    optional timeout parameter can be used to specify how
    ...    long we want to wait for the login prompt.
    [Arguments]
    ...    ${username}
    ...    ${password}
    ...    ${device_ubuntu_user_prompt}=${device_ubuntu_user_prompt}
    ...    ${timeout}=180
    Set DUT Response Timeout    ${timeout} seconds
    Telnet.Read Until    login:
    Telnet.Write    ${username}
    Telnet.Read Until    Password:
    Telnet.Write    ${password}
    Telnet.Set Prompt    ${device_ubuntu_user_prompt}    prompt_is_regexp=False
    Telnet.Read Until Prompt

Login to Linux via SSH
    [Documentation]    Login to Linux via SSH by using provided arguments as
    ...    username and password respectively. The optional timeout
    ...    parameter can be used to specify how long we want to
    ...    wait for the login prompt.
    [Arguments]    ${username}    ${password}    ${timeout}=180    ${prompt}=${device_ubuntu_user_prompt}
    # We need this when switching from PiKVM to SSH
    Remap keys variables from PiKVM
    SSHLibrary.Open Connection    ${device_ip}    prompt=${prompt}
    SSHLibrary.Set Client Configuration
    ...    timeout=${timeout}
    ...    term_type=vt100
    ...    width=400
    ...    height=100
    ...    escape_ansi=True
    ...    newline=LF
    Wait Until Keyword Succeeds    12x    10s    SSHLibrary.Login    ${username}    ${password}

Login to Windows via SSH
    [Documentation]    Login to Windows via SSH by using provided arguments as
    ...    username and password respectively. The optional timeout
    ...    parameter can be used to specify how long we want to
    ...    wait for the login prompt.
    [Arguments]    ${username}    ${password}    ${timeout}=180
    SSHLibrary.Open Connection    ${device_ip}    prompt=${device_windows_user_prompt}
    SSHLibrary.Set Client Configuration
    ...    timeout=${timeout}
    ...    term_type=vt100
    ...    width=400
    ...    height=100
    ...    escape_ansi=True
    ...    newline=CRLF
    Wait Until Keyword Succeeds
    ...    12x
    ...    10s
    ...    SSHLibrary.Login
    ...    ${device_windows_username}
    ...    ${device_windows_password}

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

Switch to root user
    [Documentation]    Switch to the root environment.
    # the "sudo -S" to pass password from stdin does not work correctly with
    # the su command and we need to type in the password
    Write Into Terminal    sudo su
    Read From Terminal Until    [sudo] password for ${device_ubuntu_username}:
    Write Into Terminal    ${device_ubuntu_password}
    Set Prompt For Terminal    ${device_ubuntu_root_prompt}
    Read From Terminal Until Prompt

Exit from root user
    [Documentation]    Exit from the root environment
    Write Into Terminal    exit
    Set Prompt For Terminal    ${device_ubuntu_user_prompt}
    Read From Terminal Until Prompt

Open Connection And Log In
    [Documentation]    Open SSH connection and login to session. Setup RteCtrl
    ...    REST API, serial connection and checkout used asset in
    ...    SnipeIt
    Check provided ip
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    SSHLibrary.Open Connection    ${rte_ip}    prompt=~#
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    RTE REST API Setup    ${rte_ip}    ${http_port}
    IF    'sonoff' == '${power_ctrl}'
        ${sonoff_ip}=    Get current RTE param    sonoff_ip
        Sonoff API Setup    ${sonoff_ip}
    END
    Serial setup    ${rte_ip}    ${rte_s2n_port}
    IF    '${snipeit}'=='no'    RETURN
    SnipeIt Checkout    ${rte_ip}

Check provided ip
    [Documentation]    Check the correctness of the provided ip address, if the
    ...    address is not found in the RTE list, fail the test.
    ${index}=    Set Variable    ${0}
    FOR    ${item}    IN    @{RTE_LIST}
        ${result}=    Evaluate    ${item}.get("ip")
        IF    '${result}'=='${rte_ip}'    RETURN
        ${index}=    Set Variable    ${index + 1}
    END
    Fail    rte_ip:${rte_ip} not found in the hardware configuration.

Open Connection And Log In OpenBMC
    [Documentation]    Keyword logs in OpenBMC via SSH.
    SSHLibrary.Open Connection    ${device_ip}    prompt=${open_bmc_root_prompt}
    SSHLibrary.Login    ${open_bmc_username}    ${open_bmc_password}
    Set DUT Response Timeout    300s

Establish Host Connection
    [Documentation]    Keyword allows to establish connection with the host
    ...    system from the OBMC console.
    Write Into Terminal    obmc-console-client

Log Out And Close Connection
    [Documentation]    Close all opened SSH, serial connections and checkin used
    ...    asset in SnipeIt.
    SSHLibrary.Close All Connections
    Telnet.Close All Connections
    IF    '${platform}'=='raptor-cs_talos2'    RETURN
    IF    '${snipeit}'=='yes'    SnipeIt Checkin    ${rte_ip}

Enter Petitboot And Return Menu
    [Documentation]    Keyword allows to enter the petitboot menu and returns
    ...    it contents
    Set DUT Response Timeout    500s
    Write Into Terminal    obmc-console-client
    Read From Terminal Until    Petitboot
    Sleep    1s
    Write Bare Into Terminal    ${ARROW_UP}
    Set DUT Response Timeout    20s
    Sleep    2s
    ${menu}=    Read From Terminal Until    Processing DHCP lease response
    RETURN    ${menu}

Enter Tianocore And Return Menu
    [Documentation]    Enter SeaBIOS and returns boot entry menu.
    Enter Boot Menu Tianocore
    ${menu}=    Read From Terminal Until    ESC to exit
    RETURN    ${menu}

Enter Boot Menu
    [Documentation]    Enter Boot Menu with key specified in platform-configs.
    IF    '${payload}' == 'seabios'
        Enter SeaBIOS
    ELSE IF    '${payload}' == 'tianocore'
        Enter Boot Menu Tianocore
    END

Enter Device Manager Submenu
    [Documentation]    Enter to the Device Manager submenu which should be
    ...    located in the Setup Menu.
    ${menu_construction}=    Get Setup Menu Construction
    ${index}=    Get Index From List    ${menu_construction}    Device Manager
    Press key n times and enter    ${index}    ${ARROW_DOWN}

Enter Secure Boot Configuration Submenu
    [Documentation]    Enter to the Secure Boot Configuration submenu which
    ...    should be located in the Setup Menu.

    ${menu_construction}=    Get Setup Menu Construction
    ${index}=    Get Index From List    ${menu_construction}    Secure Boot Configuration
    Press key n times and enter    2    ${ARROW_DOWN}

Select Attempt Secure Boot Option
    [Documentation]    Selects the Attempt Secure Boot Option
    ...    in the Secure Boot Configuration Submenu
    Press key n times    1    ${ARROW_DOWN}
    ${out}=    Read From Terminal
    ${is_selected}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    X
    IF    not ${is_selected}    Press key n times    1    ${ENTER}

Clear Attempt Secure Boot Option
    [Documentation]    Deselects the Attempt Secure Boot Option
    ...    in the Secure Boot Configuration Submenu
    Press key n times    1    ${ARROW_DOWN}
    ${out}=    Read From Terminal
    ${is_selected}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    X
    IF    ${is_selected}    Press key n times    1    ${ENTER}

Enter Setup Menu Tianocore
    [Documentation]    Enter Setup Menu with key specified in platform-configs.
    Read From Terminal Until    ${tianocore_string}
    IF    '${dut_connection_method}' == 'pikvm'
        Single Key PiKVM    ${setup_menu_key}
    ELSE
        Write Bare Into Terminal    ${setup_menu_key}
    END
    # wait for setup menu to appear
    # Read From Terminal Until    Continue

Reset in Setup Menu Tianocore
    [Documentation]    Enters reset option in setup menu
    ${menu_construction}=    Get Setup Menu Construction
    ${index}=    Get Index From List    ${menu_construction}    eset
    Press key n times and enter    ${index}    ${ARROW_DOWN}

Enter iPXE
    [Documentation]    Enter iPXE after device power cutoff.
    # TODO:    2 methods for entering iPXE (Ctrl-B and SeaBIOS)
    # TODO2:    problem with iPXE string (e.g. when 3 network interfaces are available)

    IF    '${payload}' == 'seabios'
        Enter SeaBIOS
        Sleep    0.5s
        ${setup}=    Telnet.Read
        ${lines}=    Get Lines Matching Pattern    ${setup}    ${ipxe_boot_entry}
        Telnet.Write Bare    ${lines[0]}
        Telnet.Read Until    ${ipxe_string}
        Telnet.Write Bare    ${ipxe_key}
        iPXE wait for prompt
    ELSE IF    '${payload}' == 'tianocore'
        Enter Boot Menu Tianocore
        Enter Submenu in Tianocore    option=${edk2_ipxe_string}
        Enter Submenu in Tianocore
        ...    option=iPXE Shell
        ...    checkpoint=${edk2_ipxe_checkpoint}
        ...    description_lines=${edk2_ipxe_start_pos}
        Set Prompt For Terminal    iPXE>
        Read From Terminal Until Prompt
    END

Get hostname ip
    [Documentation]    Returns local IP address of the DUT.
    # TODO: We do not necessarily need Internet to be reachable for the internal
    # addresses to be assigned. But if it is, the local IPs are definitely
    # already in place.
    Wait Until Keyword Succeeds    5x    1s    Check Internet Connection on Linux
    ${out_hostname}=    Execute Command in Terminal    hostname -I
    Should Not Contain    ${out_hostname}    link is not ready
    ${ip_address}=    String.Get Regexp Matches    ${out_hostname}    \\b192\\.168\\.\\d{1,3}\\.\\d{1,3}\\b
    Should Not Be Empty    ${ip_address}
    RETURN    ${ip_address[0]}

    # [Return]    ${ip_address.partition("\n")[0]}

Get firmware version from binary
    [Documentation]    Return firmware version from local firmware binary file.
    ...    Takes binary file path as an argument.
    [Arguments]    ${binary_path}
    ${coreboot_version1}=    Run    strings ${binary_path}|grep COREBOOT_ORIGIN_GIT_TAG|cut -d" " -f 3|tr -d '"'
    ${coreboot_version2}=    Run    strings ${binary_path}|grep CONFIG_LOCALVERSION|cut -d"=" -f 2|tr -d '"'
    ${coreboot_version3}=    Run    strings ${binary_path}|grep -w COREBOOT_VERSION|cut -d" " -f 3|tr -d '"'
    ${version_length1}=    Get Length    ${coreboot_version1}
    ${coreboot_version}=    Set Variable If    ${version_length1} == 0    ${coreboot_version2}    ${coreboot_version1}
    ${version_length}=    Get Length    ${coreboot_version}
    ${coreboot_version}=    Set Variable If    ${version_length} == 0    ${coreboot_version3}    ${coreboot_version}
    RETURN    ${coreboot_version}

Get firmware version from UEFI shell
    [Documentation]    Return firmware version from UEFI shell.
    Telnet.Set Timeout    90s
    Telnet.Read Until    Shell>
    Telnet.Write Bare    smbiosview -t 0
    Telnet.Write Bare    \n
    ${output}=    Telnet.Read Until    BiosSegment
    ${version}=    Get Lines Containing String    ${output}    BiosVersion
    RETURN    ${version.replace('BiosVersion: ', '')}

Get Firmware Version From Dmidecode
    ${output}=    Execute Linux command    dmidecode -t bios
    ${version_string}=    Get Lines Containing String    ${output}    Version:
    ${version}=    Fetch From Right    ${version_string}    ${SPACE}
    RETURN    ${version}

Get firmware version
    [Documentation]    Return firmware version via method supported by the
    ...    platform.
    # Boot platform into payload allowing to read flashed firmware version
    IF    '${FLASH_VERIFY_METHOD}'=='iPXE-boot'
        Boot Debian from iPXE    ${pxe_ip}    ${http_port}    ${filename}    ${debian_stable_ver}
    ELSE IF    '${FLASH_VERIFY_METHOD}'=='tianocore-shell'
        Tianocore One Time Boot    ${FLASH_VERIFY_OPTION}
    ELSE IF    '${FLASH_VERIFY_METHOD}'=='none'
        No Operation
    END
    # Read firmware version
    IF    '${FLASH_VERIFY_METHOD}'=='iPXE-boot'
        ${version}=    Get Firmware Version From Dmidecode
    ELSE IF    '${FLASH_VERIFY_METHOD}'=='tianocore-shell'
        ${version}=    Get firmware version from UEFI shell
    ELSE IF    '${FLASH_VERIFY_METHOD}'=='none'
        ${version}=    Get firmware version from binary    ${fw_file}
    ELSE
        ${version}=    Set Variable    ${None}
    END
    RETURN    ${version}

Enter Boot Menu Tianocore
    [Documentation]    Enter Boot Menu with tianocore boot menu key mapped in
    ...    keys list.
    Read From Terminal Until    ${tianocore_string}
    IF    '${dut_connection_method}' == 'pikvm'
        Single Key PiKVM    ${boot_menu_key}
    ELSE
        Write Bare Into Terminal    ${boot_menu_key}
    END

Enter UEFI Shell Tianocore
    [Documentation]    Enter UEFI Shell in Tianocore by specifying its position
    ...    in the list.
    Set Local Variable    ${is_shell_available}    ${False}
    ${menu_construction}=    Get Boot Menu Construction
    ${is_shell_available}=    Evaluate    "UEFI Shell" in """${menu_construction}"""
    IF    not ${is_shell_available}
        FAIL    Test case marked as Failed\nBoot menu does not contain position for entering UEFI Shell
    END
    ${system_index}=    Get Index From List    ${menu_construction}    UEFI Shell
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}

Enter submenu in Tianocore
    [Documentation]    Enter chosen option. Generic keyword.
    [Arguments]    ${option}    ${checkpoint}=ESC to exit    ${description_lines}=1
    ${rel_pos}=    Get relative menu position    ${option}    ${checkpoint}    ${description_lines}
    Press key n times and enter    ${rel_pos}    ${ARROW_DOWN}

Get Menu Reference Tianocore
    [Documentation]    Get first entry from Tianocore Boot Manager menu.
    [Arguments]    ${raw_menu}    ${bias}
    ${lines}=    Get Lines Matching Pattern    ${raw_menu}    *[qwertyuiopasdfghjklzxcvbnm]*
    ${lines}=    Split To Lines    ${lines}
    ${bias}=    Convert To Integer    ${bias}
    ${first_entry}=    Get From List    ${lines}    ${bias}
    ${first_entry}=    Strip String    ${first_entry}    characters=1234567890()
    ${first_entry}=    Strip String    ${first_entry}
    RETURN    ${first_entry}

Enter One Time Boot in Tianocore
    [Documentation]    Enter One Time Boot option in Tianocore (edk2).
    Telnet.Set Timeout    20 seconds
    ${rel_pos}=    Get Relative Menu Position    Standard English    One Time Boot    Select Entry
    Press key n times and enter    ${rel_pos - 8}    ${ARROW_DOWN}
    Telnet.Read Until    Device Path

Tianocore One Time Boot
    [Arguments]    ${option}
    Enter Boot Menu Tianocore
    Enter submenu in Tianocore    ${option}

Reset to Defaults Tianocore
    [Documentation]    Resets all Tianocore options to defaults. It is invoked
    ...    by pressing F9 and confirming with 'y' when in option
    ...    setting menu.
    Telnet.Read Until    exit.
    Press key n times    1    ${F9}
    Telnet.Read Until    ignore.
    Write Bare Into Terminal    y

Enter Dasharo System Features
    [Documentation]    Enters Dasharo System Features after the machine has been
    ...    powered on.
    Enter Setup Menu Tianocore
    ${menu_construction}=    Get Setup Menu Construction
    ${index}=    Get Index From List    ${menu_construction}    Dasharo System Features
    Press key n times and enter    ${index}    ${ARROW_DOWN}

Enter Setup Menu Option
    [Documentation]    Enter given Setup Menu Tianocore option after entering
    ...    Setup Menu Tianocore
    [Arguments]    ${option}
    ${menu_construction}=    Get Setup Menu Construction
    ${index}=    Get Index From List    ${menu_construction}    ${option}
    Press key n times and enter    ${index}    ${ARROW_DOWN}

Check if submenu exists Tianocore
    [Documentation]    Checks if given submenu exists
    [Arguments]    ${submenu}
    ${out}=    Telnet.Read Until    exit.
    ${result}=    Run Keyword And Return Status    Should Contain    ${out}    ${submenu}
    RETURN    ${result}

Reenter menu
    [Documentation]    Returns to the previous menu and enters the same one
    ...    again
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
    ...    password is passed as list of keys.
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
        Sleep    0.5s
    END
    Press key n times    1    ${setup_menu_key}

Change to next option in setting
    [Documentation]    Changes given setting option to next in the list of
    ...    possible options.
    [Arguments]    ${setting}
    Enter submenu in Tianocore    ${setting}
    Press key n times and enter    1    ${ARROW_DOWN}

Change numeric value of setting
    [Documentation]    Changes numeric value of ${setting} present in menu to
    ...    ${value}
    [Arguments]    ${setting}    ${value}
    Enter submenu in Tianocore    ${setting}    description_lines=2
    Write Bare Into Terminal    ${value}
    Press key n times    1    ${ENTER}

Skip if menu option not available
    [Documentation]    Skips the test if given submenu is not available in the
    ...    menu
    [Arguments]    ${submenu}
    ${res}=    Check if submenu exists Tianocore    ${submenu}
    Skip If    not ${res}
    Reenter menu
    Sleep    1s
    Telnet.Read Until    Esc=Exit

Get Option Value
    [Documentation]    Reads given ${option} in Tianocore menu and returns its
    ...    value
    [Arguments]    ${option}    ${checkpoint}=ESC to exit
    ${out}=    Read From Terminal Until    ${checkpoint}
    ${option_value}=    Get Option Value From Output    ${out}    ${option}
    RETURN    ${option_value}

Save changes and boot to OS
    [Documentation]    Saves current UEFI settings and continues booting to OS.
    ...    ${nesting_level} is crucial, because it depicts where
    ...    Continue button is located.
    [Arguments]    ${nesting_level}=2
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Press key n times    ${nesting_level}    ${ESC}
    Enter submenu in Tianocore    Continue    checkpoint=Continue    description_lines=6

Save changes and reset
    [Documentation]    Saves current UEFI settings and restarts. ${nesting_level}
    ...    is how deep user is currently in the settings.
    ...    ${main_menu_steps_to_reset} means how many times should
    ...    arrow down be pressed to get to the Reset option in main
    ...    settings menu
    [Arguments]    ${nesting_level}=2    ${main_menu_steps_to_reset}=5
    Press key n times    1    ${F10}
    Write Bare Into Terminal    y
    Press key n times    ${nesting_level}    ${ESC}
    Press key n times and enter    ${main_menu_steps_to_reset}    ${ARROW_DOWN}

Check the presence of WiFi Card
    [Documentation]    Checks the if WiFi card is visible for operating system.
    ...    Returns True if presence is detected.
    ${terminal_result}=    Execute Command In Terminal    lspci | grep '${wifi_card_ubuntu}'
    ${result}=    Run Keyword And Return Status    Should Not Be Empty    ${terminal_result}
    RETURN    ${result}

Check the presence of Bluetooth Card
    [Documentation]    Checks the if Bluetooth card is visible for OS.
    ...    Returns True if presence is detected.
    ${terminal_result}=    Execute Command In Terminal    lsusb | grep '${bluetooth_card_ubuntu}'
    ${result}=    Run Keyword And Return Status    Should Not Be Empty    ${terminal_result}
    RETURN    ${result}

Check if Tianocore setting is enabled in current menu
    [Documentation]    Checks if option ${option} is enabled, returns True/False
    [Arguments]    ${option}
    ${option_value}=    Get Option Value    ${option}
    ${enabled}=    Run Keyword And Return Status    Should Be Equal    ${option_value}    [X]
    RETURN    ${enabled}

Get relative menu position
    [Documentation]    Evaluate and return relative menu entry position
    ...    described in the argument.
    [Arguments]    ${entry}    ${checkpoint}    ${bias}=1
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

Press key n times and enter
    [Documentation]    Enter specified in the first argument times the specified
    ...    in the second argument key and then press Enter.
    [Arguments]    ${n}    ${key}
    Press key n times    ${n}    ${key}
    IF    '${dut_connection_method}' == 'pikvm'
        Single Key PiKVM    Enter
    ELSE
        Write Bare Into Terminal    ${ENTER}
    END

Press key n times
    [Documentation]    Enter specified in the first argument times the specified
    ...    in the second argument key.
    [Arguments]    ${n}    ${key}
    FOR    ${INDEX}    IN RANGE    0    ${n}
        IF    '${dut_connection_method}' == 'pikvm'
            Single Key PiKVM    ${key}
        ELSE
            Write Bare Into Terminal    ${key}
        END
    END

Get current RTE
    [Documentation]    Returns RTE index from RTE list taken as an argument.
    ...    Returns -1 if CPU ID not found in variables.robot.
    [Arguments]    @{rte_list}
    ${con}=    SSHLibrary.Open Connection    ${rte_ip}
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    ${cpuid}=    SSHLibrary.Execute Command
    ...    cat /proc/cpuinfo |grep Serial|cut -d":" -f2|tr -d " "
    ...    connection=${con}
    ${index}=    Set Variable    ${0}
    FOR    ${item}    IN    @{rte_list}
        IF    '${item.cpuid}' == '${cpuid}'    RETURN    ${index}
        ${index}=    Set Variable    ${index + 1}
    END
    RETURN    ${-1}

Get current RTE param
    [Documentation]    Returns current RTE parameter value specified in the argument.
    [Arguments]    ${param}
    ${idx}=    Get current RTE    @{RTE_LIST}
    Should Not Be Equal    ${idx}    ${-1}    msg=RTE not found in hw-matrix
    &{rte}=    Get From List    ${RTE_LIST}    ${idx}
    RETURN    ${rte}[${param}]

Get current CONFIG start index
    [Documentation]    Returns current CONFIG start index from CONFIG_LIST
    ...    specified in the argument required for slicing list.
    ...    Returns -1 if CONFIG not found in variables.robot.
    [Arguments]    ${config_list}
    ${rte_cpuid}=    Get current RTE param    cpuid
    Should Not Be Equal    ${rte_cpuid}    ${-1}    msg=RTE not found in hw-matrix
    ${index}=    Set Variable    ${0}
    FOR    ${config}    IN    @{config_list}
        ${result}=    Evaluate    ${config}.get("cpuid")
        IF    '${result}'=='${rte_cpuid}'    RETURN    ${index}
        ${index}=    Set Variable    ${index + 1}
    END
    RETURN    ${-1}

Get current CONFIG stop index
    [Documentation]    Returns current CONFIG stop index from CONFIG_LIST
    ...    specified in the argument required for slicing list.
    ...    Returns -1 if CONFIG not found in variables.robot.
    [Arguments]    ${config_list}    ${start}
    ${length}=    Get Length    ${config_list}
    ${index}=    Set Variable    ${start + 1}
    FOR    ${config}    IN    @{config_list[${index}:]}
        ${result}=    Evaluate    ${config}.get("cpuid")
        IF    '${result}'!='None'    RETURN    ${index}
        IF    '${index}'=='${length - 1}'    RETURN    ${index + 1}
        ${index}=    Set Variable    ${index + 1}
    END
    RETURN    ${-1}

Get current CONFIG
    [Documentation]    Returns current config as a list variable based on start
    ...    and stop indexes.
    [Arguments]    ${config_list}
    ${start}=    Get current CONFIG start index    ${CONFIG_LIST}
    Should Not Be Equal    ${start}    ${-1}    msg=Current CONFIG not found in hw-matrix
    ${stop}=    Get current CONFIG stop index    ${CONFIG_LIST}    ${start}
    Should Not Be Equal    ${stop}    ${-1}    msg=Current CONFIG not found in hw-matrix
    ${config}=    Get Slice From List    ${config_list}    ${start}    ${stop}
    RETURN    ${config}

Get current CONFIG item
    [Documentation]    Returns current CONFIG item specified in the argument.
    ...    Returns -1 if CONFIG item not found in variables.robot.
    [Arguments]    ${item}
    ${config}=    Get current CONFIG    ${CONFIG_LIST}
    ${length}=    Get Length    ${config}
    Should Be True    ${length} > 1
    FOR    ${element}    IN    @{config[1:]}
        IF    '${element.type}'=='${item}'    RETURN    ${element}
    END
    RETURN    ${-1}

Get current CONFIG item param
    [Documentation]    Returns current CONFIG item parameter specified in the
    ...    arguments.
    [Arguments]    ${item}    ${param}
    ${device}=    Get current CONFIG item    ${item}
    RETURN    ${device.${param}}

Get slot count
    [Documentation]    Returns count parameter value from slot key specified in
    ...    the argument if found, otherwise return 0.
    [Arguments]    ${slot}
    ${isFound}=    Evaluate    "count" in """${slot}"""
    ${return}=    Set Variable If
    ...    ${isFound}==False    0
    ...    ${isFound}==True    ${slot.count}
    RETURN    ${return}

Get USB slot count
    [Documentation]    Returns count parameter value from USB slot key specified
    ...    in the argument if found, otherwise return 0.
    [Arguments]    ${slots}
    ${isFound1}=    Evaluate    "USB_Storage" in """${slots.slot1}"""
    ${isFound2}=    Evaluate    "USB_Storage" in """${slots.slot2}"""
    IF    ${isFound1}==True
        ${count1}=    Get slot count    ${slots.slot1}
    ELSE
        ${count1}=    Evaluate    0
    END
    IF    ${isFound2}==True
        ${count2}=    Get slot count    ${slots.slot2}
    ELSE
        ${count2}=    Evaluate    0
    END
    ${sum}=    Evaluate    ${count1}+${count2}
    RETURN    ${sum}

Get all USB
    [Documentation]    Returns number of attached USB storages in current CONFIG.
    ${conf}=    Get Current CONFIG    ${CONFIG_LIST}
    ${isFound}=    Evaluate    "USB_Storage" in """${conf}"""
    IF    ${isFound}==True
        ${usb_count}=    Get Current CONFIG item param    USB_Storage    count
    ELSE
        ${usb_count}=    Evaluate    ""
    END
    IF    ${isFound}==True
        ${count_usb}=    Evaluate    ${usb_count}
    ELSE
        ${count_usb}=    Evaluate    0
    END
    ${isFound}=    Evaluate    "USB_Expander" in """${conf}"""
    IF    ${isFound}==True
        ${external}=    Get Current CONFIG item    USB_Expander
    ELSE
        ${external}=    Evaluate    ""
    END
    IF    ${isFound}==True
        ${external_count}=    Get USB slot count    ${external}
    ELSE
        ${external_count}=    Evaluate    0
    END
    ${count}=    Evaluate    ${count_usb}+${external_count}
    RETURN    ${count}

Get boot timestamps
    [Documentation]    Returns all boot timestamps from cbmem tool.
    # fix for LT1000 and protectli platforms (output without tabs)
    ${hostname_ip}=    Wait Until Keyword Succeeds    1 min    5 sec    Get hostname ip
    ${debian_ssh_index}=    SSHLibrary.Open Connection    ${hostname_ip}    prompt=~#
    SSHLibrary.Switch Connection    ${debian_ssh_index}
    SSHLibrary.Login    root    debian
    ${timestamps}=    SSHLibrary.Execute Command    cbmem -T
    SSHLibrary.Close Connection
    # switch to RTE ssh connection
    SSHLibrary.Switch Connection    ${1}
    # FIXME: missing tabs in the first half of below output:
    # ${timestamps}=    Telnet.Execute Command    cbmem -T
    ${timestamps}=    Split String    ${timestamps}    \n
    ${timestamps}=    Get Slice From List    ${timestamps}    0    -1
    RETURN    ${timestamps}

Log boot timestamps
    [Documentation]    Log to console formatted boot timestamps. Takes timestamp
    ...    string and string length as an arguments.
    [Arguments]    ${timestamps}    ${length}
    FOR    ${number}    IN RANGE    0    ${length}
        ${line}=    Get From List    ${timestamps}    ${number}
        ${line}=    Split String    ${Line}    \
        ${duration}=    Get From List    ${line}    2
        ${duration}=    Convert To Number    ${duration}
        ${name}=    Get Slice From List    ${line}    3
        ${name}=    Evaluate    " ".join(${name})
        ${duration_formatted}=    Evaluate    ${duration}/1000000
        Log    ${name}: ${duration_formatted} s (${duration} ns)
    END

Get duration from timestamps
    [Documentation]    Returns number representing full boot duration. Takes
    ...    cbmem string timestamp and string length as an arguments.
    [Arguments]    ${timestamps}    ${length}
    ${index}=    Evaluate    ${length}-1
    ${line}=    Get From List    ${timestamps}    ${index}
    ${line}=    Split String    ${line}    \
    ${duration}=    Get From List    ${line}    1
    ${duration}=    Convert To Number    ${duration}
    RETURN    ${duration}

Prepare lm-sensors
    [Documentation]    Install lm-sensors and probe sensors.
    Detect or Install Package    lm-sensors
    Execute Command In Terminal    yes | sudo sensors-detect
    IF    '${platform}' == 'raptor-cs_talos2'
        Execute Command In Terminal    modprobe w83795
    END

Get Fan Speed
    [Documentation]    Returns current fan speed as int.
    # Detect or Install Package    lm-sensors
    # Execute Command In Terminal    yes | sudo sensors-detect
    # Execute Command In Terminal    modprobe w83795
    ${speed}=    Execute Command In Terminal    sensors | grep fan1
    ${speed}=    Get Lines Containing String    ${speed}    RPM)
    ${speed_split}=    Split String    ${speed}
    ${rpm}=    Get From List    ${speed_split}    1
    ${rpm}=    Convert To Number    ${rpm}
    RETURN    ${rpm}

Get CPU Frequency MAX
    [Documentation]    Get max CPU Frequency.
    ${freq}=    Execute Command In Terminal    lscpu | grep "CPU max"
    ${freq}=    Split String    ${freq}
    ${freq}=    Get From List    ${freq}    3
    ${freq}=    Split String    ${freq}    separator=,
    ${freq}=    Get From List    ${freq}    0
    ${freq}=    Convert To Number    ${freq}
    RETURN    ${freq}

Get CPU Frequency MIN
    [Documentation]    Get min CPU Frequency.
    ${freq}=    Execute Command In Terminal    lscpu | grep "CPU min"
    ${freq}=    Split String    ${freq}
    ${freq}=    Get From List    ${freq}    3
    ${freq}=    Split String    ${freq}    separator=,
    ${freq}=    Get From List    ${freq}    0
    ${freq}=    Convert To Number    ${freq}
    RETURN    ${freq}

Get CPU Temperature CURRENT
    [Documentation]    Get current CPU temperature.
    ${temperature}=    Execute Command In Terminal    sensors | grep "Package id 0"
    ${temperature}=    Fetch From Left    ${temperature}    °C
    ${temperature}=    Fetch From Right    ${temperature}    +
    ${temperature}=    Convert To Number    ${temperature}
    RETURN    ${temperature}

Get CPU frequencies in Ubuntu
    [Documentation]    Get all CPU frequencies in Ubuntu OS. Keyword returns
    ...    list of current CPU frequencies
    @{frequency_list}=    Create List
    ${output}=    Execute Command In Terminal    cat /proc/cpuinfo
    ${output}=    Get Lines Containing String    ${output}    clock
    @{frequencies}=    Split To Lines    ${output}
    FOR    ${frequency}    IN    @{frequencies}
        ${frequency}=    Evaluate    re.sub(r'(?s)[^0-9]*([1-9][0-9]*)[,.][0-9]+MHz', r'\\1', $frequency)
        ${frequency}=    Convert To Number    ${frequency}
        Append To List    ${frequency_list}    ${frequency}
    END
    RETURN    @{frequency_list}

Check If CPU not stucks on Initial Frequency in Ubuntu
    [Documentation]    Check that CPU not stuck on initial frequency.
    ${is_cpu_stucks}=    Set Variable    ${False}
    ${are_frequencies_equal}=    Set Variable    ${True}
    @{frequencies}=    Get CPU frequencies in Ubuntu
    ${first_frequency}=    Get From List    ${frequencies}    0
    FOR    ${frequency}    IN    @{frequencies}
        IF    ${frequency} != ${first_frequency}
            ${are_frequencies_equal}=    Set Variable    ${False}
        ELSE
            ${are_frequencies_equal}=    Set Variable    ${None}
        END
        IF    '${are_frequencies_equal}'=='False'    BREAK
    END
    IF    '${are_frequencies_equal}'=='False'
        Pass Execution    CPU does not stuck on initial frequency
    END
    IF    ${first_frequency}!=${initial_cpu_frequency}
        Pass Execution    CPU does not stuck on initial frequency
    ELSE
        FAIL    CPU stucks on initial frequency: ${initial_cpu_frequency}
    END

Check If CPU not stucks on Initial Frequency in Windows
    [Documentation]    Check that CPU not stuck on initial frequency.
    ${out}=    Execute Command In Terminal
    ...    (Get-CimInstance CIM_Processor).MaxClockSpeed*((Get-Counter -Counter "\\Processor Information(_Total)\\% Processor Performance").CounterSamples.CookedValue/100)
    FOR    ${number}    IN RANGE    0    10
        ${out2}=    Execute Command In Terminal
        ...    (Get-CimInstance CIM_Processor).MaxClockSpeed*((Get-Counter -Counter "\\Processor Information(_Total)\\% Processor Performance").CounterSamples.CookedValue/100)
        Should Not be equal    ${out}    ${out2}
    END

Check CPU frequency in Windows
    [Documentation]    Check that CPU is running on expected frequency.
    ${freq_max}=    Execute Command In Terminal    (Get-CimInstance CIM_Processor).MaxClockSpeed
    ${freq_max}=    Convert To Number    ${freq_max}
    FOR    ${number}    IN RANGE    0    10
        ${freq_current}=    Execute Command In Terminal
        ...    (Get-CimInstance CIM_Processor).MaxClockSpeed*((Get-Counter -Counter "\\Processor Information(_Total)\\% Processor Performance").CounterSamples.CookedValue)/100
        ${freq_current}=    Convert To Number    ${freq_current}
        Run Keyword And Continue On Failure    Should Be True    ${freq_max} > ${freq_current}
    END

Stress Test
    [Documentation]    Proceed with the stress test.
    [Arguments]    ${time}=60s
    Detect or Install Package    stress-ng
    Execute Command In Terminal    stress-ng --cpu 1 --timeout ${time} &> /dev/null &

Flash firmware
    [Documentation]    Flash platform with firmware file specified in the
    ...    argument. Keyword fails if file size doesn't match target
    ...    chip size.
    [Arguments]    ${fw_file}
    ${file_size}=    Run    ls -l ${fw_file} | awk '{print $5}'
    IF    '${file_size}'!='${flash_size}'
        FAIL    Image size doesn't match the flash chip's size!
    END
    IF    '${dut_connection_method}' == 'Telnet'
        Put File    ${fw_file}    /tmp/coreboot.rom
    END
    Sleep    2s
    ${platform}=    Get current RTE param    platform
    IF    '${platform[:3]}' == 'apu'
        Flash apu
    ELSE IF    '${platform[:13]}' == 'optiplex-7010'
        Flash firmware optiplex
    ELSE IF    '${platform[:8]}' == 'KGPE-D16'
        Flash KGPE-D16
    ELSE IF    '${platform[:10]}' == 'novacustom'
        Flash Device via Internal Programmer    ${fw_file}
    ELSE IF    '${platform[:16]}' == 'protectli-vp4630'
        Flash Protectli VP4620 External
    ELSE IF    '${platform[:16]}' == 'protectli-vp4650'
        Flash Protectli VP4650 External
    ELSE IF    '${platform[:16]}' == 'protectli-vp4670'
        Flash Protectli VP4670 External
    ELSE IF    '${platform[:16]}' == 'protectli-vp2420'
        Flash Protectli VP2420 Internal
    ELSE IF    '${platform[:16]}' == 'protectli-vp2410'
        Flash Protectli VP2410 External
    ELSE IF    '${platform[:19]}' == 'msi-pro-z690-a-ddr5'
        Flash MSI-PRO-Z690-A-DDR5
    ELSE IF    '${platform[:24]}' == 'msi-pro-z690-a-wifi-ddr4'
        Flash MSI-PRO-Z690-A-WiFi-DDR4
    ELSE IF    '${platform[:46]}' == 'msi-pro-z790-p-ddr5'
        Flash MSI-PRO-Z790-P-DDR5
    ELSE
        Fail    Flash firmware not implemented for platform ${platform}
    END
    # First boot after flashing may take longer than usual
    Set DUT Response Timeout    180s

Prepare Test Suite
    [Documentation]    Keyword prepares Test Suite by importing specific
    ...    platform configuration keywords and variables and
    ...    preparing connection with the DUT based on used
    ...    transmission protocol. Keyword used in all [Suite Setup]
    ...    sections.
    IF    '${config}' == 'crystal'
        Import Resource    ${CURDIR}/platform-configs/vitro_crystal.robot
    ELSE IF    '${config}' == 'pv30'
        Import Resource    ${CURDIR}/dev-tests/operon/configs/pv30.robot
    ELSE IF    '${config}' == 'yocto'
        Import Resource    ${CURDIR}/dev-tests/operon/configs/yocto.robot
    ELSE IF    '${config}' == 'raspbian'
        Import Resource    ${CURDIR}/dev-tests/operon/configs/raspbian.robot
    ELSE
        Import Resource    ${CURDIR}/platform-configs/${config}.robot
    END
    IF    '${dut_connection_method}' == 'SSH'
        Prepare To SSH Connection
    ELSE IF    '${dut_connection_method}' == 'Telnet'
        Prepare To Serial Connection
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        Prepare To OBMC Connection
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        Prepare To PiKVM Connection
    ELSE
        FAIL    Unknown connection method for config: ${config}
    END

Prepare To SSH Connection
    [Documentation]    Keyword prepares Test Suite by setting current platform
    ...    and its ip to the global variables, configuring the
    ...    SSH connection, Setup RteCtrl REST API and checkout used
    ...    asset in SnipeIt . Keyword used in [Suite Setup]
    ...    sections if the communication with the platform based on
    ...    the SSH protocol
    # tu leci zmiana, musimy brać platformy zgodnie z tym co zostało pobrane w dasharo
    Set Global Variable    ${platform}    ${config}
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    # Sonoff API Setup    ${sonoff_ip}

Prepare To Serial Connection
    [Documentation]    Keyword prepares Test Suite by opening SSH connection to
    ...    the RTE, opening serial connection with the DUT, setting
    ...    current platform to the global variable and setting the
    ...    DUT to start state. Keyword used in [Suite Setup]
    ...    sections if the communication with the platform based on
    ...    the serial connection
    Open Connection And Log In
    ${platform}=    Get current RTE param    platform
    Set Global Variable    ${platform}
    Get DUT To Start State

Prepare To OBMC Connection
    [Documentation]    Keyword prepares Test Suite by opening open-bmc
    ...    connection, setting current platform to the global
    ...    variable and setting the DUT to start state. Keyword
    ...    used in [Suite Setup] sections if the communication with
    ...    the platform based on the open-bmc
    Set Global Variable    ${platform}    ${config}
    Set Global Variable    ${OPENBMC_HOST}    ${device_ip}
    Import Resource    ${CURDIR}/openbmc-test-automation/lib/rest_client.robot
    Import Resource    ${CURDIR}/openbmc-test-automation/lib/utils.robot
    Import Resource    ${CURDIR}/openbmc-test-automation/lib/state_manager.robot
    Set Platform Power State
    Open Connection And Log In OpenBMC
    Set DUT Response Timeout    300s
    Set Chassis Power State    on
    Establish Host Connection

Prepare To PiKVM Connection
    [Documentation]    Keyword prepares Test Suite by opening SSH connection to
    ...    the RTE, opening serial connection with the DUT (for
    ...    gathering output from platform), configuring PiKVM,
    ...    setting current platform to the global variable and
    ...    setting the DUT to start state. Keyword used in
    ...    [Suite Setup] sections if the communication with the
    ...    platform based on the serial connection (platform
    ...    output) and PiKVM (platform input)
    Remap keys variables to PiKVM
    Open Connection And Log In
    ${platform}=    Get current RTE param    platform
    Set Global Variable    ${platform}
    Get DUT To Start State

Remap keys variables to PiKVM
    [Documentation]    Updates keys variables from keys.robot to be compatible
    ...    with PiKVM
    Set Global Variable    ${ARROW_UP}    ArrowUp
    Set Global Variable    ${ARROW_DOWN}    ArrowDown
    Set Global Variable    ${ARROW_RIGHT}    ArrowRight
    Set Global Variable    ${ARROW_LEFT}    ArrowLeft
    Set Global Variable    ${F1}    F1
    Set Global Variable    ${F2}    F2
    Set Global Variable    ${F3}    F3
    Set Global Variable    ${F4}    F4
    Set Global Variable    ${F5}    F5
    Set Global Variable    ${F6}    F6
    Set Global Variable    ${F7}    F7
    Set Global Variable    ${F8}    F8
    Set Global Variable    ${F9}    F9
    Set Global Variable    ${F10}    F10
    Set Global Variable    ${F11}    F11
    Set Global Variable    ${F12}    F12
    Set Global Variable    ${ESC}    Escape
    Set Global Variable    ${ENTER}    Enter
    Set Global Variable    ${BACKSPACE}    Backspace
    Set Global Variable    ${SPACE}    Space
    Set Global Variable    ${DELETE}    Delete
    Set Global Variable    ${Digit0}    Digit0
    Set Global Variable    ${Digit1}    Digit1
    Set Global Variable    ${Digit2}    Digit2
    Set Global Variable    ${Digit3}    Digit3
    Set Global Variable    ${Digit4}    Digit4
    Set Global Variable    ${Digit5}    Digit5
    Set Global Variable    ${Digit6}    Digit6
    Set Global Variable    ${Digit7}    Digit7
    Set Global Variable    ${Digit8}    Digit8
    Set Global Variable    ${Digit9}    Digit9

Remap keys variables from PiKVM
    [Documentation]    Updates keys variables from PiKVM ones to the ones
    ...    as defined in keys.robot
    Import Resource    ${CURDIR}/keys.robot

Get DUT To Start State
    [Documentation]    Clears telnet buffer and get Device Under Test to start
    ...    state (RTE Relay On).
    Telnet.Read
    ${result}=    Get Power Supply State
    IF    '${result}'=='low'    Turn On Power Supply

Turn On Power Supply
    ${pc}=    Get Variable Value    ${POWER_CTRL}
    IF    'sonoff' == '${pc}'
        ${state}=    Sonoff Power On
    ELSE
        ${state}=    RteCtrl Relay
    END

Power Cycle On
    [Documentation]    Clears telnet buffer and perform full power cycle with
    ...    RTE relay set to ON.
    ${pc}=    Get Variable Value    ${POWER_CTRL}
    IF    'sonoff' == '${pc}'
        Sonoff Power Cycle On
    ELSE IF    'obmcutil' == '${pc}'
        OBMC Power Cycle On
    ELSE
        Rte Relay Power Cycle On
    END

Rte Relay Power Cycle On
    [Documentation]    Clears telnet buffer and perform full power cycle with
    ...    RTE relay set to ON.
    Telnet.Read
    ${result}=    RteCtrl Relay
    IF    ${result} == 0
        Run Keywords    Sleep    4s    AND    Telnet.Read    AND    RteCtrl Relay
    END

OBMC Power Cycle On
    [Documentation]    Clears obmc-console-client buffer and perform full power
    ...    cycle with Chassis and Host State Control
    ${host_state}=    Get Host State
    ${chassis_state}=    Get Chassis Power State
    IF    '${host_state.lower()}'=='on' or '${chassis_state.lower()}'=='on'
        Set Chassis Power State    off
        Sleep    15s
    END
    Read From Terminal
    Power On

OBMC Power Cycle Off
    [Documentation]    Clears obmc-console-client buffer and perform full power
    ...    cycle with Chassis and Host State Control
    ${host_state}=    Get Host State
    ${chassis_state}=    Get Chassis Power State
    IF    '${host_state.lower()}'=='on' or '${chassis_state.lower()}'=='on'
        Set Chassis Power State    off
        Sleep    15s
    END
    Read From Terminal

Sonoff Power Cycle On
    [Documentation]    Clear telnet buffer and perform full power cycle with
    ...    Sonoff
    Telnet.Read
    Sonoff Power Off
    Sonoff Power On
    Sleep    15
    # Send "Power On" signal resembling power button press
    Power On

Power Cycle Off
    [Documentation]    Power cycle off power supply using the supported
    ...    method.
    ${pc}=    Get Variable Value    ${POWER_CTRL}
    IF    'sonoff' == '${pc}'
        Sonoff Power Cycle Off
    ELSE IF    'obmcutil' == '${pc}'
        OBMC Power Cycle Off
    ELSE
        Rte Relay Power Cycle Off
    END
    Telnet.Close All Connections
    Serial setup    ${rte_ip}    ${rte_s2n_port}

Rte Relay Power Cycle Off
    [Documentation]    Performs full power cycle with RTE relay set to OFF.
    # sleep for DUT Start state in Suite Setup
    Sleep    1s
    ${result}=    Get RTE Relay State
    IF    '${result}' == 'high'    RteCtrl Relay

Sonoff Power Cycle Off
    Sonoff Power On
    Sonoff Power Off

Get Relay State
    [Documentation]    Returns the power relay state depending on the supported
    ...    method.
    ${pc}=    Get Variable Value    ${POWER_CTRL}
    IF    'sonoff' == '${pc}'
        ${state}=    Get Sonoff State
    ELSE
        ${state}=    Get RTE Relay State
    END
    RETURN    ${state}

Get RTE Relay State
    [Documentation]    Returns the RTE relay state through REST API.
    ${state}=    RteCtrl Get GPIO State    0
    RETURN    ${state}

Get Power Supply State
    [Documentation]    Returns the power supply state.
    ${pc}=    Get Variable Value    ${POWER_CTRL}
    IF    '${pc}'=='sonoff'
        ${state}=    Get Sonoff State
    ELSE
        ${state}=    Get Relay State
    END
    RETURN    ${state}

Get Sound Devices Windows
    [Documentation]    Get and return all sound devices in Windows OS using
    ...    PowerShell
    ${out}=    Execute Command In Terminal    Get-WmiObject -class Win32_SoundDevice
    RETURN    ${out}

Get USB Devices Windows
    [Documentation]    Get and return all sound devices in Windows OS using
    ...    PowerShell
    ${out}=    Execute Command In Terminal    Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
    RETURN    ${out}

Get CPU temperature and CPU fan speed
    [Documentation]    Get the current CPU temperature in Celsius degrees and
    ...    the current CPU fan speed in rpms.
    ${output}=    Telnet.Execute Command    sensors w83795g-i2c-1-2f |grep fan1 -A 16
    ${rpm}=    Get Lines Containing String    ${output}    fan1
    ${rpm}=    Split String    ${rpm}    ${SPACE}
    ${rpm}=    Get Substring    ${rpm}    -8    -7
    ${rpm}=    Get From List    ${rpm}    0
    ${rpm_value}=    Convert To Integer    ${rpm}
    ${temperature}=    Get Lines Containing String    ${output}    temp7
    ${temperature}=    Split String    ${temperature}    ${SPACE}
    ${temperature}=    Get Substring    ${temperature}    -8    -7
    ${temperature}=    Get From List    ${temperature}    0
    ${temperature}=    Remove String    ${temperature}    +
    ${temperature}=    Remove String    ${temperature}    °
    ${temperature}=    Remove String    ${temperature}    C
    ${temperature_value}=    Convert To Number    ${temperature}
    RETURN    ${rpm_value}    ${temperature_value}

Execute Linux command without output
    [Documentation]    Execute linux command over serial console. Do not return
    ...    standard output. There is one optional argument. The
    ...    timeout_before defines how long we wait till we have a
    ...    clear prompt to enter the command.
    [Arguments]    ${cmd}    ${timeout}=10
    Set DUT Response Timeout    ${timeout} seconds
    # Make sure that we have a clear prompt before executing next command
    # Clear the buffer as well
    Read From Terminal
    Write Into Terminal    echo
    Read From Terminal Until Prompt
    Write Into Terminal    ${cmd}

Execute Linux command
    [Documentation]    Execute linux command over serial console and return the
    ...    standard output. There are two optional arguments. The
    ...    timeout_before defines how long we wait till we have a
    ...    clear prompt to enter the command. The timeout_after
    ...    defines for how long we wait until the next prompt (until
    ...    the executed command finishes).
    [Arguments]    ${cmd}    ${timeout_after}=30
    Write Into Terminal    ${cmd}
    Set DUT Response Timeout    ${timeout_after} seconds
    ${out}=    Read From Terminal Until Prompt
    RETURN    ${out}

Execute Linux tpm2_tools command
    [Documentation]    Execute linux tpm2_tools command, check that no errors
    ...    and warnings apper and return the standard output.
    ...    There are two optional arguments. The timeout_before
    ...    defines how long we wait till we have a clear prompt to
    ...    enter the command. The timeout_after defines for how long
    ...    we wait until the next prompt (until the executed command
    ...    finishes).
    [Arguments]    ${cmd}    ${timeout_after}=30
    Write Into Terminal    ${cmd}
    Set DUT Response Timeout    ${timeout_after} seconds
    ${out}=    Read From Terminal Until Prompt
    Should Not Contain Any    ${out}    WARN    ERROR
    RETURN    ${out}

Restore Initial DUT Connection Method
    [Documentation]    We need to go back to pikvm control when going back from OS to firmware
    ${initial_method_defined}=    Get Variable Value    ${initial_dut_connection_method}
    IF    '${initial_method_defined}' == 'None'    RETURN
    IF    '${initial_dut_connection_method}' == 'pikvm'
        Set Global Variable    ${dut_connection_method}    pikvm
        # We need this when going back from SSH to PiKVM
        Remap keys variables to PiKVM
    END

Execute Poweroff Command
    Write Into Terminal    poweroff
    Set DUT Response Timeout    180 seconds
    Restore Initial DUT Connection Method

Execute Reboot Command
    Write Into Terminal    reboot
    Set DUT Response Timeout    180 seconds
    Restore Initial DUT Connection Method

Check Displays Windows
    [Documentation]    Check and return all displays with PowerShell in Windows.
    # '-2' = 'Unknown'
    # '-1' = 'Unknown'
    # '0' = 'VGA'
    # '1' = 'S-Video'
    # '2' = 'Composite'
    # '3' = 'Component'
    # '4' = 'DVI'
    # '5' = 'HDMI'
    # '6' = 'LVDS'
    # '8' = 'D-Jpn'
    # '9' = 'SDI'
    # '10' = 'DisplayPort (external)'
    # '11' = 'DisplayPort (internal)'
    # '12' = 'Unified Display Interface'
    # '13' = 'Unified Display Interface (embedded)'
    # '14' = 'SDTV dongle'
    # '15' = 'Miracast'
    # '16' = 'Internal'
    # '2147483648' = 'Internal'
    ${out}=    Execute Command In Terminal    Get-WmiObject WmiMonitorConnectionParams -Namespace root/wmi
    RETURN    ${out}

Check HDMI Windows
    [Documentation]    Check if HDMI display is recognized by Windows OS.
    ${out}=    Check Displays Windows
    Should Contain    ${out}    VideoOutputTechnology : 5

Check docking station HDMI Windows
    [Documentation]    Check if docking station HDMI display is recognized by
    ...    Windows OS.
    ${out}=    Check Displays Windows
    Should Contain Any    ${out}    VideoOutputTechnology : 12    VideoOutputTechnology : 10

Check DP Windows
    [Documentation]    Check if DP display is recognized by Windows OS.
    ${out}=    Check Displays Windows
    IF    '${platform}' == 'protectli-vp4630'
        Should Contain Any
        ...    ${out}
        ...    VideoOutputTechnology : 10
        ...    VideoOutputTechnology : 11
        ...    VideoOutputTechnology : 2147483648
    ELSE
        Should Contain Any    ${out}    VideoOutputTechnology : 10    VideoOutputTechnology : 11
    END

Check docking station DP Windows
    [Documentation]    Check if docking station DP display is recognized by
    ...    Windows OS.
    ${out}=    Check Displays Windows
    Should Contain Any    ${out}    VideoOutputTechnology : 10    VideoOutputTechnology : 11

Check Internal LCD Windows
    [Documentation]    Check if internal LCD is recognized by Windows OS.
    ${out}=    Check Displays Windows
    Should Contain Any    ${out}    VideoOutputTechnology : 2147483648    VideoOutputTechnology : 16

Check external HDMI in Linux
    [Documentation]    Keyword checks if an external HDMI device is visible
    ...    in Linux OS.
    ${out}=    Execute Linux command    cat /sys/class/drm/card0/*HDMI*/status
    Should Contain    ${out}    connected

Check docking station HDMI in Linux
    [Documentation]    Keyword checks if an docking station HDMI device is
    ...    visiblein Linux OS.
    TRY
        ${out}=    Execute Linux command    cat /sys/class/drm/card0-DP-7/status
        Should Not Contain    ${out}    disconnected
        Should Contain    ${out}    connected
    EXCEPT
        ${out}=    Execute Linux command    cat /sys/class/drm/card0-DP-1/status
        Should Not Contain    ${out}    disconnected
        Should Contain    ${out}    connected
    END

Check external DP in Linux
    [Documentation]    Keyword checks if an external Display Port device is
    ...    visible in Linux OS.
    ${out}=    Execute Linux command    cat /sys/class/drm/card0-DP-1/status
    Should Not Contain    ${out}    disconnected
    Should Contain    ${out}    connected

Check docking station DP in Linux
    [Documentation]    Keyword checks if an docking station Display Port device
    ...    is visible in Linux OS.
    ${out}=    Execute Linux command    cat /sys/class/drm/card0-DP-7/status
    Should Not Contain    ${out}    disconnected
    Should Contain    ${out}    connected

Device detection in Linux
    [Documentation]    Keyword checks if a given device name as a parameter is
    ...    visible in Linux OS.
    [Arguments]    ${device}
    ${out}=    Execute Linux command    libinput list-devices | grep ${device}
    Should Contain    ${out}    ${device}

Check charge level in Linux
    [Documentation]    Keyword checks the charge level in Linux OS.
    Set Local Variable    ${cmd}    cat /sys/class/power_supply/BAT0/charge_now
    ${out}=    Execute Linux command    ${cmd}
    # capacity in uAh
    ${capacity}=    Convert To Integer    ${out}
    Should Be True    ${capacity} <= ${clevo_battery_capacity}
    Should Be True    ${capacity} > 0

Check charging state in Linux
    [Documentation]    Keyword checks the charging state in Linux OS.
    ${out}=    Execute Linux command    cat /sys/class/power_supply/BAT0/status
    Should Contain Any    ${out}    Charging    Full

Check charging state Not charging in Linux
    [Documentation]    Keyword checks if the battery state is Not charging
    ...    in Linux OS.
    ${out}=    Execute Linux command    cat /sys/class/power_supply/BAT0/status
    Should Contain Any    ${out}    Not charging

Check charging state in Windows
    [Documentation]    Keyword checks the charging state in Windows OS.
    ${out}=    Execute Command in Terminal    Get-WmiObject win32_battery
    Should Contain    ${out}    BatteryStatus${SPACE * 15}: 2

Discharge the battery until target level in Linux
    [Documentation]    Keyword stresses the CPU to discharge the battery until
    ...    the target charge level is reached.
    [Arguments]    ${target}
    Detect or Install Package    stress-ng
    WHILE    True
        ${out}=    Execute Command In Terminal    cat /sys/class/power_supply/BAT0/capacity
        IF    ${out} <= ${target}    BREAK
        Execute Command In Terminal    stress-ng --cpu 0 --timeout 10s
    END

Check battery percentage in Linux
    [Documentation]    Keyword check the battery percentage in Linux OS.
    ${percentage}=    Execute Command In Terminal    cat /sys/class/power_supply/BAT0/capacity
    RETURN    ${percentage}

Charge battery until target level in Linux
    [Documentation]    Keyword periodically checks battery charge level until it
    ...    reaches defined target in Linux OS.
    [Arguments]    ${target}
    FOR    ${i}    IN RANGE    2000
        ${out}=    Check battery percentage in Linux
        Sleep    5
        IF    ${out} == ${target}    BREAK
    END
    Run Keyword Unless    ${out} == ${target}
    Log    Could not charge battery to specified level within timeout.

Turn On ACPI_CALL module in Linux
    [Documentation]    Keyword turns on acpi_call module in Linux OS.
    Execute Linux command    modprobe acpi_call

Set Brightness in Linux
    [Documentation]    Keyword sets desired brightness in Linux OS.
    ...    Brightness value range: [0 , 48000].
    [Arguments]    ${brightness}
    Execute Linux command    echo ${brightness} > /sys/class/backlight/intel_backlight/brightness

Get current Brightness in Linux
    [Documentation]    Keyword gets current brightness in Linux OS and returns
    ...    it as an integer.
    Set Local Variable    ${cmd}    cat /sys/class/backlight/intel_backlight/brightness
    ${out1}=    Execute Linux command    ${cmd}
    ${brightness}=    Convert To Integer    ${out1}
    RETURN    ${brightness}

Brightness up button in Linux
    [Documentation]    Keyword increases the screen brightness in Linux OS.
    # simulating brightness up hotkey
    Execute Linux command    echo '\\_SB.PCI0.LPCB.EC0._Q12' | tee /proc/acpi/call
    Sleep    2s

Brightness down button in Linux
    [Documentation]    Keyword decreases the screen brightness in Linux OS.
    # simulating brightness down hotkey
    Execute Linux command    echo '\\_SB.PCI0.LPCB.EC0._Q11' | tee /proc/acpi/call
    Sleep    2s

Toggle Camera in Linux
    [Documentation]    Keyword toggles camera by simulating the function
    ...    button in Linux OS.
    # simulating camera hotkey
    Execute Linux command    echo '\\_SB.PCI0.LPCB.EC0._Q13' | tee /proc/acpi/call
    Sleep    2s

Get WiFi block status
    [Documentation]    Keyword returns True if WiFi is soft or hard blocked.
    ...    Soft or hard blocking check depends on the given
    ...    argument.
    ...    Mode - Soft or Hard
    [Arguments]    ${mode}=Soft
    ${wifi_status}=    Execute Linux command    rfkill list 0
    ${status}=    Run Keyword And Return Status    Should Contain    ${wifi_status}    ${mode} blocked: yes
    RETURN    ${status}

Get Bluetooth block status
    [Documentation]    Keyword returns True if Bluetooth is soft or hard blocked.
    ...    Soft or hard blocking check depends on the given
    ...    argument.
    ...    Mode - Soft or Hard
    [Arguments]    ${mode}=Soft
    ${bt_status}=    Execute Linux command    rfkill list 0
    ${status}=    Run Keyword And Return Status    Should Contain    ${bt_status}    ${mode} blocked: yes
    RETURN    ${status}

Toggle flight mode in Linux
    [Documentation]    Keyword toggles the airplane mode by simulating the
    ...    function button usage in Linux OS.
    # simulating airplane mode hotkey
    Execute Linux command    echo '\\_SB.PCI0.LPCB.EC0._Q14' | tee /proc/acpi/call
    Sleep    2s

List devices in Linux
    [Documentation]    Keyword lists devices in Linux OS and returns output.
    ...    The port is given as an argument:
    ...    ${port}: pci or usb
    [Arguments]    ${port}
    ${out}=    Execute Linux command    ls${port}
    RETURN    ${out}

Detect Docking Station in Linux
    [Documentation]    Keyword check the docking station is detected correctly.
    ${out}=    List devices in Linux    usb
    Should Contain    ${out}    Realtek Semiconductor Corp. RTL8153 Gigabit Ethernet Adapter
    Should Contain    ${out}    Prolific Technology, Inc. USB SD Card Reader
    Should Contain    ${out}    VIA Labs, Inc. USB3.0 Hub

Check if files are identical in Linux
    [Documentation]    Keyword takes two files as arguments and compares them
    ...    using sha256sum in Linux OS. Returns True if both files
    ...    have an identical content.
    [Arguments]    ${file1}    ${file2}
    ${out1}=    Execute Linux command    sha256sum ${file1}
    ${out2}=    Execute Linux command    sha256sum ${file2}
    ${splitted1}=    Split String    ${out1}
    ${sha256sum1}=    Get From List    ${splitted1}    1
    ${splitted2}=    Split String    ${out2}
    ${sha256sum2}=    Get From List    ${splitted2}    1
    ${status}=    Run Keyword And Return Status    Should Be Equal    ${sha256sum1}    ${sha256sum2}
    RETURN    ${status}

Scan for Wi-Fi in Linux
    [Documentation]    Turn on Wi-Fi then scan in search of company network.
    Execute Linux command without output    nmcli radio wifi on
    Write Into Terminal    nmcli device wifi rescan
    Set DUT Response Timeout    60 seconds
    Write Into Terminal    nmcli device wifi list
    Read From Terminal Until    ${3mdeb_wifi_network}

Scan for Bluetooth in Linux
    [Documentation]    Turn on Bluetooth then scan in search of company network.
    ${out}=    Execute Linux command    bluetoothctl power on
    Should Contain    ${out}    Changing power on succeeded
    Set DUT Response Timeout    60 seconds
    Write Into Terminal    bluetoothctl scan on
    Sleep    60s
    Write Bare Into Terminal    ${CTRL_C}
    ${out}=    Read From Terminal Until Prompt
    Should Contain    ${out}    Discovery started

Get Video Controllers Windows
    [Documentation]    Get and return all video controllers on the device using
    ...    PowerShell on Windows OS.
    ${out}=    Execute Command In Terminal
    ...    Get-WmiObject -Class Win32_VideoController | Select Description, Name, Status
    RETURN    ${out}

Check NVIDIA Power Management in Linux
    [Documentation]    Check whether the NVIDIA Graphics Card power management
    ...    works correctly (card should powers on only if it's in
    ...    use).
    Sleep    20s
    ${out}=    Execute Linux command    cat /sys/class/drm/card1/device/power/runtime_status
    Should Contain    ${out}    suspended
    Execute Linux command    lspci | grep -i nvidia | cat
    ${out}=    Execute Linux command    cat /sys/class/drm/card1/device/power/runtime_status
    Should Contain    ${out}    active
    Sleep    20s
    ${out}=    Execute Linux command    cat /sys/class/drm/card1/device/power/runtime_status
    Should Contain    ${out}    suspended

Get Battery Power Level Windows
    [Documentation]    Check and return battery power level in % using PowerShell
    ...    on Windows OS.
    ${out}=    Execute Command In Terminal
    ...    Get-CimInstance -ClassName Win32_Battery | Select-Object -ExpandProperty EstimatedChargeRemaining
    ${out}=    Convert To Integer    ${out}
    RETURN    ${out}

Check If Battery Is Charging Windows
    [Documentation]    Check if battery is currently charging using PowerShell
    ...    on Windows OS.
    ${out}=    Execute Command In Terminal
    ...    Get-CimInstance -ClassName Win32_Battery | Select-Object -Property BatteryStatus
    Should Contain    ${out}    2

Get Pointing Devices Windows
    [Documentation]    Get and return all devices used to move mouse across the
    ...    screen using PowerShell on Windows OS.
    ${out}=    Execute Command In Terminal
    ...    Get-CimInstance -ClassName Win32_PointingDevice | Select-Object -Property DeviceID, Caption
    RETURN    ${out}

Identify Disks in Linux
    [Documentation]    Check whether any disk is recognized in Linux system
    ...    and identify their vndor and model.
    ${out}=    Execute Linux command    lsblk --nodeps --output NAME
    @{disks}=    Get Regexp matches    ${out}    sd.
    ${disks_info}=    Create List
    FOR    ${disk}    IN    @{disks}
        ${vendor}=    Execute Linux command    cat /sys/class/block/${disk}/device/vendor
        ${model}=    Execute Linux command    cat /sys/class/block/${disk}/device/model
        ${vendor_name}=    Fetch From Left    ${vendor}    \r\n
        ${model_name}=    Fetch From Left    ${model}    \r\n
        ${vendor_name}=    Fetch From Right    ${vendor_name}    \r
        ${model_name}=    Fetch From Right    ${model_name}    \r
        # ${vendor_name}=    Fetch From Left    ${vendor_name}    \x20
        # ${model_name}=    Fetch From Left    ${model_name}    \x20
        Append To List    ${disks_info}    ${disk}
        Append To List    ${disks_info}    ${vendor_name}
        Append To List    ${disks_info}    ${model_name}
    END
    RETURN    ${disks_info}

Identify Path To SD Card in linux
    [Documentation]    Check which sdX is the correct path to mounted SD card.
    ${out}=    Execute Linux command    lsblk --nodeps --output NAME
    @{disks}=    Get Regexp matches    ${out}    sd.
    @{path}=    Create List
    FOR    ${disk}    IN    @{disks}
        TRY
            ${model}=    Execute Linux command    fdisk -l | grep "Disk /dev/${disk}" -A 1
            ${match}=    Should Match    str(${model})    *SD*
            Append To List    ${path}    ${disk}
        EXCEPT
            Log    ${disk} is not SD Card
        END
    END
    RETURN    @{path}

Check Read Write To External Drive in linux
    [Documentation]    Check if read/write to external drive works on Linux.
    [Arguments]    ${disk}
    Execute Linux command    dd if=/dev/urandom of=/tmp/in.bin bs=4K count=100
    Execute Linux command    dd if=/tmp/in.bin of=/dev/${disk} bs=4K count=100
    Execute Linux command    dd if=/dev/${disk} of=/tmp/out.bin bs=4K count=100
    ${result}=    Check if files are identical in Linux    /tmp/in.bin    /tmp/out.bin
    Should Be True    ${result}

Identify Path To SD Card in Windows
    [Documentation]    Check thecorrect path to mounted SD card.
    ${out}=    Run
    ...    sshpass -p ${device_windows_password} scp drive_letters.ps1 ${device_windows_username}@${device_ip}:/C:/Users/user
    Should Be Empty    ${out}
    ${result}=    Execute Command in Terminal    .\\drive_letters.ps1
    ${lines}=    Get Lines Matching Pattern    ${result}    *SD*
    ${drive_letter}=    Evaluate    $lines[0:2]
    RETURN    ${drive_letter}

Check Read Write To External Drive in Windows
    [Arguments]    ${drive_letter}
    Execute Command in Terminal
    ...    New-Item -Path "${drive_letter}/" -Name "testfile.txt" -ItemType "file" -Value "This is a test string."
    ${out}=    Execute Command in Terminal    Get-Content "${drive_letter}/testfile.txt"
    Should Contain    ${out}    This is a test string.
    Execute Command in Terminal    rm -fo ${drive_letter}/testfile.txt

Install Docker Packages
    [Documentation]    Install Docker Engine using latest version on Ubuntu.
    ${out_test}=    Execute Command In Terminal    docker --version; echo $?
    ${exit_code_str}=    Get Line    ${out_test}    -1
    ${exit_code}=    Convert To Integer    ${exit_code_str}
    IF    ${exit_code} != 0
        Wait Until Keyword Succeeds    5x    1s    Check Internet Connection on Linux
        Execute Command In Terminal    wget https://get.docker.com -O /tmp/get-docker.sh
        Execute Command In Terminal    sh /tmp/get-docker.sh    timeout=5m
        ${out_docker}=    Execute Command In Terminal    docker --version
        Should Contain    ${out_docker}    Docker version
    END

Detect or Install Package
    [Documentation]    Check whether the package, that is necessary to run the
    ...    test case, has already been installed on the system.
    [Arguments]    ${package}
    ${is_package_installed}=    Set Variable    ${False}
    Log To Console    \nChecking if ${package} is installed...
    ${is_package_installed}=    Check if package is installed    ${package}
    IF    ${is_package_installed}
        Log To Console    \nPackage ${package} is installed
    ELSE
        Log To Console    \nPackage ${package} is not installed
    END
    IF    ${is_package_installed}    RETURN
    Log To Console    \nInstalling required package (${package})...
    Install package    ${package}
    Sleep    10s
    ${is_package_installed}=    Check if package is installed    ${package}
    IF    ${is_package_installed}=='False'
        FAIL    \nRequired package (${package}) cannot be installed
    END
    Log To Console    \nRequired package (${package}) installed successfully

Check if package is installed
    [Documentation]    Check whether the package, that is necessary to run the
    ...    test case, has already been installed on the system.
    [Arguments]    ${package}
    ${output}=    Execute Command In Terminal    dpkg --list ${package} | cat
    IF    "no packages found matching" in """${output}""" or "<none>" in """${output}"""
        ${is_installed}=    Set Variable    ${False}
    ELSE
        ${is_installed}=    Set Variable    ${True}
    END
    RETURN    ${is_installed}

Install package
    [Documentation]    Install the package, that is necessary to run the
    ...    test case
    [Arguments]    ${package}
    Set DUT Response Timeout    600s
    Write Into Terminal    apt-get install --assume-yes ${package}
    Read From Terminal Until Prompt
    Set DUT Response Timeout    180s

Download File
    [Documentation]    Download file from the given URL.
    [Arguments]    ${remote_url}    ${local_path}    ${timeout}=30
    Wait Until Keyword Succeeds    5x    1s    Check Internet Connection on Linux
    ${out}=    Execute Linux command
    ...    wget --content-disposition --no-check-certificate --retry-connrefused -O ${local_path} ${remote_url}
    ...    ${timeout}
    Should Contain    ${out}    200 OK
    Should Contain    ${out}    ${local_path}
    Should Contain    ${out}    saved
    Should Not Contain    ${out}    failed

Login to Linux with Root Privileges
    [Documentation]    Login to Linux to perform test on OS level. Which login
    ...    method will be used depends on: connection method and
    ...    platform type.
    IF    '${dut_connection_method}' == 'SSH'
        Run Keywords
        ...    Login to Linux via SSH
        ...    ${device_ubuntu_username}
        ...    ${device_ubuntu_password}
        ...    AND
        ...    Switch to root user
    END
    IF    '${config}'=='raptor-cs_talos2'
        Login to Linux via OBMC    root    debian
    ELSE IF    '${platform[:8]}' == 'KGPE-D16'
        Serial root login Linux    debian
    END

Execute Command In Terminal
    [Documentation]    Universal keyword to execute command regardless of the
    ...    used method of connection to the DUT (Telnet or SSH).
    [Arguments]    ${command}    ${timeout}=30s
    Set DUT Response Timeout    ${timeout}
    IF    '${dut_connection_method}' == 'Telnet'
        ${output}=    Telnet.Execute Command    ${command}    strip_prompt=True
    ELSE
        Write Into Terminal    ${command}
        ${output}=    Read From Terminal Until Prompt
    END
    RETURN    ${output}

Read From Terminal
    [Documentation]    Universal keyword to read the console output regardless
    ...    of the used method of connection to the DUT
    ...    (Telnet or SSH).
    IF    '${dut_connection_method}' == 'Telnet'
        ${output}=    Telnet.Read
    ELSE IF    '${dut_connection_method}' == 'SSH'
        ${output}=    SSHLibrary.Read
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        ${output}=    SSHLibrary.Read
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        ${output}=    Telnet.Read
    ELSE
        ${output}=    FAIL    Unknown connection method: ${dut_connection_method}
    END
    RETURN    ${output}

Read From Terminal Until
    [Documentation]    Universal keyword to read the console output until the
    ...    defined text occurs regardless of the used method of
    ...    connection to the DUT (Telnet or SSH).
    [Arguments]    ${expected}
    IF    '${dut_connection_method}' == 'Telnet'
        ${output}=    Telnet.Read Until    ${expected}
    ELSE IF    '${dut_connection_method}' == 'SSH'
        ${output}=    SSHLibrary.Read Until    ${expected}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        ${output}=    SSHLibrary.Read Until    ${expected}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        ${output}=    Telnet.Read Until    ${expected}
    ELSE
        ${output}=    FAIL    Unknown connection method: ${dut_connection_method}
    END
    RETURN    ${output}

Read From Terminal Until Prompt
    [Documentation]    Universal keyword to read the console output until the
    ...    defined prompt occurs regardless of the used method of
    ...    connection to the DUT (Telnet or SSH).
    IF    '${dut_connection_method}' == 'SSH' or '${dut_connection_method}' == 'open-bmc'
        ${output}=    SSHLibrary.Read Until Prompt    strip_prompt=${True}
        ${output}=    Strip String    ${output}    characters=\n\r
    ELSE
        IF    '${dut_connection_method}' == 'Telnet'
            ${output}=    Telnet.Read Until Prompt    strip_prompt=${True}
        ELSE IF    '${dut_connection_method}' == 'pikvm'
            ${output}=    Telnet.Read Until Prompt    strip_prompt=${True}
        ELSE
            ${output}=    FAIL    Unknown connection method: ${dut_connection_method}
        END
    END
    RETURN    ${output}

Read From Terminal Until Regexp
    [Documentation]    Universal keyword to read the console output until the
    ...    defined regexp occurs regardless of the used method of
    ...    connection to the DUT (Telnet or SSH).
    [Arguments]    ${regexp}
    IF    '${dut_connection_method}' == 'Telnet'
        ${output}=    Telnet.Read Until Regexp    ${regexp}
    ELSE IF    '${dut_connection_method}' == 'SSH'
        ${output}=    SSHLibrary.Read Until Regexp    ${regexp}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        ${output}=    SSHLibrary.Read Until Regexp    ${regexp}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        ${output}=    Telnet.Read Until Regexp    ${regexp}
    ELSE
        ${output}=    FAIL    Unknown connection method: ${dut_connection_method}
    END
    RETURN    ${output}

Set Prompt For Terminal
    [Documentation]    Universal keyword to set the prompt (used in Read Until
    ...    prompt keyword) regardless of the used method of
    ...    connection to the DUT (Telnet or SSH).
    [Arguments]    ${prompt}
    IF    '${dut_connection_method}' == 'Telnet'
        Telnet.Set Prompt    ${prompt}    prompt_is_regexp=False
    ELSE IF    '${dut_connection_method}' == 'SSH'
        SSHLibrary.Set Client Configuration    prompt=${prompt}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        SSHLibrary.Set Client Configuration    prompt=${prompt}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        Telnet.Set Prompt    ${prompt}
    ELSE
        FAIL    Unknown connection method: ${dut_connection_method}
    END

Set DUT Response Timeout
    [Documentation]    Universal keyword to set the timeout (used for operations
    ...    that expect some output to appear) regardless of the
    ...    used method of connection to the DUT (Telnet or SSH).
    [Arguments]    ${timeout}
    IF    '${dut_connection_method}' == 'Telnet'
        Telnet.Set Timeout    ${timeout}
    ELSE IF    '${dut_connection_method}' == 'SSH'
        SSHLibrary.Set Client Configuration    timeout=${timeout}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        SSHLibrary.Set Client Configuration    timeout=${timeout}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        Telnet.Set Timeout    ${timeout}
    ELSE
        FAIL    Unknown connection method: ${dut_connection_method}
    END

Write Into Terminal
    [Documentation]    Universal keyword to write text to console regardless of
    ...    the used method of connection to the DUT (Telnet, PiKVM or SSH).
    [Arguments]    ${text}
    IF    '${dut_connection_method}' == 'Telnet'
        Telnet.Write    ${text}
    ELSE IF    '${dut_connection_method}' == 'SSH'
        SSHLibrary.Write    ${text}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        SSHLibrary.Write    ${text}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        Write PiKVM    ${text}
    ELSE
        FAIL    Unknown connection method: ${dut_connection_method}
    END

Write Bare Into Terminal
    [Documentation]    Universal keyword to write bare text (without new line
    ...    mark) to console regardless of the used method of
    ...    connection to the DUT (Telnet, PiKVM or SSH).
    [Arguments]    ${text}    ${interval}=${null}
    IF    '${dut_connection_method}' == 'Telnet'
        Telnet.Write Bare    ${text}    ${interval}
    ELSE IF    '${dut_connection_method}' == 'SSH'
        SSHLibrary.Write Bare    ${text}
    ELSE IF    '${dut_connection_method}' == 'open-bmc'
        SSHLibrary.Write Bare    ${text}
    ELSE IF    '${dut_connection_method}' == 'pikvm'
        Write Bare PiKVM    ${text}
    ELSE
        FAIL    Unknown connection method: ${dut_connection_method}
    END

Compare Serial Number from MAC
    [Documentation]    Compare serial number with value got calculated from MAC
    ...    address with serial number got from dmidecode.
    [Arguments]    ${serial_number}
    ${out}=    Calculate serial number from MAC
    Should Contain    ${serial_number}    ${out}

Firmware version verification from binary
    [Documentation]    Check whether the DUT firmware version is the same as it
    ...    is expected by checking it with dmidecode and comparing
    ...    with a value get from binary.
    Read Firmware    ${TEMPDIR}${/}coreboot.rom
    Power Cycle On
    ${version}=    Get firmware version
    ${coreboot_version}=    Get firmware version from binary    ${TEMPDIR}${/}coreboot.rom
    Should Contain    ${coreboot_version}    ${version}

Firmware release date verification from SOL
    [Documentation]    Check whether the DUT firmware release date is the same
    ...    as it is expected by checking it with dmidecode and
    ...    comparing with a value get from sign of life.
    Power Cycle On
    ${sign_of_life}=    Get sign of life
    ${sol_date}=    Get Lines Containing String    ${sign_of_life}    coreboot build
    Power On
    ${slash_release_date}=    Get release date
    IF    ${change_release_date}
        ${release_date}=    Change release date format    ${slash_release_date}
    ELSE
        ${release_date}=    Set Variable    ${slash_release_date}
    END
    Should Be Equal    ${sol_date.split()[-1]}    ${release_date}

Build Firmware From Source
    [Documentation]    Builds firmware based on device type.
    IF    "novacustom" in "${config}"
        Build Firmware Novacustom
    ELSE
        FAIL    Unsupported platform type.
    END

Check Write Protection Availability
    [Documentation]    Check whether it is possible to set Write Protection
    ...    on the DUT.
    ${out}=    Execute Linux command    ./flashrom -p internal --wp-list
    Should Not Contain    ${out}    write protect support is not implemented for this flash chip
    Should Contain    ${out}    Available write protection ranges:
    Should Contain    ${out}    all

Erase Write Protection
    [Documentation]    Erase write protection from the flash chip.
    ${out}=    Execute Linux command    ./flashrom -p internal --wp-disable    180
    Should Contain    ${out}    Successfully set the requested mode
    ${out}=    Execute Linux command    ./flashrom -p internal --wp-range=0,0    180
    Should Contain    ${out}    Successfully set the requested protection range

Set Write Protection
    [Documentation]    Set protection range as defined by the parameters:
    ...    `${start_adress}` -    protection start address,
    ...    `${length}` - flash protected range length.
    [Arguments]    ${start_adress}    ${length}
    ${out}=    Execute Linux command    ./flashrom -p internal --wp-range=${start_adress},${length}    180
    Should Contain    ${out}    Successfully set the requested protection range
    ${out}=    Execute Linux command    ./flashrom -p internal --wp-enable    180
    Should Contain    ${out}    Successfully set the requested mode

Check Write Protection Status
    [Documentation]    Check whether Write Protection mechanism is active.
    ${out}=    Execute Linux command    ./flashrom -p internal --wp-status    180
    Should Contain    ${out}    Protection mode: hardware

Compare Write Protection Ranges
    [Documentation]    Allows to compare Protection Range: declared and
    ...    currently set.
    [Arguments]    ${start_adress}    ${length}
    ${out}=    Execute Linux command    ./flashrom -p internal --wp-status    180
    ${protection_range}=    Get Lines Containing String    ${out}    Protection range:
    ${protection_range}=    Split String    ${protection_range}
    ${set_start_adress}=    Get From List    ${protection_range}    2
    ${set_start_adress}=    Fetch From Right    ${set_start_adress}    =
    ${set_length}=    Get From List    ${protection_range}    3
    ${set_length}=    Fetch From Right    ${set_length}    =
    IF    ${set_start_adress}!=${start_adress}
        FAIL    Declared and currently set protection start addresses are not the same
    END
    IF    ${set_length}!=${length}
        FAIL    Declared and currently set protection lengths are not the same
    END

Read System information in Petitboot
    [Documentation]    Keyword allows to check whether the read system
    ...    information option is available in Petitboot and
    ...    whether the option works correctly.
    Sleep    2s
    ${output}=    Read From Terminal Until    help
    Should Contain    ${output}    System information
    Set Local Variable    ${move}    7
    FOR    ${index}    IN RANGE    0    ${move}
        Write Bare Into Terminal    ${ARROW_UP}
        Read From Terminal
    END
    Sleep    2s
    Write Bare Into Terminal    ${ENTER}
    ${output}=    Read From Terminal Until    help
    Should Contain    ${output}    Petitboot System Information

Rescan devices in Petitboot
    [Documentation]    Keyword allows to check whether the rescan devices
    ...    option is available in Petitboot and whether the
    ...    option works correctly.
    Sleep    2s
    ${output}=    Read From Terminal Until    help
    Should Contain    ${output}    Rescan devices
    Set Local Variable    ${move}    3
    FOR    ${index}    IN RANGE    0    ${move}
        Write Bare Into Terminal    ${ARROW_UP}
        Read From Terminal
    END
    Sleep    2s
    Write Bare Into Terminal    ${ENTER}
    # To Do: read system log

Check eMMC module
    [Documentation]    Check the eMMC module is detected via the Operating
    ...    System.
    ${out}=    Execute Linux command    parted /dev/mmcblk0 -- print
    Should Contain    ${out}    ${eMMC_name}
    Should Contain    ${out}    ${eMMC_partition_table}

Coldboot via RTE Relay
    [Documentation]    Coldboot the DUT using RTE Relay.
    RteCtrl Relay
    Sleep    5s
    RteCtrl Relay

Reboot via OS boot by Petitboot
    [Documentation]    Reboot system with system installed on the DUT while
    ...    already logged into Petitboot.
    Boot from USB
    Login to Linux
    Execute Linux Command    reboot
    Sleep    60s

Reboot via Ubuntu by Tianocore
    [Documentation]    Reboot system with Ubuntu installed on the DUT while
    ...    already logged into Tianocore.
    Enter Boot Menu Tianocore
    Enter submenu in Tianocore    ubuntu
    Login to Linux
    Switch to root user
    Write Into Terminal    reboot

Reboot via Linux on USB
    [Documentation]    Reboot system with Ubuntu installed on the USB stick.
    Login to Linux over serial console    ${device_usb_username}    ${device_usb_password}    ${device_usb_prompt}
    Write Into Terminal    sudo su
    Read From Terminal Until    [sudo] password for ${device_usb_username}:
    Write Into Terminal    ${device_usb_password}
    Set Prompt For Terminal    ${device_usb_root_prompt}
    Read From Terminal Until Prompt
    Write Into Terminal    reboot

Refresh serial screen in BIOS editable settings menu
    [Documentation]    This keyword tries to refresh the screen while inside the
    ...    BIOS setting menu - to be specific while in a screen where you can
    ...    press F10 to save the changes. Opening save windows and closing it
    ...    should refresh the screen, but it is not guaranteed.
    Press key n times    1    ${F10}
    Press key n times    1    ${ESC}

Get coreboot tools from cloud
    [Documentation]    Downloads required coreboot tools from cloud
    Get cbmem from cloud
    Get flashrom from cloud
    Get cbfstool from cloud

Get cbmem from cloud
    [Documentation]    Download cbmem from the cloud.
    ${cbmem_path}=    Set Variable    /usr/local/bin/cbmem
    ${out_test}=    Execute Command In Terminal    test -x ${cbmem_path}; echo $?
    ${exit_code}=    Convert To Integer    ${out_test}
    IF    ${exit_code} != 0
        Download File    https://cloud.3mdeb.com/index.php/s/C6LJMi4bWz3wzR9/download    ${cbmem_path}
        Execute Command In Terminal    chmod 777 ${cbmem_path}
    END

Get flashrom from cloud
    [Documentation]    Download flashrom from the cloud.
    ${flashrom_path}=    Set Variable    /usr/local/bin/flashrom
    ${out_test}=    Execute Command InTerminal    test -x ${flashrom_path}; echo $?
    ${exit_code}=    Convert To Integer    ${out_test}
    IF    ${exit_code} != 0
        Download File    https://cloud.3mdeb.com/index.php/s/D7AQDdRZmQFTL6n/download    ${flashrom_path}
        Execute Command In Terminal    chmod 777 ${flashrom_path}
    END

Get cbfstool from cloud
    [Documentation]    Download cbfstool from the cloud
    ${cbfstool_path}=    Set Variable    /usr/local/bin/cbfstool
    ${out_test}=    Execute Command In Terminal    test -x ${cbfstool_path}; echo $?
    ${exit_code}=    Convert To Integer    ${out_test}
    IF    ${exit_code} != 0
        Download File    https://cloud.3mdeb.com/index.php/s/ScCf8XFLZYWBE25/download    ${cbfstool_path}
        Execute Command In Terminal    chmod 777 ${cbfstool_path}
    END

Extract Repository Name From URL
    [Documentation]    Accepts git URL as an argument. Returns repository name.
    [Arguments]    ${url}
    ${url_without_extension}=    Fetch From Left    ${url}    .git
    ${repo_name}=    Fetch From Right    ${url_without_extension}    /
    RETURN    ${repo_name}

Clone git repository
    [Documentation]    Clones given git repository to the target location
    [Arguments]    ${repo_url}    ${location}=${EMPTY}
    Wait Until Keyword Succeeds    5x    1s    Check Internet Connection on Linux
    IF    '${location}' != '${EMPTY}'
        ${repo_path}=    ${location}=
    ELSE
        ${repo_path}=    Extract Repository Name from URL    ${repo_url}
    END
    ${is_git_installed}=    Check if package is installed    git
    IF    ${is_git_installed} != True
        ${out_install}=    Execute Command in Terminal    apt install -y git
        Should Not Contain    ${out_install}    Failed
    END
    Execute Command In Terminal    rm -rf ${repo_path}
    ${out_clone}=    Execute Command In Terminal    git clone ${repo_url} ${location}
    Should Contain    ${out_clone}    Receiving objects: 100%
    Should Contain    ${out_clone}    Resolving deltas: 100%

Send File To DUT
    [Documentation]    Sends file DUT and saves it at given location
    [Arguments]    ${source_path}    ${target_path}
    IF    '${dut_connection_method}' == 'Telnet'
        ${ip_address}=    Get hostname ip
        Execute Command In Terminal    rm -f ${target_path}
        SSHLibrary.Open Connection    ${ip_address}
        SSHLibrary.Login    ${device_ubuntu_username}    ${device_ubuntu_password}
        SSHLibrary.Put File    ${source_path}    ${target_path}
        SSHLibrary.Close Connection
    ELSE
        Put File    ${source_path}    ${target_path}
    END

Check Internet Connection on Linux
    [Documentation]    Check internet connection on Linux.
    ${out}=    Execute Linux command    ping -c 4 google-public-dns-a.google.com
    Should Contain    ${out}    , 0% packet loss

Check Internet Connection on Windows
    [Documentation]    Check internet connection on Windows.
    ${out}=    Execute Command in Terminal    ping google-public-dns-a.google.com
    Should Contain    ${out}    (0% loss)

Boot operating system
    [Documentation]    Keyword allows boot operating system installed on the
    ...    DUT. Takes as an argument operating system name.
    [Arguments]    ${operating_system}
    IF    '${dut_connection_method}' == 'SSH'    RETURN
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
    [Documentation]    Tries to boot ${system_name}. If it is not possible then it tries
    ...    to boot from connected disk set up in config
    [Arguments]    ${system_name}
    IF    '${dut_connection_method}' == 'SSH'    RETURN
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
        IF    ${system_index} == -1
            Fail    Disk: ${disk_name} not found in Boot Menu
        END
    ELSE
        ${system_index}=    Get Index From List    ${menu_construction}    ${system_name}
    END
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}

Get iPXE Boot Menu Construction
    [Documentation]    Keyword allows to get and return iPXE boot menu construction.
    [Arguments]    ${checkpoint}=${edk2_ipxe_checkpoint}
    ${menu}=    Read From Terminal Until    ${checkpoint}
    ${menu}=    Remove String    ${menu}    \r
    @{menu_lines}=    Split String    ${menu}    \n
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        # Replace multiple spaces with a single one
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        # Remove leading and trailing spaces
        ${line}=    Strip String    ${line}
        # Drop leading and trailing pipes
        ${line}=    Strip String    ${line}    characters=|
        # Remove leading and trailing spaces
        ${line}=    Strip String    ${line}
        # If the resulting line is not empty, add it as a bootable entry
        ${length}=    Get Length    ${line}
        IF    ${length} > 0    Append To List    ${menu_construction}    ${line}
    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[1:]
    RETURN    ${menu_construction}

Get Boot Menu Construction
    [Documentation]    Keyword allows to get and return boot menu construction.
    ...    Getting boot menu construction is carried out in the following basis:
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
        ${line}=    Strip String    ${line}
        # Drop leading and trailing pipes
        ${line}=    Strip String    ${line}    characters=|
        # Remove leading and trailing spaces
        ${line}=    Strip String    ${line}
        # If the resulting line is not empty, add it as a bootable entry
        ${length}=    Get Length    ${line}
        IF    ${length} > 0    Append To List    ${menu_construction}    ${line}
    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[3:-4]
    RETURN    ${menu_construction}

Get Setup Menu Construction
    [Documentation]    Keyword allows to get and return setup menu construction.
    ...    Getting setup menu construction is carried out in the following basis:
    ...    1. Get serial output, which shows Boot menu with all elements,
    ...    headers and whitespaces.
    ...    2. Split serial output string and create list.
    ...    3. Create empty list for detected elements of menu.
    ...    4. Add to the new list only elements which are not whitespaces and
    ...    not menu frames.
    ...    5. Remove from new list menu header and footer (header always
    ...    occupies one line, footer -3)
    [Arguments]    ${checkpoint}=Select Entry
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
    RETURN    ${menu_construction}

Get Setup Submenu Construction
    [Documentation]    Keyword allows to get and return setup menu construction.
    ...    Getting setup menu construction is carried out in the following basis:
    ...    1. Get serial output, which shows Boot menu with all elements,
    ...    headers and whitespaces.
    ...    2. Split serial output string and create list.
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
    RETURN    ${menu_construction}

Remove Entry From List
    [Arguments]    ${input_list}    ${regexp}
    @{output_list}=    Create List
    FOR    ${item}    IN    @{input_list}
        ${is_match}=    Run Keyword And Return Status    Should Not Match Regexp    ${item}    ${regexp}
        IF    ${is_match}    Append To List    ${output_list}    ${item}
    END
    RETURN    ${output_list}

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
    RETURN    ${menu_construction}

Get USB Configuration Submenu Construction
    [Documentation]    Keyword allows to get and return setup menu construction.
    ...    Getting setup menu construction is carried out in the following basis:
    ...    1. Get serial output, which shows Boot menu with all elements,
    ...    headers and whitespaces.
    ...    2. Split serial output string and create list.
    ...    3. Create empty list for detected elements of menu.
    ...    4. Add to the new list only elements which are not whitespaces and
    ...    not menu frames.
    ...    5. Remove from new list menu header and footer (header always
    ...    occupies one line, footer -3)
    ${menu}=    Read From Terminal Until    Press ESC to exit.
    @{menu_lines}=    Split String    ${menu}    \n
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        ${line}=    Remove String    ${line}    -    \\    \    /    |    <    >
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        IF    "${line}"!="${EMPTY}" and "${line}"!="${SPACE}"
            ${line}=    Get Substring    ${line}    1
            Append To List    ${menu_construction}    ${line}
        END
    END
    ${menu_construction}=    Get Slice From List    ${menu_construction}[3:-1]
    RETURN    ${menu_construction}

Generate 1GB File in Windows
    [Documentation]    Generates 1G file in Windows in .txt format.
    ${out}=    Execute Command in Terminal    fsutil file createnew test_file.txt 1073741824
    Should Contain    ${out}    is created

Get Drive Letter Of USB
    [Documentation]    Gets drive letter of attached USB, work with only one USB
    ...    attached.
    ${drive_letter}=    Execute Command in Terminal
    ...    (Get-Volume | where drivetype -eq removable | where filesystemtype -eq FAT32).driveletter
    ${drive_letter}=    Fetch From Left    ${drive_letter}    \r
    RETURN    ${drive_letter}

Get Hash Of File
    [Documentation]    Gets line with hash of file.
    [Arguments]    ${path_file}
    ${out}=    Execute Command in Terminal    Get-FileHash -Path ${path_file} | Format-List
    ${hash}=    Get Lines Containing String    ${out}    Hash
    RETURN    ${hash}

Identify Path To USB
    [Documentation]    Identifies path to USB storage. Setting ${usb_model}
    ...    variable in .config file is required to correctly work
    ...    this keyword.
    ${out}=    Execute Linux command    lsblk --nodeps --output NAME
    @{disks}=    Get Regexp matches    ${out}    sd.
    FOR    ${disk}    IN    @{disks}
        ${model}=    Execute Linux command    cat /sys/class/block/${disk}/device/model
        ${model_name}=    Fetch From Left    ${model}    \r\n
        ${model_name}=    Fetch From Right    ${model_name}    \r
        Set Local Variable    ${usb_disk}    ${disk}
        IF    '${model_name}' == '${usb_model}'    BREAK
    END
    ${out}=    Execute Linux command    lsblk | grep ${usb_disk} | grep part | cat
    ${split}=    Split String    ${out}
    ${path_to_usb}=    Get From List    ${split}    7
    RETURN    ${path_to_usb}

Get Intel ME Mode State
    [Documentation]    Returns the current state of Intel ME mode.
    [Arguments]    ${menu_ME}
    ${menu_ME}=    Fetch From Right    ${menu_ME}    <
    ${actual_state}=    Fetch From Left    ${menu_ME}    >
    RETURN    ${actual_state}

Setup Intel ME Mode
    [Documentation]    Sets the state of Intel ME mode based on the current
    ...    state.
    [Arguments]    ${actual_state}    ${tested_state}
    IF    '${dut_connection_method}' == 'pikvm'
        Single Key PiKVM    Enter
        IF    '${actual_state}' == 'Enabled'
            IF    '${tested_state}' == 'Disabled (Soft)'
                Press key n times and enter    1    ${ARROW_DOWN}
            ELSE IF    '${tested_state}' == 'Disabled (HAP)'
                Press key n times and enter    2    ${ARROW_DOWN}
            END
        ELSE IF    '${actual_state}' == 'Disabled (Soft)'
            IF    '${tested_state}' == 'Enabled'
                Press key n times and enter    1    ${ARROW_UP}
            ELSE IF    '${tested_state}' == 'Disabled (HAP)'
                Press key n times and enter    1    ${ARROW_DOWN}
            END
        ELSE IF    '${actual_state}' == 'Disabled (HAP)'
            IF    '${tested_state}' == 'Enabled'
                Press key n times and enter    2    ${ARROW_UP}
            ELSE IF    '${tested_state}' == 'Disabled (Soft)'
                Press key n times and enter    1    ${ARROW_UP}
            END
        END
        Single Key PiKVM    F10
        Single Key PiKVM    KeyY
    ELSE
        Write Bare Into Terminal    ${ENTER}
        IF    '${actual_state}' == 'Enabled'
            IF    '${tested_state}' == 'Disabled (Soft)'
                Press key n times and enter    1    ${ARROW_DOWN}
            ELSE IF    '${tested_state}' == 'Disabled (HAP)'
                Press key n times and enter    2    ${ARROW_DOWN}
            END
        ELSE IF    '${actual_state}' == 'Disabled (Soft)'
            IF    '${tested_state}' == 'Enabled'
                Press key n times and enter    1    ${ARROW_UP}
            ELSE IF    '${tested_state}' == 'Disabled (HAP)'
                Press key n times and enter    1    ${ARROW_DOWN}
            END
        ELSE IF    '${actual_state}' == 'Disabled (HAP)'
            IF    '${tested_state}' == 'Enabled'
                Press key n times and enter    2    ${ARROW_UP}
            ELSE IF    '${tested_state}' == 'Disabled (Soft)'
                Press key n times and enter    1    ${ARROW_UP}
            END
        END
        Write Bare Into Terminal    ${F10}
        Write Bare Into Terminal    ${Y}
    END

Return Intel ME Options
    [Documentation]    Returns output of Intel ME Options.
    ${menu_construction}=    Get Setup Menu Construction
    ${system_index}=    Get Index From List    ${menu_construction}    Dasharo System Features
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}
    ${menu_construction}=    Get Setup SubMenu Construction
    ${system_index}=    Get Index From List    ${menu_construction}    Intel Management Engine Options
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}
    ${menu}=    Read From Terminal Until    Press ESC to exit.
    RETURN    ${menu}

Calculate Smoothing
    [Documentation]    Compares the actual and expected value of the fan speed,
    ...    taking smoothing into account.
    [Arguments]    ${pwm}    ${expected_speed_percentage}
    ${pwm}=    Evaluate    float(${pwm}/2.55)
    IF    ${expected_speed_percentage} < 35
        ${smoothing}=    Evaluate    1
    ELSE
        ${smoothing}=    Evaluate    6
    END
    ${high_limit}=    Evaluate    ${expected_speed_percentage}+${smoothing}
    ${low_limit}=    Evaluate    ${expected_speed_percentage}-${smoothing}
    Log To Console    \n ----------------------------------------------------------------
    Log To Console    From PWM: ${pwm}%
    Log To Console    From Temp: ${expected_speed_percentage}%
    Should Be True    ${low_limit} < ${pwm} < ${high_limit}

Get PWM Value
    [Documentation]    Returns current PWN value from hwmon.
    # ../hwmon/hwmonX/pwm{1,2}
    ${hwmon}=    Execute Command In Terminal
    ...    ls /sys/devices/LNXSYSTM\:00/LNXSYBUS\:00/17761776\:00/hwmon | grep hwmon
    ${pwm}=    Execute Command In Terminal    cat /sys/devices/LNXSYSTM:00/LNXSYBUS:00/17761776:00/hwmon/${hwmon}/pwm1
    ${pwm}=    Convert To Number    ${pwm}
    RETURN    ${pwm}

Get Temperature CURRENT
    [Documentation]    Get current temperature from hwmon.
    ${hwmon}=    Execute Command In Terminal
    ...    ls /sys/devices/LNXSYSTM\:00/LNXSYBUS\:00/17761776\:00/hwmon | grep hwmon
    ${temperature}=    Execute Command In Terminal
    ...    cat /sys/devices/LNXSYSTM:00/LNXSYBUS:00/17761776:00/hwmon/${hwmon}/temp1_input
    ${temperature}=    Evaluate    ${temperature[:2]}
    ${temperature}=    Convert To Number    ${temperature}
    RETURN    ${temperature}

Get RPM Value From System76_acpi
    [Documentation]    Returns current RPM value of CPU fan form driver
    ...    system76_acpi.
    ${speed}=    Execute Command In Terminal    sensors | grep "CPU fan"
    ${speed_split}=    Split String    ${speed}
    ${rpm}=    Get From List    ${speed_split}    2
    RETURN    ${rpm}

Detect or install FWTS
    [Documentation]    Keyword allows to check if Firmware Test Suite (fwts)
    ...    has been already installed on the device. Otherwise, triggers
    ...    process of obtaining and installation.
    [Arguments]    ${package}=fwts
    ${is_package_installed}=    Set Variable    ${False}
    Log To Console    \nChecking if ${package} is installed...
    ${is_package_installed}=    Check if package is installed    ${package}
    IF    ${is_package_installed}
        Log To Console    \nPackage ${package} is installed
        RETURN
    ELSE
        Log To Console    \nPackage ${package} is not installed
    END
    Log To Console    \nInstalling required package (${package})...
    Get and install FWTS
    Sleep    10s
    ${is_package_installed}=    Check if package is installed    ${package}
    IF    ${is_package_installed}=='False'
        FAIL    \nRequired package (${package}) cannot be installed
    END
    Log To Console    \nRequired package (${package}) installed successfully

Get and install FWTS
    [Documentation]    Keyword allows to obtain and install Firmware Test Suite
    ...    (fwts) tool.
    Set DUT Response Timeout    500s
    Write Into Terminal    add-apt-repository ppa:firmware-testing-team/ppa-fwts-stable
    Read From Terminal Until    Press [ENTER] to continue or Ctrl-c to cancel
    Write Bare Into Terminal    ${ENTER}
    Read From Terminal Until    Reading package lists... Done
    Write Into Terminal    apt-get install --assume-yes fwts
    Read From Terminal Until Prompt

Perform suspend test using FWTS
    [Documentation]    Keyword allows to perform suspend and resume procedure
    ...    test by using Firmware Test Suite tool
    [Arguments]    ${test_duration}=40
    ${is_suspend_performed_correctly}=    Set Variable    ${False}
    Write Into Terminal    fwts s3 -f -r /tmp/suspend_test_log.log
    Sleep    ${test_duration}s
    Login to Linux
    Switch to root user
    ${test_result}=    Execute Linux command    cat /tmp/suspend_test_log.log
    TRY
        Should Contain    ${test_result}    0 failed
        Should Contain    ${test_result}    0 warning
        Should Contain    ${test_result}    0 aborted
        Should Contain    ${test_result}    0 skipped
        ${is_suspend_performed_correctly}=    Set Variable    ${True}
    EXCEPT
        ${is_suspend_performed_correctly}=    Set Variable    ${False}
    END
    RETURN    ${is_suspend_performed_correctly}

Perform hibernation test using FWTS
    [Documentation]    Keyword allows to perform hibernation and resume procedure
    ...    test by using Firmware Test Suite tool
    [Arguments]    ${test_duration}=40
    ${is_hibernation_performed_correctly}=    Set Variable    ${False}
    Execute Command In Terminal    fwts s4 -f -r /tmp/hibernation_test_log.log
    Sleep    ${test_duration}s
    Boot operating system    ubuntu
    Login to Linux
    Switch to root user
    ${test_result}=    Execute Command In Terminal    cat /tmp/hibernation_test_log.log
    TRY
        Should Contain    ${test_result}    0 failed
        Should Contain    ${test_result}    0 warning
        Should Contain    ${test_result}    0 aborted
        Should Contain    ${test_result}    0 skipped
        ${is_hibernation_performed_correctly}=    Set Variable    ${True}
    EXCEPT
        ${is_hibernation_performed_correctly}=    Set Variable    ${False}
    END
    RETURN    ${is_hibernation_performed_correctly}

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
    RETURN    ${index}

Enter TCG Drive Management Submenu
    [Documentation]    Enters TCG Drive Management submenu
    ${menu_construction}=    Get Setup SubMenu Construction
    ${system_index}=    Get Index of Matching option in menu    ${menu_construction}    TCG Drive Management
    # Above instruction detects "Devices list" as an option in the menu which
    # isn't one so we have to decrease the index
    ${system_index}=    Evaluate    ${system_index}-1
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}

Disable Option in submenu
    [Documentation]    Disables selected option in submenu provided in ${menu_construction}
    [Arguments]    ${menu_construction}    ${option}
    ${option}=    Set Variable    ${option[1:]}
    ${line}=    Get Matches    ${menu_construction}    *${option}*
    TRY
        Should Match Regexp    ${line[0]}    .*\\[\ \\].*
        Refresh serial screen in BIOS editable settings menu
    EXCEPT
        FOR    ${element}    IN    @{menu_construction}
            ${matches}=    Run Keyword And Return Status    Should Match    ${element}    pattern=*${option}*
            IF    ${matches}
                ${option}=    Set Variable    ${element}
                BREAK
            END
        END
        Strip String    ${option}    mode=left
        ${system_index}=    Get Index From List    ${menu_construction}    ${option}
        Press key n times and enter    ${system_index}    ${ARROW_DOWN}
        Press key n times    1    ${F10}
        Write Bare Into Terminal    y
    END

Enter Dasharo Security Options Submenu
    [Documentation]    Enters and returns the output of Dasharo Security
    ...    Options
    ${menu_construction}=    Get Setup Menu Construction
    ${system_index}=    Get Index From List    ${menu_construction}    Dasharo System Features
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}
    ${menu_construction}=    Get Setup SubMenu Construction
    ${system_index}=    Get Index From List    ${menu_construction}    Dasharo Security Options
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}
    ${menu_construction}=    Get Dasharo Security Submenu Construction
    RETURN    ${menu_construction}

Enter Dasharo System Features submenu
    [Documentation]    Returns output of ${submenu}.
    [Arguments]    ${submenu}
    ${menu_construction}=    Get Setup Menu Construction
    ${system_index}=    Get Index From List    ${menu_construction}    Dasharo System Features
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}
    ${menu_construction}=    Get Setup SubMenu Construction
    ${system_index}=    Get Index From List    ${menu_construction}    ${submenu}
    IF    ${system_index} == -1    Skip    msg=Menu option not found
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}
    ${menu_construction}=    Get Setup Submenu Construction
    RETURN    ${menu_construction}

Enter USB Configuration Submenu
    [Documentation]    Returns output of USB Configuration SubMenu.
    ${menu_construction}=    Get Setup Menu Construction
    ${system_index}=    Get Index From List    ${menu_construction}    Dasharo System Features
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}
    ${menu_construction}=    Get Setup SubMenu Construction
    ${system_index}=    Get Index From List    ${menu_construction}    USB Configuration
    Press key n times and enter    ${system_index}    ${ARROW_DOWN}
    ${menu_construction}=    Get USB Configuration Submenu Construction
    RETURN    ${menu_construction}

Enable Option In USB Configuration Submenu
    [Documentation]    Enables option in USB Configuration SubMenu.
    [Arguments]    ${menu_construction}    ${option}
    ${line}=    Get Matches    ${menu_construction}    *${option}*
    TRY
        Should Contain Match    ${line}    *[X]*
    EXCEPT
        FOR    ${element}    IN    @{menu_construction}
            ${matches}=    Run Keyword And Return Status    Should Match    ${element}    pattern=*${option}*
            IF    ${matches}
                ${option}=    Set Variable    ${element}
                BREAK
            END
        END
        Strip String    ${option}    mode=left
        ${system_index}=    Get Index From List    ${menu_construction}    ${option}
        ${steps}=    Evaluate    ${system_index}-1
        Press key n times and enter    ${steps}    ${ARROW_DOWN}
        Write Bare Into Terminal    ${F10}
        Write Bare Into Terminal    Y
    END

Disable Option In USB Configuration Submenu
    [Documentation]    Disables option in USB Configuration SubMenu.
    [Arguments]    ${menu_construction}    ${option}
    ${line}=    Get Matches    ${menu_construction}    *${option}*
    TRY
        Should Not Contain Match    ${line}    *[X]*
    EXCEPT
        FOR    ${element}    IN    @{menu_construction}
            ${matches}=    Run Keyword And Return Status    Should Match    ${element}    pattern=*${option}*
            IF    ${matches}
                ${option}=    Set Variable    ${element}
                BREAK
            END
        END
        ${system_index}=    Get Index From List    ${menu_construction}    ${option}
        ${steps}=    Evaluate    ${system_index}-1
        Press key n times and enter    ${steps}    ${ARROW_DOWN}
        Write Bare Into Terminal    ${F10}
        Write Bare Into Terminal    Y
    END

Enable Option In submenu
    [Documentation]    Enables option in submenu
    [Arguments]    ${menu_construction}    ${option}
    ${option}=    Set Variable    ${option[1:]}
    ${line}=    Get Matches    ${menu_construction}    *${option}*
    TRY
        Should Not Match Regexp    ${line[0]}    .*\\[ \\].*
        Refresh serial screen in BIOS editable settings menu
    EXCEPT
        FOR    ${element}    IN    @{menu_construction}
            ${matches}=    Run Keyword And Return Status    Should Match    ${element}    pattern=*${option}*
            IF    ${matches}
                ${option}=    Set Variable    ${element}
                BREAK
            END
        END
        Strip String    ${option}    mode=left
        ${system_index}=    Get Index From List    ${menu_construction}    ${option}
        ${steps}=    Evaluate    ${system_index}-1
        Press key n times and enter    ${steps}    ${ARROW_DOWN}
        Write Bare Into Terminal    ${F10}
        Write Bare Into Terminal    Y
    END

Get Current CONFIG list param
    [Documentation]    Returns current CONFIG list parameters specified in the
    ...    arguments.
    [Arguments]    ${item}    ${param}
    ${config}=    Get current CONFIG    ${CONFIG_LIST}
    ${length}=    Get Length    ${config}
    Should Be True    ${length} > 1
    @{attached_usb_list}=    Create List
    FOR    ${element}    IN    @{config[1:]}
        IF    '${element.type}'=='${item}'
            Append To List    ${attached_usb_list}    ${element.${param}}
        END
    END
    ${length}=    Get Length    ${attached_usb_list}
    Should Be True    ${length} > 0
    RETURN    @{attached_usb_list}

Check That USB Devices Are detected
    [Documentation]    Checks if the USB devices from the config are the same as
    ...    those visible in the boot menu.
    ${menu_construction}=    Read From Terminal Until    exit
    @{attached_usb_list}=    Get Current CONFIG list param    USB_Storage    name
    FOR    ${stick}    IN    @{attached_usb_list}
        # ${stick} should match with one element of ${menu_construction}

        Should Match    ${menu_construction}    *${stick}*
    END

Check That USB Devices Are Not Detected
    [Documentation]    Checks if the USB devices from the config are the same as
    ...    those visible in the boot menu.
    ${menu_construction}=    Get Boot Menu Construction
    @{attached_usb_list}=    Get Current CONFIG list param    USB_Storage    name
    FOR    ${stick}    IN    @{attached_usb_list}
        Should Not Contain    ${menu_construction}    ${stick}
    END

Switch to root user in Ubuntu Server
    [Documentation]    Switch to the root environment in Ubuntu Server.
    Write Into Terminal    sudo su
    Read From Terminal Until    [sudo] password for user:
    Write Into Terminal    ubuntuserver
    Set Prompt For Terminal    \#
    Read From Terminal Until Prompt

Reboot In OPNsense
    [Documentation]    Perform reboot in OPNsense.
    Write Into Terminal    6
    Read From Terminal Until    [y/N]:
    Write Into Terminal    y

Reboot In PfSense
    [Documentation]    Perform reboot in OPNsense.
    Write Into Terminal    5
    Read From Terminal Until    Enter an option:
    Write Into Terminal    y

Remove Extra Default Route
    [Documentation]    If two default routes are present in Linux, remove
    ...    the one NOT pointing to the gateway in test network (192.168.10.1)
    ${route_info}=    Execute Linux Command    ip route | grep ^default
    ${devname}=    String.Get Regexp Matches    ${route_info}
    ...    ^default via 172\.16\.0\.1 dev (?P<devname>\\w+)    devname
    ${length}=    Get Length    ${devname}
    IF    ${length} > 0
        Execute Linux Command    ip route del default via 172.16.0.1 dev ${devname[0]}
        ${route_info}=    Execute Linux Command    ip route | grep ^default
        Log    Default route via 172.16.0.1 dev ${devname[0]} removed
    END

Get Dasharo Security Submenu Construction
    [Documentation]    Keyword allows to get and return setup menu construction.
    ...    Getting setup menu construction is carried out in the following basis:
    ...    1. Get serial output, which shows Boot menu with all elements,
    ...    headers and whitespaces.
    ...    2. Split serial output string and create list.
    ...    3. Create empty list for detected elements of menu.
    ...    4. Add to the new list only elements which are not whitespaces and
    ...    not menu frames.
    ...    5. Remove from new list menu header and footer (header always
    ...    occupies one line, footer -3)
    ${menu}=    Read From Terminal Until    Press ESC to exit.
    @{menu_lines}=    Split String    ${menu}    \n
    @{menu_construction}=    Create List
    FOR    ${line}    IN    @{menu_lines}
        ${line}=    Remove String    ${line}    -    \\    \    /    |    <    >
        ${line}=    Replace String Using Regexp    ${line}    ${SPACE}+    ${SPACE}
        ${line_contains_checkbox}=    Run Keyword And Return Status    Should Contain    ${line}    [

        IF    "${line}"!="${EMPTY}" and "${line}"!="${SPACE}" and "${line_contains_checkbox}"=="True"
            ${line}=    Get Substring    ${line}    1
            Append To List    ${menu_construction}    ${line}
        END
    END
    RETURN    ${menu_construction}

Should Contain All
    [Arguments]    ${string}    @{substrings}
    FOR    ${substring}    IN    @{substrings}
        Should Contain    ${string}    ${substring}
    END
