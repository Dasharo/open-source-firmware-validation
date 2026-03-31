#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import ast
import difflib
import json
import os
import re
import subprocess
from pathlib import Path

from robot.model import SuiteVisitor
from robot.running import TestSuiteBuilder


class TestCasesFinder(SuiteVisitor):
    def __init__(self):
        self.tests = []

    def visit_test(self, test):
        self.tests.append(test)


class OsConfig:
    def __init__(self):
        """Parse the os-config file contents into a dictionary"""
        self.os_ids = {}
        self.friendly_names = {}
        this_file = os.path.dirname(os.path.realpath(__file__))
        os_config_path = os.path.join(
            #               ci scripts osfv
            this_file,
            "..",
            "..",
            "..",
            "os-config",
            "environment-test-ids.py",
        )
        self._parse_os_config(os_config_path)

    def _parse_os_config(self, path):
        src = Path(path).read_text()
        tree = ast.parse(src, filename=path)
        vars = {}

        def _parse_ast_node(node):
            if isinstance(node, ast.Constant):  # literal
                return node.value
            if isinstance(node, ast.Name):  # reference
                try:
                    return vars[node.id]
                except KeyError as exc:
                    raise ValueError(f"Unknown identifier {node.id!r}") from exc
            if isinstance(node, (ast.List, ast.Tuple, ast.Set)):  # containers
                ctor = {ast.List: list, ast.Tuple: tuple, ast.Set: set}[type(node)]
                return ctor(_parse_ast_node(elt) for elt in node.elts)
            if isinstance(node, ast.Dict):
                return {
                    _parse_ast_node(k): _parse_ast_node(v)
                    for k, v in zip(node.keys, node.values)
                }
            raise ValueError(f"Unsupported expression: {ast.dump(node)}")

        for node in tree.body:
            if (
                isinstance(node, ast.Assign)
                and len(node.targets) == 1
                and isinstance(node.targets[0], ast.Name)
            ):
                name = node.targets[0].id
                vars[name] = _parse_ast_node(node.value)

        for name, value in vars.items():
            if name == "ENV_ID_OS_FRIENDLY_NAMES":
                self.friendly_names = value
            elif not isinstance(value, dict):
                self.os_ids[name] = value

    def get_id_to_friendly_mapping(self):
        mapping = {}
        for var_name, os_id in self.os_ids.items():
            if os_id in self.friendly_names.keys():
                mapping[os_id] = self.friendly_names[os_id]
        return mapping


OS_SKIP_VARS = [
    "TESTS_IN_WINDOWS_SUPPORT",
    "TESTS_IN_UBUNTU_SUPPORT",
    "TESTED_LINUX_DISTROS",
]

_ROBOT_TEST_PATHS = [
    "dasharo-compatibility",
    "dasharo-performance",
    "dasharo-security",
    "dasharo-stability",
]

_DOCS_TEST_ID_PATTERN = re.compile(
    r"^##\s+([A-Z]{2,9}[0-9]{1,10}\.[0-9]{1,10})\s+(.+?)\s*$"
)
_OSFV_DOCS_SKIP_PATTERN = re.compile(r"<!--\s*OSFV_DOCS_SKIP\s*-->")
_ROBOT_TEST_ID_PATTERN = re.compile(r"^([A-Z]{2,9}[0-9]{1,10}\.[0-9]{1,10})\s+(.+)$")


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
    pattern = re.compile(r"^[A-Z]*[0-9]{1,10}\.[0-9]{1,10}")
    list_of_tests = [t for t in finder.tests if pattern.search(t.name)]

    return list_of_tests


def get_id(test):
    res = re.search("^([A-Z]{3,9}[0-9]{3}\\.[0-9]{3}).*", test.name)
    if res:
        return res.group(1)
    return None


def id_valid(test):
    # pseudo test cases used as helpers start with _
    # they are technically valid to use
    return get_id(test) is not None or test.name.startswith("_")


def os_valid(test):
    os_ids = {
        re.escape(f".{key}"): re.escape(f"({value})")
        for key, value in OsConfig().get_id_to_friendly_mapping().items()
    }
    assert len(os_ids) > 0
    for os_id in os_ids.keys():
        contains_id = re.search(os_id, test.name)
        contains_name = re.search(os_ids[os_id], test.name)
        if bool(contains_id) != bool(contains_name):  # xor
            print(test.name)
            return False
    return True


def _collect_body_strings(body):
    """Recursively collect name/arg strings from a Robot Framework body."""
    result = []
    for item in body:
        if hasattr(item, "name") and item.name:
            result.append(item.name)
        if hasattr(item, "args"):
            result.extend(item.args)
        if hasattr(item, "body") and item.body:
            result.extend(_collect_body_strings(item.body))
        if hasattr(item, "branches"):
            for branch in item.branches:
                if hasattr(branch, "body") and branch.body:
                    result.extend(_collect_body_strings(branch.body))
    return result


def has_os_skip(test):
    """Return True if the test (or its suite setup) skips based on OS support vars."""
    strings = _collect_body_strings(test.body)
    if test.parent and test.parent.setup:
        suite_setup = test.parent.setup
        if hasattr(suite_setup, "name") and suite_setup.name:
            strings.append(suite_setup.name)
        if hasattr(suite_setup, "args"):
            strings.extend(suite_setup.args)
    full = " ".join(strings)
    return any(var in full for var in OS_SKIP_VARS)


def get_env_id(test):
    """Return the 3-digit ENV ID from the test name, or None."""
    m = re.search(r"[A-Z]{2,9}[0-9]{1,10}\.([0-9]{3})", test.name)
    return m.group(1) if m else None


def os_skip_valid(test):
    """Return True if OS-skip presence is consistent with the ENV ID.

    Tests with a non-0xx ENV ID must skip based on OS support variables,
    and tests that skip based on OS support must have a non-0xx ENV ID.
    """
    if test.name.startswith("_"):
        return True
    env_id = get_env_id(test)
    if env_id is None:
        return True
    has_os_env = not env_id.startswith("0")
    has_skip = has_os_skip(test)
    return not (has_os_env ^ has_skip)


def compare_mappings():
    robot = subprocess.run(
        "./scripts/list-tests-from-robot.sh", capture_output=True, text=True
    )
    json = subprocess.run(
        "./scripts/list-tests-from-json.sh", capture_output=True, text=True
    )
    diff = difflib.unified_diff(
        sorted([r.split()[0] for r in str.splitlines(robot.stdout)]),
        sorted([r.split()[0] for r in str.splitlines(json.stdout)]),
        fromfile="robot",
        tofile="json",
        lineterm="",
    )
    return [d for d in diff if not d.startswith((" ", "@@")) and not "DEPRECATED" in d]


def get_tests_from_docs():
    """Extract {id: name} from unified-test-documentation markdown files.

    Lines containing '<!-- OSFV_DOCS_SKIP -->' are excluded from comparison.
    """
    this_file = os.path.dirname(os.path.realpath(__file__))
    docs_path = os.path.join(
        this_file,
        "..",
        "..",
        "..",
        "docs-dasharo",
        "docs",
        "unified-test-documentation",
    )
    tests = {}
    for dirpath, _, filenames in os.walk(docs_path):
        for filename in sorted(filenames):
            if not filename.endswith(".md"):
                continue
            filepath = os.path.join(dirpath, filename)
            with open(filepath, "r", encoding="utf-8") as f:
                for line in f:
                    m = _DOCS_TEST_ID_PATTERN.match(line.rstrip())
                    if not m:
                        continue
                    test_id, test_name = m.group(1), m.group(2)
                    if _OSFV_DOCS_SKIP_PATTERN.search(test_name):
                        continue
                    tests[test_id] = test_name
    return tests


def get_tests_from_robot():
    """Extract {id: name} from all robot test files."""
    tests = {}
    for path in _ROBOT_TEST_PATHS:
        for t in get_test_cases_from_dir(path):
            m = _ROBOT_TEST_ID_PATTERN.match(t.name)
            if m:
                tests[m.group(1)] = m.group(2)
    return tests


def compare_docs_robot():
    """Compare tests in docs vs robot files.

    Returns dict with keys:
    - only_in_docs: {id: name} found in docs but not in robot
    - only_in_robot: {id: name} found in robot but not in docs
    - name_mismatches: {id: (docs_name, robot_name)} where names differ
    """
    docs = get_tests_from_docs()
    robot = get_tests_from_robot()
    return {
        "only_in_docs": {k: v for k, v in docs.items() if k not in robot},
        "only_in_robot": {k: v for k, v in robot.items() if k not in docs},
        "name_mismatches": {
            k: (docs[k], robot[k]) for k in docs if k in robot and docs[k] != robot[k]
        },
    }


def get_tests_from_json(json_path="test_cases.json"):
    """Extract {id: name} from test_cases.json, excluding deprecated tests."""
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return {
        item["doc"]["_id"]: item["doc"]["name"]
        for item in data
        if "changed_to" not in item.get("doc", {})
    }


def compare_names_robot_json():
    """Return list of (id, robot_name, json_name) for tests with mismatched names."""
    robot = get_tests_from_robot()
    json_tests = get_tests_from_json()
    return sorted(
        [
            (test_id, robot[test_id], json_tests[test_id])
            for test_id in robot
            if test_id in json_tests and robot[test_id] != json_tests[test_id]
        ]
    )


if __name__ == "__main__":
    from pprint import pprint

    pprint(OsConfig().get_id_to_friendly_mapping())
