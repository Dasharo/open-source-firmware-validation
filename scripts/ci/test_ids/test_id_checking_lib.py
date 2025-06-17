#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import difflib
import re
import subprocess

from robot.model import SuiteVisitor
from robot.running import TestSuiteBuilder

# Maybe use os-config/environment-test-ids.py instead???
# A mapping from id to some name is missing though
# and the bootmanager entries might not be perfect to
# insert into the braces in test names
OS_IDS = {
    r"\.201": r"\(Ubuntu\)",
    r"\.301": r"\(Windows\)",
    r"\.202": r"\(Fedora\)",
}


class TestCasesFinder(SuiteVisitor):
    def __init__(self):
        self.tests = []

    def visit_test(self, test):
        self.tests.append(test)


def get_test_cases_from_dir(directory):
    builder = TestSuiteBuilder()
    try:
        testsuite = builder.build(directory)
    except Exception as e:
        print(
            f"Error building test suite from {directory}: {e}. Assuming no test cases."
        )
        return []
    finder = TestCasesFinder()
    testsuite.visit(finder)

    list_of_tests = finder.tests

    return list_of_tests


def get_id(test):
    res = re.search("^([A-Z]{0,9}[0-9]{3}\\.[0-9]{3}).*", test.name)
    if res:
        return res.group(1)
    return None


def id_valid(test):
    return get_id(test) is not None


def os_valid(test):
    for os_id in OS_IDS.keys():
        if re.search(os_id, test.name) and not re.search(OS_IDS[os_id], test.name):
            return False
    return True


def compare_mappings():
    robot = subprocess.run(
        "./scripts/list-tests-from-robot.sh", capture_output=True, text=True
    )
    json = subprocess.run(
        "./scripts/list-tests-from-json.sh", capture_output=True, text=True
    )
    diff = difflib.unified_diff(
        str.splitlines(robot.stdout),
        str.splitlines(json.stdout),
        fromfile="robot",
        tofile="json",
        lineterm="",
    )
    return [d for d in diff if not d.startswith(" ")]
