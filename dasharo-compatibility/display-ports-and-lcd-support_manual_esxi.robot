*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
DSP002.401 External HDMI display in OS (ESXi)
    [Documentation]    Verify that the external HDMI display is initialized and displays output
    ...    during and after ESXi boots. No multi-display configuration is required.
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    DSP002.401 not supported
    Skip If    '${ENV_ID_ESXI}' not in ${TESTED_LINUX_DISTROS}    DSP002.401 not supported

    Pause Execution
    ...    This is a manual test to verify HDMI output on ESXi.
    ...    You only need to confirm the display shows the ESXi screen.

    Execute Manual Step    [1/4] Connect an external display to the DUT via HDMI
    Execute Manual Step    [2/4] Power on the DUT
    Execute Manual Step    [3/4] Boot into ESXi and wait for the DCUI to appear
    Execute Manual Step    [4/4] Confirm that the ESXi interface is visible on the external HDMI display

DSP003.401 External DP display in OS (ESXi)
    [Documentation]    Verify that the external DisplayPort monitor shows output
    ...    during and after ESXi boot. No display mode configuration is required.
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    DSP003.401 not supported
    Skip If    '${ENV_ID_ESXI}' not in ${TESTED_LINUX_DISTROS}    DSP003.401 not supported

    Pause Execution
    ...    This is a manual test to verify DisplayPort output on ESXi.
    ...    You only need to confirm the display shows the ESXi screen.

    Execute Manual Step    [1/4] Connect an external display to the DUT via DisplayPort
    Execute Manual Step    [2/4] Power on the DUT
    Execute Manual Step    [3/4] Boot into ESXi and wait for the DCUI to appear
    Execute Manual Step    [4/4] Confirm that the ESXi interface is visible on the external DisplayPort display
