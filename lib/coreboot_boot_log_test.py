# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Offline checks for coreboot boot-log needles (no QEMU / DUT required).

Sample lines are taken from dasharo-issues#1364 / #1409 and from coreboot
``src/include/assert.h``.
"""

import pytest

from coreboot_boot_log import (
    DEVICETREE_WARN_NEEDLES,
    HARD_FAIL_NEEDLES,
    coreboot_boot_log_should_not_contain,
    find_needle_hits,
)

# Condensed excerpt of the console log attached to dasharo-issues#1364.
ISSUE_1364_LOG = """\
ASSERTION ERROR: file 'src/soc/intel/meteorlake/pmutil.c', line 159
  PCI: 00:00:07.0 24 *  [0x99200000 - 0xb51fffff] limit: b51fffff prefmem
Resource didn't fit!!!
  PCI: 00:00:07.0 20 *  size: 0xc200000 limit: ffffffff mem
BUG: tbt_pcie_ports_present requests hidden 00:07.1
BUG: tbt_pcie_ports_present requests hidden 00:07.2
BUG: tbt_pcie_ports_present requests hidden 00:07.3
PCI: Static device PCI: 00:00:1f.1 not found, disabling it.
PCI: Leftover static devices:
PCI: 00:00:04.0
PCI: Check your devicetree.cb.
"""

CLEAN_QEMU_LOG = """\
coreboot-qemu_q35_v0.2.1 ramstage starting...
FMAP: area COREBOOT found @ 20000 (16711680 bytes)
CBFS: 'COREBOOT' located CBFS at [20000:ffffc0]
Enumerating buses...
PCI: 00:00:1f.2 enabled
Devices initialized
"""

BUG_MACRO_LOG = (
    "ERROR: BUG ENCOUNTERED at file 'src/soc/intel/common/block/tbt/tbt.c'"
    ", line 42\n"
)


def test_issue_1364_hits_every_documented_hard_fail_needle():
    hits = find_needle_hits(ISSUE_1364_LOG, HARD_FAIL_NEEDLES)
    found = {needle for needle, _ in hits}
    assert "ASSERTION ERROR" in found
    assert "not found, disabling it." in found
    assert "Resource didn't fit!!!" in found
    assert "BUG:" in found


def test_issue_1364_hits_devicetree_warning():
    hits = find_needle_hits(ISSUE_1364_LOG, DEVICETREE_WARN_NEEDLES)
    assert hits
    assert hits[0][0] == "Check your devicetree.cb"


def test_clean_log_has_no_hard_fail_or_devicetree_hits():
    assert find_needle_hits(CLEAN_QEMU_LOG, HARD_FAIL_NEEDLES) == []
    assert find_needle_hits(CLEAN_QEMU_LOG, DEVICETREE_WARN_NEEDLES) == []


def test_bug_macro_from_current_coreboot_assert_h():
    hits = find_needle_hits(BUG_MACRO_LOG, HARD_FAIL_NEEDLES)
    found = {needle for needle, _ in hits}
    assert "ERROR: BUG ENCOUNTERED" in found
    # The BUG() macro does not emit the older "BUG:" printk used in #1364.
    assert "BUG:" not in found


def test_keyword_passes_on_clean_log():
    coreboot_boot_log_should_not_contain(CLEAN_QEMU_LOG, *HARD_FAIL_NEEDLES)


def test_keyword_fails_with_matching_line_excerpt():
    with pytest.raises(AssertionError, match="ASSERTION ERROR") as exc:
        coreboot_boot_log_should_not_contain(ISSUE_1364_LOG, "ASSERTION ERROR")
    assert "pmutil.c" in str(exc.value)


def test_keyword_requires_at_least_one_needle():
    with pytest.raises(AssertionError, match="At least one"):
        coreboot_boot_log_should_not_contain(CLEAN_QEMU_LOG)
