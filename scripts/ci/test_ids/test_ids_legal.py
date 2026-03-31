#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


import sys

import fire
import test_id_checking_lib as lib

paths = [
    "dasharo-compatibility",
    "dasharo-performance",
    "dasharo-security",
    "dasharo-stability",
]


def check_tests(check_function):
    invalid_tests = []
    for path in paths:
        tests = lib.get_test_cases_from_dir(path)
        for t in tests:
            if not check_function(t):
                invalid_tests.append(t)
    return invalid_tests


class CLI:
    def id_valid(self, print_invalid=False):
        """Checks if the IDs of tests are not illegal

        print_invalid: Print invalid test names
        """
        invalid_ids = check_tests(lib.id_valid)
        if print_invalid:
            for test in invalid_ids:
                print(test.name)

        if len(invalid_ids) == 0:
            sys.exit(0)
        else:
            sys.exit(1)

    def os_valid(self, print_invalid=False):
        """Checks if the OS Ids are valid and represented in test name

        print_invalid: Print invalid test names
        """
        invalid_ids = check_tests(lib.os_valid)
        if print_invalid:
            for test in invalid_ids:
                print(test.name)

        if len(invalid_ids) == 0:
            sys.exit(0)
        else:
            sys.exit(1)

    def id_mapped(self, print_invalid=False):
        """Checks if the test_cases.json test ID mappings are correct

        print_invalid: Print the invalid mappings
        """
        diff = lib.compare_mappings()
        if print_invalid:
            for d in diff:
                print(d)
        if len(diff) == 0:
            sys.exit(0)
        else:
            sys.exit(1)

    def os_skip_valid(self, print_invalid=False):
        """Checks that tests with OS ENV IDs have OS-support Skips, and vice versa

        print_invalid: Print invalid test names
        """
        invalid_tests = check_tests(lib.os_skip_valid)
        if print_invalid:
            for test in invalid_tests:
                print(test.name)

        if len(invalid_tests) == 0:
            sys.exit(0)
        else:
            sys.exit(1)

    def docs_match(self, print_invalid=False):
        """Checks that all tests from docs exist in robot code with matching names

        print_invalid: Print differences
        """
        diff = lib.compare_docs_robot()
        has_unexpected_diff = False
        # Only fails if some docs test is not in robot, other way around is expected
        if print_invalid:
            for test_id, name in sorted(diff["only_in_docs"].items()):
                has_unexpected_diff = True
                print(f"Only in docs: {test_id} {name}")
            for test_id, name in sorted(diff["only_in_robot"].items()):
                # print(f"Only in robot: {test_id} {name}")
                pass
            for test_id, (docs_name, robot_name) in sorted(
                diff["name_mismatches"].items()
            ):
                has_unexpected_diff = True
                print(
                    f"Name mismatch {test_id}: docs='{docs_name}' robot='{robot_name}'"
                )
        sys.exit(0 if not has_unexpected_diff else 1)

    def names_match(self, print_invalid=False):
        """Checks that test names in robot code match names in test_cases.json

        print_invalid: Print mismatches
        """
        mismatches = lib.compare_names_robot_json()
        if print_invalid:
            for test_id, robot_name, json_name in mismatches:
                print(f"{test_id}: robot='{robot_name}' json='{json_name}'")

        if len(mismatches) == 0:
            sys.exit(0)
        else:
            sys.exit(1)


if __name__ == "__main__":
    fire.Fire(CLI())
