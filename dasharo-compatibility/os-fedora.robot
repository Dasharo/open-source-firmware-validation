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
FED001.202 Fedora installation (Fedora)
    [Documentation]    Check whether Fedora can be installed on the DUT.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Execute Manual Step    [1/5] Prepare a Fedora installation medium (USB or DVD)
    Execute Manual Step    [2/5] Power on the DUT and boot from the Fedora installation medium
    Execute Manual Step    [3/5] Follow the Fedora installer steps to complete the installation
    Execute Manual Step    [4/5] Reboot after installation completes
    Execute Manual Step    [5/5] Confirm Fedora boots successfully after installation

FED002.202 Boot Fedora (Fedora)
    [Documentation]    Check whether Fedora boots correctly on the DUT.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}
    Execute Manual Step    [1/3] Power on the DUT with Fedora installed
    Execute Manual Step    [2/3] Select Fedora from the boot menu if multiple OS are present
    Execute Manual Step    [3/3] Confirm Fedora boots to the login screen or desktop successfully
