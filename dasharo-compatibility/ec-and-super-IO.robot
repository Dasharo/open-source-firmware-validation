*** Settings ***
Library             Collections
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    EC and SuperI/O tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
ECR001.001 Battery monitoring - charge level in OS (Ubuntu)
    [Documentation]    Check whether the battery charge level can be read
    ...    (in mAh) in Linux OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    acpi-call
    Turn On ACPI CALL Module In Linux
    Check Charge Level In Linux
    Exit From Root User

ECR001.002 Battery monitoring - charge level in OS (Windows)
    [Documentation]    Check whether battery charge level can be read in
    ...    Windows OS.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR001.002 not supported
    Power On
    Login To Windows
    ${out}=    Get Battery Power Level Windows
    Should Be True    ${out} > 0 and ${out} < 101

ECR002.001 Battery monitoring - charging state in OS (Ubuntu)
    [Documentation]    Check whether the battery state can be read in Linux OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR002.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    acpi-call
    Turn On ACPI CALL Module In Linux
    Check Charging State In Linux
    Exit From Root User

ECR002.002 Battery monitoring - charging state in OS (Windows)
    [Documentation]    Check whether the battery state can be read in Windows
    ...    OS.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR002.002 not supported
    Power On
    Login To Windows
    Check If Battery Is Charging Windows

ECR003.001 Touchpad in OS - (Ubuntu)
    [Documentation]    Check whether touchpad is visible in Linux OS.
    ...    Touchpad steering and effect detection must be checked
    ...    manually.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR003.001 not supported

    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    libinput-tools
    Detect Or Install Package    acpi-call
    Turn On ACPI CALL Module In Linux
    Device Detection In Linux    Touchpad
    Exit From Root User

ECR003.002 Touchpad in OS - (Windows)
    [Documentation]    Check whether touchpad is visible in Windows OS.
    ...    Touchpad steering and effect detection must be checked
    ...    manually.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR003.002 not supported
    Power On
    Login To Windows
    ${out}=    Get Pointing Devices Windows
    Should Contain    ${out}    HID-compliant mouse

# ECR005.001 Keyboard (function key: play/pause) in OS (Ubuntu)
#    [Documentation]    Check whether function key: play/pause works in
#    ...    Linux OS.
#    Skip If    not ${ec_and_super_io_support}    ECR006.001 not supported
#    No Operation
#    # TODO: Pi-KVM necessary

# manual
# ECR09.001 Keyboard (function key: mute) in OS (Ubuntu)
#    [Documentation]    Check whether function key: mute works in Linux OS.
#    Skip If    not ${ec_and_super_io_support}    ECR010.001 not supported
#    No Operation
#    # TODO: Pi-KVM necessary

# manual
# ECR011.001 Keyboard (function key: volume down) in OS (Ubuntu)
#    [Documentation]    Check whether function key: volume down works in
#    ...    Linux OS.
#    Skip If    not ${ec_and_super_io_support}    ECR012.001 not supported
#    No Operation
#    # TODO: Pi-KVM necessary

# manual
# ECR012.001 Keyboard (function key: volume up) in OS (Ubuntu)
#    [Documentation]    Check whether function key: volume up works in
#    ...    Linux OS.
#    Skip If    not ${ec_and_super_io_support}    ECR013.001 not supported
#    No Operation
#    # TODO: Pi-KVM necessary

# manual
# ECR013.001 Keyboard (function key: display switch) in OS (Ubuntu)
#    [Documentation]    Check whether function key: display switch works in
#    ...    Linux OS.
#    Skip If    not ${ec_and_super_io_support}    ECR014.001 not supported
#    No Operation
#    # TODO: Pi-KVM necessary

ECR014.001 Keyboard (function key: brightness down) in OS (Ubuntu)
    [Documentation]    Check whether function key: brightness down works in
    ...    Linux OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR015.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    acpi-call
    Turn On ACPI CALL Module In Linux
    ${max_brightness}=    Get Maximum Brightness In Linux
    Set Brightness In Linux    ${max_brightness}
    ${brightness1}=    Get Current Brightness In Linux
    Brightness Down Button In Linux
    ${brightness2}=    Get Current Brightness In Linux
    Should Be True    ${brightness2} < ${brightness1}
    Exit From Root User

ECR015.001 Keyboard (function key: brightness up) in OS (Ubuntu)
    [Documentation]    Check whether function key: brightness up works in
    ...    Linux OS.
    IF    not ${EC_AND_SUPER_IO_SUPPORT}    SKIP    ECR015.001 not supported
    IF    not ${TESTS_IN_UBUNTU_SUPPORT}    SKIP    ECR015.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    acpi-call
    Turn On ACPI CALL Module In Linux
    Set Brightness In Linux    0
    ${brightness1}=    Get Current Brightness In Linux
    Brightness Up Button In Linux
    ${brightness2}=    Get Current Brightness In Linux
    Should Be True    ${brightness2} > ${brightness1}
    Exit From Root User

ECR016.001 Keyboard (function key: camera on/off) in OS (Ubuntu)
    [Documentation]    Check whether the camera on/off hotkey works correctly.
    IF    not ${EC_AND_SUPER_IO_SUPPORT}    SKIP    ECR016.001 not supported
    IF    not ${USB_CAMERA_DETECTION_SUPPORT}
        SKIP    ECR016.001 not supported
    END
    IF    not ${TESTS_IN_UBUNTU_SUPPORT}    SKIP    ECR016.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    acpi-call
    Turn On ACPI CALL Module In Linux
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    Camera
    Toggle Camera In Linux
    ${out}=    List Devices In Linux    usb
    Should Not Contain    ${out}    Camera
    Toggle Camera In Linux
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    Camera
    Exit From Root User

ECR017.001 Keyboard (function key: flight mode) in OS (Ubuntu)
    [Documentation]    Check whether function key: flight mode works in
    ...    Linux OS.
    IF    not ${EC_AND_SUPER_IO_SUPPORT}    SKIP    ECR017.001 not supported
    IF    not ${TESTS_IN_UBUNTU_SUPPORT}    SKIP    ECR017.001 not supported
    IF    not ${WIRELESS_CARD_SUPPORT}    SKIP    ECR017.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    acpi-call
    Turn On ACPI CALL Module In Linux
    ${wifi_status}=    Get WiFi Block Status
    ${bt_status}=    Get Bluetooth Block Status
    Should Be True    ${wifi_status} == False
    Should Be True    ${bt_status} == False
    Toggle Flight Mode In Linux
    ${wifi_status}=    Get WiFi Block Status
    ${bt_status}=    Get Bluetooth Block Status
    Should Be True    ${wifi_status} == True
    Should Be True    ${bt_status} == True
    Toggle Flight Mode In Linux
    ${wifi_status}=    Get WiFi Block Status
    ${bt_status}=    Get Bluetooth Block Status
    Should Be True    ${wifi_status} == False
    Should Be True    ${bt_status} == False
    Exit From Root User

# ECR018.001 Keyboard (function key: sleep) in OS (Ubuntu)
#    [Documentation]    Check whether function key: sleep works in Linux OS.
#    IF    not ${ec_and_super_io_support}    SKIP    ECR019.001 not supported
#    Power On
#    Login to Linux
#    Switch to root user
#    Detect or Install Package    acpi-call
#    Turn On ACPI_CALL module in Linux
#    Enter sleep mode in Linux
#    Wake from sleep mode in Linux
#    Exit from root user

ECR019.001 Buttons (button: power) in OS (Ubuntu)
    [Documentation]    Check whether button: power is detected in Linux OS.
    IF    not ${EC_AND_SUPER_IO_SUPPORT}    SKIP    ECR019.001 not supported
    IF    not ${TESTS_IN_UBUNTU_SUPPORT}    SKIP    ECR019.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    acpi-call
    Turn On ACPI CALL Module In Linux
    Device Detection In Linux    Power
    Exit From Root User

ECR020.001 Charging until 98% level in OS (Ubuntu)
    [Documentation]    Check whether the DUT stops charging the battery when the
    ...    98% threshold is reached.
    IF    not ${EC_AND_SUPER_IO_SUPPORT}    SKIP    ECR020.001 not supported
    IF    not ${TESTS_IN_UBUNTU_SUPPORT}    SKIP    ECR020.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Sonoff On
    Charge Battery Until Target Level In Linux    98
    Sonoff Off
    Check Charging State Not Charging In Linux

ECR021.001 Not charging between 95% and 98% in OS (Ubuntu)
    [Documentation]    Check whether the DUT does not charge the battery when
    ...    the charge level is between 95% and 98%.
    IF    not ${EC_AND_SUPER_IO_SUPPORT}    SKIP    ECR021.001 not supported
    IF    not ${TESTS_IN_UBUNTU_SUPPORT}    SKIP    ECR021.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    ${percentage}=    Check Battery Percentage In Linux
    IF    ${percentage} < 95
        Sonoff On
        Charge Battery Until Target Level In Linux    96
        Sonoff Off
        Sleep    5
        Sonoff On
        Check Charging State Not Charging In Linux
    ELSE
        Sonoff Off
        Sleep    5
        Sonoff On
        Check Charging State Not Charging In Linux
    END

ECR022.001 EC sync update with power adapter connected works correctly
    [Documentation]    This test aims to verify whether coreboot update
    ...    will also update EC firmware when power adapter is connected.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ECR022.001 not supported
    Skip If    not ${DTS_FIRMWARE_FLASHING_SUPPORT}    ECR022.001 not supported
    Skip If    not ${DTS_EC_FLASHING_SUPPORT}    ECR022.001 not supported
    # Flash old fw version without ec sync
    Make Sure That Flash Locks Are Disabled
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Set DUT Response Timeout    320s
    Flash Firmware In DTS    ${FW_NO_EC_SYNC_DOWNLOAD_LINK}
    Flash EC Firmware
    ...    ${EC_NO_SYNC_DOWNLOAD_LINK}    TOOL=dasharo_ectool
    Sleep    15s
    Power On
    Execute Manual Step    Enable console redirection

    # Make sure both coreboot and EC was flashed
    Make Sure That Flash Locks Are Disabled
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check Firmware Version    ${FW_NO_EC_SYNC_VERSION}
    Check EC Firmware Version
    ...    EXPECTED_VERSION=${EC_NO_SYNC_VERSION}    TOOL=dasharo_ectool

    # Flash new fw with ec sync
    Put File    ${FW_FILE}    /tmp/coreboot_with_ec.rom    scp=ALL
    ${flash_result}=    Execute Command In Terminal
    ...    flashrom -p internal --ifd -i bios -w /tmp/coreboot_with_ec.rom
    Should Contain    ${flash_result}    VERIFIED
    Write Into Terminal    reboot
    Sleep    20s
    Power On
    Execute Manual Step    Enable console redirection
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Run Keyword And Expect Error    *    Check Firmware Version
    ...    ${FW_NO_EC_SYNC_VERSION}
    Run Keyword And Expect Error    *    Check EC Firmware Version
    ...    EXPECTED_VERSION=${EC_NO_SYNC_VERSION}    TOOL=dasharo_ectool

    # Make sure EC isn't flashed second time after restart
    Write Into Terminal    reboot
    ${out}=    Read From Terminal Until    ${TIANOCORE_STRING}

ECR023.001 EC sync doesn't update with power adapter disconnected
    [Documentation]    This test aims to verify whether coreboot update
    ...    will display information to connect power adapter when it's
    ...    disconnected
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS023.001 not supported
    Skip If    not ${DTS_FIRMWARE_FLASHING_SUPPORT}    DTS023.001 not supported
    Skip If    not ${DTS_EC_FLASHING_SUPPORT}    DTS023.001 not supported

    # Flash old fw version without ec sync
    # Connect Laptop to power adapter
    Make Sure That Flash Locks Are Disabled
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Set DUT Response Timeout    320s
    Flash Firmware In DTS    ${FW_NO_EC_SYNC_DOWNLOAD_LINK}
    Flash EC Firmware
    ...    ${EC_NO_SYNC_DOWNLOAD_LINK}    TOOL=dasharo_ectool
    Sleep    15s
    Power On
    Execute Manual Step    Enable console redirection
    Make Sure That Flash Locks Are Disabled
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check Firmware Version    ${FW_NO_EC_SYNC_VERSION}
    Check EC Firmware Version
    ...    EXPECTED_VERSION=${EC_NO_SYNC_VERSION}    TOOL=dasharo_ectool

    # Flash new fw with ec sync
    Put File    ${FW_FILE}    /tmp/coreboot_with_ec.rom    scp=ALL
    ${flash_result}=    Execute Command In Terminal
    ...    flashrom -p internal --ifd -i bios -w /tmp/coreboot_with_ec.rom
    Should Contain    ${flash_result}    VERIFIED
    # Disconnect power adapter
    Sonoff Off
    Write Into Terminal    reboot
    Sleep    20
    Power On
    Execute Manual Step    Enable console redirection
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Run Keyword And Expect Error    *    Check Firmware Version
    ...    ${FW_NO_EC_SYNC_VERSION}
    Check EC Firmware Version
    ...    EXPECTED_VERSION=${EC_NO_SYNC_VERSION}    TOOL=dasharo_ectool
