*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    Windows not supported
...                     AND    Init DSP Windows
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
DSP001.301 - Internal display in OS (Windows)
    [Documentation]    Check whether an internal display is visible in
    ...    Windows OS.
    ...    Previous IDs: DSP001.003
    Skip If    not ${INTERNAL_LCD_DISPLAY_SUPPORT}    DSP001.002 not supported
    Check Internal LCD Windows

DSP002.301 - External HDMI display in OS (Windows)
    [Documentation]    Check whether an external HDMI display is visible in
    ...    Windows OS. An external HDMI display must be provided in
    ...    the platform config.
    ...    Previous IDs: DSP002.002
    Skip If    not ${EXTERNAL_HDMI_DISPLAY_SUPPORT}    DSP002.301 not supported
    Check HDMI Windows

DSP003.301 - External DP display in OS (Windows)
    [Documentation]    Check whether an external Display Port is visible in
    ...    Windows OS. An external Display Port must be provided in
    ...    the platform config.
    ...    Previous IDs: DSP003.002
    Skip If    not ${EXTERNAL_DISPLAY_PORT_SUPPORT}    DSP003.301 not supported
    Check DP Windows


*** Keywords ***
Init DSP Windows
    Power On
    Login To Windows
