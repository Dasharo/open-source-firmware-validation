*** Keywords ***
Depends On Variable
    [Documentation]    Skips the test if ``variable`` does not exist.
    [Arguments]    ${variable}
    ${variable_exists}=    Run Keyword And Return Status    Variable Should Exist    ${variable}
    Depends On    ${variable_exists}    Variable: ${variable} is not defined

Depends On
    [Documentation]    Skips test if ``condition`` is not met. Test identifier
    ...    (first word of its name) and optional ``reason`` is set
    ...    to the test as per ``Skip`` keyword.
    [Arguments]    ${condition}    ${reason}=${NONE}
    VAR    ${line}=    ${TEST_NAME.split()}[0] not supported
    IF    "${reason}" != "${NONE}"
        VAR    ${line}=    ${line}: ${reason}
    END
    ${should_skip}=    Evaluate    not bool(${condition})
    Skip If    ${should_skip}    ${line}

Should Run Semiauto Tests
    [Documentation]    Semiauto tests should only be run if the `semiauto` tag
    ...    is explicitly given. Only fully automated tests should run by default.
    ${semiauto_should_run}=    Evaluate
    ...    ${INCLUDE_TAGS} is not @{EMPTY} and 'semiauto' in ${INCLUDE_TAGS}
    RETURN    ${semiauto_should_run}
