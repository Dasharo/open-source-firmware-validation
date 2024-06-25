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
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${NVIDIA_GRAPHICS_CARD_SUPPORT}    Nvidia GPU tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
NVI001.001 NVIDIA Graphics detect (Ubuntu)
    [Documentation]    Check whether the NVIDIA graphics card is initialized
    ...    correctly and can be detected by the Linux OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NVI001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    pciutils
    ${out}=    Execute Linux Command    lspci | grep -i nvidia | cat
    Should Contain    ${out}    3D controller: NVIDIA Corporation
    Exit From Root User

NVI001.002 NVIDIA Graphics detect (Windows)
    [Documentation]    Check whether the NVIDIA graphics card is initialized
    ...    correctly and can be detected by the Windows 11.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    NVI001.002 not supported
    Power On
    Login To Windows
    ${out}=    Get Video Controllers Windows
    Should Contain    ${out}    NVIDIA GeForce

NVI002.001 NVIDIA Graphics power management (Ubuntu)
    [Documentation]    Check whether the NVIDIA graphics power management is
    ...    functional and the card powers on only while it's used.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NVI002.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Detect Or Install Package    mesa-utils
    Detect Or Install Package    pciutils
    Check NVIDIA Power Management In Linux
    Exit From Root User
