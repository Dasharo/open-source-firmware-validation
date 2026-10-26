# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Checks that a TCG crypto-agile event log covers a set of PCR banks.

Reads the YAML tpm2_eventlog prints. An event log that misses an active bank
cannot be replayed in that bank, so a verifier has nothing to compare the PCR
with, and the replay checks warn or skip instead of failing.
"""

import yaml

# Events of this type extend no PCR (TCG PC Client Platform Firmware Profile,
# section 10.4.1), so they need no digest in any bank.
EV_NO_ACTION = "EV_NO_ACTION"


def _parse(text):
    """Returns the events of the tpm2_eventlog output in text. Lines before
    the YAML document, such as the echoed command, are dropped."""
    lines = text.splitlines()
    start = next((i for i, line in enumerate(lines) if line.strip() == "---"), None)
    if start is None:
        raise AssertionError("tpm2_eventlog printed no YAML document")
    try:
        document = yaml.safe_load("\n".join(lines[start:]))
    except yaml.YAMLError as error:
        raise AssertionError(
            f"Cannot parse the tpm2_eventlog output: {error}"
        ) from None
    events = (document or {}).get("events") or []
    if not events:
        raise AssertionError("The event log has no events")
    return events


def _spec_id_algorithms(event):
    """Returns the algorithm names the Spec ID event lists, or None when the
    first event is no Spec ID Event03, so the log is not crypto-agile."""
    for spec in event.get("SpecID") or []:
        if spec.get("Signature") != "Spec ID Event03":
            continue
        # tpm2_eventlog prints each entry as "- Algorithm[0]:" with the
        # algorithmId at the same indent, so it lands next to that key, whose
        # value is null. Older versions may nest it, so read both.
        names = []
        for entry in spec.get("Algorithms") or []:
            nested = [value for value in entry.values() if isinstance(value, dict)]
            for algorithm in [entry, *nested]:
                if "algorithmId" in algorithm:
                    names.append(algorithm["algorithmId"])
        return names
    return None


def event_log_should_cover_banks(text, pcrs, banks):
    """Fails when the event log tpm2_eventlog printed as ${text} does not
    cover each bank in ${banks}: the Spec ID event must list the bank, and
    every event for a PCR in ${pcrs} that extends a PCR must have a digest in
    it. Fails when the log has no such event, so the check cannot pass on a
    log with nothing for those PCRs. Lists every event that lacks a bank.

    Arm's EVTYPE_ARM_NO_ACTION events print as "Unknown event type", so they
    are checked like events that extend a PCR."""
    pcrs = {int(pcr) for pcr in pcrs}
    banks = list(banks)
    events = _parse(text)

    algorithms = _spec_id_algorithms(events[0])
    if algorithms is None:
        raise AssertionError(
            "The event log does not start with a Spec ID Event03, it is not crypto-agile"
        )
    missing = [bank for bank in banks if bank not in algorithms]
    if missing:
        raise AssertionError(
            f"The Spec ID event lists {', '.join(algorithms) or 'no algorithm'}, not the bank {', '.join(missing)}"
        )

    problems = []
    checked = 0
    for event in events[1:]:
        if event.get("PCRIndex") not in pcrs or event.get("EventType") == EV_NO_ACTION:
            continue
        checked += 1
        digests = [digest.get("AlgorithmId") for digest in event.get("Digests") or []]
        lacking = [bank for bank in banks if bank not in digests]
        if lacking:
            problems.append(
                f"event {event.get('EventNum')} ({event.get('EventType')}, PCR {event.get('PCRIndex')}) "
                f"has digests {', '.join(digests) or 'none'}, none in {', '.join(lacking)}"
            )
    if not checked:
        raise AssertionError(
            f"The event log has no events that extend PCR {', '.join(map(str, sorted(pcrs)))}"
        )
    if problems:
        raise AssertionError(
            f"{len(problems)} of {checked} events lack a bank: " + "; ".join(problems)
        )
