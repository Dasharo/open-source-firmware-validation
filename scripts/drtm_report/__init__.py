# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""The DRTM criteria report: the matrix of the DRTM criteria against runs of
one or more test suites, each run compared with the expected results of its
platform, firmware and kernel. docs/drtm-report.md describes it.

A Source describes one tree of suites: its criteria document, its suites, its
expectation files and how it reads a run. trenchboot.py is the Source of the
TrenchBoot suites of this repository, and another repository can add its own
and put its runs in the same report.
"""
