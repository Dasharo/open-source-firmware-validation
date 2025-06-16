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
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
EPN001.201 Check the ethernet port names (Ubuntu)
    [Documentation]    Check whether the ethernet ports are named 'enp'
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    EPN001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    EPN001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    ${out}=    Execute Linux Command    ip a
    Should Not Contain Any    ${out}
    ...    eno1    eno2    eno3    eno4    eno5    eno6
    ${regexes}=    Get Regexp Matches    ${out}    enp[0-9]s[0-9]
    Should Not Be Empty    ${regexes}
