*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     ECR Suite Setup
...                     AND    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    Fedora not supported
...                     AND    Init ECR Fedora
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
ECR001.202 Battery monitoring - charge level in OS (Fedora)
    [Documentation]    Check whether the battery charge level can be read
    ...    (in mAh) in Linux OS.
    Turn On ACPI CALL Module In Linux
    Check Charge Level In Linux

ECR002.202 Battery monitoring - charging state in OS (Fedora)
    [Documentation]    Check whether the battery state can be read in Linux OS.
    Turn On ACPI CALL Module In Linux
    Check Charging State In Linux

ECR003.202 Touchpad in OS - (Fedora)
    [Documentation]    Check whether touchpad is visible in Linux OS.
    ...    Touchpad steering and effect detection must be checked
    ...    manually.
    Turn On ACPI CALL Module In Linux
    Device Detection In Linux    Touchpad

ECR014.202 Keyboard (function key: brightness down) in OS (Fedora)
    [Documentation]    Check whether function key: brightness down works in
    ...    Linux OS.
    Keyboard Function Key Brightness Down In Linux

ECR015.202 Keyboard (function key: brightness up) in OS (Fedora)
    [Documentation]    Check whether function key: brightness up works in
    ...    Linux OS.
    Keyboard Function Key Brightness Up In Linux

ECR016.202 Keyboard (function key: camera on/off) in OS (Fedora)
    [Documentation]    Check whether the camera on/off hotkey works correctly.
    Skip If    not ${USB_CAMERA_DETECTION_SUPPORT}    ECR016.202 not supported
    Skip If    not ${ACPI_CAMERA_SWITCH_SUPPORT}    ECR016.201 not supported
    Keyboard Function Key Camera OnOff In Linux

ECR017.202 Keyboard (function key: flight mode) in OS (Fedora)
    [Documentation]    Check whether function key: flight mode works in
    ...    Linux OS.
    Skip If    not ${WIRELESS_CARD_SUPPORT}    ECR017.202 not supported
    Skip If    '${DUT_CONNECTION_METHOD}' == 'SSH'    ECR017.202 not supported
    Keyboard Function Key Flight Mode In Linux

ECR019.202 Buttons (button: power) in OS (Fedora)
    [Documentation]    Check whether button: power is detected in Linux OS.
    Turn On ACPI CALL Module In Linux
    Device Detection In Linux    Power

ECR020.202 Charging until 98% level in OS (Fedora)
    [Documentation]    Check whether the DUT stops charging the battery when the
    ...    98% threshold is reached.
    Skip If    '${POWER_CTRL}' != 'sonoff'    ECR020.202 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ECR020.202 not supported
    Charging Until 98% Level In Linux
    Check Charging State Not Charging In Linux

ECR021.202 Not charging between 95% and 98% in OS (Fedora)
    [Documentation]    Check whether the DUT does not charge the battery when
    ...    the charge level is between 95% and 98%.
    Skip If    '${POWER_CTRL}' != 'sonoff'    ECR021.202 not supported
    Not Charging Between 95% And 98% In Linux


*** Keywords ***
Init ECR Fedora
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
