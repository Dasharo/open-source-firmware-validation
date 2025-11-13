*** Settings ***
Library             Dialogs
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    ESXi not supported
Suite Teardown      Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
DSP002.401 External HDMI display in OS (ESXi)
    [Documentation]    Verify that the external HDMI display is initialized and displays output
    ...    during and after ESXi boots. No multi-display configuration is required.
    ...    Previous IDs: DSP002.011
    Pause Execution
    ...    This is a manual test to verify HDMI output on ESXi.
    Execute Manual Step    [1/4] Connect an external display to the DUT via HDMI
    Execute Manual Step    [2/4] Power on the DUT
    Execute Manual Step    [3/4] Boot into ESXi and wait for the DCUI to appear
    Execute Manual Step    [4/4] Confirm that the ESXi interface is visible on the external HDMI display

DSP003.401 External DP display in OS (ESXi)
    [Documentation]    Verify that the external DisplayPort monitor shows output
    ...    during and after ESXi boot. No display mode configuration is required.
    ...    Previous IDs: DSP003.011
    Pause Execution
    ...    This is a manual test to verify DisplayPort output on ESXi.
    Execute Manual Step    [1/4] Connect an external display to the DUT via DisplayPort
    Execute Manual Step    [2/4] Power on the DUT
    Execute Manual Step    [3/4] Boot into ESXi and wait for the DCUI to appear
    Execute Manual Step    [4/4] Confirm that the ESXi interface is visible on the external DisplayPort display
