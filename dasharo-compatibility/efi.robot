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
EFI001.001 Boot into UEFI OS (Ubuntu 20.04)
    [Documentation]    Boot into Linux OS and check whether there is a
    ...    possibility to identify the system.
    Skip If    not ${uefi_compatible_interface_support}    EFI001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    EFI001.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out}=    Execute Command in Terminal    cat /etc/os-release
    Should Contain    ${out}    Ubuntu

EFI001.002 Boot into UEFI OS (Windows 11)
    [Documentation]    Boot into Windows 11 OS and check whether there is a
    ...    possibility to identify the system
    Skip If    not ${uefi_compatible_interface_support}    EFI001.002 not supported
    Skip If    not ${tests_in_windows_support}    EFI001.002 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    ${out}=    Execute Command In Terminal    (Get-WmiObject -class Win32_OperatingSystem).Caption
    Should Contain    ${out}    Microsoft Windows 11
