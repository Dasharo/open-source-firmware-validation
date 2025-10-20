*** Settings ***
Library    DateTime
Library    Collections

*** Variables ***
&{PARALLEL_TESTS}=    &{EMPTY}
${PARALLEL_TEST_ID}=    ${EMPTY}

*** Keywords ***
Init Parallel Testing
    [Documentation]    Initializes variables used by the parallel testing library.
    ...    Needs to be called before any other library keyword is called.
    VAR    &{PARALLEL_TESTS}=    &{EMPTY}    scope=GLOBAL
    VAR    ${PARALLEL_TEST_ID}=    ${EMPTY}    scope=GLOBAL

Wait Until Time
    [Documentation]    Sleeps until given DateTime is reached.
    ...    Not accurate, will most likely wait a bit more, but never less than required.
    [Arguments]    ${target}
    ${now}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S.%f
    ${diff}=    Subtract Date From Date    ${target}    ${now}    result_format=number
    ${sleep}=    Evaluate    max(min(${diff}, 0.1), 0.01)
    Sleep    ${sleep}

Add Parallel Test Skip Condition
    [Documentation]    Creates a parallel test context if does not exist.
    ...    Verifies a skip condition immediately and saves the skip state and
    ...    a skip reason if the skip condition is true.
    [Arguments]    ${condition}    ${skip_reason}
    # [Globals]    ${TESTS_TO_RUN}    ${TEST_ID}
    ${current_details}=    Get From Dictionary    ${PARALLEL_TESTS}    ${PARALLEL_TEST_ID}    default=${FALSE}
    IF    not ${current_details}
        VAR    &{support_details}=    test=${PARALLEL_TEST_ID}    run=${TRUE}    skip_reason=supported
    ELSE
        VAR    ${support_details}=    ${current_details}
    END
    ${run}=    Get From Dictionary    ${support_details}    run
    IF    ${run} and (${condition})
        Set To Dictionary    ${support_details}    run=${FALSE}    skip_reason=${skip_reason}
    END
    Set To Dictionary    ${PARALLEL_TESTS}    ${PARALLEL_TEST_ID}=${support_details}

Skip If Parallel Test Not Supported
    [Documentation]    Skips execution if the parallel test context shows that
    ...    the test should be skipped. Configured using `Add Parallel Test Skip Condition`.
    [Arguments]    ${test_id}
    ${will_be_run}=    Will Parallel Test Be Run    ${test_id}
    ${reason}=    Get Parallel Test Value    ${test_id}    skip_reason
    Skip If    not $will_be_run    ${reason}

Will Parallel Test Be Run
    [Documentation]    Returns TRUE/FALSE if the given parallel test case will
    ...    be run. Configured using `Add Parallel Test Skip Condition`.
    [Arguments]    ${test_id}
    ${test}=    Get From Dictionary    ${PARALLEL_TESTS}    ${test_id}    ${None}
    IF    $test is ${None}
        Log    Test ${test_id} not found
        RETURN    ${FALSE}
    END
    ${value}=    Get From Dictionary    ${test}    run    ${FALSE}
    RETURN    ${value}

Get Parallel Test Value
    [Documentation]    Returns a value for a given key in a parallel test context.
    [Arguments]    ${test}    ${key}
    ${test}=    Get From Dictionary    ${PARALLEL_TESTS}    ${test}
    ${value}=    Get From Dictionary    ${test}    ${key}
    RETURN    ${value}

Get Parallel Test Outputs
    [Documentation]    Returns the value of `outputs` key of a parallel test context.
    [Arguments]    ${test_id}
    ${outputs}=    Get Parallel Test Value    ${test_id}    outputs
    RETURN    ${outputs}

Set Parallel Test Value
    [Documentation]    Sets the value of a given key for a parallel test context.
    [Arguments]    ${test_id}    ${key}    ${value}
    ${test}=    Get From Dictionary    ${PARALLEL_TESTS}    ${test_id}
    Set To Dictionary    ${test}    ${key}=${value}
    Set To Dictionary    ${PARALLEL_TESTS}    ${test_id}=${test}

Set Parallel Test Outputs
    [Documentation]    Sets the value of `output` key for a parallel test context.
    [Arguments]    ${test}    ${value}
    Set Parallel Test Value    ${test}    outputs    ${value}

Get Parallel Tests To Run
    [Documentation]    Returns a list of all the parallel test cases that are
    ...    to be run according to their skip conditions.
    ...    Configured using `Add Parallel Test Skip Condition`.
    ${tests}=    Create List
    FOR    ${key}    IN    @{PARALLEL_TESTS.keys()}
        VAR    ${run}=    ${PARALLEL_TESTS["${key}"]["run"]}
        IF    ${run}    Append To List    ${tests}    ${key}
    END
    RETURN    ${tests}

Will Parallel Test Be Run Regex
    [Documentation]    Returns TRUE/FALSE if any parallel test case, the name of
    ...    which matches a given regular expression, will be run.
    ...    Helpful for determining whether a preparation step should be run by
    ...    checking if any test from a group of tests will be run.
    ...    Configured using `Add Parallel Test Skip Condition`.
    [Arguments]    ${pattern}
    FOR    ${key}    IN    @{PARALLEL_TESTS.keys()}
        ${match}=    Evaluate    re.search(r"""${pattern}""", """${key}""")    re
        IF    $match is not ${None}
            ${id}=    Evaluate    $match.string
            ${run}=    Will Parallel Test Be Run    ${id}
            IF    ${run}    RETURN    ${TRUE}
        END
    END
    RETURN    ${FALSE}