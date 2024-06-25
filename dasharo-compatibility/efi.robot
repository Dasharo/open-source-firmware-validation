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
...                     Skip If    not ${UEFI_COMPATIBLE_INTERFACE_SUPPORT}    UEFI interface tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
EFI001.001 Boot into UEFI OS (Ubuntu)
    [Documentation]    Boot into Linux OS and check whether there is a
    ...    possibility to identify the system.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    EFI001.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    cat /etc/os-release
    Should Contain    ${out}    Ubuntu

EFI001.002 Boot into UEFI OS (Windows)
    [Documentation]    Boot into Windows 11 OS and check whether there is a
    ...    possibility to identify the system
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    EFI001.002 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    (Get-WmiObject -class Win32_OperatingSystem).Caption
    Should Contain    ${out}    Microsoft Windows 11
