*** Settings ***
Library     Telnet    timeout=20 seconds    connection_timeout=120 seconds
Resource    terminal.robot


*** Keywords ***
TrenchBoot Telnet Root Login
    [Documentation]    Telnet login for Trenchboot
    # The login is password-less which makes use of Telnet.Login very
    # inconvenient.
    Telnet.Set Prompt    root@tb:~#
    Telnet.Read Until    login:
    Telnet.Write    root
    # Try to work around prompt detection issues by first matching on a single
    # character.
    Telnet.Set Prompt    \#
    Telnet.Read Until Prompt
    # Now set the real prompt and tell dmesg to shut up.
    Telnet.Set Prompt    root@tb:~#
    Execute Command In Terminal    dmesg -n1

Validate DRTM PCRs Against Event Log
    [Documentation]    Validates DRTM PCRs Against Event Log
    [Arguments]    @{pcrs}
    Execute Command In Terminal
    ...    tpm2_eventlog /sys/kernel/security/slaunch/eventlog > /tmp/event-log
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
    FOR    ${algo}    IN    sha1    sha256
        ${algo_present}=    Execute Command In Terminal
        ...    test -d /sys/class/tpm/tpm0/pcr-${algo} && echo y
        IF    '''${algo_present}''' != 'y'    CONTINUE

        FOR    ${pcr}    IN    @{pcrs}
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
        END
    END
