*** Settings ***
Library     TelnetLibrary    timeout=20 seconds    connection_timeout=120 seconds
Library     event_log_banks.py
Resource    terminal.robot
Resource    tpm.robot


*** Keywords ***
TrenchBoot Telnet Root Login
    [Documentation]    Telnet login for Trenchboot
    # The login is password-less which makes use of TelnetLibrary.Login very
    # inconvenient.
    TelnetLibrary.Set Prompt    root@tb:~#
    TelnetLibrary.Set Timeout    120s
    TelnetLibrary.Read Until    login:
    TelnetLibrary.Write    root
    # Try to work around prompt detection issues by first matching on a single
    # character.
    TelnetLibrary.Set Prompt    \#
    TelnetLibrary.Read Until Prompt
    # Now set the real prompt and tell dmesg to shut up.
    TelnetLibrary.Set Prompt    root@tb:~#
    Execute Command In Terminal    dmesg -n1

Validate DRTM PCRs Against Event Log
    [Documentation]    Replays the DRTM event log at \${eventlog} for each PCR
    ...    in \@{pcrs} and each bank in \${algos}, and compares the result with
    ...    the PCR value in sysfs. By default the banks are the active ones,
    ...    and a bank the log has no events in for a PCR is logged as a
    ...    warning. A bank passed in \${algos} must be active and have events
    ...    for every PCR in the log. Fails when no PCR was compared at all.
    [Arguments]    @{pcrs}
    ...    ${eventlog}=/sys/kernel/security/slaunch/eventlog
    ...    ${algos}=${NONE}
    Execute Command In Terminal Should Succeed
    ...    tpm2_eventlog '${eventlog}' > /tmp/event-log
    VAR    ${required}=    ${{$algos is not None}}
    @{active}=    Get Active PCR Banks
    IF    not ${required}
        VAR    ${algos}=    ${active}
    END
    # This extracts hashes for a combination of a PCR (first parameter) and an
    # algorithm (second parameter). The printed line have the form
    #    {event data length}-{digest}
    # to make it possible to ignore some events based on a combination of these
    # fields.
    #
    # Backslash in front of some dollar signs is escaping AWK fields while
    # unescaped ones are parameters of this function that get embedded into
    # AWK script. The escaping is doubled because Robot Framework also
    # interprets escapes.
    VAR    ${hashes_func}=
    ...    function hashes() {
    ...    awk "/PCRIndex:/{ pcr = \\$2; alg = \\"\\"; digest = \\"\\" }
    ...    /- AlgorithmId:/{ alg = \\$3 }
    ...    /Digest:/{ if (alg == \\"$2\\") digest = substr(\\$2, 2, length(\\$2) - 2) }
    ...    /EventSize:/{ if (pcr == $1 && length(digest) != 0) print \\$2 \\"-\\" digest }"
    ...    /tmp/event-log;
    ...    }
    ...    separator=${SPACE}
    Execute Command In Terminal    ${hashes_func}

    Execute Command In Terminal
    ...    function extend() { pcr=$(echo -n "$pcr$2" | xxd -r -p | $1sum | cut -f1 -d' '); }
    VAR    ${compared}=    ${0}
    FOR    ${algo}    IN    @{algos}
        IF    $algo not in $active
            Fail    The ${algo} bank is not active, the active banks are ${active}
        END

        FOR    ${pcr}    IN    @{pcrs}
            ${events}=    Execute Command In Terminal
            ...    hashes ${pcr} ${algo} | wc -l
            IF    ${events} == 0 and ${required}
                Fail    ${eventlog} has no PCR-${pcr} events in the ${algo} bank
            ELSE IF    ${events} == 0
                Log    ${eventlog} has no PCR-${pcr} events in the active ${algo} bank    WARN
                CONTINUE
            END
            # Replaying the log skips digests of no data. These correspond to
            # informational markers which don't extend PCRs.
            VAR    ${replay_pcr}=
            ...    empty=$(${algo}sum < /dev/null | cut -f1 -d' ');
            ...    pcr=\${empty//?/0};
            ...    for line in $(hashes ${pcr} ${algo}); do
            ...    len=\${line%-*};
            ...    hash=\${line#*-};
            ...    if [ "\${hash^^*}" != "\${empty^^*}" -o "$len" -ne 0 ]; then extend ${algo} "$hash"; fi;
            ...    done;
            ...    echo "$pcr"
            ...    separator=${SPACE}
            ${expected}=    Execute Command In Terminal    ${replay_pcr}
            ${actual}=    Execute Command In Terminal
            ...    cat /sys/class/tpm/tpm0/pcr-${algo}/${pcr}
            Should Be Equal As Strings    ${actual}    ${expected}
            ...    PCR-${pcr} ${algo} doesn't match
            ...    ignore_case=${TRUE}
            ${compared}=    Evaluate    ${compared} + 1
        END
    END
    IF    ${compared} == 0
        Fail    ${eventlog} replays none of PCRs ${pcrs} in the banks ${algos}
    END

DRTM Event Log Should Cover Banks
    [Documentation]    Fails when the DRTM event log at \${eventlog} does not
    ...    cover every bank in \${banks}, the active ones by default: its
    ...    Spec ID event must list the bank, and every event for a PCR in
    ...    \@{pcrs} that extends a PCR must have a digest in it. A log that
    ...    misses an active bank cannot be replayed in it, so the replay checks
    ...    have nothing to compare that bank with.
    [Arguments]    @{pcrs}
    ...    ${eventlog}=/sys/kernel/security/slaunch/eventlog
    ...    ${banks}=${NONE}
    IF    $banks is None
        ${banks}=    Get Active PCR Banks
    END
    ${tpm2_eventlog}=    Execute Command In Terminal
    ...    tpm2_eventlog '${eventlog}'
    Should Not Contain    ${tpm2_eventlog}    ERROR:
    Event Log Should Cover Banks    ${tpm2_eventlog}    ${pcrs}    ${banks}
