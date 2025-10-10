*** Settings ***
Library     Collections
Library     OperatingSystem
Library     Process
Library     String
Library     Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library     SSHLibrary    timeout=90 seconds
Library     RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource    ../variables.robot
Resource    ../keywords.robot
Resource    ../keys.robot
Resource    ../keys-and-keywords/heads-keywords.robot
Resource    ../lib/performance/cpu.robot
# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)


*** Variables ***
&{TESTS_TO_RUN}=                &{EMPTY}
${CPU_FREQUENCY_MEASURE}=       ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=     ${FALSE}
@{TESTED_LINUX_DISTROS}=        202    201


*** Test Cases ***
_CANARY_CPF001.201
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    CPF001.201
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    CPF001.201
    ...    not ${TESTS_IN_UBUNTU_SUPPORT}
    ...    tests in Ubuntu not supported
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    CPF001.201
    ...    '201' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros

_PSEUDO_Background Measurements Data Init (no load) (Ubuntu)
    Log    Doing some init    WARN

CPF001.201 CPU not stuck on initial frequency (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.001
    Skip If Not Supported    CPF001.201    ${TESTS_TO_RUN}


*** Keywords ***
Add Test Case Skip Condition
    [Arguments]    ${tests_dict}    ${test_id}    ${condition}    ${skip_reason}
    ${current_details}=    Get From Dictionary    ${tests_dict}    ${test_id}    default=${FALSE}
    IF    not ${current_details}
        VAR    &{support_details}=    test=${test_id}    run=${TRUE}    reason=supported
    ELSE
        VAR    ${support_details}=    ${current_details}
    END
    ${run}=    Get From Dictionary    ${support_details}    run
    IF    ${run} and (${condition})
        Set To Dictionary    ${support_details}    run=${FALSE}    reason=${skip_reason}
    END
    Set To Dictionary    ${tests_dict}    ${test_id}=${support_details}

Skip If Not Supported
    [Arguments]    ${test_id}    ${tests_dict}
    &{support_details}=    Get From Dictionary    ${tests_dict}    ${test_id}
    ${run}=    Get From Dictionary    ${support_details}    run
    ${reason}=    Get From Dictionary    ${support_details}    reason
    ${not_run}=    Evaluate    not ${run}
    Skip If    ${not_run}    ${reason}
