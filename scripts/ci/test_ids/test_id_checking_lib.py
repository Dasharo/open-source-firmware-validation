#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import ast
import difflib
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
            else:
                self.os_ids[name] = value

    def get_id_to_friendly_mapping(self):
        mapping = {}
        for var_name, os_id in self.os_ids.items():
            if os_id in self.friendly_names.keys():
                mapping[os_id] = self.friendly_names[os_id]
        return mapping


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
    res = re.search("^([A-Z]{3,9}[0-9]{3}\\.[0-9]{3}).*", test.name)
    if res:
        return res.group(1)
    return None


def id_valid(test):
    return get_id(test) is not None


def os_valid(test):
    os_ids = {
        re.escape(f".{key}"): re.escape(f"({value})")
        for key, value in OsConfig().get_id_to_friendly_mapping().items()
    }
    for os_id in os_ids.keys():
        if re.search(os_id, test.name) and not re.search(os_ids[os_id], test.name):
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
    return [d for d in diff if not d.startswith((" ", "@@"))]


if __name__ == "__main__":
    from pprint import pprint

    pprint(OsConfig().get_id_to_friendly_mapping())
