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
Resource    ../lib/sensors/sensors.robot
# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)

Suite Setup    Run Keywords    Prepare Test Suite

*** Variables ***
&{TESTS_TO_RUN}=                &{EMPTY}
${CPU_FREQUENCY_MEASURE}=       ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=     ${TRUE}
@{TESTED_LINUX_DISTROS}=        202    201


*** Test Cases ***

# Tests that can be performed immediately
_CANARY_CPF001.201
    VAR    ${TEST_ID}=    CPF001.201
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    ${TEST_ID}
    ...    not ${CPU_FREQUENCY_MEASURE}
    ...    frequency measure not supported
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    ${TEST_ID}
    ...    not ${TESTS_IN_UBUNTU_SUPPORT}
    ...    tests in Ubuntu not supported
    Add Test Case Skip Condition
    ...    ${TESTS_TO_RUN}
    ...    ${TEST_ID}
    ...    '201' not in ${TESTED_LINUX_DISTROS}
    ...    Ubuntu not in tested distros
    Skip If Not Supported    ${TEST_ID}    ${TESTS_TO_RUN}

# _CANARY_CPF005.201 CPU runs on expected frequency (Ubuntu)
#     VAR    ${TEST_ID}=    CPF005.201
#     Add Test Case Skip Condition
#     ...    ${TESTS_TO_RUN}
#     ...    ${TEST_ID}
#     ...    not ${CPU_FREQUENCY_MEASURE}
#     ...    frequency measure not supported
#     Add Test Case Skip Condition
#     ...    ${TESTS_TO_RUN}
#     ...    ${TEST_ID}
#     ...    not ${TESTS_IN_UBUNTU_SUPPORT}
#     ...    tests in Ubuntu not supported
#     Add Test Case Skip Condition
#     ...    ${TESTS_TO_RUN}
#     ...    ${TEST_ID}
#     ...    '201' not in ${TESTED_LINUX_DISTROS}
#     ...    Ubuntu not in tested distros
#     Add Test Case Skip Condition
#     ...    ${TESTS_TO_RUN}
#     ...    ${TEST_ID}
#     ...    ${LAPTOP_PLATFORM}
#     ...    The Platform is a Laptop

# _CANARY_CPT001.201 CPU temperature without load (Ubuntu)
#     VAR    ${TEST_ID}=    CPT001.201
#     Add Test Case Skip Condition
#     ...    ${TESTS_TO_RUN}
#     ...    ${TEST_ID}
#     ...    not ${TESTS_IN_UBUNTU_SUPPORT}
#     ...    tests in Ubuntu not supported
#     Add Test Case Skip Condition
#     ...    ${TESTS_TO_RUN}
#     ...    ${TEST_ID}
#     ...    ${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
#     ...    Ubuntu not in tested distros
#     Add Test Case Skip Condition
#     ...    ${TESTS_TO_RUN}
#     ...    ${TEST_ID}
#     ...    ${LAPTOP_PLATFORM}
#     ...    The Platform is a Laptop


_GATHER_Background Measurements Data Init (no load) (Ubuntu)
    ${prepare_sensors}=    Will Test Be Run Regex   ${TESTS_TO_RUN}    CP[TF]
    IF    ${prepare_sensors}    Prepare Sensors

_GATHER_Background Measurements Immediate (no load) (Ubuntu)
    ${will_any_be_run}=    Will Test Be Run Regex  ${TESTS_TO_RUN}    CP[TF]
    Skip If    not ${will_any_be_run}

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    # CPF001.201 steps
    VAR    ${test_id}=    CPF001.201
    ${check_frequency}=    Will Test Be Run  ${TESTS_TO_RUN}    ${test_id}
    IF    ${check_frequency}
        Sleep    10s
        @{frequencies}=    Get CPU Frequencies In Ubuntu
        Set Test Outputs    ${TESTS_TO_RUN}    ${test_id}    ${frequencies}
    END

CPF001.201 CPU not stuck on initial frequency (Ubuntu)
    [Documentation]    This test aims to verify whether the mounted CPU does not
    ...    stuck on the initial frequency after booting into the OS.
    ...    Previous IDs: CPF001.001
    VAR    ${test_id}=    CPF001.201
    Skip If Not Supported    ${test_id}    ${TESTS_TO_RUN}
    @{frequencies}=    Get Test Outputs    ${TESTS_TO_RUN}    ${test_id}
    ${first_frequency}=    Get From List    ${frequencies}    0
    FOR    ${frequency}    IN    @{frequencies}
        IF    ${frequency} != ${INITIAL_CPU_FREQUENCY}
            Pass Execution    CPU does not stuck on initial frequency
        END
    END
    Fail    CPU stuck on initial frequency: ${INITIAL_CPU_FREQUENCY}


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
    ${will_be_run}=    Will Test Be Run    ${tests_dict}    ${test_id}
    Skip If    not $will_be_run

Will Test Be Run
    [Arguments]    ${tests_dict}    ${test_id}
    ${test}=    Get From Dictionary    ${tests_dict}    ${test_id}    ${None}
    IF    $test is ${None}
        Log    Test ${test_id} not found
        RETURN    ${FALSE}
    END
    ${value}=    Get From Dictionary    ${test}    run    ${FALSE}
    RETURN    ${value}


Get Test Value
    [Arguments]    ${tests_dict}    ${test}    ${key}
    ${test}=    Get From Dictionary    ${tests_dict}    ${test}
    ${value}=    Get From Dictionary    ${test}    ${key}
    RETURN    ${value}

Get Test Outputs
    [Arguments]    ${tests_dict}    ${test}
    ${outputs}=    Get Test Value    ${tests_dict}    ${test}    outputs
    RETURN    ${outputs}

Set Test Value
    [Arguments]    ${tests_dict}    ${test_id}    ${key}    ${value}
    ${test}=    Get From Dictionary    ${tests_dict}    ${test_id}
    Set To Dictionary    ${test}    ${key}=${value}
    Set To Dictionary    ${tests_dict}    ${test_id}=${test}

Set Test Outputs
    [Arguments]    ${tests_dict}    ${test}    ${value}
    Set Test Value    ${tests_dict}    ${test}    outputs    ${value}

*** Keywords ***
Will Test Be Run Regex
    [Arguments]    ${dict}    ${pattern}
    FOR    ${key}    IN    @{dict.keys()}
        ${match}=    Evaluate    re.search(r"""${pattern}""", """${key}""")    re
        IF    $match is not ${None}
            ${id}=    Evaluate    $match.string
            ${run}=    Will Test Be Run    ${TESTS_TO_RUN}    ${id}
            IF    ${run}    RETURN    ${TRUE}
        END
    END
    RETURN    ${FALSE}