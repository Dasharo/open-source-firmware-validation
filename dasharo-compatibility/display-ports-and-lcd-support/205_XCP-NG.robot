*** Settings ***
Library             Dialogs
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${TESTS_IN_XCP_NG_SUPPORT}    XCP-NG not supported
Suite Teardown      Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
DSP002.205 - External HDMI display in OS (XCP-NG)
    [Documentation]    Check whether an external HDMI display is visible in
    ...    XCP-NG OS. An external HDMI display must be provided in
    ...    the platform config.
    ...    Previous IDs: DSP002.010
    Skip If    not ${EXTERNAL_HDMI_DISPLAY_SUPPORT}    DSP002.203 not supported
    Pause Execution
    ...    This is a manual test to verify HDMI output on XCP-NG.
    Execute Manual Step    [1/4] Connect an external display to the DUT via HDMI
    Execute Manual Step    [2/4] Power on the DUT
    Execute Manual Step    [3/4] Boot into XCP-NG and wait for the DCUI to appear
    Execute Manual Step    [4/4] Confirm that the XCP-NG interface is visible on the external HDMI display

DSP003.205 - External DP display in OS (XCP-NG)
    [Documentation]    Check whether an external Display Port is visible in
    ...    XCP-NG OS. An external Display Port must be provided in
    ...    the platform config.
    ...    Previous IDs: DSP003.010
    Skip If    not ${EXTERNAL_DISPLAY_PORT_SUPPORT}    DSP003.203 not supported
    Pause Execution
    ...    This is a manual test to verify DisplayPort output on XCP-NG.
    Execute Manual Step    [1/4] Connect an external display to the DUT via DisplayPort
    Execute Manual Step    [2/4] Power on the DUT
    Execute Manual Step    [3/4] Boot into XCP-NG
    Execute Manual Step    [4/4] Confirm that the XCP-NG interface is visible on the external DisplayPort display
