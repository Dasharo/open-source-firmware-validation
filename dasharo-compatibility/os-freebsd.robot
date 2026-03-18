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

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    '${ENV_ID_FREEBSD}' not in ${TESTED_BSD_DISTROS}    FreeBSD tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
BSD001.501 FreeBSD installation and boot (FreeBSD)
    [Documentation]    Verify that FreeBSD can be installed and booted on the DUT.
    Execute Manual Step    [1/6] Prepare a FreeBSD installation medium (USB or optical disk)
    Execute Manual Step    [2/6] Power on the DUT and boot from the installation medium
    Execute Manual Step    [3/6] Follow the FreeBSD installer steps to complete the installation
    Execute Manual Step    [4/6] Reboot the DUT after installation completes
    Execute Manual Step    [5/6] Verify the DUT boots into FreeBSD from the installed disk
    Execute Manual Step    [6/6] Log in and confirm the system is fully operational
