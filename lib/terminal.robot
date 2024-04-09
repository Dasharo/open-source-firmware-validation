*** Settings ***
Documentation       Generic keywords for reading/writing into terminal.

Library             Collections
Library             String


*** Keywords ***
Set Prompt For Terminal
    [Documentation]    Universal keyword to set the prompt (used in Read Until
    ...    prompt keyword) regardless of the used method of
    ...    connection to the DUT (Telnet or SSH).
    [Arguments]    ${prompt}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Telnet.Set Prompt    ${prompt}    prompt_is_regexp=False
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        SSHLibrary.Set Client Configuration    prompt=${prompt}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        SSHLibrary.Set Client Configuration    prompt=${prompt}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Telnet.Set Prompt    ${prompt}
    ELSE
        FAIL    Unknown connection method: ${DUT_CONNECTION_METHOD}
    END

Set DUT Response Timeout
    [Documentation]    Universal keyword to set the timeout (used for operations
    ...    that expect some output to appear) regardless of the
    ...    used method of connection to the DUT (Telnet or SSH).
    [Arguments]    ${timeout}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Telnet.Set Timeout    ${timeout}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        SSHLibrary.Set Client Configuration    timeout=${timeout}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        SSHLibrary.Set Client Configuration    timeout=${timeout}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Telnet.Set Timeout    ${timeout}
    ELSE
        FAIL    Unknown connection method: ${DUT_CONNECTION_METHOD}
    END

Read From Terminal
    [Documentation]    Universal keyword to read the console output regardless
    ...    of the used method of connection to the DUT
    ...    (Telnet or SSH).
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        ${output}=    Telnet.Read
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        ${output}=    SSHLibrary.Read
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        ${output}=    SSHLibrary.Read
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        ${output}=    Telnet.Read
    ELSE
        ${output}=    FAIL    Unknown connection method: ${DUT_CONNECTION_METHOD}
    END
    RETURN    ${output}

Read From Terminal Until
    [Documentation]    Universal keyword to read the console output until the
    ...    defined text occurs regardless of the used method of
    ...    connection to the DUT (Telnet or SSH).
    [Arguments]    ${expected}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        ${output}=    Telnet.Read Until    ${expected}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        ${output}=    SSHLibrary.Read Until    ${expected}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        ${output}=    SSHLibrary.Read Until    ${expected}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        ${output}=    Telnet.Read Until    ${expected}
    ELSE
        ${output}=    FAIL    Unknown connection method: ${DUT_CONNECTION_METHOD}
    END
    RETURN    ${output}

Read From Terminal Until Prompt
    [Documentation]    Universal keyword to read the console output until the
    ...    defined prompt occurs regardless of the used method of
    ...    connection to the DUT (Telnet or SSH).
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH' or '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        ${output}=    SSHLibrary.Read Until Prompt    strip_prompt=${TRUE}
        ${output}=    Strip String    ${output}    characters=\n\r
    ELSE
        IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
            ${output}=    Telnet.Read Until Prompt    strip_prompt=${TRUE}
        ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
            ${output}=    Telnet.Read Until Prompt    strip_prompt=${TRUE}
        ELSE
            ${output}=    FAIL    Unknown connection method: ${DUT_CONNECTION_METHOD}
        END
    END
    # Drop last newline, if any
    ${output}=    Strip String    ${output}    mode=right    characters=\n\r
    RETURN    ${output}

Read From Terminal Until Regexp
    [Documentation]    Universal keyword to read the console output until the
    ...    defined regexp occurs regardless of the used method of
    ...    connection to the DUT (Telnet or SSH).
    [Arguments]    ${regexp}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        ${output}=    Telnet.Read Until Regexp    ${regexp}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        ${output}=    SSHLibrary.Read Until Regexp    ${regexp}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        ${output}=    SSHLibrary.Read Until Regexp    ${regexp}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        ${output}=    Telnet.Read Until Regexp    ${regexp}
    ELSE
        ${output}=    FAIL    Unknown connection method: ${DUT_CONNECTION_METHOD}
    END
    RETURN    ${output}

Write Into Terminal
    [Documentation]    Universal keyword to write text to console regardless of
    ...    the used method of connection to the DUT (Telnet, PiKVM or SSH).
    [Arguments]    ${text}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Telnet.Write    ${text}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        SSHLibrary.Write    ${text}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        SSHLibrary.Write    ${text}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Write PiKVM    ${text}
    ELSE
        FAIL    Unknown connection method: ${DUT_CONNECTION_METHOD}
    END

Write Bare Into Terminal
    [Documentation]    Universal keyword to write bare text (without new line
    ...    mark) to console regardless of the used method of
    ...    connection to the DUT (Telnet, PiKVM or SSH).
    [Arguments]    ${text}    ${interval}=${NULL}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Telnet.Write Bare    ${text}    ${interval}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        SSHLibrary.Write Bare    ${text}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'open-bmc'
        SSHLibrary.Write Bare    ${text}
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Write Bare PiKVM    ${text}
    ELSE
        FAIL    Unknown connection method: ${DUT_CONNECTION_METHOD}
    END

Execute Command In Terminal
    [Documentation]    Universal keyword to execute command regardless of the
    ...    used method of connection to the DUT (Telnet or SSH).
    [Arguments]    ${command}    ${timeout}=30s
    Set DUT Response Timeout    ${timeout}
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        ${output}=    Telnet.Execute Command    ${command}    strip_prompt=True
    ELSE
        Write Into Terminal    ${command}
        ${output}=    Read From Terminal Until Prompt
    END
    # Drop last newline, if any
    ${output}=    Strip String    ${output}    mode=right    characters=\n\r
    RETURN    ${output}
