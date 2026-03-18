*** Settings ***
Library             Dialogs
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
DPC001.001 Reset button (QubesOS)
    [Documentation]    Check whether the reset button works correctly in QubesOS.
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Observe the power LED and use the reset button.
    Execute Manual Step    [5/5] Note the results.
    VAR    ${result_msg}=
    ...    [Expected result] The DUT should perform a reset, the power LED should be on all the time.
    ...    The DUT shouldn't perform a power cycle, the power LED shouldn't be off even for a moment.
    ...    separator=${SPACE}
    Execute Manual Step    ${result_msg}
