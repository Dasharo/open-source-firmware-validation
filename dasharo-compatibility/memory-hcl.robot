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
HCL001.201 Memory HCL - boot into OS (Ubuntu)
    [Documentation]    Check whether the DUT with HCL-listed memory can boot into Ubuntu successfully.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    HCL001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    HCL001.201 not supported
    Execute Manual Step    [1/3] Install HCL-listed memory modules in the DUT
    Execute Manual Step    [2/3] Power on the DUT and boot into Ubuntu
    Execute Manual Step
    ...    [3/3] Confirm Ubuntu boots successfully and the memory is detected correctly (check via: free -h or dmidecode -t memory)
