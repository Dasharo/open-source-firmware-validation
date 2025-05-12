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
DSP001.201 - Internal display in OS (Ubuntu)
    [Documentation]    Check whether an internal display is visible in
    ...    Ubuntu.
    ...    Previous IDs: DSP001.002
    Skip If    not ${INTERNAL_LCD_DISPLAY_SUPPORT}    DSP001.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DSP001.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in "${TESTED_LINUX_DISTROS}"    DSP001.201 not supported
    Internal Display In OS    ${ENV_ID_UBUNTU}

DSP001.202 - Internal display in OS (Fedora)
    [Documentation]    Check whether an internal display is visible in
    ...    Ubuntu.
    Skip If    not ${INTERNAL_LCD_DISPLAY_SUPPORT}    DSP001.202 not supported
    Skip If    "${ENV_ID_FEDORA}" not in "${TESTED_LINUX_DISTROS}"    DSP003.202 not supported
    Internal Display In OS    ${ENV_ID_FEDORA}

DSP001.301 - Internal display in OS (Windows)
    [Documentation]    Check whether an internal display is visible in
    ...    Windows OS.
    ...    Previous IDs: DSP001.003
    Skip If    not ${INTERNAL_LCD_DISPLAY_SUPPORT}    DSP001.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    DSP001.002 not supported
    Power On
    Login To Windows
    Check Internal LCD Windows

DSP002.201 - External HDMI display in OS (Ubuntu)
    [Documentation]    Check whether an external HDMI display is visible in
    ...    Linux OS. An external HDMI display must be provided in
    ...    the platform config.
    ...    Previous IDs: DSP002.001
    Skip If    not ${EXTERNAL_HDMI_DISPLAY_SUPPORT}    DSP002.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DSP002.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in "${TESTED_LINUX_DISTROS}"    DSP002.201 not supported
    External HDMI Display    ${ENV_ID_UBUNTU}

DSP002.202 - External HDMI display in OS (Fedora)
    [Documentation]    Check whether an external HDMI display is visible in
    ...    Fedora OS. An external HDMI display must be provided in
    ...    the platform config.
    Skip If    not ${EXTERNAL_HDMI_DISPLAY_SUPPORT}    DSP002.202 not supported
    Skip If    "${ENV_ID_FEDORA}" not in "${TESTED_LINUX_DISTROS}"    DSP002.202 not supported
    External HDMI Display    ${ENV_ID_FEDORA}

DSP002.301 - External HDMI display in OS (Windows)
    [Documentation]    Check whether an external HDMI display is visible in
    ...    Windows OS. An external HDMI display must be provided in
    ...    the platform config.
    ...    Previous IDs: DSP002.002
    Skip If    not ${EXTERNAL_HDMI_DISPLAY_SUPPORT}    DSP002.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    DSP002.301 not supported
    Power On
    Login To Windows
    Check HDMI Windows

DSP002.203 - External HDMI display in OS (XCP-NG)
    [Documentation]    Check whether an external HDMI display is visible in
    ...    XCP-NG OS. An external HDMI display must be provided in
    ...    the platform config.
    Skip If    not ${EXTERNAL_HDMI_DISPLAY_SUPPORT}    DSP002.203 not supported
    Skip If    not ${TESTS_IN_XCP_NG_SUPPORT}    DSP002.203 not supported
    Skip If    "${ENV_ID_XCP_NG}" not in "${TESTED_LINUX_DISTROS}"    DSP002.203 not supported
    Execute Manual Step    External HDMI Display    ${ENV_ID_XCP_NG}

DSP003.201 - External DP display in OS (Ubuntu)
    [Documentation]    Check whether an external Display Port is visible in
    ...    Linux OS. An external Display Port must be provided in
    ...    the platform config.
    ...    Previous IDs: DSP003.001
    Skip If    not ${EXTERNAL_DISPLAY_PORT_SUPPORT}    DSP003.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DSP003.201 supported
    Skip If    "${ENV_ID_UBUNTU}" not in "${TESTED_LINUX_DISTROS}"    DSP001.201 not supported
    External DP Display In OS    ${ENV_ID_UBUNTU}

DSP003.202 - External DP display in OS (Fedora)
    [Documentation]    Check whether an external Display Port is visible in
    ...    Linux OS. An external Display Port must be provided in
    ...    the platform config.
    Skip If    not ${EXTERNAL_DISPLAY_PORT_SUPPORT}    DSP003.202 not supported
    Skip If    "${ENV_ID_FEDORA}" not in "${TESTED_LINUX_DISTROS}"    DSP003.202 not supported
    External DP Display In OS    ${ENV_ID_FEDORA}

DSP003.301 - External DP display in OS (Windows)
    [Documentation]    Check whether an external Display Port is visible in
    ...    Windows OS. An external Display Port must be provided in
    ...    the platform config.
    ...    Previous IDs: DSP003.002
    Skip If    not ${EXTERNAL_DISPLAY_PORT_SUPPORT}    DSP003.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    301.002 not supported
    Power On
    Login To Windows
    Check DP Windows

DSP003.203 - External DP display in OS (XCP-NG)
    [Documentation]    Check whether an external Display Port is visible in
    ...    XCP-NG OS. An external Display Port must be provided in
    ...    the platform config.
    Skip If    not ${EXTERNAL_DISPLAY_PORT_SUPPORT}    DSP003.203 not supported
    Skip If    not ${TESTS_IN_XCP_NG_SUPPORT}    DSP003.203 not supported
    Skip If    "${ENV_ID_XCP_NG}" not in "${TESTED_LINUX_DISTROS}"    DSP003.203 not supported
    Execute Manual Step    External DP Display In OS    ${ENV_ID_XCP_NG}


*** Keywords ***
External HDMI Display
    [Documentation]    Check whether an external HDMI display is visible in
    ...    Linux OS. An external HDMI display must be provided in
    ...    the platform config.
    [Tags]    robot:private
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    Check External HDMI In Linux
    Exit From Root User

Internal Display In OS
    [Documentation]    Check whether an internal display is visible
    [Tags]    robot:private
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    Check Internal LCD Linux
    Exit From Root User

External DP Display In OS
    [Documentation]    Check whether an external Display Port is visible in
    ...    Linux OS. An external Display Port must be provided in
    ...    the platform config.
    [Tags]    robot:private
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    Check External DP In Linux
    Exit From Root User
