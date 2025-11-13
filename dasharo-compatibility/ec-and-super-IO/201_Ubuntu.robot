*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     ECR Suite Setup
...                     AND    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Ubuntu not supported
...                     AND    Skip If    "${ENV_ID_UBUNTU}" not in ${TESTED_LINUX_DISTROS}    Ubuntu not supported
...                     AND    Init ECR Ubuntu
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
ECR001.201 Battery monitoring - charge level in OS (Ubuntu)
    [Documentation]    Check whether the battery charge level can be read
    ...    (in mAh) in Linux OS.
    ...    Previous IDs: ECR001.001
    Turn On ACPI CALL Module In Linux
    Check Charge Level In Linux

ECR002.201 Battery monitoring - charging state in OS (Ubuntu)
    [Documentation]    Check whether the battery state can be read in Linux OS.
    ...    Previous IDs: ECR002.001
    Turn On ACPI CALL Module In Linux
    Check Charging State In Linux

ECR003.201 Touchpad in OS - (Ubuntu)
    [Documentation]    Check whether touchpad is visible in Linux OS.
    ...    Touchpad steering and effect detection must be checked
    ...    manually.
    ...    Previous IDs: ECR003.001
    Turn On ACPI CALL Module In Linux
    Device Detection In Linux    Touchpad

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

ECR014.201 Keyboard (function key: brightness down) in OS (Ubuntu)
    [Documentation]    Check whether function key: brightness down works in
    ...    Linux OS.
    ...    Previous IDs: ECR014.001
    Keyboard Function Key Brightness Down In Linux

ECR015.201 Keyboard (function key: brightness up) in OS (Ubuntu)
    [Documentation]    Check whether function key: brightness up works in
    ...    Linux OS.
    ...    Previous IDs: ECR015.001
    Keyboard Function Key Brightness Up In Linux

ECR016.201 Keyboard (function key: camera on/off) in OS (Ubuntu)
    [Documentation]    Check whether the camera on/off hotkey works correctly.
    ...    Previous IDs: ECR016.001
    Skip If    not ${USB_CAMERA_DETECTION_SUPPORT}    ECR016.201 not supported
    Skip If    not ${ACPI_CAMERA_SWITCH_SUPPORT}    ECR016.201 not supported
    Keyboard Function Key Camera OnOff In Linux

ECR017.201 Keyboard (function key: flight mode) in OS (Ubuntu)
    [Documentation]    Check whether function key: flight mode works in
    ...    Linux OS.
    ...    Previous IDs: ECR017.001
    Skip If    not ${WIRELESS_CARD_SUPPORT}    ECR017.201 not supported
    Skip If    '${DUT_CONNECTION_METHOD}' == 'SSH'    ECR017.201 not supported
    Keyboard Function Key Flight Mode In Linux

# ECR018.001 Keyboard (function key: sleep) in OS (Ubuntu)
#    [Documentation]    Check whether function key: sleep works in Linux OS.
#    IF    not ${ec_and_super_io_support}    SKIP    ECR019.001 not supported
#    Power On
#    Login to Linux
#    Switch to root user
#
#    Turn On ACPI_CALL module in Linux
#    Enter sleep mode in Linux
#    Wake from sleep mode in Linux
#    Exit from root user

ECR019.201 Buttons (button: power) in OS (Ubuntu)
    [Documentation]    Check whether button: power is detected in Linux OS.
    ...    Previous IDs: ECR019.001
    Turn On ACPI CALL Module In Linux
    Device Detection In Linux    Power

ECR020.201 Charging until 98% level in OS (Ubuntu)
    [Documentation]    Check whether the DUT stops charging the battery when the
    ...    98% threshold is reached.
    ...    Previous IDs: ECR020.001
    Skip If    '${POWER_CTRL}' != 'sonoff'    ECR020.201 not supported
    Charging Until 98% Level In Linux
    Check Charging State Not Charging In Linux

ECR021.201 Not charging between 95% and 98% in OS (Ubuntu)
    [Documentation]    Check whether the DUT does not charge the battery when
    ...    the charge level is between 95% and 98%.
    ...    Previous IDs: ECR021.001
    Skip If    '${POWER_CTRL}' != 'sonoff'    ECR021.201 not supported
    Not Charging Between 95% And 98% In Linux


*** Keywords ***
Init ECR Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
