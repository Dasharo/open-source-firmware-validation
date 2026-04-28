#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os
import re

##################################################
# Paths

# Absolute path to the repository root
_THIS_DIR = os.path.dirname(os.path.realpath(__file__))
REPO_ROOT = os.path.normpath(os.path.join(_THIS_DIR, "..", "..", ".."))


OS_CONFIG_PATH = os.path.join(REPO_ROOT, "os-config", "environment-test-ids.py")
DOCS_PATH = os.path.join(
    REPO_ROOT, "docs-dasharo", "docs", "unified-test-documentation"
)

ROBOT_TEST_PATHS = [
    "dasharo-compatibility",
    "dasharo-performance",
    "dasharo-security",
    "dasharo-stability",
]

################################################
# Regex patterns


# Test names that look like a test case to find potentially invalid ones
TEST_CASE_ID_PATTERN = re.compile(r"^[A-Z]*[0-9]{1,10}\.[0-9]{1,10}")

# Strict capture of a correct test ID (PREFIX###.ENV)
# Others are less strict to find other potential issues even if the ID contains typo
TEST_ID_STRICT_PATTERN = re.compile(r"^([A-Z]{3,9}[0-9]{3}\.[0-9]{3})")

# Capture the 3-digit ENV ID from a test name
ENV_ID_CAPTURE_PATTERN = re.compile(r"[A-Z]{2,9}[0-9]{1,10}\.([0-9]{3})")

# Match a test ID heading in a docs.dasharo unified-test-documentation markdown file
DOCS_TEST_ID_PATTERN = re.compile(
    r"^##\s+([A-Z]{2,9}[0-9]{1,10}\.[0-9]{1,10})\s+(.+?)\s*$"
)

# Match the skip marker comment that excludes a test from docs/robot comparison
OSFV_DOCS_SKIP_PATTERN = re.compile(r"<!--\s*OSFV_DOCS_SKIP\s*-->")

# Match "ID name" at the start of a robot test case name
ROBOT_TEST_ID_PATTERN = re.compile(r"^([A-Z]{2,9}[0-9]{1,10}\.[0-9]{1,10})\s+(.+)$")

# Match "PREFIX###.ENV" for suite sort key extraction
SUITE_SORT_ID_PATTERN = re.compile(r"^([A-Z]{2,9}[0-9]{1,10})\.([0-9]+)")


#######################################
# Keywords

# Robot Framework variable names used as OS-support skip guards
OS_SKIP_VARS = [
    "TESTS_IN_WINDOWS_SUPPORT",
    "TESTS_IN_UBUNTU_SUPPORT",
    "TESTS_IN_ESXI_SUPPORT",
    "TESTS_IN_XCP_NG_SUPPORT",
    "TESTS_IN_OPENWRT_SUPPORT",
    "TESTS_IN_FIRMWARE_SUPPORT",
    "TESTED_LINUX_DISTROS",
    "TESTED_BSD_DISTROS",
    "HEADS_PAYLOAD_SUPPORT",
]

# Keywords whose presence in a test body requires the 'semiauto' tag
MANUAL_KEYWORDS = frozenset(
    [
        "Execute Manual Step",
        "Get Value From User",
        "Get Selections From User",
        "Pause Execution In Console",
    ]
)

# Keywords that require a 'Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}' guard
FIRMWARE_ENTRY_KEYWORDS = frozenset(
    [
        # Primary entry, bring the user from reset/boot into the firmware UI
        "Enter Boot Menu Tianocore",
        "Enter Boot Menu Tianocore And Return Construction",
        "Enter Setup Menu Tianocore",
        "Enter Setup Menu Tianocore And Return Construction",
        "Enter Petitboot And Return Menu",
        "Detect Heads Main Menu",
        "Power Cycle Into Firmware Setup",
        "Enter IPXE",
        # Sub-navigation, always within an already-open firmware UI
        "Enter Submenu From Snapshot",
        "Enter Dasharo System Features",
        "Enter Dasharo APU Configuration",
        "Enter Secure Boot Menu",
        "Enter Advanced Secure Boot Keys Management",
        "Enter Enroll DB Signature Using File In DB Options",
        "Enter Volume In File Explorer",
        "Enter Boot From File",
        "Enter UEFI Shell",
        "Enter The TCG Configuration Menu",
        "Enter IPXE Inner",
        "Enter IPXE Shell Submenu",
        "Enter Heads Recovery Shell",
    ]
)

# Keywords that boot an OS and require an OS-specific Skip If guard
OS_BOOT_KEYWORDS = frozenset(
    [
        "Boot System Or From Connected Disk",
        "Boot And Login To OS",
        "Boot And Login To Windows",
    ]
)

# Maps the OS arg Robot variable (as it appears in robot source) to a list of
# (skip_var_name, skip_condition) pairs.  A test is valid if at least one
# skip_var_name is present in its body strings.  skip_condition strings are
# inserted verbatim by the auto-fixer.
BOOT_ARG_SKIP_SPECS = {
    "${ENV_ID_UBUNTU}": [
        ("TESTS_IN_UBUNTU_SUPPORT", "not ${TESTS_IN_UBUNTU_SUPPORT}"),
        ("TESTED_LINUX_DISTROS", "'${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}"),
    ],
    "${ENV_ID_FEDORA}": [
        ("TESTED_LINUX_DISTROS", "'${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}"),
    ],
    "${ENV_ID_QUBES}": [
        ("TESTED_LINUX_DISTROS", "'${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}"),
    ],
    "${ENV_ID_TRENCHBOOT}": [
        (
            "TESTED_LINUX_DISTROS",
            "'${ENV_ID_TRENCHBOOT}' not in ${TESTED_LINUX_DISTROS}",
        ),
    ],
    "${ENV_ID_XCP_NG}": [
        ("TESTS_IN_XCP_NG_SUPPORT", "not ${TESTS_IN_XCP_NG_SUPPORT}"),
        ("TESTED_LINUX_DISTROS", "'${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}"),
    ],
    "${ENV_ID_ZARHUS}": [
        ("TESTED_LINUX_DISTROS", "'${ENV_ID_ZARHUS}' not in ${TESTED_LINUX_DISTROS}"),
    ],
    "${ENV_ID_OPENWRT}": [
        ("TESTS_IN_OPENWRT_SUPPORT", "not ${TESTS_IN_OPENWRT_SUPPORT}"),
    ],
    "${ENV_ID_DEBIAN}": [
        ("TESTED_LINUX_DISTROS", "'${ENV_ID_DEBIAN}' not in ${TESTED_LINUX_DISTROS}"),
    ],
    "${ENV_ID_HEADS}": [("HEADS_PAYLOAD_SUPPORT", "not ${HEADS_PAYLOAD_SUPPORT}")],
    "${ENV_ID_HEADS_DEBIAN}": [
        (
            "TESTED_LINUX_DISTROS",
            "'${ENV_ID_HEADS_DEBIAN}' not in ${TESTED_LINUX_DISTROS}",
        ),
    ],
    "${ENV_ID_PROXMOX}": [
        ("TESTED_LINUX_DISTROS", "'${ENV_ID_PROXMOX}' not in ${TESTED_LINUX_DISTROS}"),
    ],
    "${ENV_ID_WINDOWS}": [
        ("TESTS_IN_WINDOWS_SUPPORT", "not ${TESTS_IN_WINDOWS_SUPPORT}"),
    ],
    "${ENV_ID_ESXI}": [
        ("TESTS_IN_ESXI_SUPPORT", "not ${TESTS_IN_ESXI_SUPPORT}"),
    ],
    "${ENV_ID_FREEBSD}": [
        ("TESTED_BSD_DISTROS", "'${ENV_ID_FREEBSD}' not in ${TESTED_BSD_DISTROS}"),
    ],
    "${ENV_ID_PFSENSE}": [
        ("TESTED_BSD_DISTROS", "'${ENV_ID_PFSENSE}' not in ${TESTED_BSD_DISTROS}"),
    ],
    "${ENV_ID_OPNSENSE}": [
        ("TESTED_BSD_DISTROS", "'${ENV_ID_OPNSENSE}' not in ${TESTED_BSD_DISTROS}"),
    ],
}
