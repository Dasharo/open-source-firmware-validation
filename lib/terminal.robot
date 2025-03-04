*** Settings ***
Documentation       Generic keywords for reading/writing into terminal.

Library             Collections
Library             String
Library             Telnet
Library             SSHLibrary
Resource            ../pikvm-rest-api/pikvm_comm.robot
Resource            bios/menus.robot


*** Keywords ***
Set Prompt For Terminal
    [Documentation]
    ...    Universal keyword to set the prompt (used in ``Read Until Prompt``
    ...    keyword) regardless of the used method of
    ...    connection to the DUT.
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    ``${prompt}``: ``string`` - The prompt text
    ...
    ...    === Return Value ===
    ...    None
    ...
    ...    === Effects ===
    ...    The prompt is changed in the currently used connection library
    ...    according to ``${DUT_CONNECTION_METHOD}`` platform config
    ...    variable.
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
    [Documentation]
    ...    Universal keyword to set the timeout (used for operations
    ...    that expect some output to appear) regardless of the
    ...    used method of connection to the DUT.
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    ``${timeout}``: ``string`` - The time in Robot Framework time format
    ...
    ...    === Return Value ===
    ...    None
    ...
    ...    === Effects ===
    ...    The timeout is changed in the currently used connection library
    ...    according to ``${DUT_CONNECTION_METHOD}`` platform config
    ...    variable.
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
    [Documentation]
    ...    Universal keyword to read the console output regardless
    ...    of the used method of connection to the DUT.
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    None
    ...
    ...    === Return Value ===
    ...    ``string`` - All the text from the terminal buffer, from the last
    ...    time it was cleared, up to the moment the keyword is called
    ...
    ...    === Effects ===
    ...    The terminal buffer is read and consequently cleared
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
    [Documentation]
    ...    Universal keyword to read the console output until the
    ...    defined text occurs regardless of the used method of
    ...    connection to the DUT.
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    ``${expected}``: ``string`` - The text up to which the terminal
    ...    will be read
    ...
    ...    === Return Value ===
    ...    ``string`` - All the text from the terminal buffer, from the last
    ...    time it was cleared, up to the moment ``${expected}`` is found, or
    ...    the timeout passes
    ...
    ...    === Effects ===
    ...    The terminal buffer is read and consequently cleared up until
    ...    ${expected}. Everything after ``${expected}`` stays in the buffer.
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
    [Documentation]
    ...    Universal keyword to read the console output until the
    ...    defined prompt occurs regardless of the used method of
    ...    connection to the DUT.
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    None
    ...
    ...    === Return Value ===
    ...    ``string`` - All the text from the terminal buffer, from the last
    ...    time it was cleared, up to the moment the prompt is found, or
    ...    the timeout passes
    ...
    ...    === Effects ===
    ...    The terminal buffer is read and consequently cleared
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
    [Documentation]
    ...    Universal keyword to read the console output until the
    ...    defined regexp occurs regardless of the used method of
    ...    connection to the DUT.
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    ``${regexp}``: ``string`` - The regular expression up to which the
    ...    terminal will be read
    ...
    ...    === Return Value ===
    ...    ``string`` - All the text from the terminal buffer, from the last
    ...    time it was cleared, up to the moment ``${regexp}`` is matched, or
    ...    the timeout passes
    ...
    ...    === Effects ===
    ...    The terminal buffer is read and consequently cleared up until
    ...    the matched ``${regex}``. Everything after the match stays in the
    ...    buffer.
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
    [Documentation]
    ...    Universal keyword to write text and a newline to console regardless
    ...    of the used method of connection to the DUT.
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    ``${text}``: ``string`` - The text to write
    ...
    ...    === Return Value ===
    ...    None
    ...
    ...    === Effects ===
    ...    The ``${text}`` is written to the terminal, followed by a newline
    ...    character
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
    ...    connection to the DUT.
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    ``${text}``: ``string`` - The text to write
    ...
    ...    === Return Value ===
    ...    None
    ...
    ...    === Effects ===
    ...    The ``${text}`` is written to the terminal
    [Arguments]    ${text}    ${interval}=None
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
    ...    used method of connection to the DUT (Telnet or SSH). The DUT Response
    ...    Timeout is changed to ``${timeout}`` and not restored.
    ...
    ...    === Requirements ===
    ...    The command prompt has to be set using ``Set Prompt For Terminal``
    ...
    ...    === Arguments ===
    ...    - ``${command}``: ``string`` - The command to execute
    ...    - ``${timeout}``: ``string`` = ``30s`` - The DUT Response Timeout for
    ...    \ executing the command
    ...
    ...    === Return Value ===
    ...    ``string`` - The full command output, or up to the time ``${timeout}``
    ...    passes.
    ...
    ...    === Effects ===
    ...    The ``${command}`` is written to the terminal and the keyword waits
    ...    until the execution ends or ``${timeout}`` passes.
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

Execute UEFI Shell Command
    [Documentation]
    ...    Executes a command in UEFI Shell. Adds some delays to be more
    ...    reliable in the UEFI Shell.
    ...
    ...    === Requirements ===
    ...    - The UEFI shell has to be entered first.
    ...    - The command prompt has to be set using ``Set Prompt For Terminal``
    ...
    ...    === Arguments ===
    ...    - ``${command}``: ``string`` - The command to execute
    ...    - ``${timeout}``: ``string`` = ``30s`` - The DUT Response Timeout for
    ...    \ executing the command
    ...    - ``${uefi_shell_input_latency}``: ``integer`` - additional delay
    ...    \ in milliseconds for every entered character. Used to make sure the
    ...    \ whole command is written down before pressing ``Enter``, as the
    ...    \ UEFI shell might sometimes be slow to register the input.
    ...
    ...    === Return Value ===
    ...    ``string`` - The full command output, or up to the time ``${timeout}``
    ...    passes.
    ...
    ...    === Effects ===
    ...    The ``${command}`` is written to the terminal and the keyword waits
    ...    until the execution ends or ``${timeout}`` passes.
    [Arguments]    ${command}    ${timeout}=30s    ${uefi_shell_input_latency}=10
    Set DUT Response Timeout    ${timeout}
    ${length}=    Get Length    ${command}
    ${input_delay}=    Evaluate    ${length} * ${uefi_shell_input_latency}
    Write Bare Into Terminal    ${command}
    Sleep    ${input_delay}ms
    Press Enter
    ${output}=    Read From Terminal Until Prompt
    RETURN    ${output}
