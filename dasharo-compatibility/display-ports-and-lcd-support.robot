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
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
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
DSP001.003 - Internal display in OS (Windows 11)
    [Documentation]    Check whether an internal display is visible in
    ...    Windows OS.
    Skip If    not ${INTERNAL_LCD_DISPLAY_SUPPORT}    DSP001.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    DSP001.002 not supported
    Power On
    Login To Windows
    Check Internal LCD Windows

DSP002.001 - External HDMI display in OS (Ubuntu 20.04)
    [Documentation]    Check whether an external HDMI display is visible in
    ...    Linux OS. An external HDMI display must be provided in
    ...    the platform config.
    Skip If    not ${EXTERNAL_HDMI_DISPLAY_SUPPORT}    DSP003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DSP003.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Check External HDMI In Linux
    Exit From Root User

DSP002.002 - External HDMI display in OS (Windows 11)
    [Documentation]    Check whether an external HDMI display is visible in
    ...    Windows OS. An external HDMI display must be provided in
    ...    the platform config.
    Skip If    not ${EXTERNAL_HDMI_DISPLAY_SUPPORT}    DSP002.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    DSP002.002 not supported
    Power On
    Login To Windows
    Check HDMI Windows

DSP003.001 - External DP display in OS (Ubuntu 20.04)
    [Documentation]    Check whether an external Display Port is visible in
    ...    Linux OS. An external Display Port must be provided in
    ...    the platform config.
    Skip If    not ${EXTERNAL_DISPLAY_PORT_SUPPORT}    DSP003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DSP003.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Check External DP In Linux
    Exit From Root User

DSP003.002 - External DP display in OS (Windows 11)
    [Documentation]    Check whether an external Display Port is visible in
    ...    Windows OS. An external Display Port must be provided in
    ...    the platform config.
    Skip If    not ${EXTERNAL_DISPLAY_PORT_SUPPORT}    DSP003.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    DSP003.002 not supported
    Power On
    Login To Windows
    Check DP Windows
