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
MSS001.201 M.2 automatic SATA/NVMe switching support (Ubuntu)
    [Documentation]    Check whether M.2 automatic SATA/NVMe switching works correctly in Ubuntu 22.04.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MSS001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    MSS001.201 not supported
    Execute Manual Step    [1/4] Install an M.2 drive (SATA or NVMe) in the M.2 slot
    Execute Manual Step    [2/4] Power on the DUT and boot into Ubuntu 22.04
    Execute Manual Step
    ...    [3/4] Run: lspci | grep -i sata or lsblk to verify the M.2 drive is detected in the correct mode
    Execute Manual Step
    ...    [4/4] Confirm the M.2 slot automatically detects and switches between SATA and NVMe modes correctly
