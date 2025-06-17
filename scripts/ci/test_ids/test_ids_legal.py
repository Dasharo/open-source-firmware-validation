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


if __name__ == "__main__":
    fire.Fire(CLI())
