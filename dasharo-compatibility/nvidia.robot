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
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
NVI001.001 NVIDIA Graphics detect (Ubuntu 20.04)
    [Documentation]    Check whether the NVIDIA graphics card is initialized
    ...    correctly and can be detected by the Linux OS.
    Skip If    not ${nvidia_graphics_card_support}    NVI001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    NVI001.001 not supported
    Power On
    Login to Linux
    Switch to root user
    ${out}=    Execute Linux command    lspci | grep -i nvidia | cat
    Should Contain    ${out}    3D controller: NVIDIA Corporation
    Exit from root user

NVI001.002 NVIDIA Graphics detect (Windows 11)
    [Documentation]    Check whether the NVIDIA graphics card is initialized
    ...    correctly and can be detected by the Windows 11.
    Skip If    not ${nvidia_graphics_card_support}    NVI001.002 not supported
    Skip If    not ${tests_in_windows_support}    NVI001.002 not supported
    Power On
    Login to Windows
    ${out}=    Get Video Controllers Windows
    Should Contain    ${out}    NVIDIA GeForce

NVI002.001 NVIDIA Graphics power management (Ubuntu 20.04)
    [Documentation]    Check whether the NVIDIA graphics power management is
    ...    functional and the card powers on only while it's used.
    Skip If    not ${nvidia_graphics_card_support}    NVI002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    NVI002.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Detect or Install Package    mesa-utils
    Check NVIDIA Power Management in Linux
    Exit from root user
