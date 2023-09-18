*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
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
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
DSP001.003 - Internal display in OS (Windows 11)
    [Documentation]    Check whether an internal display is visible in
    ...    Windows OS.
    Skip If    not ${internal_lcd_display_support}    DSP001.002 not supported
    Skip If    not ${tests_in_windows_support}    DSP001.002 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    Check Internal LCD Windows

DSP002.001 - External HDMI display in OS (Ubuntu 20.04)
    [Documentation]    Check whether an external HDMI display is visible in
    ...    Linux OS. An external HDMI display must be provided in
    ...    the platform config.
    Skip If    not ${external_hdmi_display_support}    DSP003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DSP003.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Check external HDMI in Linux
    Exit from root user

DSP002.002 - External HDMI display in OS (Windows 11)
    [Documentation]    Check whether an external HDMI display is visible in
    ...    Windows OS. An external HDMI display must be provided in
    ...    the platform config.
    Skip If    not ${external_hdmi_display_support}    DSP002.002 not supported
    Skip If    not ${tests_in_windows_support}    DSP002.002 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    Check HDMI Windows

DSP003.001 - External DP display in OS (Ubuntu 20.04)
    [Documentation]    Check whether an external Display Port is visible in
    ...    Linux OS. An external Display Port must be provided in
    ...    the platform config.
    Skip If    not ${external_display_port_support}    DSP003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DSP003.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Check external DP in Linux
    Exit from root user

DSP003.002 - External DP display in OS (Windows 11)
    [Documentation]    Check whether an external Display Port is visible in
    ...    Windows OS. An external Display Port must be provided in
    ...    the platform config.
    Skip If    not ${external_display_port_support}    DSP003.002 not supported
    Skip If    not ${tests_in_windows_support}    DSP003.002 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    Check DP Windows
