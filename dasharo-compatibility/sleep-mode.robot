*** Settings ***
Library             Dialogs
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
SLM001.201 Sleep mode - battery monitoring (Ubuntu)
    [Documentation]    Check how quickly the battery discharges while in sleep mode in Ubuntu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SLM001.201 not supported
    Execute Manual Step    [1/7] Power on the DUT.
    Execute Manual Step    [2/7] Boot into the system.
    Execute Manual Step    [3/7] Log into the system by using the proper login and password.
    VAR    ${charge_msg}=
    ...    [4/7] Charge the battery fully (note: due to the manufacturer's settings the maximum battery charge level is limited to 90%;
    ...    also, the battery charging process can only be started if the current battery level is less than 80%).
    ...    separator=${SPACE}
    Execute Manual Step    ${charge_msg}
    Execute Manual Step    [5/7] Disconnect the power supply.
    Execute Manual Step    [6/7] Close the lid.
    VAR    ${wake_msg}=
    ...    [7/7] Wake up the DUT in the following timestamps and note the battery level:
    ...    1 hour from fully charging, 2 hours from fully charging, 3 hours from fully charging,
    ...    6 hours from fully charging, (optional) 24 hours from fully charging.
    ...    separator=${SPACE}
    Execute Manual Step    ${wake_msg}
    VAR    ${result_msg}=
    ...    [Expected result] The battery should discharge at a similar rate as in the table below
    ...    (take the battery wear into account): 0h=90%, 1h=88%, 2h=86%, 3h=84%, 6h=80%, 24h(optional)=57%.
    ...    separator=${SPACE}
    Execute Manual Step    ${result_msg}

SLM000.301 Sleep mode - battery monitoring (Windows)
    [Documentation]    Check how quickly the battery discharges while in sleep mode in Windows.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    SLM000.301 not supported
    Execute Manual Step    [1/8] Power on the DUT.
    Execute Manual Step    [2/8] Boot into the system.
    Execute Manual Step    [3/8] Log into the system by using the proper login and password.
    VAR    ${charge_msg}=
    ...    [4/8] Charge the battery fully (note: due to the manufacturer's settings the maximum battery charge level is limited to 90%;
    ...    also, the battery charging process can only be started if the current battery level is less than 80%).
    ...    separator=${SPACE}
    Execute Manual Step    ${charge_msg}
    Execute Manual Step    [5/8] Wait 30 seconds for the system to load fully.
    Execute Manual Step    [6/8] Disconnect the power supply.
    Execute Manual Step    [7/8] Close the lid.
    VAR    ${wake_msg}=
    ...    [8/8] Wake up the DUT in the following timestamps and note the battery level:
    ...    1 hour from fully charging, 2 hours from fully charging, 3 hours from fully charging,
    ...    6 hours from fully charging.
    ...    separator=${SPACE}
    Execute Manual Step    ${wake_msg}
    Execute Manual Step
    ...    [Expected result] The battery should discharge at a similar rate as in the table below (take the battery wear into account): 0h=90%, 1h=79%, 2h=69%, 3h=58%, 6h=26%.
