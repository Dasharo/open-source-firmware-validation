*** Settings ***
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
PEX001.201 PCI Express card detection (Ubuntu)
    [Documentation]    Check whether the PCI Express extension card is enumerated correctly and can be detected from Ubuntu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PEX001.201 not supported
    Execute Manual Step    [1/4] Power on the DUT with the PCI Express extension card plugged into the tested slot.
    Execute Manual Step    [2/4] Boot into the system.
    Execute Manual Step    [3/4] Log into the system by using the proper login and password.
    Execute Manual Step    [4/4] Open a terminal window and execute the following command: lspci
    Execute Manual Step
    ...    [Expected result] The output of the command should contain the plugged device name. The exact name and revision may be different depending on hardware configuration.

PEX001.301 PCI Express card detection (Windows)
    [Documentation]    Check whether the PCI Express extension card is enumerated correctly and can be detected from Windows.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    PEX001.301 not supported
    Execute Manual Step    [1/5] Power on the DUT with the PCI Express extension card plugged into the tested slot.
    Execute Manual Step    [2/5] Boot into the system.
    Execute Manual Step    [3/5] Log into the system by using the proper login and password.
    Execute Manual Step    [4/5] Open Device Manager and find the plugged device.
    Execute Manual Step    [5/5] Note the device status.
    Execute Manual Step
    ...    [Expected result] The device status in the Device Manager should indicate that the device is working properly and has no problems.
