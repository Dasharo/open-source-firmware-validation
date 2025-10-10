*** Settings ***
Resource    terminal.robot
Resource    ../keywords.robot


*** Keywords ***
Wait For Checkpoint
    [Documentation]    This KW waits for checkpoint (first argument) and logs
    ...    everything read up to the checkpoint. If regexp is ${True} then
    ...    treat checkpoint as regexp
    [Arguments]    ${checkpoint}    ${regexp}=${FALSE}
    IF    ${regexp}
        ${out}=    Read From Terminal Until Regexp    ${checkpoint}
    ELSE
        ${out}=    Read From Terminal Until    ${checkpoint}
    END
    Log    ${out}
    RETURN    ${out}

Wait For Checkpoint And Write Bare
    [Documentation]    This KW waits for checkpoint (first argument)
    ...    and writes specified answer (second argument), with logging all
    ...    output before the checkpoint.
    [Arguments]    ${checkpoint}    ${to_write}    ${regexp}=${FALSE}
    ${out}=    Wait For Checkpoint    ${checkpoint}    ${regexp}
    Sleep    1s
    Write Bare Into Terminal    ${to_write}
    RETURN    ${out}

Wait For Checkpoint And Write
    [Documentation]    This KW waits for checkpoint (first argument)
    ...    and writes specified answer (second argument), with logging all
    ...    output before the checkpoint.
    [Arguments]    ${checkpoint}    ${to_write}    ${regexp}=${FALSE}
    ${out}=    Wait For Checkpoint And Write Bare
    ...    ${checkpoint}    ${to_write}${ENTER}    ${regexp}
    Log    Waited for """${checkpoint}""" and written "${to_write}"
    RETURN    ${out}

Wait For Either Checkpoint And Write
    [Documentation]    Keywords waits for any of the ${checkpoints} key and if
    ...    it matches then writes value of this element to the console
    [Arguments]    ${bare}=${FALSE}    &{checkpoints}
    Log    Waiting for either checkpoint: ${checkpoints}
    ${out}=    Wait For Either Checkpoint    @{checkpoints}
    # Find which checkpoint we found
    Sleep    1s
    FOR    ${checkpoint}    ${write}    IN    &{checkpoints}
        IF    """${checkpoint}""" in """${out}"""
            IF    ${bare}
                Write Bare Into Terminal    ${checkpoints}[${checkpoint}]
            ELSE
                Write Into Terminal    ${checkpoints}[${checkpoint}]
            END
            Log    Waited for """${checkpoint}""" and written "${checkpoints}[${checkpoint}]"
            RETURN    ${out}
        END
    END

    # We shouldn't ever get here
    Fail    Couldn't find checkpoint in returned output

Wait For Either Checkpoint
    [Documentation]    Keywords waits for any of the ${checkpoints} and returns
    ...    console output to that point
    [Arguments]    @{checkpoints}
    VAR    ${regexp}=    ${EMPTY}
    # Iterate over keys (checkpoints)
    FOR    ${checkpoint}    IN    @{checkpoints}
        ${checkpoint_escaped}=    Evaluate
        ...    re.escape("""${checkpoint}""")
        VAR    ${regexp}=    ${regexp}${checkpoint_escaped}|
    END
    # Remove trailing |
    ${regexp}=    Get Substring    ${regexp}    0    -1
    ${out}=    Wait For Checkpoint    ${regexp}    ${TRUE}
    RETURN    ${out}

Wait For Checkpoint And Press Enter
    [Documentation]    This KW waits for checkpoint (first argument)
    ...    and preses enter, with logging all output before the checkpoint.
    [Arguments]    ${checkpoint}    ${regexp}=${FALSE}
    ${out}=    Wait For Checkpoint    ${checkpoint}    ${regexp}
    Sleep    1s
    Write Bare Into Terminal    ${ENTER}
    RETURN    ${out}

Wait For ME Warning Or Reboot
    [Documentation]    Helper keyword to deal with ME warning that shows up
    ...    during multiple workflows
    [Arguments]    ${skip_me}
    ${checkpoint}=    Wait For Either Checkpoint
    ...    ${DTS_ME_WARN}
    ...    Rebooting
    IF    """${DTS_ME_WARN}""" in """${checkpoint}"""
        IF    ${skip_me}
            Write Into Terminal    Y
            ${checkpoint2}=    Wait For Checkpoint    Rebooting in
            VAR    ${checkpoint}=    ${checkpoint}    ${checkpoint2}    separator=\n
        ELSE
            Fail    Cannot update Intel ME
        END
    END

    RETURN    ${checkpoint}

Add Checkpoint And Write
    [Documentation]    Add required checkpoint to list. ${checkpoints}
    ...    has to be list variable
    [Arguments]    ${checkpoints}    ${checkpoint}    ${to_write}    ${regexp}=${FALSE}    ${bare}=${FALSE}
    IF    ${bare} == ${FALSE}
        VAR    ${to_write}=    ${to_write}${ENTER}
    END
    Append To List    ${checkpoints}
    ...    ${{("""${checkpoint}""", """${to_write}""", """${regexp}""", "${TRUE}")}}

Add Optional Checkpoint And Write
    [Documentation]    Add optional checkpoint to list. ${checkpoints}
    ...    has to be list variable
    [Arguments]    ${checkpoints}    ${checkpoint}    ${to_write}    ${regexp}=${FALSE}    ${bare}=${FALSE}
    IF    ${bare} == ${FALSE}
        VAR    ${to_write}=    ${to_write}${ENTER}
    END
    Append To List    ${checkpoints}
    ...    ${{("""${checkpoint}""", """${to_write}""", """${regexp}""", "${FALSE}")}}

Wait For Checkpoints
    [Documentation]    Run checkpoint based workflow waiting for checkpoints
    ...    based on order they are defined. Optional checkpoints don't have to
    ...    be present to succeed. ${checkpoints} argument has to be created via
    ...    'Add Checkpoint' keywords. Last checkpoint has to be required one.
    [Arguments]    ${checkpoints}
    VAR    ${output}=    ${EMPTY}
    WHILE    ${checkpoints}
        VAR    @{wait_for_checkpoints}=    ${checkpoints}[0]
        Remove From List    ${checkpoints}    0
        # checkpoints format is a list of:
        # checkpoint, what to write, is what to write regexp, is it required
        WHILE    ${wait_for_checkpoints}[-1][-1] != ${TRUE}
            Append To List    ${wait_for_checkpoints}    ${checkpoints}[0]
            Remove From List    ${checkpoints}    0
        END

        # repeat until we deal with all checkpoints
        WHILE    ${wait_for_checkpoints}
            ${out}=    Wait For Either Checkpoint And Write
            ...    bare=${TRUE}
            ...    &{{{checkpoint[0]: checkpoint[1] for checkpoint in ${wait_for_checkpoints}}}}
            VAR    ${output}=    ${output}    ${out}    separator=${SPACE}
            WHILE    ${wait_for_checkpoints}
                IF    """${wait_for_checkpoints}[0][0]""" in """${out}"""
                    Log    Checkpoint reached: ${wait_for_checkpoints}[0][0]
                    Remove From List    ${wait_for_checkpoints}    0
                    BREAK
                ELSE
                    Remove From List    ${wait_for_checkpoints}    0
                END
            END
        END
    END
    RETURN    ${output}
