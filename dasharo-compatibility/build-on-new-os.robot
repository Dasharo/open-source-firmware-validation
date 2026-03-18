*** Settings ***
Library             Dialogs
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
BNO001.201 Build on a newly installed OS (Ubuntu)
    [Documentation]    Check whether Dasharo is buildable on freshly installed Ubuntu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    BNO001.201 not supported
    Execute Manual Step
    ...    [1/3] Install a fresh installation of Ubuntu on the device
    Execute Manual Step    [2/3] Boot into Ubuntu.
    Execute Manual Step
    ...    [3/3] Build the Dasharo firmware following the build instructions from docs.dasharo.com for this device.
    Execute Manual Step    [Expected result] The build process should result in creating a rom file.

BNO002.201 Boot (Ubuntu)
    [Documentation]    Check whether Ubuntu Linux is bootable with the firmware built using the instructions at docs.dasharo.com.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    BNO002.201 not supported
    Execute Manual Step
    ...    [1/3] Flash the firmware built on a newly installed OS using the instructions for the device from docs.dasharo.com.
    Execute Manual Step    [2/3] Power on the DUT.
    Execute Manual Step    [3/3] Boot into Ubuntu.
    Execute Manual Step
    ...    [Expected result] There was no message that the device booted from recovery. The OS boots properly.
