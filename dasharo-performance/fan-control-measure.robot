*** Settings ***
Library             Dialogs
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
FNM001.201 Fan does not stuck after coldboot (Ubuntu)
    [Documentation]    Check whether the fan does not stuck on initial or any defined speed after coldboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FNM001.201 not supported
    Execute Manual Step    [1/7] Cut the power off while DUT is turned on.
    Execute Manual Step    [2/7] Restore power and power on the DUT.
    Execute Manual Step    [3/7] Boot into the system.
    Execute Manual Step    [4/7] Log into the system by using the proper login and password.
    Execute Manual Step    [5/7] In the terminal window run the following command: sensors | grep fan1
    Execute Manual Step    [6/7] Repeat command every one minute, for 60 minutes.
    Execute Manual Step    [7/7] Compare the results.
    VAR    ${result_msg}=
    ...    [Expected result] The output of the command should contain information about the current fan speed.
    ...    If the current speed is the same as initial speed, the test should be considered as failed.
    ...    If the current speed does not change in the long term, the test should be considered as failed.
    ...    Example output: fan1: 1131 RPM (min = 329 RPM)
    ...    separator=${SPACE}
    Execute Manual Step    ${result_msg}

FNM002.201 Fan does not stuck after warmboot (Ubuntu)
    [Documentation]    Check whether the fan does not stuck on initial or any defined speed after warmboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FNM002.201 not supported
    Execute Manual Step    [1/6] Power on the DUT.
    Execute Manual Step    [2/6] Boot into the system.
    Execute Manual Step    [3/6] Log into the system by using the proper login and password.
    Execute Manual Step    [4/6] In the terminal window run the following command: sensors | grep fan1
    Execute Manual Step    [5/6] Repeat command every one minute, for 60 minutes.
    Execute Manual Step    [6/6] Compare the results.
    VAR    ${result_msg}=
    ...    [Expected result] The output of the command should contain information about the current fan speed.
    ...    If the current speed is the same as initial speed, the test should be considered as failed.
    ...    If the current speed does not change in the long term, the test should be considered as failed.
    ...    Example output: fan1: 1131 RPM (min = 329 RPM)
    ...    separator=${SPACE}
    Execute Manual Step    ${result_msg}

FNM003.201 Fan does not stuck after reboot (Ubuntu)
    [Documentation]    Check whether the fan does not stuck on initial or any defined speed after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    FNM003.201 not supported
    Execute Manual Step    [1/6] Power on the DUT.
    Execute Manual Step    [2/6] Boot into the system.
    Execute Manual Step    [3/6] Log into the system by using the proper login and password.
    Execute Manual Step    [4/6] In the terminal window run the following command: sensors | grep fan1
    Execute Manual Step    [5/6] Repeat command every one minute, for 60 minutes.
    Execute Manual Step    [6/6] Compare the results.
    VAR    ${result_msg}=
    ...    [Expected result] The output of the command should contain information about the current fan speed.
    ...    If the current speed is the same as initial speed, the test should be considered as failed.
    ...    If the current speed does not change in the long term, the test should be considered as failed.
    ...    Example output: fan1: 1131 RPM (min = 329 RPM)
    ...    separator=${SPACE}
    Execute Manual Step    ${result_msg}
