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
...                     Skip If    not ${INTEL_CBNT_SUPPORT}    Intel CBnT not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
CBNT001.201 Converged Boot Guard and TXT - CBnT profile is 5 / FVME (Ubuntu)
    [Documentation]    CBnT profile MUST be 5 - FVME
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBNT001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CBNT001.201 not supported
    Check CBnT Profile 5    ${ENV_ID_UBUNTU}


*** Keywords ***
Check CBnT Profile 5
    [Documentation]    Check if F, V and M components of the boot policy match
    ...    profile 5
    [Tags]    robot:private
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${out_cbmem}=    Execute Command In Terminal    cbmem -1
    Should Contain    ${out_cbmem}    FACB:${SPACE*20}1
    Should Contain    ${out_cbmem}    measured boot:${SPACE*11}1
    Should Contain    ${out_cbmem}    verified boot:${SPACE*11}1
    Exit From Root User
