*** Settings ***
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
DSR001.203 Changing the display resolution (Qubes OS)
    [Documentation]    Check whether the display resolution can be changed in the OS and the GUI is displayed correctly after the change.
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
    Execute Manual Step    [1/5] Power on the DUT with any display connected.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step
    ...    [4/5] Open a terminal window in dom0 and run the following command: xrandr -s <display_resolution>
    Execute Manual Step    [5/5] Note the results.
    Execute Manual Step
    ...    [Expected result] Changing the display resolution is possible. After changing the resolution, all icons and subtitles should be displayed correctly.
