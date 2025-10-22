*** Settings ***
Library     Collections
Library     DateTime


*** Variables ***
&{PARALLEL_TESTS}=      &{EMPTY}
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

Check Parallel Test Supported
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

Check Parallel Test Supported Regex
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
            ${run}=    Check Parallel Test Supported    ${id}
            IF    ${run}    RETURN    ${TRUE}
        END
    END

Skip If Parallel Test Not Supported
    [Documentation]    Skips execution if the parallel test context shows that
    ...    the test should be skipped. Configured using `Add Parallel Test Skip Condition`.
    [Arguments]    ${test_id}
    ${will_be_run}=    Check Parallel Test Supported    ${test_id}
    ${reason}=    Get Parallel Test Value    ${test_id}    skip_reason
    Skip If    not $will_be_run    ${reason}

Skip If Parallel Test Not Supported Regex
    [Documentation]    Skips execution if the parallel test context shows that
    ...    the test should be skipped. Configured using `Add Parallel Test Skip Condition`.
    [Arguments]    ${pattern}    ${reason}=${None}
    ${will_be_run}=    Check Parallel Test Supported Regex    ${pattern}
    Skip If    not $will_be_run    ${reason}
    RETURN    ${FALSE}

Will Parallel Test Be Run
    [Documentation]    Returns TRUE/FALSE if the parallel test case is supported =
    ...    and was not run already.
    ...    Helpful for determining whether a preparation step should be run by
    ...    checking if any test from a group of tests will be run.
    ...    Configured using `Add Parallel Test Skip Condition`.
    [Arguments]    ${test_id}
    ${run}=    Check Parallel Test Supported    ${test_id}
    ${outputs}=    Get Parallel Test Outputs    ${test_id}
    IF    ${run} and $outputs != ${None}   RETURN    ${TRUE}
    RETURN    ${FALSE}

Will Parallel Test Be Run Regex
    [Documentation]    Returns TRUE/FALSE if any parallel test case, the name of
    ...    which matches a given regular expression, is supported and was not
    ...    run already.
    ...    Helpful for determining whether a preparation step should be run by
    ...    checking if any test from a group of tests will be run.
    ...    Configured using `Add Parallel Test Skip Condition`.
    [Arguments]    ${pattern}
    FOR    ${key}    IN    @{PARALLEL_TESTS.keys()}
        ${match}=    Evaluate    re.search(r"""${pattern}""", """${key}""")    re
        IF    $match is not ${None}
            ${id}=    Evaluate    $match.string
            ${run}=    Check Parallel Test Supported    ${id}
            ${outputs}=    Get Parallel Test Outputs    ${id}
            IF    ${run} and $outputs != ${None}   RETURN    ${TRUE}
        END
    END
    RETURN    ${FALSE}

Skip If Parallel Test Wont Be Run
    [Documentation]    Skips execution if the parallel test context shows that
    ...    the test should be skipped or the test was already run.
    ...    Configured using `Add Parallel Test Skip Condition`.
    [Arguments]    ${test_id}    ${reason}=${None}
    ${will_be_run}=    Will Parallel Test Be Run    ${test_id}
    Skip If    not $will_be_run    ${reason}
    RETURN    ${FALSE}

Skip If Parallel Test Wont Be Run Regex
    [Documentation]    Skips execution if the parallel test context shows that
    ...    the test should be skipped or the test was already run.
    ...    Configured using `Add Parallel Test Skip Condition`.
    [Arguments]    ${pattern}    ${reason}=${None}
    ${will_be_run}=    Will Parallel Test Be Run Regex    ${pattern}
    Skip If    not $will_be_run    ${reason}
    RETURN    ${FALSE}

Get Parallel Test Value
    [Documentation]    Returns a value for a given key in a parallel test context.
    [Arguments]    ${test}    ${key}
    ${test}=    Get From Dictionary    ${PARALLEL_TESTS}    ${test}
    ${value}=    Get From Dictionary    ${test}    ${key}    ${EMPTY}
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
    VAR    @{tests}=    @{EMPTY}
    FOR    ${key}    IN    @{PARALLEL_TESTS.keys()}
        VAR    ${run}=    ${PARALLEL_TESTS["${key}"]["run"]}
        IF    ${run}    Append To List    ${tests}    ${key}
    END
    RETURN    ${tests}

Copy Parallel Test Outputs
    [Documentation]    Copies the outputs of one test to another.
    ...    Useful when both can be verified using the same logs.
    [Arguments]    ${test_id_source}    ${test_id_dest}
    ${outs}=    Get Parallel Test Outputs    ${test_id_source}
    Set Parallel Test Outputs    ${test_id_dest}    ${outs}

Print Parallel Tests Summary
    [Documentation]    Prints the summary of Parallel tests to be run
    # Log to console to inform tester about the scope
    Log To Console    Tests to run:
    ${tests}=    Get Parallel Tests To Run
    Log To Console    ${tests}