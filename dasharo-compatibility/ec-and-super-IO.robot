*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
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
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
ECR001.001 Battery monitoring - charge level in OS (Ubuntu 20.04)
    [Documentation]    Check whether the battery charge level can be read
    ...    (in mAh) in Linux OS.
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    acpi-call
    Turn On ACPI CALL Module In Linux
    Check Charge Level In Linux
    Exit From Root User

ECR001.002 Battery monitoring - charge level in OS (Windows 11)
    [Documentation]    Check whether battery charge level can be read in
    ...    Windows OS.
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR001.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR001.002 not supported
    Power On
    Login To Windows
    ${out}=    Get Battery Power Level Windows
    Should Be True    ${out} > 0 and ${out} < 101

ECR002.001 Battery monitoring - charging state in OS (Ubuntu 20.04)
    [Documentation]    Check whether the battery state can be read in Linux OS.
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR002.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    acpi-call
    Turn On ACPI CALL Module In Linux
    Check Charging State In Linux
    Exit From Root User

ECR002.002 Battery monitoring - charging state in OS (Windows 11)
    [Documentation]    Check whether the battery state can be read in Windows
    ...    OS.
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR002.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR002.002 not supported
    Power On
    Login To Windows
    Check If Battery Is Charging Windows

ECR003.001 Touchpad in OS - (Ubuntu 20.04)
    [Documentation]    Check whether touchpad is visible in Linux OS.
    ...    Touchpad steering and effect detection must be checked
    ...    manually.
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR003.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    libinput-tools
    Detect Or Install Package    acpi-call
    Turn On ACPI CALL Module In Linux
    Device Detection In Linux    Touchpad
    Exit From Root User

ECR003.002 Touchpad in OS - (Windows 11)
    [Documentation]    Check whether touchpad is visible in Windows OS.
    ...    Touchpad steering and effect detection must be checked
    ...    manually.
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR003.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ECR003.002 not supported
    Power On
    Login To Windows
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
    Skip If    not ${EC_AND_SUPER_IO_SUPPORT}    ECR015.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR015.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    acpi-call
    Turn On ACPI CALL Module In Linux
    Set Brightness In Linux    48000
    ${brightness1}=    Get Current Brightness In Linux
    Brightness Down Button In Linux
    ${brightness2}=    Get Current Brightness In Linux
    Should Be True    ${brightness2} < ${brightness1}
    Exit From Root User

ECR015.001 Keyboard (function key: brightness up) in OS (Ubuntu 20.04)
    [Documentation]    Check whether function key: brightness up works in
    ...    Linux OS.
    IF    not ${EC_AND_SUPER_IO_SUPPORT}    SKIP    ECR015.001 not supported
    IF    not ${TESTS_IN_UBUNTU_SUPPORT}    SKIP    ECR015.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    acpi-call
    Turn On ACPI CALL Module In Linux
    Set Brightness In Linux    20000
    ${brightness1}=    Get Current Brightness In Linux
    Brightness Up Button In Linux
    ${brightness2}=    Get Current Brightness In Linux
    Should Be True    ${brightness2} > ${brightness1}
    Exit From Root User

ECR016.001 Keyboard (function key: camera on/off) in OS (Ubuntu 20.04)
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

ECR017.001 Keyboard (function key: flight mode) in OS (Ubuntu 20.04)
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
    IF    not ${EC_AND_SUPER_IO_SUPPORT}    SKIP    ECR019.001 not supported
    IF    not ${TESTS_IN_UBUNTU_SUPPORT}    SKIP    ECR019.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    acpi-call
    Turn On ACPI CALL Module In Linux
    Device Detection In Linux    Power
    Exit From Root User

ECR020.001 Charging until 98% level in OS (Ubuntu 22.04)
    [Documentation]    Check whether the DUT stops charging the battery when the
    ...    98% threshold is reached.
    IF    not ${EC_AND_SUPER_IO_SUPPORT}    SKIP    ECR020.001 not supported
    IF    not ${TESTS_IN_UBUNTU_SUPPORT}    SKIP    ECR020.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Sonoff Power On
    Charge Battery Until Target Level In Linux    98
    Sonoff Power Off
    Check Charging State Not Charging In Linux

ECR021.001 Not charging between 95% and 98% in OS (Ubuntu 22.04)
    [Documentation]    Check whether the DUT does not charge the battery when
    ...    the charge level is between 95% and 98%.
    IF    not ${EC_AND_SUPER_IO_SUPPORT}    SKIP    ECR021.001 not supported
    IF    not ${TESTS_IN_UBUNTU_SUPPORT}    SKIP    ECR021.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    ${percentage}=    Check Battery Percentage In Linux
    IF    ${percentage} < 95
        Sonoff Power On
        Charge Battery Until Target Level In Linux    96
        Sonoff Power Off
        Sleep    5
        Sonoff Power On
        Check Charging State Not Charging In Linux
    ELSE
        Sonoff Power Off
        Sleep    5
        Sonoff Power On
        Check Charging State Not Charging In Linux
    END
