*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Ubuntu not supported
...                     AND    Skip If    "${ENV_ID_UBUNTU}" not in "${TESTED_LINUX_DISTROS}"    Ubuntu not supported
...                     AND    Init DSP Ubuntu
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
DSP001.201 - Internal display in OS (Ubuntu)
    [Documentation]    Check whether an internal display is visible in
    ...    Ubuntu.
    ...    Previous IDs: DSP001.002
    Skip If    not ${INTERNAL_LCD_DISPLAY_SUPPORT}    DSP001.201 not supported
    Check Internal Display Linux

DSP002.201 - External HDMI display in OS (Ubuntu)
    [Documentation]    Check whether an external HDMI display is visible in
    ...    Linux OS. An external HDMI display must be provided in
    ...    the platform config.
    ...    Previous IDs: DSP002.001
    Skip If    not ${EXTERNAL_HDMI_DISPLAY_SUPPORT}    DSP002.201 not supported
    Check External HDMI Display Linux

DSP003.201 - External DP display in OS (Ubuntu)
    [Documentation]    Check whether an external Display Port is visible in
    ...    Linux OS. An external Display Port must be provided in
    ...    the platform config.
    ...    Previous IDs: DSP003.001
    Skip If    not ${EXTERNAL_DISPLAY_PORT_SUPPORT}    DSP003.201 not supported
    Check External DP Display Linux


*** Keywords ***
Init DSP Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
