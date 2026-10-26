# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Checks the event types and order of the TrenchBoot Secure Launch DRTM log.

Parses the TCG crypto-agile log (TCG PC Client Platform Firmware Profile,
section 10) from the hex dump `xxd -p` prints. tpm2_eventlog prints the TXT
event types as "Unknown event type", so the check reads the binary log itself.

The log has three parts:

- the launch: the events the Intel SINIT ACM or the AMD Secure Kernel Loader
  (SKL) logged
- the kernel: TrenchBoot Linux's measurements, between a start and an end
  marker (arch/x86/boot/compressed/sl_main.c, sl_main())
- anything appended later: the log is writable from userspace
  (arch/x86/kernel/slmodule.c, sl_evtlog_write()), so it is not checked

Sources: Intel TXT Measured Launch Environment Developer's Guide (315168),
revision 017.7, section 1.10.2 and Table 37; TrenchBoot secure-kernel-loader
de189900 (main.c, event_log.c) and TrenchBoot Linux dbbb5ef0, the revisions
meta-trenchboot builds.
"""

import hashlib
import re
import struct

EV_NO_ACTION = 0x3

# TrenchBoot Linux, include/linux/slaunch.h. SKL logs its events with the same
# type as the kernel (event_log.c, EV_TYPE_SLAUNCH).
TXT_EVTYPE_BASE = 0x400
SLAUNCH = TXT_EVTYPE_BASE + 0x102
SLAUNCH_START = TXT_EVTYPE_BASE + 0x103
SLAUNCH_END = TXT_EVTYPE_BASE + 0x104

# MLE Developer's Guide Table 37: the TPM 2.0 event types of the SINIT ACM,
# as (name, PCRs it may be extended to, event data size or the allowed data,
# None when the table does not fix it). Section 1.10.2.1 allows 24 B of
# HASH_START data for CPUs that hash SINIT with SHA-1. ELEMENTS_HASH (13) and
# LCP_HASH (17) are reserved in TPM 2.0 mode, so they are not listed.
# PCR_MAPPING is not extended, and CAP_VALUE has no real log entry.
TXT_EVENTS = {
    TXT_EVTYPE_BASE + 1: ("PCR_MAPPING", None, 4),
    TXT_EVTYPE_BASE + 2: ("HASH_START", {17}, (24, 36)),
    TXT_EVTYPE_BASE + 4: ("MLE_HASH", {17}, 0),
    TXT_EVTYPE_BASE + 10: ("BIOSAC_REG_DATA", {17}, 32),
    TXT_EVTYPE_BASE + 11: ("CPU_SCRTM_STAT", {17, 18}, 4),
    TXT_EVTYPE_BASE + 12: ("LCP_CONTROL_HASH", {17, 18}, 4),
    TXT_EVTYPE_BASE + 14: ("STM_HASH", {17}, 0),
    TXT_EVTYPE_BASE + 15: ("OSSINITDATA_CAP_HASH", {17, 18}, 4),
    TXT_EVTYPE_BASE + 16: ("SINIT_PUBKEY_HASH", {17, 18}, 0),
    TXT_EVTYPE_BASE + 18: ("LCP_DETAILS_HASH", {17}, None),
    TXT_EVTYPE_BASE + 19: ("LCP_AUTHORITIES_HASH", {18}, None),
    TXT_EVTYPE_BASE + 20: ("NV_INFO_HASH", {17, 18}, None),
    TXT_EVTYPE_BASE + 21: ("COLD_BOOT_BIOS_HASH", {17}, b"TXT cold boot BIOS"),
    TXT_EVTYPE_BASE + 22: ("KM_HASH", {17}, b"Key Manifest signature"),
    TXT_EVTYPE_BASE + 23: ("BPM_HASH", {17}, b"Boot Policy Manifest signature"),
    TXT_EVTYPE_BASE + 24: ("KM_INFO_HASH", {18}, None),
    TXT_EVTYPE_BASE + 25: ("BPM_INFO_HASH", {18}, None),
    TXT_EVTYPE_BASE + 26: ("BOOT_POL_HASH", {17}, 8),
    TXT_EVTYPE_BASE + 27: ("FBM_HASH", {18}, b"FSP Boot Manifest signature"),
    TXT_EVTYPE_BASE + 28: ("FBM_INFO_HASH", {17, 18}, None),
    TXT_EVTYPE_BASE + 254: ("RANDOM_VALUE", {17, 18}, 4),
    TXT_EVTYPE_BASE + 255: ("CAP_VALUE", {17, 18}, None),
}
HASH_START = TXT_EVTYPE_BASE + 2
MLE_HASH = TXT_EVTYPE_BASE + 4
RANDOM_VALUE = TXT_EVTYPE_BASE + 254

# SKL main.c and event_log.c: the PCR 17 events SKL logs after SKINIT, in
# order. The first one stands for the SKINIT measurement of SKL itself.
SKL_EVENTS = (b"SKINIT", b"DLME entry offset", b"DLME")

DRTM_PCRS = (17, 18)

# TCG Algorithm Registry, named as hashlib and /sys/class/tpm/tpm0/pcr-* name
# them.
TPM_ALG = {0x4: "sha1", 0xB: "sha256", 0xC: "sha384", 0xD: "sha512", 0x12: "sm3_256"}

# Table 37 types whose digest is HashHashAlgID(EventData), so the log carries
# the measured value itself.
TXT_DIGEST_OF_DATA = {
    TXT_EVTYPE_BASE + n for n in (2, 10, 11, 12, 15, 18, 19, 20, 24, 25, 26, 28, 254)
}

# The evt_info GRUB gives the policy entries of the command line and the
# initrd (grub-core/loader/slaunch/slrt.c), which the kernel logs as the
# event data.
CMDLINE_EVENT = b"Measured Kernel command line"
INITRD_EVENT = b"Measured Kernel initrd"


def _parse(hex_dump):
    """Returns the events of the log in hex_dump as a list of dicts with
    number, pcr, type, digests (algorithm name to digest) and data. The Spec
    ID event is not included. Parsing
    stops at an all-zero event header: the kernel exposes the whole buffer
    the log was allocated in, and the rest of it is zeros."""
    lines = [line.strip() for line in hex_dump.splitlines()]
    data = bytes.fromhex(
        "".join(line for line in lines if re.fullmatch(r"[0-9a-fA-F]+", line))
    )
    if len(data) < 32:
        raise AssertionError(
            f"The event log has {len(data)} B, too short for a Spec ID event"
        )

    _, ev_type = struct.unpack_from("<II", data, 0)
    (size,) = struct.unpack_from("<I", data, 28)
    spec = data[32 : 32 + size]
    if ev_type != EV_NO_ACTION or not spec.startswith(b"Spec ID Event03\0"):
        raise AssertionError(
            "The event log does not start with a Spec ID Event03, it is not crypto-agile"
        )
    (count,) = struct.unpack_from("<I", spec, 24)
    algorithms = dict(struct.unpack_from("<HH", spec, 28 + 4 * i) for i in range(count))
    offset = 32 + size

    events = []
    while offset + 12 <= len(data):
        number = len(events) + 1
        pcr, ev_type, count = struct.unpack_from("<III", data, offset)
        if pcr == 0 and ev_type == 0 and count == 0:
            break
        offset += 12
        digests = {}
        try:
            for _ in range(count):
                (alg,) = struct.unpack_from("<H", data, offset)
                if alg not in algorithms:
                    raise AssertionError(
                        f"Event {number} has a digest of algorithm 0x{alg:x}, which the Spec ID event does not list"
                    )
                name = TPM_ALG.get(alg, f"0x{alg:x}")
                digests[name] = data[offset + 2 : offset + 2 + algorithms[alg]]
                offset += 2 + algorithms[alg]
            (size,) = struct.unpack_from("<I", data, offset)
            offset += 4
        except struct.error:
            raise AssertionError(f"The event log ends inside event {number}") from None
        if offset + size > len(data):
            raise AssertionError(
                f"The event log ends inside the data of event {number}"
            )
        events.append(
            {
                "number": number,
                "pcr": pcr,
                "type": ev_type,
                "digests": digests,
                "data": data[offset : offset + size],
            }
        )
        offset += size
    return events


def _describe(event):
    name = TXT_EVENTS.get(event["type"], (None,))[0]
    name = {
        EV_NO_ACTION: "EV_NO_ACTION",
        SLAUNCH: "SLAUNCH",
        SLAUNCH_START: "SLAUNCH_START",
        SLAUNCH_END: "SLAUNCH_END",
    }.get(event["type"], name or f"0x{event['type']:x}")
    data = event["data"]
    printable = (
        data.rstrip(b"\0").isascii() and data.rstrip(b"\0").decode().isprintable()
    )
    shown = repr(data) if printable else data.hex()
    return f"event {event['number']} ({name}, PCR {event['pcr']}, data {shown})"


def _is_marker(event, marker):
    """True for a kernel marker event, before or after the kernel rewrote it:
    slaunch_tpm2_extend() in slmodule.c changes the type of both markers to
    EV_NO_ACTION once it has extended the events between them."""
    return (
        event["pcr"] == 17
        and event["type"] in (marker, EV_NO_ACTION)
        and not event["data"]
    )


def _split(events):
    """Returns (launch, kernel, unrewritten) for the DRTM PCR events of the
    log: the events before the kernel's start marker, the events between its
    markers, and the marker types the kernel did not rewrite."""
    events = [e for e in events if e["pcr"] in DRTM_PCRS]
    start = next(
        (i for i, e in enumerate(events) if _is_marker(e, SLAUNCH_START)), None
    )
    if start is None:
        raise AssertionError(
            "The event log has no kernel start marker: no PCR 17 SLAUNCH_START or EV_NO_ACTION event without data"
        )
    end = next(
        (
            i
            for i, e in enumerate(events[start + 1 :], start + 1)
            if _is_marker(e, SLAUNCH_END)
        ),
        None,
    )
    if end is None:
        raise AssertionError(
            f"The event log has no kernel end marker after its start marker, {_describe(events[start])}"
        )
    unrewritten = [
        name
        for event, name in (
            (events[start], "SLAUNCH_START"),
            (events[end], "SLAUNCH_END"),
        )
        if event["type"] != EV_NO_ACTION
    ]
    return events[:start], events[start + 1 : end], unrewritten


def _kernel_problems(kernel, unrewritten):
    problems = []
    if unrewritten:
        problems.append(
            f"the kernel markers {' and '.join(unrewritten)} still have their own type: "
            "slmodule did not extend the kernel's measurements into the TPM"
        )
    if not kernel:
        problems.append("the kernel logged no measurements between its markers")
    for event in kernel:
        if event["type"] != SLAUNCH:
            problems.append(
                f"{_describe(event)} is between the kernel markers, where TrenchBoot Linux logs only SLAUNCH events"
            )
        elif not event["data"]:
            problems.append(
                f"{_describe(event)} has no description, the kernel logs the evt_info of its policy entry"
            )
    return problems


def _amd_problems(launch):
    """SKL logs SKL_EVENTS for PCR 17, and nothing else, before the kernel."""
    logged = [e for e in launch if e["type"] != EV_NO_ACTION]
    expected = " ".join(repr(data) for data in SKL_EVENTS)
    if [(e["pcr"], e["type"], e["data"]) for e in logged] == [
        (17, SLAUNCH, data) for data in SKL_EVENTS
    ]:
        return []
    found = "; ".join(_describe(e) for e in logged) or "nothing"
    return [
        f"before the kernel the log has {found}, SKL logs the PCR 17 SLAUNCH events {expected}"
    ]


def _intel_problems(launch):
    """Checks the SINIT ACM events against Table 37 of the MLE Developer's
    Guide. The guide does not fix their order (section 1.10.2: "Attester
    might retrieve the exact order from the Event Log"), apart from
    HASH_START, which the _TPM_HASH_* sequence extends to PCR 17 first."""
    problems = []
    for event in launch:
        if event["type"] == EV_NO_ACTION:
            continue
        rule = TXT_EVENTS.get(event["type"])
        if rule is None:
            problems.append(
                f"{_describe(event)} has no event type of Table 37 in TPM 2.0 mode"
            )
            continue
        name, pcrs, data = rule
        if pcrs is not None and event["pcr"] not in pcrs:
            allowed = " or ".join(str(pcr) for pcr in sorted(pcrs))
            problems.append(
                f"{_describe(event)}: Table 37 extends {name} to PCR {allowed}"
            )
        if isinstance(data, bytes):
            if event["data"].rstrip(b"\0") != data:
                problems.append(
                    f"{_describe(event)}: Table 37 defines the data {data!r}"
                )
        elif data is not None:
            sizes = data if isinstance(data, tuple) else (data,)
            if len(event["data"]) not in sizes:
                allowed = " or ".join(str(size) for size in sizes)
                problems.append(
                    f"{_describe(event)}: Table 37 defines {allowed} B of {name} data"
                )

    extended = [
        e for e in launch if e["type"] not in (EV_NO_ACTION, TXT_EVTYPE_BASE + 1)
    ]
    first = next((e for e in extended if e["pcr"] == 17), None)
    if first is None or first["type"] != HASH_START:
        problems.append(
            f"the first PCR 17 event of the ACM is {_describe(first) if first else 'missing'}, "
            "the _TPM_HASH_* sequence extends HASH_START first"
        )
    mle = [e for e in extended if e["type"] == MLE_HASH]
    if len(mle) != 1:
        problems.append(
            f"the ACM logged {len(mle)} MLE_HASH events, the measurement of the MLE, expected 1"
        )
    if any(e["type"] == RANDOM_VALUE for e in extended):
        problems.append(
            "the ACM logged RANDOM_VALUE: it is an NPW (non-production) SINIT, "
            "which makes PCR 17 and 18 unusable"
        )
    return problems


def secure_launch_event_log_should_follow_order(hex_dump, vendor):
    """Fails when the PCR 17 and 18 events of the Secure Launch DRTM log in
    ${hex_dump} do not have the types and order the launch of ${vendor}
    (intel or amd) and TrenchBoot Linux log. Lists every problem.

    - the launch, Intel: the SINIT ACM events follow Table 37 of the MLE
      Developer's Guide (known types, their PCRs and fixed data), the first
      PCR 17 event is HASH_START, there is one MLE_HASH and no RANDOM_VALUE
    - the launch, AMD: exactly the PCR 17 events SKL logs, SKINIT, DLME entry
      offset and DLME
    - the kernel: a start and an end marker, PCR 17 events without data that
      the kernel turns into EV_NO_ACTION once it extended the events between
      them, and between them only SLAUNCH events with a description"""
    vendor = vendor.lower()
    if vendor not in ("intel", "amd"):
        raise AssertionError(f"Unknown vendor {vendor}, expected intel or amd")
    launch, kernel, unrewritten = _split(_parse(hex_dump))
    problems = _intel_problems(launch) if vendor == "intel" else _amd_problems(launch)
    problems += _kernel_problems(kernel, unrewritten)
    if problems:
        raise AssertionError("; ".join(problems))


def _one_digest(digest):
    """True for the OneDigest the ACM and the kernel extend into a bank they
    cannot hash in: 0x01 followed by zeros (Table 37, EVTYPE_CAP_VALUE;
    sl_main.c, sl_tpm2_log_event())."""
    return digest == b"\x01" + bytes(len(digest) - 1)


def _compare(event, measured, label):
    """Returns (problems, compared) for the digests of event against the hash
    of measured, in every bank hashlib computes. A OneDigest is a capped bank,
    not a mismatch."""
    problems = []
    compared = 0
    for name, digest in event["digests"].items():
        if name not in hashlib.algorithms_available or _one_digest(digest):
            continue
        compared += 1
        if digest != hashlib.new(name, measured).digest():
            problems.append(f"{_describe(event)}: the {name} digest is not {label}")
    return problems, compared


def _find(kernel, data):
    return [e for e in kernel if e["type"] == SLAUNCH and e["data"] == data]


def secure_launch_measurements_should_match(
    hex_dump, vendor, cmdline_hex, cmdline_size_hex, initrd_digests=None
):
    """Fails when a digest of the Secure Launch DRTM log in ${hex_dump} is
    not the hash of the value it measures, where that value is known. Lists
    every mismatch, and fails when no digest was compared.

    - Intel: the SINIT ACM events whose digest Table 37 of the MLE
      Developer's Guide defines as HashHashAlgID(EventData)
    - the kernel command line: GRUB's policy entry measures
      hdr.cmdline_size bytes of a zero-filled buffer that holds the command
      line (grub-core/loader/i386/linux.c), so the measured value is
      ${cmdline_hex}, the bytes of /proc/cmdline without the newline, padded
      with zeros to ${cmdline_size_hex}, the little-endian hdr.cmdline_size
      from /sys/kernel/boot_params/data. A command line the kernel changed,
      such as a built-in one, does not match
    - the initrd, when ${initrd_digests} maps algorithm names to the hex
      digests of the initrd file GRUB loaded

    AMD's SKL logs descriptions, not the measured values, so its events are
    not checked."""
    vendor = vendor.lower()
    launch, kernel, _ = _split(_parse(hex_dump))
    problems = []
    compared = 0

    if vendor == "intel":
        for event in launch:
            if event["type"] in TXT_DIGEST_OF_DATA:
                found, count = _compare(event, event["data"], "the hash of its data")
                problems += found
                compared += count

    cmdline = bytes.fromhex(cmdline_hex.strip()).rstrip(b"\n")
    (size,) = struct.unpack("<I", bytes.fromhex(cmdline_size_hex.strip()))
    measured = (cmdline + bytes(max(size - len(cmdline), 0)))[:size]
    events = _find(kernel, CMDLINE_EVENT)
    if len(events) != 1:
        problems.append(
            f"the kernel logged {len(events)} {CMDLINE_EVENT!r} events, expected 1"
        )
    for event in events:
        found, count = _compare(
            event,
            measured,
            f"the hash of /proc/cmdline padded with zeros to {size} B",
        )
        problems += found
        compared += count

    if initrd_digests:
        events = _find(kernel, INITRD_EVENT)
        if len(events) != 1:
            problems.append(
                f"the kernel logged {len(events)} {INITRD_EVENT!r} events, expected 1"
            )
        for event in events:
            for name, expected in initrd_digests.items():
                digest = event["digests"].get(name)
                if digest is None:
                    problems.append(f"{_describe(event)} has no {name} digest")
                    continue
                compared += 1
                if digest != bytes.fromhex(expected):
                    problems.append(
                        f"{_describe(event)}: the {name} digest is not the hash of the initrd file"
                    )

    if problems:
        raise AssertionError("; ".join(problems))
    if not compared:
        raise AssertionError(
            "No digest of the log could be compared with a measured value"
        )
