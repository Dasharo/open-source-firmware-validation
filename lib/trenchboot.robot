*** Settings ***
Library     Collections
Library     TelnetLibrary    timeout=20 seconds    connection_timeout=120 seconds
Library     event_log_banks.py
Library     slaunch_event_log.py
Library     tpm_quote.py
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
    ...    \${timeout} is the DUT Response Timeout of each command, which a
    ...    slow platform needs longer to replay a PCR of many events.
    [Arguments]    @{pcrs}
    ...    ${eventlog}=/sys/kernel/security/slaunch/eventlog
    ...    ${algos}=${NONE}
    ...    ${timeout}=30s
    Execute Command In Terminal Should Succeed
    ...    tpm2_eventlog '${eventlog}' > /tmp/event-log
    ...    timeout=${timeout}
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
    Execute Command In Terminal    ${hashes_func}    ${timeout}

    Execute Command In Terminal
    ...    function extend() { pcr=$(echo -n "$pcr$2" | xxd -r -p | $1sum | cut -f1 -d' '); }
    ...    ${timeout}
    VAR    ${compared}=    ${0}
    FOR    ${algo}    IN    @{algos}
        IF    $algo not in $active
            Fail    The ${algo} bank is not active, the active banks are ${active}
        END

        FOR    ${pcr}    IN    @{pcrs}
            ${events}=    Execute Command In Terminal
            ...    hashes ${pcr} ${algo} | wc -l    ${timeout}
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
            ${expected}=    Execute Command In Terminal    ${replay_pcr}    ${timeout}
            ${actual}=    Execute Command In Terminal
            ...    cat /sys/class/tpm/tpm0/pcr-${algo}/${pcr}    ${timeout}
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

DRTM Event Log Should Follow Secure Launch Order
    [Documentation]    Fails when the PCR 17 and 18 events of the DRTM event
    ...    log at \${eventlog} do not have the types and order the launch and
    ...    TrenchBoot Linux log: the SINIT ACM events of Table 37 of the Intel
    ...    MLE Developer's Guide, or the events of the AMD Secure Kernel Loader,
    ...    then the kernel's measurements between its start and end markers.
    [Arguments]    ${eventlog}=/sys/kernel/security/slaunch/eventlog
    ${vendor}=    Get Secure Launch Vendor
    ${dump}=    Execute Command In Terminal
    ...    xxd -p '${eventlog}'
    Secure Launch Event Log Should Follow Order    ${dump}    ${vendor}

DRTM Event Log Should Match Measured Values
    [Documentation]    Fails when a digest of the DRTM event log at
    ...    \${eventlog} is not the hash of the value it measures, where the OS
    ...    knows that value: the Intel SINIT ACM events whose data is the
    ...    measured value, the kernel command line, and the initrd at
    ...    \${initrd} when it is set.
    [Arguments]    ${eventlog}=/sys/kernel/security/slaunch/eventlog
    ...    ${initrd}=${EMPTY}
    ${vendor}=    Get Secure Launch Vendor
    ${dump}=    Execute Command In Terminal
    ...    xxd -p '${eventlog}'
    ${cmdline}=    Execute Command In Terminal
    ...    xxd -p /proc/cmdline
    # hdr.cmdline_size of the Linux boot protocol, at offset 0x238 of the
    # boot parameters.
    ${cmdline_size}=    Execute Command In Terminal
    ...    xxd -p -s 0x238 -l 4 /sys/kernel/boot_params/data
    Should Match Regexp    ${cmdline_size}    ^[0-9a-f]{8}$
    ...    Cannot read hdr.cmdline_size: ${cmdline_size}
    VAR    &{initrd_digests}=    &{EMPTY}
    IF    $initrd
        FOR    ${algo}    IN    sha1    sha256
            ${digest}=    Execute Command In Terminal
            ...    ${algo}sum '${initrd}' | cut -f1 -d' '
            Should Match Regexp    ${digest}    ^[0-9a-f]+$
            ...    Cannot hash ${initrd}: ${digest}
            Set To Dictionary    ${initrd_digests}    ${algo}=${digest}
        END
    END
    Secure Launch Measurements Should Match
    ...    ${dump}    ${vendor}    ${cmdline}    ${cmdline_size}    ${initrd_digests}

Get Secure Launch Vendor
    [Documentation]    Returns intel or amd, from the vendor_id in
    ...    /proc/cpuinfo.
    ${vendor_id}=    Execute Command In Terminal
    ...    grep -m1 '^vendor_id' /proc/cpuinfo
    IF    'GenuineIntel' in $vendor_id    RETURN    intel
    IF    'AuthenticAMD' in $vendor_id    RETURN    amd
    Fail    No Secure Launch vendor for the CPU: ${vendor_id}

PCRs Should Be Zero In Every Active Bank
    [Documentation]    Fails when one of \@{pcrs} is not all zeros in an
    ...    active PCR bank.
    [Arguments]    @{pcrs}
    @{banks}=    Get Active PCR Banks
    FOR    ${bank}    IN    @{banks}
        FOR    ${pcr}    IN    @{pcrs}
            ${value}=    Execute Command In Terminal
            ...    cat /sys/class/tpm/tpm0/pcr-${bank}/${pcr}
            Should Match Regexp    ${value}    ^0+$
            ...    PCR ${pcr} ${bank} is ${value}, expected all zeros    values=False
        END
    END

DRTM TPM Quote Should Verify
    [Documentation]    The runner picks a 32-byte nonce, and the OS creates
    ...    an ECC EK, an ECDSA-SHA256 AK under it, and a quote of \@{pcrs}
    ...    in \${bank} with the nonce. The runner checks the quote's
    ...    signature with the AK and its PCR digest against the values the
    ...    OS reads from sysfs, and returns the TPMS_ATTEST as hex. The keys
    ...    are transient and the files are removed. \${timeout} is the DUT
    ...    Response Timeout of the key and quote commands, which a slow TPM
    ...    needs longer for.
    [Arguments]    ${bank}=sha256    ${pcrs}=${{["17", "18"]}}    ${timeout}=60s
    ${missing}=    Execute Command In Terminal
    ...    for c in tpm2_createek tpm2_createak tpm2_quote xxd; do command -v $c >/dev/null || echo $c; done
    Should Be Empty    ${missing}    The OS lacks the quote tools: ${missing}
    ${nonce}=    Evaluate    secrets.token_hex(32)    modules=secrets
    VAR    ${selection}=    @{pcrs}    separator=,
    VAR    ${dir}=    /tmp/drtm-quote
    VAR    ${quote}=
    ...    rm -rf ${dir} && mkdir ${dir} && ( cd ${dir}
    ...    && tpm2_createek -c ek.ctx -G ecc -u ek.pub
    ...    && tpm2_createak -C ek.ctx -c ak.ctx -G ecc -g sha256 -s ecdsa -u ak.pem -f pem -n ak.name
    ...    && tpm2_quote -c ak.ctx -l ${bank}:${selection} -q ${nonce} -g sha256 -m quote.msg -s quote.sig
    ...    > /dev/null )
    ...    separator=${SPACE}
    TRY
        Execute Command In Terminal Should Succeed    ${quote}    timeout=${timeout}
        ${attest}=    Execute Command In Terminal    xxd -p ${dir}/quote.msg | tr -d '\\n'
        ${signature}=    Execute Command In Terminal    xxd -p ${dir}/quote.sig | tr -d '\\n'
        ${ak}=    Execute Command In Terminal    xxd -p ${dir}/ak.pem | tr -d '\\n'
    FINALLY
        Execute Command In Terminal    rm -rf ${dir}
    END
    VAR    &{values}=    &{EMPTY}
    FOR    ${pcr}    IN    @{pcrs}
        ${value}=    Execute Command In Terminal
        ...    cat /sys/class/tpm/tpm0/pcr-${bank}/${pcr}
        Should Match Regexp    ${value}    ^[0-9A-Fa-f]+$
        ...    Cannot read PCR ${pcr} ${bank}: ${value}
        Set To Dictionary    ${values}    ${pcr}=${value}
    END
    ${summary}=    Quote Should Verify With AK    ${attest}    ${signature}    ${ak}    ${nonce}
    ...    ${bank}    ${values}
    Log    ${summary}
    RETURN    ${attest}

PCR Extend From OS Should Be Refused
    [Documentation]    Tries to extend each of \@{pcrs} in \${bank} from the
    ...    OS with tpm2_pcrextend, and fails when the TPM accepts one: the
    ...    command succeeds or the PCR changes. A refused extend leaves the
    ...    PCR as it was; an accepted one changes it, so the PCRs no longer
    ...    replay from the DRTM event log after this keyword.
    [Arguments]    @{pcrs}    ${bank}=sha256
    ${missing}=    Execute Command In Terminal
    ...    command -v tpm2_pcrextend >/dev/null || echo tpm2_pcrextend
    Should Be Empty    ${missing}    The OS lacks tpm2_pcrextend
    @{banks}=    Get Active PCR Banks
    IF    $bank not in $banks
        Fail    The ${bank} bank is not active, the active banks are ${banks}
    END
    ${digest}=    Evaluate    hashlib.new($bank, b"WTD012.001").hexdigest()    modules=hashlib
    VAR    @{accepted}=    @{EMPTY}
    FOR    ${pcr}    IN    @{pcrs}
        ${before}=    Execute Command In Terminal
        ...    cat /sys/class/tpm/tpm0/pcr-${bank}/${pcr}
        Should Match Regexp    ${before}    ^[0-9A-Fa-f]+$
        ...    Cannot read PCR ${pcr} ${bank}: ${before}
        ${out}=    Execute Command In Terminal
        ...    tpm2_pcrextend ${pcr}:${bank}=${digest} 2>&1; echo "rc=$?"
        ${after}=    Execute Command In Terminal
        ...    cat /sys/class/tpm/tpm0/pcr-${bank}/${pcr}
        ${succeeded}=    Evaluate    $out.strip().endswith("rc=0")
        IF    ${succeeded} or $before != $after
            Append To List    ${accepted}    PCR ${pcr} ${bank}: ${before} -> ${after}
        ELSE
            Log    PCR ${pcr} ${bank} extend refused: ${out}
        END
    END
    IF    $accepted
        Fail    The OS extended ${accepted} after the launch, the launch's write access stays open
    END
