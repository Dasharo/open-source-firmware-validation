*** Settings ***
Library         Collections
Resource        keys-and-keywords/flashrom.robot
Resource        pikvm-rest-api/pikvm_comm.robot
Resource        lib/bios/menus.robot
Resource        lib/secure-boot-lib.robot
Resource        lib/usb-hid-msc-lib.robot
Resource        lib/terminal.robot
Resource        lib/esp-scanning-lib.robot
Resource        lib/dl-cache.robot
Variables       platform-configs/fan-curve-config.yaml


*** Keywords ***
# TODO: split this file into some manageable modules

Serial Setup
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
    Telnet.Set Timeout    180s

IPXE Dhcp
    [Documentation]    Request IP address in iPXE shell
    Write Bare Into Terminal    \n
    # make sure we are inside iPXE shell
    Read From Terminal Until    iPXE>

IPXE DTS
    [Documentation]    Enter DTS via iPXE.
    Set DUT Response Timeout    180s
    Wait Until Keyword Succeeds    3x    2s
    ...    IPXE Dhcp
    Write Bare Into Terminal    chain http://boot.3mdeb.com/dts.ipxe\n    0.1

Check IPXE Appears Only Once
    [Documentation]    Check the iPXE option appears only once in the boot
    ...    option list.
    ${menu_construction}=    Get Boot Menu Construction
    TRY
        Should Contain X Times    ${menu_construction}    ${IPXE_BOOT_ENTRY}    1
    EXCEPT
        FAIL    Test case marked as Failed\nRequested boot option: (${IPXE_BOOT_ENTRY}) appears not only once.
    END

Launch To DTS Shell
    [Documentation]    Launch to DTS via iPXE and open Shell.
    Enter IPXE
    IPXE DTS
    Set DUT Response Timeout    120s
    Read From Terminal Until    Enter an option
    Set DUT Response Timeout    30s
    Write Into Terminal    9
    Set Prompt For Terminal    bash-5.1#
    Read From Terminal Until Prompt
    # These could be removed once routes priorities in DTS are resolved.
    Sleep    10
    Remove Extra Default Route

Replace Logo In Firmware
    [Documentation]    Swap to custom logo in firmware on DUT using cbfstool according
    ...    to: https://docs.dasharo.com/guides/logo-customization
    [Arguments]    ${logo_file}
    Read FMAP And BOOTSPLASH Regions Internally    /tmp/firmware.rom
    # Remove the existing logo from the firmware image
    ${out}=    Execute Linux Command    cbfstool /tmp/firmware.rom remove -r BOOTSPLASH -n logo.bmp
    # Add your desired bootlogo to the firmware image
    ${out}=    Execute Linux Command
    ...    cbfstool /tmp/firmware.rom add -f ${logo_file} -r BOOTSPLASH -n logo.bmp -t raw -c lzma
    Should Not Contain    ${out}    Image is missing 'BOOTSPLASH' region
    Write BOOTSPLASH Region Internally    /tmp/firmware.rom

Read FMAP And BOOTSPLASH Regions Internally
    [Documentation]    Read BOOTSPLASH firmware on DUT using flashrom.
    [Arguments]    ${fw_file}
    ${out}=    Execute Linux Command    flashrom -p internal --fmap -i FMAP -i BOOTSPLASH -r ${fw_file}    180
    Should Contain    ${out}    Reading flash... done

Write BOOTSPLASH Region Internally
    [Documentation]    Flash BOOTSPLASH firmware region on DUT using flashrom.
    [Arguments]    ${fw_file}
    ${out}=    Execute Linux Command    flashrom -p internal --fmap -i BOOTSPLASH -N -w ${fw_file}    180
    Should Contain Any    ${out}    VERIFIED    Chip content is identical to the requested image

Login To Linux
    [Documentation]    Universal login to one of the supported linux systems:
    ...    Ubuntu or Debian.
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Read From Terminal Until    login:
        Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
    END
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        Login To Linux Via SSH    ${DEVICE_UBUNTU_USERNAME}    ${DEVICE_UBUNTU_PASSWORD}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        Login To Linux Via OBMC    root    root
    ELSE
        Login To Linux Over Serial Console    ${DEVICE_UBUNTU_USERNAME}    ${DEVICE_UBUNTU_PASSWORD}
    END

Login To Linux Via OBMC
    [Documentation]    Login to Linux via OBMC
    [Arguments]    ${username}    ${password}    ${timeout}=300s
    Set DUT Response Timeout    ${timeout}
    Read From Terminal Until    debian login:
    Write Into Terminal    ${username}
    Read From Terminal Until    Password:
    Write Into Terminal    ${password}
    Set Prompt For Terminal    root@debian:~#
    Read From Terminal Until Prompt

Login To Windows
    [Documentation]    Universal login to Windows.
    Boot System Or From Connected Disk    ${OS_WINDOWS}
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
    END
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        Login To Windows Via SSH    ${DEVICE_WINDOWS_USERNAME}    ${DEVICE_WINDOWS_PASSWORD}
    END

Serial Root Login Linux
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

Serial User Login Linux
    [Documentation]    Universal telnet login to Linux system
    [Arguments]    ${password}
    Telnet.Set Prompt    :~$
    Telnet.Set Timeout    300
    Telnet.Login    user    ${password}

# To Do: unify with keyword: Serial root login Linux

Login To Linux Over Serial Console
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

Login To Linux Via SSH
    [Documentation]    Login to Linux via SSH by using provided arguments as
    ...    username and password respectively. The optional timeout
    ...    parameter can be used to specify how long we want to
    ...    wait for the login prompt.
    [Arguments]    ${username}    ${password}    ${timeout}=180    ${prompt}=${DEVICE_UBUNTU_USER_PROMPT}
    # We need this when switching from PiKVM to SSH
    Remap Keys Variables From PiKVM
    SSHLibrary.Open Connection    ${DEVICE_IP}    prompt=${prompt}
    SSHLibrary.Set Client Configuration
    ...    timeout=${timeout}
    ...    term_type=vt100
    ...    width=400
    ...    height=100
    ...    escape_ansi=True
    ...    newline=LF
    Wait Until Keyword Succeeds    12x    10s
    ...    SSHLibrary.Login    ${username}    ${password}

Login To Windows Via SSH
    [Documentation]    Login to Windows via SSH by using provided arguments as
    ...    username and password respectively. The optional timeout
    ...    parameter can be used to specify how long we want to
    ...    wait for the login prompt.
    [Arguments]    ${username}=${DEVICE_WINDOWS_USERNAME}    ${password}=${DEVICE_WINDOWS_PASSWORD}    ${timeout}=180
    SSHLibrary.Open Connection    ${DEVICE_IP}    prompt=${DEVICE_WINDOWS_USER_PROMPT}
    SSHLibrary.Set Client Configuration
    ...    timeout=${timeout}
    ...    term_type=vt100
    ...    width=400
    ...    height=100
    ...    escape_ansi=True
    ...    newline=CRLF
    FOR    ${reboot_count}    IN RANGE    3
        ${login}=    Run Keyword And Return Status
        ...    Wait Until Keyword Succeeds    5x    10s
        ...    SSHLibrary.Login    ${username}    ${password}
        IF    ${login} == ${TRUE}
            BREAK
        ELSE
            IF    ${reboot_count} == 2
                Fail
                ...    SSH: Unable to connect - The platform may be in Windows "Recovery Mode" - Rebooted ${reboot_count} times.
            END
            Power On
            Set Global Variable    ${DUT_CONNECTION_METHOD}    pikvm
            Boot System Or From Connected Disk    ${OS_WINDOWS}
            Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
        END
    END
    IF    ${reboot_count} >= 1
        Log    Windows "Recovery Mode" Workaround - Rebooted ${reboot_count} times.    WARN
    END

Login To Linux Via SSH Without Password
    [Documentation]    Login to Linux via SSH without password
    [Arguments]    ${username}    ${prompt}
    Login To Linux Via SSH    ${username}    ${EMPTY}    prompt=${prompt}

Switch To Root User
    [Documentation]    Switch to the root environment.
    # the "sudo -S" to pass password from stdin does not work correctly with
    # the su command and we need to type in the password
    Write Into Terminal    sudo su
    Read From Terminal Until    [sudo] password for ${DEVICE_UBUNTU_USERNAME}:
    Write Into Terminal    ${DEVICE_UBUNTU_PASSWORD}
    Set Prompt For Terminal    ${DEVICE_UBUNTU_ROOT_PROMPT}
    Read From Terminal Until Prompt

Exit From Root User
    [Documentation]    Exit from the root environment
    Write Into Terminal    exit
    Set Prompt For Terminal    ${DEVICE_UBUNTU_USER_PROMPT}
    Read From Terminal Until Prompt

Open Connection And Log In
    [Documentation]    Open SSH connection and login to session. Setup RteCtrl
    ...    REST API, serial connection and checkout used asset in
    ...    SnipeIt
    Check Provided Ip
    IF    '${CONFIG}' != 'qemu'
        SSHLibrary.Set Default Configuration    timeout=60 seconds
        SSHLibrary.Open Connection    ${RTE_IP}    prompt=~#
        SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
        RTE REST API Setup    ${RTE_IP}    ${HTTP_PORT}
    END
    IF    'sonoff' == '${POWER_CTRL}'
        ${sonoff_ip}=    Get Current RTE Param    sonoff_ip
        Sonoff API Setup    ${sonoff_ip}
    END
    Serial Setup    ${RTE_IP}    ${RTE_S2_N_PORT}
    IF    '${SNIPEIT}'=='no'    RETURN
    SnipeIt Checkout    ${RTE_IP}

Check Provided Ip
    [Documentation]    Check the correctness of the provided ip address, if the
    ...    address is not found in the RTE list, fail the test.
    ${index}=    Set Variable    ${0}
    FOR    ${item}    IN    @{RTE_LIST}
        ${result}=    Evaluate    ${item}.get("ip")
        IF    '${result}'=='${RTE_IP}'    RETURN
        ${index}=    Set Variable    ${index+1}
    END
    Fail    rte_ip:${RTE_IP} not found in the hardware configuration.

Open Connection And Log In OpenBMC
    [Documentation]    Keyword logs in OpenBMC via SSH.
    SSHLibrary.Open Connection    ${DEVICE_IP}    prompt=${OPEN_BMC_ROOT_PROMPT}
    SSHLibrary.Login    ${OPEN_BMC_USERNAME}    ${OPEN_BMC_PASSWORD}
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
    IF    '${PLATFORM}'=='raptor-cs_talos2'    RETURN
    IF    '${SNIPEIT}'=='yes'    SnipeIt Checkin    ${RTE_IP}

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

Enter IPXE
    [Documentation]    Enter iPXE after device power cutoff.
    # TODO:    2 methods for entering iPXE (Ctrl-B and SeaBIOS)
    # TODO2:    problem with iPXE string (e.g. when 3 network interfaces are available)

    IF    '${PAYLOAD}' == 'seabios'
        Enter SeaBIOS
        Sleep    0.5s
        ${setup}=    Telnet.Read
        ${lines}=    Get Lines Matching Pattern    ${setup}    ${IPXE_BOOT_ENTRY}
        Telnet.Write Bare    ${lines[0]}
        Telnet.Read Until    ${IPXE_STRING}
        Telnet.Write Bare    ${IPXE_KEY}
        IPXE Wait For Prompt
    ELSE IF    '${PAYLOAD}' == 'tianocore'
        Enter Boot Menu Tianocore
        Enter Submenu In Tianocore    option=${IPXE_BOOT_ENTRY}
        Enter Submenu In Tianocore
        ...    option=iPXE Shell
        ...    checkpoint=${EDK2_IPXE_CHECKPOINT}
        ...    description_lines=${EDK2_IPXE_START_POS}
        Set Prompt For Terminal    iPXE>
        Read From Terminal Until Prompt
    END

Get Hostname Ip
    [Documentation]    Returns local IP address of the DUT.
    # TODO: We do not necessarily need Internet to be reachable for the internal
    # addresses to be assigned. But if it is, the local IPs are definitely
    # already in place.
    Wait Until Keyword Succeeds    5x    1s
    ...    Check Internet Connection On Linux
    ${out_hostname}=    Execute Command In Terminal    hostname -I
    Should Not Contain    ${out_hostname}    link is not ready
    ${ip_address}=    String.Get Regexp Matches    ${out_hostname}    \\b192\\.168\\.\\d{1,3}\\.\\d{1,3}\\b
    Should Not Be Empty    ${ip_address}
    RETURN    ${ip_address[0]}

    # [Return]    ${ip_address.partition("\n")[0]}

Get Firmware Version From Binary
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

Get Firmware Version From UEFI Shell
    [Documentation]    Return firmware version from UEFI shell.
    Telnet.Set Timeout    90s
    Telnet.Read Until    Shell>
    Telnet.Write Bare    smbiosview -t 0
    Telnet.Write Bare    \n
    ${output}=    Telnet.Read Until    BiosSegment
    ${version}=    Get Lines Containing String    ${output}    BiosVersion
    RETURN    ${version.replace('BiosVersion: ', '')}

Get Firmware Version From Dmidecode
    ${output}=    Execute Linux Command    dmidecode -t bios
    ${version_string}=    Get Lines Containing String    ${output}    Version:
    ${version}=    Fetch From Right    ${version_string}    ${SPACE}
    RETURN    ${version}

Get Firmware Version
    [Documentation]    Return firmware version via method supported by the
    ...    platform.
    # Boot platform into payload allowing to read flashed firmware version
    IF    '${FLASH_VERIFY_METHOD}'=='iPXE-boot'
        Boot Debian From IPXE    ${PXE_IP}    ${HTTP_PORT}    ${FILENAME}    ${DEBIAN_STABLE_VER}
    ELSE IF    '${FLASH_VERIFY_METHOD}'=='tianocore-shell'
        ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
        Enter Submenu From Snapshot    ${boot_menu}    ${FLASH_VERIFY_OPTION}
    ELSE IF    '${FLASH_VERIFY_METHOD}'=='none'
        No Operation
    END
    # Read firmware version
    IF    '${FLASH_VERIFY_METHOD}'=='iPXE-boot'
        ${version}=    Get Firmware Version From Dmidecode
    ELSE IF    '${FLASH_VERIFY_METHOD}'=='tianocore-shell'
        ${version}=    Get Firmware Version From UEFI Shell
    ELSE IF    '${FLASH_VERIFY_METHOD}'=='none'
        ${version}=    Get Firmware Version From Binary    ${FW_FILE}
    ELSE
        ${version}=    Set Variable    ${NONE}
    END
    RETURN    ${version}

Check The Presence Of WiFi Card
    [Documentation]    Checks the if WiFi card is visible for operating system.
    ...    Returns True if presence is detected.
    ${terminal_result}=    Execute Command In Terminal    lspci | grep '${WIFI_CARD_UBUNTU}'
    ${result}=    Run Keyword And Return Status
    ...    Should Not Be Empty    ${terminal_result}
    RETURN    ${result}

Check The Presence Of Bluetooth Card
    [Documentation]    Checks the if Bluetooth card is visible for OS.
    ...    Returns True if presence is detected.
    ${terminal_result}=    Execute Command In Terminal    lsusb | grep '${BLUETOOTH_CARD_UBUNTU}'
    ${result}=    Run Keyword And Return Status
    ...    Should Not Be Empty    ${terminal_result}
    RETURN    ${result}

Get Current RTE
    [Documentation]    Returns RTE index from RTE list taken as an argument.
    ...    Returns -1 if CPU ID not found in variables.robot.
    [Arguments]    @{rte_list}
    ${con}=    SSHLibrary.Open Connection    ${RTE_IP}
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    ${cpuid}=    SSHLibrary.Execute Command
    ...    cat /proc/cpuinfo |grep Serial|cut -d":" -f2|tr -d " "
    ...    connection=${con}
    ${index}=    Set Variable    ${0}
    FOR    ${item}    IN    @{rte_list}
        IF    '${item.cpuid}' == '${cpuid}'    RETURN    ${index}
        ${index}=    Set Variable    ${index+1}
    END
    RETURN    ${-1}

Get Current RTE Param
    [Documentation]    Returns current RTE parameter value specified in the argument.
    [Arguments]    ${param}
    ${idx}=    Get Current RTE    @{RTE_LIST}
    Should Not Be Equal    ${idx}    ${-1}    msg=RTE not found in hw-matrix
    &{rte}=    Get From List    ${RTE_LIST}    ${idx}
    RETURN    ${rte}[${param}]

Get Current CONFIG Start Index
    [Documentation]    Returns current CONFIG start index from CONFIG_LIST
    ...    specified in the argument required for slicing list.
    ...    Returns -1 if CONFIG not found in variables.robot.
    [Arguments]    ${config_list}
    ${rte_cpuid}=    Get Current RTE Param    cpuid
    Should Not Be Equal    ${rte_cpuid}    ${-1}    msg=RTE not found in hw-matrix
    ${index}=    Set Variable    ${0}
    FOR    ${config}    IN    @{config_list}
        ${result}=    Evaluate    ${config}.get("cpuid")
        IF    '${result}'=='${rte_cpuid}'    RETURN    ${index}
        ${index}=    Set Variable    ${index+1}
    END
    RETURN    ${-1}

Get Current CONFIG Stop Index
    [Documentation]    Returns current CONFIG stop index from CONFIG_LIST
    ...    specified in the argument required for slicing list.
    ...    Returns -1 if CONFIG not found in variables.robot.
    [Arguments]    ${config_list}    ${start}
    ${length}=    Get Length    ${config_list}
    ${index}=    Set Variable    ${start+1}
    FOR    ${config}    IN    @{config_list[${index}:]}
        ${result}=    Evaluate    ${config}.get("cpuid")
        IF    '${result}'!='None'    RETURN    ${index}
        IF    '${index}'=='${length-1}'    RETURN    ${index+1}
        ${index}=    Set Variable    ${index+1}
    END
    RETURN    ${-1}

Get Current CONFIG
    [Documentation]    Returns current config as a list variable based on start
    ...    and stop indexes.
    [Arguments]    ${config_list}
    ${start}=    Get Current CONFIG Start Index    ${config_list}
    Should Not Be Equal    ${start}    ${-1}    msg=Current CONFIG not found in hw-matrix
    ${stop}=    Get Current CONFIG Stop Index    ${config_list}    ${start}
    Should Not Be Equal    ${stop}    ${-1}    msg=Current CONFIG not found in hw-matrix
    ${config}=    Get Slice From List    ${config_list}    ${start}    ${stop}
    RETURN    ${config}

Get Current CONFIG Item
    [Documentation]    Returns current CONFIG item specified in the argument.
    ...    Returns -1 if CONFIG item not found in variables.robot.
    [Arguments]    ${item}
    ${config}=    Get Current CONFIG    ${CONFIG_LIST}
    ${length}=    Get Length    ${config}
    Should Be True    ${length} > 1
    FOR    ${element}    IN    @{config[1:]}
        IF    '${element.type}'=='${item}'    RETURN    ${element}
    END
    RETURN    ${-1}

Get Current CONFIG Item Param
    [Documentation]    Returns current CONFIG item parameter specified in the
    ...    arguments.
    [Arguments]    ${item}    ${param}
    ${device}=    Get Current CONFIG Item    ${item}
    RETURN    ${device.${param}}

Get Slot Count
    [Documentation]    Returns count parameter value from slot key specified in
    ...    the argument if found, otherwise return 0.
    [Arguments]    ${slot}
    ${is_found}=    Evaluate    "count" in """${slot}"""
    ${return}=    Set Variable If
    ...    ${is_found}==False    0
    ...    ${is_found}==True    ${slot.count}
    RETURN    ${return}

Get USB Slot Count
    [Documentation]    Returns count parameter value from USB slot key specified
    ...    in the argument if found, otherwise return 0.
    [Arguments]    ${slots}
    ${is_found1}=    Evaluate    "USB_Storage" in """${slots.slot1}"""
    ${is_found2}=    Evaluate    "USB_Storage" in """${slots.slot2}"""
    IF    ${is_found1}==True
        ${count1}=    Get Slot Count    ${slots.slot1}
    ELSE
        ${count1}=    Evaluate    0
    END
    IF    ${is_found2}==True
        ${count2}=    Get Slot Count    ${slots.slot2}
    ELSE
        ${count2}=    Evaluate    0
    END
    ${sum}=    Evaluate    ${count1}+${count2}
    RETURN    ${sum}

Get All USB
    [Documentation]    Returns number of attached USB storages in current CONFIG.
    ${conf}=    Get Current CONFIG    ${CONFIG_LIST}
    ${is_found}=    Evaluate    "USB_Storage" in """${conf}"""
    IF    ${is_found}==True
        ${usb_count}=    Get Current CONFIG Item Param    USB_Storage    count
        ${count_usb}=    Evaluate    ${usb_count}
    ELSE
        ${usb_count}=    Evaluate    ""
        ${count_usb}=    Evaluate    0
    END
    ${is_found}=    Evaluate    "USB_Expander" in """${conf}"""
    IF    ${is_found}==True
        ${external}=    Get Current CONFIG Item    USB_Expander
        ${external_count}=    Get USB Slot Count    ${external}
    ELSE
        ${external}=    Evaluate    ""
        ${external_count}=    Evaluate    0
    END
    ${count}=    Evaluate    ${count_usb}+${external_count}
    RETURN    ${count}

Get Boot Timestamps
    [Documentation]    Returns all boot timestamps from cbmem tool.
    # fix for LT1000 and protectli platforms (output without tabs)
    Get Cbmem From Cloud
    ${out_cbmem}=    Execute Command In Terminal    cbmem -T
    ${timestamps}=    Split String    ${out_cbmem}    \n
    ${timestamps}=    Get Slice From List    ${timestamps}    0    -1
    RETURN    ${timestamps}

Log Boot Timestamps
    [Documentation]    Log to console formatted boot timestamps. Takes timestamp
    ...    string and string length as an arguments.
    [Arguments]    ${timestamps}    ${length}
    FOR    ${number}    IN RANGE    0    ${length}
        ${line}=    Get From List    ${timestamps}    ${number}
        ${line}=    Split String    ${line}    \
        ${duration}=    Get From List    ${line}    2
        ${duration}=    Convert To Number    ${duration}
        ${name}=    Get Slice From List    ${line}    3
        ${name}=    Evaluate    " ".join(${name})
        ${duration_formatted}=    Evaluate    ${duration}/1000000
        Log    ${name}: ${duration_formatted} s (${duration} ns)
    END

Get Duration From Timestamps
    [Documentation]    Returns number representing full boot duration. Takes
    ...    cbmem string timestamp and string length as an arguments.
    [Arguments]    ${timestamps}    ${length}
    ${index}=    Evaluate    ${length}-1
    ${line}=    Get From List    ${timestamps}    ${index}
    ${line}=    Split String    ${line}    \
    ${duration}=    Get From List    ${line}    1
    ${duration}=    Convert To Number    ${duration}
    RETURN    ${duration}

Prepare Lm-sensors
    [Documentation]    Install lm-sensors and probe sensors.
    Detect Or Install Package    lm-sensors
    Execute Command In Terminal    yes | sudo sensors-detect
    IF    '${PLATFORM}' == 'raptor-cs_talos2'
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

Get CPU Frequencies In Ubuntu
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

Check If CPU Not Stucks On Initial Frequency In Ubuntu
    [Documentation]    Check that CPU not stuck on initial frequency.
    ${is_cpu_stucks}=    Set Variable    ${FALSE}
    ${are_frequencies_equal}=    Set Variable    ${TRUE}
    @{frequencies}=    Get CPU Frequencies In Ubuntu
    ${first_frequency}=    Get From List    ${frequencies}    0
    FOR    ${frequency}    IN    @{frequencies}
        IF    ${frequency} != ${first_frequency}
            ${are_frequencies_equal}=    Set Variable    ${FALSE}
        ELSE
            ${are_frequencies_equal}=    Set Variable    ${NONE}
        END
        IF    '${are_frequencies_equal}'=='False'    BREAK
    END
    IF    '${are_frequencies_equal}'=='False'
        Pass Execution    CPU does not stuck on initial frequency
    END
    IF    ${first_frequency}!=${INITIAL_CPU_FREQUENCY}
        Pass Execution    CPU does not stuck on initial frequency
    ELSE
        FAIL    CPU stucks on initial frequency: ${INITIAL_CPU_FREQUENCY}
    END

Check If CPU Not Stucks On Initial Frequency In Windows
    [Documentation]    Check that CPU not stuck on initial frequency.
    ${out}=    Execute Command In Terminal
    ...    (Get-CimInstance CIM_Processor).MaxClockSpeed*((Get-Counter -Counter "\\Processor Information(_Total)\\% Processor Performance").CounterSamples.CookedValue/100)
    FOR    ${number}    IN RANGE    0    10
        ${out2}=    Execute Command In Terminal
        ...    (Get-CimInstance CIM_Processor).MaxClockSpeed*((Get-Counter -Counter "\\Processor Information(_Total)\\% Processor Performance").CounterSamples.CookedValue/100)
        Should Not Be Equal    ${out}    ${out2}
    END

Check CPU Frequency In Windows
    [Documentation]    Check that CPU is running on expected frequency.
    ${freq_max_info}=    Execute Command In Terminal    (Get-CimInstance CIM_Processor).MaxClockSpeed
    ${freq_max}=    Get Line    ${freq_max_info}    -1
    ${freq_max}=    Convert To Number    ${freq_max}
    FOR    ${number}    IN RANGE    0    10
        ${freq_current_info}=    Execute Command In Terminal
        ...    (Get-CimInstance CIM_Processor).MaxClockSpeed*((Get-Counter -Counter "\\Processor Information(_Total)\\% Processor Performance").CounterSamples.CookedValue)/100
        ${freq_current}=    Get Line    ${freq_current_info}    -1
        ${freq_current}=    Convert To Number    ${freq_current}
        Run Keyword And Continue On Failure
        ...    Should Be True    ${freq_max} > ${freq_current}
    END

Stress Test
    [Documentation]    Proceed with the stress test.
    [Arguments]    ${time}=60s
    Detect Or Install Package    stress-ng
    Execute Command In Terminal    stress-ng --cpu 1 --timeout ${time} &> /dev/null &

Flash Firmware
    [Documentation]    Flash platform with firmware file specified in the
    ...    argument. Keyword fails if file size doesn't match target
    ...    chip size.
    [Arguments]    ${fw_file}
    ${file_size}=    Run    ls -l ${fw_file} | awk '{print $5}'
    IF    '${file_size}'!='${FLASH_SIZE}'
        FAIL    Image size doesn't match the flash chip's size!
    END
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Put File    ${fw_file}    /tmp/coreboot.rom
    END
    Sleep    2s
    ${platform}=    Get Current RTE Param    platform
    IF    '${platform[:3]}' == 'apu'
        Flash Apu
    ELSE IF    '${platform[:13]}' == 'optiplex-7010'
        Flash Firmware Optiplex
    ELSE IF    '${platform[:8]}' == 'KGPE-D16'
        Flash KGPE-D16
    ELSE IF    '${platform[:10]}' == 'novacustom'
        Flash Device Via Internal Programmer    ${fw_file}
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
    IF    '${SNIPEIT}' == 'yes'
        Import Library    ${CURDIR}/osfv-scripts/osfv_cli/osfv_cli/snipeit_robot.py
        # Import Library    snipeit_robot.py
    END
    IF    '${CONFIG}' == 'crystal'
        Import Resource    ${CURDIR}/platform-configs/vitro_crystal.robot
    ELSE IF    '${CONFIG}' == 'pv30'
        Import Resource    ${CURDIR}/dev-tests/operon/configs/pv30.robot
    ELSE IF    '${CONFIG}' == 'yocto'
        Import Resource    ${CURDIR}/dev-tests/operon/configs/yocto.robot
    ELSE IF    '${CONFIG}' == 'raspbian'
        Import Resource    ${CURDIR}/dev-tests/operon/configs/raspbian.robot
    ELSE IF    '${CONFIG}' == 'rpi-3b'
        Import Resource    ${CURDIR}/platform-configs/rpi-3b.robot
    ELSE
        Import Resource    ${CURDIR}/platform-configs/${CONFIG}.robot
    END
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        Prepare To SSH Connection
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Prepare To Serial Connection
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        Prepare To OBMC Connection
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Prepare To PiKVM Connection
    ELSE
        FAIL    Unknown connection method for config: ${CONFIG}
    END
    IF    '${CONFIG}' == 'rpi-3b'    Verify Number Of Connected SD Wire Devices

Prepare To SSH Connection
    [Documentation]    Keyword prepares Test Suite by setting current platform
    ...    and its ip to the global variables, configuring the
    ...    SSH connection, Setup RteCtrl REST API and checkout used
    ...    asset in SnipeIt . Keyword used in [Suite Setup]
    ...    sections if the communication with the platform based on
    ...    the SSH protocol
    # tu leci zmiana, musimy brać platformy zgodnie z tym co zostało pobrane w dasharo
    Set Global Variable    ${PLATFORM}    ${CONFIG}
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
    IF    '${CONFIG}' == 'qemu'
        Set Global Variable    ${PLATFORM}    qemu
    ELSE
        ${platform}=    Get Current RTE Param    platform
        Set Global Variable    ${PLATFORM}
    END
    Get DUT To Start State

Prepare To OBMC Connection
    [Documentation]    Keyword prepares Test Suite by opening open-bmc
    ...    connection, setting current platform to the global
    ...    variable and setting the DUT to start state. Keyword
    ...    used in [Suite Setup] sections if the communication with
    ...    the platform based on the open-bmc
    Set Global Variable    ${PLATFORM}    ${CONFIG}
    Set Global Variable    ${OPENBMC_HOST}    ${DEVICE_IP}
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
    Remap Keys Variables To PiKVM
    Open Connection And Log In
    ${platform}=    Get Current RTE Param    platform
    ${pikvm_ip}=    Get Current RTE Param    pikvm_ip
    Set Global Variable    ${PIKVM_IP}
    Set Global Variable    ${PLATFORM}
    Get DUT To Start State

Remap Keys Variables To PiKVM
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
    Set Global Variable    ${DIGIT0}    Digit0
    Set Global Variable    ${DIGIT1}    Digit1
    Set Global Variable    ${DIGIT2}    Digit2
    Set Global Variable    ${DIGIT3}    Digit3
    Set Global Variable    ${DIGIT4}    Digit4
    Set Global Variable    ${DIGIT5}    Digit5
    Set Global Variable    ${DIGIT6}    Digit6
    Set Global Variable    ${DIGIT7}    Digit7
    Set Global Variable    ${DIGIT8}    Digit8
    Set Global Variable    ${DIGIT9}    Digit9

Remap Keys Variables From PiKVM
    [Documentation]    Updates keys variables from PiKVM ones to the ones
    ...    as defined in keys.robot
    Import Resource    ${CURDIR}/keys.robot

Get DUT To Start State
    [Documentation]    Clears telnet buffer and get Device Under Test to start
    ...    state (RTE Relay On).
    Telnet.Read
    IF    '${CONFIG}' != 'qemu'
        ${result}=    Get Power Supply State
        IF    '${result}'=='low'    Turn On Power Supply
    END

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
        Run Keywords
        ...    Sleep    4s
        ...    AND
        ...    Telnet.Read
        ...    AND
        ...    RteCtrl Relay
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
    Serial Setup    ${RTE_IP}    ${RTE_S2_N_PORT}

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

Get CPU Temperature And CPU Fan Speed
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

Execute Linux Command Without Output
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

Execute Linux Command
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

Execute Linux Tpm2 Tools Command
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
    ${initial_method_defined}=    Get Variable Value    ${INITIAL_DUT_CONNECTION_METHOD}
    IF    '${initial_method_defined}' == 'None'    RETURN
    IF    '${INITIAL_DUT_CONNECTION_METHOD}' == 'pikvm'
        Set Global Variable    ${DUT_CONNECTION_METHOD}    pikvm
        # We need this when going back from SSH to PiKVM
        Remap Keys Variables To PiKVM
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

Check Docking Station HDMI Windows
    [Documentation]    Check if docking station HDMI display is recognized by
    ...    Windows OS.
    ${out}=    Check Displays Windows
    Should Contain Any    ${out}    VideoOutputTechnology : 12    VideoOutputTechnology : 10

Check DP Windows
    [Documentation]    Check if DP display is recognized by Windows OS.
    ${out}=    Check Displays Windows
    IF    '${PLATFORM}' == 'protectli-vp4630'
        Should Contain Any
        ...    ${out}
        ...    VideoOutputTechnology : 10
        ...    VideoOutputTechnology : 11
        ...    VideoOutputTechnology : 2147483648
    ELSE
        Should Contain Any    ${out}    VideoOutputTechnology : 10    VideoOutputTechnology : 11
    END

Check Docking Station DP Windows
    [Documentation]    Check if docking station DP display is recognized by
    ...    Windows OS.
    ${out}=    Check Displays Windows
    Should Contain Any    ${out}    VideoOutputTechnology : 10    VideoOutputTechnology : 11

Check Internal LCD Windows
    [Documentation]    Check if internal LCD is recognized by Windows OS.
    ${out}=    Check Displays Windows
    Should Contain Any    ${out}    VideoOutputTechnology : 2147483648    VideoOutputTechnology : 16

Check External HDMI In Linux
    [Documentation]    Keyword checks if an external HDMI device is visible
    ...    in Linux OS.
    ${out}=    Execute Linux Command    cat /sys/class/drm/card0/*HDMI*/status
    Should Contain    ${out}    connected

Check Docking Station HDMI In Linux
    [Documentation]    Keyword checks if an docking station HDMI device is
    ...    visiblein Linux OS.
    TRY
        ${out}=    Execute Linux Command    cat /sys/class/drm/card0-DP-7/status
        Should Not Contain    ${out}    disconnected
        Should Contain    ${out}    connected
    EXCEPT
        ${out}=    Execute Linux Command    cat /sys/class/drm/card0-DP-1/status
        Should Not Contain    ${out}    disconnected
        Should Contain    ${out}    connected
    END

Check External DP In Linux
    [Documentation]    Keyword checks if an external Display Port device is
    ...    visible in Linux OS.
    ${out}=    Execute Linux Command    cat /sys/class/drm/card0-DP-1/status
    Should Not Contain    ${out}    disconnected
    Should Contain    ${out}    connected

Check Docking Station DP In Linux
    [Documentation]    Keyword checks if an docking station Display Port device
    ...    is visible in Linux OS.
    ${out}=    Execute Linux Command    cat /sys/class/drm/card0-DP-7/status
    Should Not Contain    ${out}    disconnected
    Should Contain    ${out}    connected

Device Detection In Linux
    [Documentation]    Keyword checks if a given device name as a parameter is
    ...    visible in Linux OS.
    [Arguments]    ${device}
    ${out}=    Execute Linux Command    libinput list-devices | grep ${device}
    Should Contain    ${out}    ${device}

Check Charge Level In Linux
    [Documentation]    Keyword checks the charge level in Linux OS.
    Set Local Variable    ${CMD}    cat /sys/class/power_supply/BAT0/charge_now
    ${out}=    Execute Linux Command    ${CMD}
    # capacity in uAh
    ${capacity}=    Convert To Integer    ${out}
    Should Be True    ${capacity} <= ${CLEVO_BATTERY_CAPACITY}
    Should Be True    ${capacity} > 0

Check Charging State In Linux
    [Documentation]    Keyword checks the charging state in Linux OS.
    ${out}=    Execute Linux Command    cat /sys/class/power_supply/BAT0/status
    Should Contain Any    ${out}    Charging    Full

Check Charging State Not Charging In Linux
    [Documentation]    Keyword checks if the battery state is Not charging
    ...    in Linux OS.
    ${out}=    Execute Linux Command    cat /sys/class/power_supply/BAT0/status
    Should Contain Any    ${out}    Not charging

Check Charging State In Windows
    [Documentation]    Keyword checks the charging state in Windows OS.
    ${out}=    Execute Command In Terminal    Get-WmiObject win32_battery
    Should Contain    ${out}    BatteryStatus${SPACE*15}: 2

Discharge The Battery Until Target Level In Linux
    [Documentation]    Keyword stresses the CPU to discharge the battery until
    ...    the target charge level is reached.
    [Arguments]    ${target}
    Detect Or Install Package    stress-ng
    WHILE    True
        ${out}=    Execute Command In Terminal    cat /sys/class/power_supply/BAT0/capacity
        IF    ${out} <= ${target}    BREAK
        Execute Command In Terminal    stress-ng --cpu 0 --timeout 10s
    END

Check Battery Percentage In Linux
    [Documentation]    Keyword check the battery percentage in Linux OS.
    ${percentage}=    Execute Command In Terminal    cat /sys/class/power_supply/BAT0/capacity
    RETURN    ${percentage}

Charge Battery Until Target Level In Linux
    [Documentation]    Keyword periodically checks battery charge level until it
    ...    reaches defined target in Linux OS.
    [Arguments]    ${target}
    FOR    ${i}    IN RANGE    2000
        ${out}=    Check Battery Percentage In Linux
        Sleep    5
        IF    ${out} == ${target}    BREAK
    END
    Run Keyword Unless    ${out} == ${target}
    Log    Could not charge battery to specified level within timeout.

Turn On ACPI CALL Module In Linux
    [Documentation]    Keyword turns on acpi_call module in Linux OS.
    Execute Linux Command    modprobe acpi_call

Set Brightness In Linux
    [Documentation]    Keyword sets desired brightness in Linux OS.
    ...    Brightness value range: [0 , 48000].
    [Arguments]    ${brightness}
    Execute Linux Command    echo ${brightness} > /sys/class/backlight/intel_backlight/brightness

Get Current Brightness In Linux
    [Documentation]    Keyword gets current brightness in Linux OS and returns
    ...    it as an integer.
    Set Local Variable    ${CMD}    cat /sys/class/backlight/intel_backlight/brightness
    ${out1}=    Execute Linux Command    ${CMD}
    ${brightness}=    Convert To Integer    ${out1}
    RETURN    ${brightness}

Brightness Up Button In Linux
    [Documentation]    Keyword increases the screen brightness in Linux OS.
    # simulating brightness up hotkey
    Execute Linux Command    echo '\\_SB.PCI0.LPCB.EC0._Q12' | tee /proc/acpi/call
    Sleep    2s

Brightness Down Button In Linux
    [Documentation]    Keyword decreases the screen brightness in Linux OS.
    # simulating brightness down hotkey
    Execute Linux Command    echo '\\_SB.PCI0.LPCB.EC0._Q11' | tee /proc/acpi/call
    Sleep    2s

Toggle Camera In Linux
    [Documentation]    Keyword toggles camera by simulating the function
    ...    button in Linux OS.
    # simulating camera hotkey
    Execute Linux Command    echo '\\_SB.PCI0.LPCB.EC0._Q13' | tee /proc/acpi/call
    Sleep    2s

Get WiFi Block Status
    [Documentation]    Keyword returns True if WiFi is soft or hard blocked.
    ...    Soft or hard blocking check depends on the given
    ...    argument.
    ...    Mode - Soft or Hard
    [Arguments]    ${mode}=Soft
    ${wifi_status}=    Execute Linux Command    rfkill list 0
    ${status}=    Run Keyword And Return Status
    ...    Should Contain    ${wifi_status}    ${mode} blocked: yes
    RETURN    ${status}

Get Bluetooth Block Status
    [Documentation]    Keyword returns True if Bluetooth is soft or hard blocked.
    ...    Soft or hard blocking check depends on the given
    ...    argument.
    ...    Mode - Soft or Hard
    [Arguments]    ${mode}=Soft
    ${bt_status}=    Execute Linux Command    rfkill list 0
    ${status}=    Run Keyword And Return Status
    ...    Should Contain    ${bt_status}    ${mode} blocked: yes
    RETURN    ${status}

Toggle Flight Mode In Linux
    [Documentation]    Keyword toggles the airplane mode by simulating the
    ...    function button usage in Linux OS.
    # simulating airplane mode hotkey
    Execute Linux Command    echo '\\_SB.PCI0.LPCB.EC0._Q14' | tee /proc/acpi/call
    Sleep    2s

List Devices In Linux
    [Documentation]    Keyword lists devices in Linux OS and returns output.
    ...    The port is given as an argument:
    ...    ${port}: pci or usb
    [Arguments]    ${port}
    ${out}=    Execute Linux Command    ls${port}
    RETURN    ${out}

Detect Docking Station In Linux
    [Documentation]    Keyword check the docking station is detected correctly.
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ASIX Electronics Corp. AX88179 Gigabit Ethernet
    Should Contain    ${out}    Realtek Semiconductor Corp. USB3.0 Card Reader
    Should Contain    ${out}    VIA Labs, Inc. USB3.0 Hub

Check If Files Are Identical In Linux
    [Documentation]    Keyword takes two files as arguments and compares them
    ...    using sha256sum in Linux OS. Returns True if both files
    ...    have an identical content.
    [Arguments]    ${file1}    ${file2}
    ${out1}=    Execute Command In Terminal    sha256sum ${file1}
    ${out2}=    Execute Command In Terminal    sha256sum ${file2}
    ${splitted1}=    Split String    ${out1}
    ${sha256sum1}=    Get From List    ${splitted1}    0
    ${splitted2}=    Split String    ${out2}
    ${sha256sum2}=    Get From List    ${splitted2}    0
    ${status}=    Run Keyword And Return Status
    ...    Should Be Equal    ${sha256sum1}    ${sha256sum2}
    RETURN    ${status}

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

Get Video Controllers Windows
    [Documentation]    Get and return all video controllers on the device using
    ...    PowerShell on Windows OS.
    ${out}=    Execute Command In Terminal
    ...    Get-WmiObject -Class Win32_VideoController | Select Description, Name, Status
    RETURN    ${out}

Check NVIDIA Power Management In Linux
    [Documentation]    Check whether the NVIDIA Graphics Card power management
    ...    works correctly (card should powers on only if it's in
    ...    use).
    Sleep    20s
    ${out}=    Execute Linux Command    cat /sys/class/drm/card1/device/power/runtime_status
    Should Contain    ${out}    suspended
    Execute Linux Command    lspci | grep -i nvidia | cat
    ${out}=    Execute Linux Command    cat /sys/class/drm/card1/device/power/runtime_status
    Should Contain    ${out}    active
    Sleep    20s
    ${out}=    Execute Linux Command    cat /sys/class/drm/card1/device/power/runtime_status
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

Identify Disks In Linux
    [Documentation]    Check whether any disk is recognized in Linux system
    ...    and identify their vndor and model.
    ${out}=    Execute Linux Command    lsblk --nodeps --output NAME
    @{disks}=    Get Regexp Matches    ${out}    sd.
    ${disks_info}=    Create List
    FOR    ${disk}    IN    @{disks}
        ${vendor}=    Execute Linux Command    cat /sys/class/block/${disk}/device/vendor
        ${model}=    Execute Linux Command    cat /sys/class/block/${disk}/device/model
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

Identify Path To SD Card In Linux
    [Documentation]    Check which sdX is the correct path to mounted SD card.
    ${out}=    Execute Linux Command    lsblk --nodeps --output NAME
    @{disks}=    Get Regexp Matches    ${out}    sd.
    @{path}=    Create List
    FOR    ${disk}    IN    @{disks}
        TRY
            ${model}=    Execute Linux Command    fdisk -l | grep "Disk /dev/${disk}" -A 1
            ${match}=    Should Match    str(${model})    *SD*
            Append To List    ${path}    ${disk}
        EXCEPT
            Log    ${disk} is not SD Card
        END
    END
    RETURN    @{path}

Check Read Write To External Drive In Linux
    [Documentation]    Check if read/write to external drive works on Linux.
    [Arguments]    ${disk}
    Execute Linux Command    dd if=/dev/urandom of=/tmp/in.bin bs=4K count=100
    Execute Linux Command    dd if=/tmp/in.bin of=/dev/${disk} bs=4K count=100
    Execute Linux Command    dd if=/dev/${disk} of=/tmp/out.bin bs=4K count=100
    ${result}=    Check If Files Are Identical In Linux    /tmp/in.bin    /tmp/out.bin
    Should Be True    ${result}

Identify Path To SD Card In Windows
    [Documentation]    Check thecorrect path to mounted SD card.
    ${out}=    Run
    ...    sshpass -p ${DEVICE_WINDOWS_PASSWORD} scp drive_letters.ps1 ${DEVICE_WINDOWS_USERNAME}@${DEVICE_IP}:/C:/Users/user
    Should Be Empty    ${out}
    ${result}=    Execute Command In Terminal    .\\drive_letters.ps1
    ${lines}=    Get Lines Matching Pattern    ${result}    *SD*
    ${drive_letter}=    Evaluate    $lines[0:2]
    RETURN    ${drive_letter}

Check Read Write To External Drive In Windows
    [Arguments]    ${drive_letter}
    Execute Command In Terminal
    ...    New-Item -Path "${drive_letter}/" -Name "testfile.txt" -ItemType "file" -Value "This is a test string."
    ${out}=    Execute Command In Terminal    Get-Content "${drive_letter}/testfile.txt"
    Should Contain    ${out}    This is a test string.
    Execute Command In Terminal    rm -fo ${drive_letter}/testfile.txt

Install Docker Packages
    [Documentation]    Install Docker Engine using latest version on Ubuntu.
    ${out_test}=    Execute Command In Terminal    docker --version; echo $?
    ${exit_code_str}=    Get Line    ${out_test}    -1
    ${exit_code}=    Convert To Integer    ${exit_code_str}
    IF    ${exit_code} != 0
        Wait Until Keyword Succeeds    5x    1s
        ...    Check Internet Connection On Linux
        Execute Command In Terminal    wget https://get.docker.com -O /tmp/get-docker.sh
        Execute Command In Terminal    sh /tmp/get-docker.sh    timeout=5m
        ${out_docker}=    Execute Command In Terminal    docker --version
        Should Contain    ${out_docker}    Docker version
    END

Detect Or Install Package
    [Documentation]    Check whether the package, that is necessary to run the
    ...    test case, has already been installed on the system.
    [Arguments]    ${package}
    ${is_package_installed}=    Set Variable    ${FALSE}
    Log To Console    \nChecking if ${package} is installed...
    ${is_package_installed}=    Check If Package Is Installed    ${package}
    IF    ${is_package_installed}
        Log To Console    \nPackage ${package} is installed
    ELSE
        Log To Console    \nPackage ${package} is not installed
    END
    IF    ${is_package_installed}    RETURN
    Log To Console    \nInstalling required package (${package})...
    Install Package    ${package}
    Sleep    10s
    ${is_package_installed}=    Check If Package Is Installed    ${package}
    IF    ${is_package_installed}=='False'
        FAIL    \nRequired package (${package}) cannot be installed
    END
    Log To Console    \nRequired package (${package}) installed successfully

Check If Package Is Installed
    [Documentation]    Check whether the package, that is necessary to run the
    ...    test case, has already been installed on the system.
    [Arguments]    ${package}
    ${output}=    Execute Command In Terminal    dpkg --list ${package} | cat
    IF    "no packages found matching" in """${output}""" or "<none>" in """${output}"""
        ${is_installed}=    Set Variable    ${FALSE}
    ELSE
        ${is_installed}=    Set Variable    ${TRUE}
    END
    RETURN    ${is_installed}

Install Package
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
    Wait Until Keyword Succeeds    5x    1s
    ...    Check Internet Connection On Linux
    ${out}=    Execute Linux Command
    ...    wget --content-disposition --no-check-certificate --retry-connrefused -O ${local_path} ${remote_url}
    ...    ${timeout}
    Should Contain    ${out}    200 OK
    Should Contain    ${out}    ${local_path}
    Should Contain    ${out}    saved
    Should Not Contain    ${out}    failed

Login To Linux With Root Privileges
    [Documentation]    Login to Linux to perform test on OS level. Which login
    ...    method will be used depends on: connection method and
    ...    platform type.
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        Run Keywords
        ...    Login To Linux Via SSH    ${DEVICE_UBUNTU_USERNAME}    ${DEVICE_UBUNTU_PASSWORD}
        ...    AND
        ...    Switch To Root User
    END
    IF    '${CONFIG}'=='raptor-cs_talos2'
        Login To Linux Via OBMC    root    debian
    ELSE IF    '${PLATFORM[:8]}' == 'KGPE-D16'
        Serial Root Login Linux    debian
    END

Compare Serial Number From MAC
    [Documentation]    Compare serial number with value got calculated from MAC
    ...    address with serial number got from dmidecode.
    [Arguments]    ${serial_number}
    ${out}=    Calculate Serial Number From MAC
    Should Contain    ${serial_number}    ${out}

Firmware Version Verification From Binary
    [Documentation]    Check whether the DUT firmware version is the same as it
    ...    is expected by checking it with dmidecode and comparing
    ...    with a value get from binary.
    Read Firmware    ${TEMPDIR}${/}coreboot.rom
    Power Cycle On
    ${version}=    Get Firmware Version
    ${coreboot_version}=    Get Firmware Version From Binary    ${TEMPDIR}${/}coreboot.rom
    Should Contain    ${coreboot_version}    ${version}

Firmware Release Date Verification From SOL
    [Documentation]    Check whether the DUT firmware release date is the same
    ...    as it is expected by checking it with dmidecode and
    ...    comparing with a value get from sign of life.
    Power Cycle On
    ${sign_of_life}=    Get Sign Of Life
    ${sol_date}=    Get Lines Containing String    ${sign_of_life}    coreboot build
    Power On
    ${slash_release_date}=    Get Release Date
    IF    ${CHANGE_RELEASE_DATE}
        ${release_date}=    Change Release Date Format    ${slash_release_date}
    ELSE
        ${release_date}=    Set Variable    ${slash_release_date}
    END
    Should Be Equal    ${sol_date.split()[-1]}    ${release_date}

Build Firmware From Source
    [Documentation]    Builds firmware based on device type.
    IF    "novacustom" in "${CONFIG}"
        Build Firmware Novacustom
    ELSE
        FAIL    Unsupported platform type.
    END

Check Write Protection Availability
    [Documentation]    Check whether it is possible to set Write Protection
    ...    on the DUT.
    ${out}=    Execute Linux Command    ./flashrom -p internal --wp-list
    Should Not Contain    ${out}    write protect support is not implemented for this flash chip
    Should Contain    ${out}    Available write protection ranges:
    Should Contain    ${out}    all

Erase Write Protection
    [Documentation]    Erase write protection from the flash chip.
    ${out}=    Execute Linux Command    ./flashrom -p internal --wp-disable    180
    Should Contain    ${out}    Successfully set the requested mode
    ${out}=    Execute Linux Command    ./flashrom -p internal --wp-range=0,0    180
    Should Contain    ${out}    Successfully set the requested protection range

Set Write Protection
    [Documentation]    Set protection range as defined by the parameters:
    ...    `${start_adress}` -    protection start address,
    ...    `${length}` - flash protected range length.
    [Arguments]    ${start_adress}    ${length}
    ${out}=    Execute Linux Command    ./flashrom -p internal --wp-range=${start_adress},${length}    180
    Should Contain    ${out}    Successfully set the requested protection range
    ${out}=    Execute Linux Command    ./flashrom -p internal --wp-enable    180
    Should Contain    ${out}    Successfully set the requested mode

Check Write Protection Status
    [Documentation]    Check whether Write Protection mechanism is active.
    ${out}=    Execute Linux Command    ./flashrom -p internal --wp-status    180
    Should Contain    ${out}    Protection mode: hardware

Compare Write Protection Ranges
    [Documentation]    Allows to compare Protection Range: declared and
    ...    currently set.
    [Arguments]    ${start_adress}    ${length}
    ${out}=    Execute Linux Command    ./flashrom -p internal --wp-status    180
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

Read System Information In Petitboot
    [Documentation]    Keyword allows to check whether the read system
    ...    information option is available in Petitboot and
    ...    whether the option works correctly.
    Sleep    2s
    ${output}=    Read From Terminal Until    help
    Should Contain    ${output}    System information
    Set Local Variable    ${MOVE}    7
    FOR    ${index}    IN RANGE    0    ${MOVE}
        Write Bare Into Terminal    ${ARROW_UP}
        Read From Terminal
    END
    Sleep    2s
    Write Bare Into Terminal    ${ENTER}
    ${output}=    Read From Terminal Until    help
    Should Contain    ${output}    Petitboot System Information

Rescan Devices In Petitboot
    [Documentation]    Keyword allows to check whether the rescan devices
    ...    option is available in Petitboot and whether the
    ...    option works correctly.
    Sleep    2s
    ${output}=    Read From Terminal Until    help
    Should Contain    ${output}    Rescan devices
    Set Local Variable    ${MOVE}    3
    FOR    ${index}    IN RANGE    0    ${MOVE}
        Write Bare Into Terminal    ${ARROW_UP}
        Read From Terminal
    END
    Sleep    2s
    Write Bare Into Terminal    ${ENTER}
    # To Do: read system log

Check EMMC Module
    [Documentation]    Check the eMMC module is detected via the Operating
    ...    System.
    ${out}=    Execute Linux Command    parted /dev/mmcblk0 -- print
    Should Contain    ${out}    ${E_MMC_NAME}
    Should Contain    ${out}    ${E_MMC_PARTITION_TABLE}

Coldboot Via RTE Relay
    [Documentation]    Coldboot the DUT using RTE Relay.
    RteCtrl Relay
    Sleep    5s
    RteCtrl Relay

Reboot Via OS Boot By Petitboot
    [Documentation]    Reboot system with system installed on the DUT while
    ...    already logged into Petitboot.
    Boot From USB
    Login To Linux
    Execute Linux Command    reboot
    Sleep    60s

Reboot Via Ubuntu By Tianocore
    [Documentation]    Reboot system with Ubuntu installed on the DUT while
    ...    already logged into Tianocore.
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    ubuntu
    Login To Linux
    Switch To Root User
    Write Into Terminal    reboot

Reboot Via Linux On USB
    [Documentation]    Reboot system with Ubuntu installed on the USB stick.
    Login To Linux Over Serial Console    ${DEVICE_USB_USERNAME}    ${DEVICE_USB_PASSWORD}    ${DEVICE_USB_PROMPT}
    Write Into Terminal    sudo su
    Read From Terminal Until    [sudo] password for ${DEVICE_USB_USERNAME}:
    Write Into Terminal    ${DEVICE_USB_PASSWORD}
    Set Prompt For Terminal    ${DEVICE_USB_ROOT_PROMPT}
    Read From Terminal Until Prompt
    Write Into Terminal    reboot

Refresh Serial Screen In BIOS Editable Settings Menu
    [Documentation]    This keyword tries to refresh the screen while inside the
    ...    BIOS setting menu - to be specific while in a screen where you can
    ...    press F10 to save the changes. Opening save windows and closing it
    ...    should refresh the screen, but it is not guaranteed.
    Press Key N Times    1    ${F10}
    Press Key N Times    1    ${ESC}

Get Coreboot Tools From Cloud
    [Documentation]    Downloads required coreboot tools from cloud
    Get Cbmem From Cloud
    Get Flashrom From Cloud
    Get Cbfstool From Cloud

Get Cbmem From Cloud
    [Documentation]    Download cbmem from the cloud.
    ${cbmem_path}=    Set Variable    /usr/local/bin/cbmem
    ${out_test}=    Execute Command In Terminal    test -x ${cbmem_path}; echo $?
    ${exit_code}=    Convert To Integer    ${out_test}
    IF    ${exit_code} != 0
        Download File    https://cloud.3mdeb.com/index.php/s/C6LJMi4bWz3wzR9/download    ${cbmem_path}
        Execute Command In Terminal    chmod 777 ${cbmem_path}
    END

Get Flashrom From Cloud
    [Documentation]    Download flashrom from the cloud.
    ${flashrom_path}=    Set Variable    /usr/local/bin/flashrom
    ${out_test}=    Execute Command InTerminal    test -x ${flashrom_path}; echo $?
    ${exit_code}=    Convert To Integer    ${out_test}
    IF    ${exit_code} != 0
        Download File    https://cloud.3mdeb.com/index.php/s/D7AQDdRZmQFTL6n/download    ${flashrom_path}
        Execute Command In Terminal    chmod 777 ${flashrom_path}
    END

Get Cbfstool From Cloud
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

Clone Git Repository
    [Documentation]    Clones given git repository to the target location
    [Arguments]    ${repo_url}    ${location}=${EMPTY}
    Wait Until Keyword Succeeds    5x    1s
    ...    Check Internet Connection On Linux
    IF    '${location}' != '${EMPTY}'
        ${repo_path}=    Set Variable    ${location}
    ELSE
        ${repo_path}=    Extract Repository Name From URL    ${repo_url}
    END
    ${is_git_installed}=    Check If Package Is Installed    git
    IF    ${is_git_installed} != True
        ${out_install}=    Execute Command In Terminal    apt install -y git
        Should Not Contain    ${out_install}    Failed
    END
    Execute Command In Terminal    rm -rf ${repo_path}
    ${out_clone}=    Execute Command In Terminal    git clone ${repo_url} ${location}
    Should Contain    ${out_clone}    Receiving objects: 100%
    Should Contain    ${out_clone}    Resolving deltas: 100%

Send File To DUT
    [Documentation]    Sends file DUT and saves it at given location
    [Arguments]    ${source_path}    ${target_path}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        ${ip_address}=    Get Hostname Ip
        Execute Command In Terminal    rm -f ${target_path}
        SSHLibrary.Open Connection    ${ip_address}
        SSHLibrary.Login    ${DEVICE_UBUNTU_USERNAME}    ${DEVICE_UBUNTU_PASSWORD}
        SSHLibrary.Put File    ${source_path}    ${target_path}
        SSHLibrary.Close Connection
    ELSE
        Put File    ${source_path}    ${target_path}
    END

Check Internet Connection On Linux
    [Documentation]    Check internet connection on Linux.
    ${out}=    Execute Linux Command    ping -c 4 google-public-dns-a.google.com
    Should Contain    ${out}    , 0% packet loss

Check Internet Connection On Windows
    [Documentation]    Check internet connection on Windows.
    ${out}=    Execute Command In Terminal    ping google-public-dns-a.google.com
    Should Contain    ${out}    (0% loss)

Boot Operating System
    [Documentation]    Keyword allows boot operating system installed on the
    ...    DUT. Takes as an argument operating system name.
    [Arguments]    ${operating_system}
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    Set Local Variable    ${IS_SYSTEM_INSTALLED}    ${FALSE}
    Enter Boot Menu Tianocore
    ${menu_construction}=    Get Boot Menu Construction
    ${is_system_installed}=    Evaluate    "${operating_system}" in """${menu_construction}"""
    IF    not ${is_system_installed}
        FAIL    Test case marked as Failed\nRequested OS (${operating_system}) has not been installed
    END
    ${system_index}=    Get Index From List    ${menu_construction}    ${operating_system}
    Press Key N Times And Enter    ${system_index}    ${ARROW_DOWN}

Remove Entry From List
    [Arguments]    ${input_list}    ${regexp}
    @{output_list}=    Create List
    FOR    ${item}    IN    @{input_list}
        ${is_match}=    Run Keyword And Return Status
        ...    Should Not Match Regexp    ${item}    ${regexp}
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
    @{menu_lines}=    Remove Entry From List    ${menu_lines}    .*Secure Boot Configuration.*
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

Generate 1GB File In Windows
    [Documentation]    Generates 1G file in Windows in .txt format.
    ${out}=    Execute Command In Terminal    fsutil file createnew test_file.txt 1073741824
    Should Contain    ${out}    is created

Get Drive Letter Of USB
    [Documentation]    Gets drive letter of attached USB, work with only one USB
    ...    attached.
    ${drive_letter}=    Execute Command In Terminal
    ...    (Get-Volume | where drivetype -eq removable | where filesystemtype -eq FAT32).driveletter
    ${drive_letter}=    Fetch From Left    ${drive_letter}    \r
    RETURN    ${drive_letter}

Get Hash Of File
    [Documentation]    Gets line with hash of file.
    [Arguments]    ${path_file}
    ${out}=    Execute Command In Terminal    Get-FileHash -Path ${path_file} | Format-List
    ${hash}=    Get Lines Containing String    ${out}    Hash
    RETURN    ${hash}

Identify Path To USB
    [Documentation]    Identifies path to USB storage. Setting ${usb_model}
    ...    variable in .config file is required to correctly work
    ...    this keyword.
    ${out}=    Execute Linux Command    lsblk --nodeps --output NAME
    @{disks}=    Get Regexp Matches    ${out}    sd.
    FOR    ${disk}    IN    @{disks}
        ${model}=    Execute Linux Command    cat /sys/class/block/${disk}/device/model
        ${model_name}=    Fetch From Left    ${model}    \r\n
        ${model_name}=    Fetch From Right    ${model_name}    \r
        Set Local Variable    ${USB_DISK}    ${disk}
        IF    '${model_name}' == '${USB_MODEL}'    BREAK
    END
    ${out}=    Execute Linux Command    lsblk | grep ${USB_DISK} | grep part | cat
    ${split}=    Split String    ${out}
    ${path_to_usb}=    Get From List    ${split}    7
    RETURN    ${path_to_usb}

Get Intel ME Mode State
    [Documentation]    Returns the current state of Intel ME mode.
    [Arguments]    ${menu_me}
    ${menu_me}=    Fetch From Right    ${menu_me}    <
    ${actual_state}=    Fetch From Left    ${menu_me}    >
    RETURN    ${actual_state}

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

Get RPM Value From System76 Acpi
    [Documentation]    Returns current RPM value of CPU fan form driver
    ...    system76_acpi.
    ${speed}=    Execute Command In Terminal    sensors | grep "CPU fan"
    ${speed_split}=    Split String    ${speed}
    ${rpm}=    Get From List    ${speed_split}    2
    RETURN    ${rpm}

Detect Or Install FWTS
    [Documentation]    Keyword allows to check if Firmware Test Suite (fwts)
    ...    has been already installed on the device. Otherwise, triggers
    ...    process of obtaining and installation.
    [Arguments]    ${package}=fwts
    ${is_package_installed}=    Set Variable    ${FALSE}
    Log To Console    \nChecking if ${package} is installed...
    ${is_package_installed}=    Check If Package Is Installed    ${package}
    IF    ${is_package_installed}
        Log To Console    \nPackage ${package} is installed
        RETURN
    ELSE
        Log To Console    \nPackage ${package} is not installed
    END
    Log To Console    \nInstalling required package (${package})...
    Get And Install FWTS
    Sleep    10s
    ${is_package_installed}=    Check If Package Is Installed    ${package}
    IF    ${is_package_installed}=='False'
        FAIL    \nRequired package (${package}) cannot be installed
    END
    Log To Console    \nRequired package (${package}) installed successfully

Get And Install FWTS
    [Documentation]    Keyword allows to obtain and install Firmware Test Suite
    ...    (fwts) tool.
    Set DUT Response Timeout    500s
    Write Into Terminal    add-apt-repository ppa:firmware-testing-team/ppa-fwts-stable
    Read From Terminal Until    Press [ENTER] to continue or Ctrl-c to cancel
    Write Bare Into Terminal    ${ENTER}
    Read From Terminal Until    Reading package lists... Done
    Write Into Terminal    apt-get install --assume-yes fwts
    Read From Terminal Until Prompt

Perform Suspend Test Using FWTS
    [Documentation]    Keyword allows to perform suspend and resume procedure
    ...    test by using Firmware Test Suite tool
    [Arguments]    ${test_duration}=40
    ${is_suspend_performed_correctly}=    Set Variable    ${FALSE}
    Write Into Terminal    fwts s3 -f -r /tmp/suspend_test_log.log
    Sleep    ${test_duration}s
    Login To Linux
    Switch To Root User
    ${test_result}=    Execute Linux Command    cat /tmp/suspend_test_log.log
    TRY
        Should Contain    ${test_result}    0 failed
        Should Contain    ${test_result}    0 warning
        Should Contain    ${test_result}    0 aborted
        Should Contain    ${test_result}    0 skipped
        ${is_suspend_performed_correctly}=    Set Variable    ${TRUE}
    EXCEPT
        ${is_suspend_performed_correctly}=    Set Variable    ${FALSE}
    END
    RETURN    ${is_suspend_performed_correctly}

Perform Hibernation Test Using FWTS
    [Documentation]    Keyword allows to perform hibernation and resume procedure
    ...    test by using Firmware Test Suite tool
    [Arguments]    ${test_duration}=40
    ${is_hibernation_performed_correctly}=    Set Variable    ${FALSE}
    Execute Command In Terminal    fwts s4 -f -r /tmp/hibernation_test_log.log
    Sleep    ${test_duration}s
    Boot Operating System    ubuntu
    Login To Linux
    Switch To Root User
    ${test_result}=    Execute Command In Terminal    cat /tmp/hibernation_test_log.log
    TRY
        Should Contain    ${test_result}    0 failed
        Should Contain    ${test_result}    0 warning
        Should Contain    ${test_result}    0 aborted
        Should Contain    ${test_result}    0 skipped
        ${is_hibernation_performed_correctly}=    Set Variable    ${TRUE}
    EXCEPT
        ${is_hibernation_performed_correctly}=    Set Variable    ${FALSE}
    END
    RETURN    ${is_hibernation_performed_correctly}

Disable Option In Submenu
    [Documentation]    Disables selected option in submenu provided in ${menu_construction}
    [Arguments]    ${menu_construction}    ${option_str}
    ${option}=    Set Variable    ${option_str[1:]}
    ${line}=    Get Matches    ${menu_construction}    *${option}*
    TRY
        Should Match Regexp    ${line[0]}    .*\\[\ \\].*
        Refresh Serial Screen In BIOS Editable Settings Menu
    EXCEPT
        FOR    ${element}    IN    @{menu_construction}
            ${matches}=    Run Keyword And Return Status
            ...    Should Match    ${element}    pattern=*${option}*
            IF    ${matches}
                ${option}=    Set Variable    ${element}
                BREAK
            END
        END
        Strip String    ${option}    mode=left
        ${system_index}=    Get Index From List    ${menu_construction}    ${option}
        Press Key N Times And Enter    ${system_index}    ${ARROW_DOWN}
        Press Key N Times    1    ${F10}
        Write Bare Into Terminal    y
    END

Enable Option In USB Configuration Submenu
    [Documentation]    Enables option in USB Configuration SubMenu.
    [Arguments]    ${menu_construction}    ${option}
    ${line}=    Get Matches    ${menu_construction}    *${option}*
    TRY
        Should Contain Match    ${line}    *[X]*
    EXCEPT
        FOR    ${element}    IN    @{menu_construction}
            ${matches}=    Run Keyword And Return Status
            ...    Should Match    ${element}    pattern=*${option}*
            IF    ${matches}
                ${option}=    Set Variable    ${element}
                BREAK
            END
        END
        Strip String    ${option}    mode=left
        ${system_index}=    Get Index From List    ${menu_construction}    ${option}
        ${steps}=    Evaluate    ${system_index}-1
        Press Key N Times And Enter    ${steps}    ${ARROW_DOWN}
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
            ${matches}=    Run Keyword And Return Status
            ...    Should Match    ${element}    pattern=*${option}*
            IF    ${matches}
                ${option}=    Set Variable    ${element}
                BREAK
            END
        END
        ${system_index}=    Get Index From List    ${menu_construction}    ${option}
        ${steps}=    Evaluate    ${system_index}-1
        Press Key N Times And Enter    ${steps}    ${ARROW_DOWN}
        Write Bare Into Terminal    ${F10}
        Write Bare Into Terminal    Y
    END

Enable Option In Submenu
    [Documentation]    Enables option in submenu
    [Arguments]    ${menu_construction}    ${option_str}
    ${option}=    Set Variable    ${option_str[1:]}
    ${line}=    Get Matches    ${menu_construction}    *${option}*
    TRY
        Should Not Match Regexp    ${line[0]}    .*\\[ \\].*
        Refresh Serial Screen In BIOS Editable Settings Menu
    EXCEPT
        FOR    ${element}    IN    @{menu_construction}
            ${matches}=    Run Keyword And Return Status
            ...    Should Match    ${element}    pattern=*${option}*
            IF    ${matches}
                ${option}=    Set Variable    ${element}
                BREAK
            END
        END
        Strip String    ${option}    mode=left
        ${system_index}=    Get Index From List    ${menu_construction}    ${option}
        ${steps}=    Evaluate    ${system_index}-1
        Press Key N Times And Enter    ${steps}    ${ARROW_DOWN}
        Write Bare Into Terminal    ${F10}
        Write Bare Into Terminal    Y
    END

Get Current CONFIG List Param
    [Documentation]    Returns current CONFIG list parameters specified in the
    ...    arguments.
    [Arguments]    ${item}    ${param}
    ${config}=    Get Current CONFIG    ${CONFIG_LIST}
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

Check That USB Devices Are Detected
    [Documentation]    Checks if the USB devices from the config are the same as
    ...    those visible in the boot menu. Alternatively, if we set emulated to
    ...    True, it only probes for the PiKVM emulated USB.
    [Arguments]    ${emulated}=${FALSE}
    ${menu_construction}=    Read From Terminal Until    exit

    IF    ${emulated} == ${TRUE}
        ${found}=    Run Keyword And Return Status
        ...    Should Match    ${menu_construction}    *PiKVM*
        IF    not ${found}
            Press Key N Times    1    ${ARROW_UP}
            ${menu_construction}=    Read From Terminal Until    PiKVM
            RETURN    ${TRUE}
        ELSE
            RETURN    ${TRUE}
        END
    END

    @{attached_usb_list}=    Get Current CONFIG List Param    USB_Storage    name
    FOR    ${stick}    IN    @{attached_usb_list}
        # ${stick} should match with one element of ${menu_construction}

        Should Match    ${menu_construction}    *${stick}*
    END

Check That USB Devices Are Not Detected
    [Documentation]    Checks if the USB devices from the config are the same as
    ...    those visible in the boot menu.
    ${menu_construction}=    Get Boot Menu Construction
    @{attached_usb_list}=    Get Current CONFIG List Param    USB_Storage    name
    FOR    ${stick}    IN    @{attached_usb_list}
        Should Not Contain    ${menu_construction}    ${stick}
    END

Switch To Root User In Ubuntu Server
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

Should Contain All
    [Arguments]    ${string}    @{substrings}
    FOR    ${substring}    IN    @{substrings}
        Should Contain    ${string}    ${substring}
    END
