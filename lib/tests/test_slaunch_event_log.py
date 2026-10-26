# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Tests lib/slaunch_event_log.py on synthetic DRTM event logs, built as the
Intel SINIT ACM, AMD's Secure Kernel Loader and TrenchBoot Linux write them.

Run with: python -m pytest lib/tests
"""

import hashlib
import os
import struct
import sys

import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import slaunch_event_log as log  # noqa: E402

ALGS = ((0x4, "sha1", 20), (0xB, "sha256", 32))
B = log.TXT_EVTYPE_BASE
CMDLINE = b"BOOT_IMAGE=/bzImage rootwait root=LABEL=root console=ttyS0,115200"
CMDLINE_SIZE = 2047


def spec_event():
    spec = b"Spec ID Event03\0" + struct.pack("<IBBBBI", 0, 0, 2, 0, 2, len(ALGS))
    spec += b"".join(struct.pack("<HH", alg, size) for alg, _, size in ALGS) + b"\0"
    return (
        struct.pack("<II", 0, log.EV_NO_ACTION)
        + bytes(20)
        + struct.pack("<I", len(spec))
        + spec
    )


def ev(pcr, ev_type, data=b"", measured=None, digests=None):
    """An event whose digests hash measured, or data when measured is None,
    unless digests gives them by algorithm name."""
    out = struct.pack("<III", pcr, ev_type, len(ALGS))
    for alg, name, size in ALGS:
        if digests and name in digests:
            digest = digests[name]
        else:
            digest = hashlib.new(name, data if measured is None else measured).digest()
        out += struct.pack("<H", alg) + digest[:size]
    return out + struct.pack("<I", len(data)) + data


def dump(events, pad=256):
    raw = (spec_event() + b"".join(events) + bytes(pad)).hex()
    return "\n".join(raw[i : i + 60] for i in range(0, len(raw), 60))


def padded_cmdline(cmdline=CMDLINE):
    return (cmdline + bytes(CMDLINE_SIZE))[:CMDLINE_SIZE]


def kernel(start=log.EV_NO_ACTION, end=log.EV_NO_ACTION, cmdline=CMDLINE):
    return [
        ev(17, start),
        ev(18, log.SLAUNCH, b"Measured SLR Table", measured=b"slrt"),
        ev(18, log.SLAUNCH, b"Measured boot parameters", measured=b"bp"),
        ev(18, log.SLAUNCH, log.CMDLINE_EVENT, measured=padded_cmdline(cmdline)),
        ev(17, log.SLAUNCH, log.INITRD_EVENT, measured=b"initrd"),
        ev(17, end),
        ev(23, log.SLAUNCH, b"userspace"),
        ev(18, log.SLAUNCH, b"later"),
    ]


AMD = [ev(17, log.SLAUNCH, data) for data in log.SKL_EVENTS]
INTEL = [
    ev(17, B + 1, bytes(4), digests={"sha1": bytes(20), "sha256": bytes(32)}),
    ev(17, B + 2, bytes(36)),
    ev(17, B + 10, bytes(32)),
    ev(17, B + 11, bytes(4)),
    ev(18, B + 11, bytes(4)),
    ev(17, B + 12, bytes(4)),
    ev(18, B + 12, bytes(4)),
    ev(17, B + 4, measured=b"mle"),
    ev(17, B + 14, measured=b"\0"),
    ev(17, B + 15, bytes(4)),
    ev(18, B + 15, bytes(4)),
    ev(18, B + 16, measured=b"pubkey"),
    ev(17, B + 18, b"\0"),
    ev(18, B + 19, b"\0"),
    ev(17, B + 20, bytes(14)),
    ev(18, B + 20, bytes(14)),
    ev(17, B + 22, b"Key Manifest signature\0", measured=b"km"),
]


@pytest.mark.parametrize(
    "events, vendor, message",
    [
        (AMD + kernel(), "amd", None),
        (INTEL + kernel(), "intel", None),
        (AMD + kernel(log.SLAUNCH_START, log.SLAUNCH_END), "amd", "slmodule did not"),
        ([AMD[0], AMD[2]] + kernel(), "amd", "SKL logs the PCR 17"),
        (AMD + kernel(), "intel", "has no event type of Table 37"),
        (INTEL[:7] + [ev(18, B + 4)] + INTEL[8:] + kernel(), "intel", "to PCR 17"),
        (
            [INTEL[0], INTEL[2], INTEL[1]] + INTEL[3:] + kernel(),
            "intel",
            "HASH_START first",
        ),
        (INTEL + [ev(17, B + 254, bytes(4))] + kernel(), "intel", "NPW"),
        (INTEL + [ev(17, B + 13)] + kernel(), "intel", "0x40d"),
        (INTEL[:-1] + [ev(17, B + 22, b"KM sig")] + kernel(), "intel", "Key Manifest"),
        (AMD + [ev(17, 3), ev(18, 0x4, b"x"), ev(17, 3)], "amd", "only SLAUNCH"),
        (AMD + [ev(17, 3), ev(18, log.SLAUNCH), ev(17, 3)], "amd", "no description"),
        (AMD + [ev(17, 3), ev(18, log.SLAUNCH, b"x")], "amd", "no kernel end marker"),
        (AMD, "amd", "no kernel start marker"),
    ],
)
def test_order(events, vendor, message):
    if message is None:
        log.secure_launch_event_log_should_follow_order(dump(events), vendor)
    else:
        with pytest.raises(AssertionError, match=message):
            log.secure_launch_event_log_should_follow_order(dump(events), vendor)


def check_measurements(events, vendor, cmdline=CMDLINE, initrd=None):
    log.secure_launch_measurements_should_match(
        dump(events),
        vendor,
        (cmdline + b"\n").hex(),
        struct.pack("<I", CMDLINE_SIZE).hex(),
        initrd,
    )


def test_measurements_match():
    check_measurements(INTEL + kernel(), "intel")
    check_measurements(AMD + kernel(), "amd")


def test_cmdline_changed_by_kernel():
    with pytest.raises(AssertionError, match="padded with zeros to 2047 B"):
        check_measurements(AMD + kernel(), "amd", cmdline=CMDLINE + b" extra")


def test_acm_digest_not_hash_of_data():
    bad = ev(17, B + 11, b"\1\0\0\0", measured=b"\0\0\0\0")
    with pytest.raises(
        AssertionError, match="CPU_SCRTM_STAT.*not the hash of its data"
    ):
        check_measurements(INTEL[:3] + [bad] + INTEL[4:] + kernel(), "intel")


def test_capped_bank_is_not_a_mismatch():
    capped = ev(17, B + 11, bytes(4), digests={"sha256": b"\1" + bytes(31)})
    check_measurements(INTEL[:3] + [capped] + INTEL[4:] + kernel(), "intel")


def test_initrd():
    digests = {name: hashlib.new(name, b"initrd").hexdigest() for _, name, _ in ALGS}
    check_measurements(AMD + kernel(), "amd", initrd=digests)
    digests["sha256"] = hashlib.sha256(b"other").hexdigest()
    with pytest.raises(
        AssertionError, match="sha256 digest is not the hash of the initrd"
    ):
        check_measurements(AMD + kernel(), "amd", initrd=digests)


def test_nothing_compared():
    capped = {"sha1": b"\1" + bytes(19), "sha256": b"\1" + bytes(31)}
    events = AMD + [
        ev(17, 3),
        ev(18, log.SLAUNCH, log.CMDLINE_EVENT, digests=capped),
        ev(17, 3),
    ]
    with pytest.raises(AssertionError, match="No digest"):
        check_measurements(events, "amd")
