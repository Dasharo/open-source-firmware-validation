# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Matchers for concerning coreboot console-log strings.

The needles are taken from Dasharo porting issues and from coreboot itself:

- ``ASSERTION ERROR`` — ``ASSERT()`` in coreboot ``src/include/assert.h``
  (dasharo-issues#1409 / #1364, e.g. missing PMC GPE routes).
- ``not found, disabling it.`` — static PCI device in ``devicetree.cb`` that
  was not found on the bus (``src/device/pci_device.c``, dasharo-issues#1409).
- ``Resource didn't fit!!!`` — resource allocator v4 could not place a BAR
  (``src/device/resource_allocator_v4.c``, dasharo-issues#1364).
- ``BUG:`` — ad-hoc coreboot ``printk`` bugs (dasharo-issues#1364,
  e.g. ``BUG: tbt_pcie_ports_present requests hidden ...``).
- ``ERROR: BUG ENCOUNTERED`` — the ``BUG()`` macro in current coreboot
  ``src/include/assert.h``.
- ``Check your devicetree.cb`` — leftover static devices
  (``src/device/pci_device.c``). This is a ``BIOS_WARNING`` present on almost
  all boards; OSFV treats it as opt-in rather than a hard failure.
"""

from robot.api.deco import keyword

# Substrings that indicate a real firmware misconfiguration (hard fail).
HARD_FAIL_NEEDLES = (
    "ASSERTION ERROR",
    "not found, disabling it.",
    "Resource didn't fit!!!",
    "BUG:",
    "ERROR: BUG ENCOUNTERED",
)

# Leftover static devices: documented as expected on almost all boards.
# See dasharo-issues#1409 and coreboot src/device/pci_device.c (BIOS_WARNING).
DEVICETREE_WARN_NEEDLES = ("Check your devicetree.cb",)


def find_needle_hits(log, needles):
    """Return ``[(needle, matching_lines), ...]`` for needles found in ``log``.

    ``log``: ``str`` — coreboot console text (typically ``cbmem -1``).
    ``needles``: iterable of ``str`` — literal substrings to search for.
    """
    lines = log.splitlines()
    hits = []
    for needle in needles:
        matched = [line for line in lines if needle in line]
        if matched:
            hits.append((needle, matched))
    return hits


def format_needle_hits(hits, max_lines=10):
    """Format ``find_needle_hits`` results for a failure message."""
    parts = []
    for needle, matched in hits:
        excerpt = "\n".join(matched[:max_lines])
        extra = ""
        if len(matched) > max_lines:
            extra = f"\n... ({len(matched) - max_lines} more matching line(s))"
        parts.append(f"pattern {needle!r}:\n{excerpt}{extra}")
    return "\n".join(parts)


@keyword("Coreboot Boot Log Should Not Contain")
def coreboot_boot_log_should_not_contain(log, *needles):
    """Fail if the coreboot console log contains any of ``needles``.

    === Requirements ===
    - ``${log}`` is the text of the coreboot console (``cbmem -1``).

    === Arguments ===
    - ``${log}``: ``string`` - coreboot console log
    - ``@{needles}``: ``string`` - one or more literal substrings that must
      not appear in the log

    === Return Value ===
    - None

    === Effects ===
    - None. Fails the test if a needle is present, including an excerpt of
      matching lines in the error message.
    """
    if not needles:
        raise AssertionError("At least one forbidden log pattern is required")
    hits = find_needle_hits(log, needles)
    if hits:
        raise AssertionError(
            "Forbidden coreboot boot-log pattern(s) found:\n" + format_needle_hits(hits)
        )
