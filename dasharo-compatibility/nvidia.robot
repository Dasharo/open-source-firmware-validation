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
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${NVIDIA_GRAPHICS_CARD_SUPPORT}    Nvidia GPU tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
NVI001.201 NVIDIA Graphics detect (Ubuntu)
    [Documentation]    Check whether the NVIDIA graphics card is initialized
    ...    correctly and can be detected by the Linux OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NVI001.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in ${TESTED_LINUX_DISTROS}    NVI001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Linux Command    lspci | grep -i nvidia | cat
    Should Contain Any    ${out}    3D controller: NVIDIA Corporation    VGA compatible controller: NVIDIA Corporation
    Exit From Root User

NVI002.201 NVIDIA Graphics power management (Ubuntu)
    [Documentation]    Check whether the NVIDIA graphics power management is
    ...    functional and the card powers on only while it's used.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NVI002.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in ${TESTED_LINUX_DISTROS}    NVI002.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Check NVIDIA Power Management In Linux
    Exit From Root User

NVI001.202 NVIDIA Graphics detect (Fedora)
    [Documentation]    Check whether the NVIDIA graphics card is initialized
    ...    correctly and can be detected by the Linux OS.
    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    NVI001.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Linux Command    lspci | grep -i nvidia | cat
    Should Contain Any    ${out}    3D controller: NVIDIA Corporation    VGA compatible controller: NVIDIA Corporation
    Exit From Root User

NVI002.202 NVIDIA Graphics power management (Fedora)
    [Documentation]    Check whether the NVIDIA graphics power management is
    ...    functional and the card powers on only while it's used.
    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    NVI002.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Check NVIDIA Power Management In Linux
    Exit From Root User

NVI001.301 NVIDIA Graphics detect (Windows)
    [Documentation]    Check whether the NVIDIA graphics card is initialized
    ...    correctly and can be detected by the Windows 11.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    NVI001.301 not supported
    Power On
    Boot And Login To Windows
    ${out}=    Get Video Controllers Windows
    Should Contain    ${out}    NVIDIA GeForce

NVI002.301 NVIDIA Graphics power management (Windows)
    [Documentation]    Check whether the NVIDIA graphics power management is
    ...    functional in Windows and the card powers on only while it is used.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    NVI002.301 not supported
    Execute Manual Step    [1/4] Boot into Windows
    Execute Manual Step    [2/4] Open Device Manager and verify the NVIDIA GPU is present under Display Adapters
    Execute Manual Step    [3/4] Run a GPU-intensive application and check GPU usage via Task Manager or GPU-Z
    Execute Manual Step    [4/4] Confirm the GPU activates under load and returns to low power state when idle
