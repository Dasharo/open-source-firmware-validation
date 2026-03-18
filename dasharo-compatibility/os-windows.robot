*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
WBT001.301 Windows 11 installation and boot (Windows)
    [Documentation]    Check whether Windows 11 can be installed and boot correctly on the DUT.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    WBT001.301 not supported
    Execute Manual Step    [1/5] Prepare a Windows 11 installation medium (USB)
    Execute Manual Step    [2/5] Power on the DUT and boot from the Windows 11 installation medium
    Execute Manual Step    [3/5] Follow the Windows 11 installer steps to complete the installation
    Execute Manual Step    [4/5] Reboot after installation completes
    Execute Manual Step    [5/5] Confirm Windows 11 boots successfully after installation

WBT002.301 Windows 10 installation and boot (Windows)
    [Documentation]    Check whether Windows 10 can be installed and boot correctly on the DUT.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    WBT002.301 not supported
    Execute Manual Step    [1/5] Prepare a Windows 10 installation medium (USB)
    Execute Manual Step    [2/5] Power on the DUT and boot from the Windows 10 installation medium
    Execute Manual Step    [3/5] Follow the Windows 10 installer steps to complete the installation
    Execute Manual Step    [4/5] Reboot after installation completes
    Execute Manual Step    [5/5] Confirm Windows 10 boots successfully after installation
