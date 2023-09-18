*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
ECR001.001 Battery monitoring - charge level in OS (Ubuntu 20.04)
    [Documentation]    Check whether the battery charge level can be read
    ...    (in mAh) in Linux OS.
    Skip If    not ${ec_and_super_io_support}    ECR001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    ECR001.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Detect or Install Package    acpi-call
    Turn On ACPI_CALL module in Linux
    Check charge level in Linux
    Exit from root user

ECR001.002 Battery monitoring - charge level in OS (Windows 11)
    [Documentation]    Check whether battery charge level can be read in
    ...    Windows OS.
    Skip If    not ${ec_and_super_io_support}    ECR001.002 not supported
    Skip If    not ${tests_in_windows_support}    ECR001.002 not supported
    Power On
    Login to Windows
    ${out}=    Get Battery Power Level Windows
    Should Be True    ${out} > 0 and ${out} < 101

ECR002.001 Battery monitoring - charging state in OS (Ubuntu 20.04)
    [Documentation]    Check whether the battery state can be read in Linux OS.
    Skip If    not ${ec_and_super_io_support}    ECR002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    ECR002.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Detect or Install Package    acpi-call
    Turn On ACPI_CALL module in Linux
    Check charging state in Linux
    Exit from root user

ECR002.002 Battery monitoring - charging state in OS (Windows 11)
    [Documentation]    Check whether the battery state can be read in Windows
    ...    OS.
    Skip If    not ${ec_and_super_io_support}    ECR002.002 not supported
    Skip If    not ${tests_in_windows_support}    ECR002.002 not supported
    Power On
    Login to Windows
    Check If Battery Is Charging Windows

ECR003.001 Touchpad in OS - (Ubuntu 20.04)
    [Documentation]    Check whether touchpad is visible in Linux OS.
    ...    Touchpad steering and effect detection must be checked
    ...    manually.
    Skip If    not ${ec_and_super_io_support}    ECR003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    ECR003.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Detect or Install Package    libinput-tools
    Detect or Install Package    acpi-call
    Turn On ACPI_CALL module in Linux
    Device detection in Linux    Touchpad
    Exit from root user

ECR003.002 Touchpad in OS - (Windows 11)
    [Documentation]    Check whether touchpad is visible in Windows OS.
    ...    Touchpad steering and effect detection must be checked
    ...    manually.
    Skip If    not ${ec_and_super_io_support}    ECR003.002 not supported
    Skip If    not ${tests_in_windows_support}    ECR003.002 not supported
    Power On
    Login to Windows
    ${out}=    Get Pointing Devices Windows
    Should Contain    ${out}    HID-compliant mouse

# ECR005.001 Keyboard (function key: play/pause) in OS (Ubuntu 20.04)
#    [Documentation]    Check whether function key: play/pause works in
#    ...    Linux OS.
#    Skip If    not ${ec_and_super_io_support}    ECR006.001 not supported
#    No Operation
#    # TODO: Pi-KVM necessary

# manual
# ECR09.001 Keyboard (function key: mute) in OS (Ubuntu 20.04)
#    [Documentation]    Check whether function key: mute works in Linux OS.
#    Skip If    not ${ec_and_super_io_support}    ECR010.001 not supported
#    No Operation
#    # TODO: Pi-KVM necessary

# manual
# ECR011.001 Keyboard (function key: volume down) in OS (Ubuntu 20.04)
#    [Documentation]    Check whether function key: volume down works in
#    ...    Linux OS.
#    Skip If    not ${ec_and_super_io_support}    ECR012.001 not supported
#    No Operation
#    # TODO: Pi-KVM necessary

# manual
# ECR012.001 Keyboard (function key: volume up) in OS (Ubuntu 20.04)
#    [Documentation]    Check whether function key: volume up works in
#    ...    Linux OS.
#    Skip If    not ${ec_and_super_io_support}    ECR013.001 not supported
#    No Operation
#    # TODO: Pi-KVM necessary

# manual
# ECR013.001 Keyboard (function key: display switch) in OS (Ubuntu 20.04)
#    [Documentation]    Check whether function key: display switch works in
#    ...    Linux OS.
#    Skip If    not ${ec_and_super_io_support}    ECR014.001 not supported
#    No Operation
#    # TODO: Pi-KVM necessary

ECR014.001 Keyboard (function key: brightness down) in OS (Ubuntu 20.04)
    [Documentation]    Check whether function key: brightness down works in
    ...    Linux OS.
    Skip If    not ${ec_and_super_io_support}    ECR015.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    ECR015.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Detect or Install Package    acpi-call
    Turn On ACPI_CALL module in Linux
    Set Brightness in Linux    48000
    ${brightness1}=    Get current Brightness in Linux
    Brightness down button in Linux
    ${brightness2}=    Get current Brightness in Linux
    Should Be True    ${brightness2} < ${brightness1}
    Exit from root user

ECR015.001 Keyboard (function key: brightness up) in OS (Ubuntu 20.04)
    [Documentation]    Check whether function key: brightness up works in
    ...    Linux OS.
    IF    not ${ec_and_super_io_support}    SKIP    ECR015.001 not supported
    IF    not ${tests_in_ubuntu_support}    SKIP    ECR015.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Detect or Install Package    acpi-call
    Turn On ACPI_CALL module in Linux
    Set Brightness in Linux    20000
    ${brightness1}=    Get current Brightness in Linux
    Brightness up button in Linux
    ${brightness2}=    Get current Brightness in Linux
    Should Be True    ${brightness2} > ${brightness1}
    Exit from root user

ECR016.001 Keyboard (function key: camera on/off) in OS (Ubuntu 20.04)
    [Documentation]    Check whether the camera on/off hotkey works correctly.
    IF    not ${ec_and_super_io_support}    SKIP    ECR016.001 not supported
    IF    not ${usb_camera_detection_support}
        SKIP    ECR016.001 not supported
    END
    IF    not ${tests_in_ubuntu_support}    SKIP    ECR016.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Detect or Install Package    acpi-call
    Turn On ACPI_CALL module in Linux
    ${out}=    List devices in Linux    usb
    Should Contain    ${out}    Camera
    Toggle Camera in Linux
    ${out}=    List devices in Linux    usb
    Should Not Contain    ${out}    Camera
    Toggle Camera in Linux
    ${out}=    List devices in Linux    usb
    Should Contain    ${out}    Camera
    Exit from root user

ECR017.001 Keyboard (function key: flight mode) in OS (Ubuntu 20.04)
    [Documentation]    Check whether function key: flight mode works in
    ...    Linux OS.
    IF    not ${ec_and_super_io_support}    SKIP    ECR017.001 not supported
    IF    not ${tests_in_ubuntu_support}    SKIP    ECR017.001 not supported
    IF    not ${wireless_card_support}    SKIP    ECR017.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Detect or Install Package    acpi-call
    Turn On ACPI_CALL module in Linux
    ${wifi_status}=    Get WiFi block status
    ${bt_status}=    Get Bluetooth block status
    Should Be True    ${wifi_status} == False
    Should Be True    ${bt_status} == False
    Toggle flight mode in Linux
    ${wifi_status}=    Get WiFi block status
    ${bt_status}=    Get Bluetooth block status
    Should Be True    ${wifi_status} == True
    Should Be True    ${bt_status} == True
    Toggle flight mode in Linux
    ${wifi_status}=    Get WiFi block status
    ${bt_status}=    Get Bluetooth block status
    Should Be True    ${wifi_status} == False
    Should Be True    ${bt_status} == False
    Exit from root user

# ECR018.001 Keyboard (function key: sleep) in OS (Ubuntu 20.04)
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

ECR019.001 Buttons (button: power) in OS (Ubuntu 20.04)
    [Documentation]    Check whether button: power is detected in Linux OS.
    IF    not ${ec_and_super_io_support}    SKIP    ECR019.001 not supported
    IF    not ${tests_in_ubuntu_support}    SKIP    ECR019.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Detect or Install Package    acpi-call
    Turn On ACPI_CALL module in Linux
    Device detection in Linux    Power
    Exit from root user

ECR020.001 Charging until 98% level in OS (Ubuntu 22.04)
    [Documentation]    Check wheter the DUT stops charging the battery when the
    ...    98% threshold is reached.
    IF    not ${ec_and_super_io_support}    SKIP    ECR020.001 not supported
    IF    not ${tests_in_ubuntu_support}    SKIP    ECR020.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Sonoff Power On
    Charge battery until target level in Linux    98
    Sonoff Power Off
    Check charging state Not charging in Linux

ECR021.001 Not charging between 95% and 98% in OS (Ubuntu 22.04)
    [Documentation]    Check whether the DUT does not charge the battery when
    ...    the charge level is between 95% and 98%.
    IF    not ${ec_and_super_io_support}    SKIP    ECR021.001 not supported
    IF    not ${tests_in_ubuntu_support}    SKIP    ECR021.001 not supported
    Power On
    Login to Linux
    Switch to root user
    ${percentage}=    Check battery percentage in Linux
    IF    ${percentage} < 95
        Sonoff Power On
        Charge battery until target level in Linux    96
        Sonoff Power Off
        Sleep    5
        Sonoff Power On
        Check charging state Not charging in Linux
    ELSE
        Sonoff Power Off
        Sleep    5
        Sonoff Power On
        Check charging state Not charging in Linux
    END
