*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    "${ENV_ID_FEDORA}" not in "${TESTED_LINUX_DISTROS}"    Fedora not supported
...                     AND    Init DSP Fedora
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
DSP001.202 - Internal display in OS (Fedora)
    [Documentation]    Check whether an internal display is visible in
    ...    Ubuntu.
    Skip If    not ${INTERNAL_LCD_DISPLAY_SUPPORT}    DSP001.202 not supported
    Check Internal Display Linux

DSP002.202 - External HDMI display in OS (Fedora)
    [Documentation]    Check whether an external HDMI display is visible in
    ...    Fedora OS. An external HDMI display must be provided in
    ...    the platform config.
    Skip If    not ${EXTERNAL_HDMI_DISPLAY_SUPPORT}    DSP002.202 not supported
    Check External HDMI Display Linux

DSP003.202 - External DP display in OS (Fedora)
    [Documentation]    Check whether an external Display Port is visible in
    ...    Linux OS. An external Display Port must be provided in
    ...    the platform config.
    Skip If    not ${EXTERNAL_DISPLAY_PORT_SUPPORT}    DSP003.202 not supported
    Check External DP Display Linux


*** Keywords ***
Init DSP Fedora
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
