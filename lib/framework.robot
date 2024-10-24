*** Keywords ***
Depends On Variable
    [Documentation]    Skips the test if ``variable`` does not exist.
    [Arguments]    ${variable}
    ${variable_exists}=    Run Keyword And Return Status    Variable Should Exist    ${variable}
    Depends On    ${variable_exists}    Variable: ${variable} is not defined

Depends On
    [Documentation]    Skips test if ``condition`` is not met. Test identifier
    ...    (first word of its name) and optional ``reason`` is set
    ...    to the test as per ```Skip`` keyword.
    [Arguments]    ${condition}    ${reason}=${NONE}
    ${line}=    Set Variable    ${TEST_NAME.split()}[0] not supported
    IF    '${reason}' != ${NONE}
        ${line}=    Set Variable    ${line}: ${reason}
    END
    Skip If    not ${condition}    ${line}
