#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
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
    def id_valid(self, print_invalid=False, fix=False):
        """Checks if the IDs of tests are valid and that Skip If messages reference the correct ID

        print_invalid: Print invalid test names
        fix: Auto-correct wrong IDs in Skip If messages (ID format errors cannot be auto-fixed)
        """
        if fix:
            violations = lib.find_skip_msg_violations()
            for filepath, test_name, own_id in violations:
                if lib.fix_skip_msgs_in_file(filepath, test_name, own_id):
                    print(f"Fixed: {filepath}: {test_name}")
                else:
                    print(f"Could not fix: {filepath}: {test_name}")

        invalid_ids = check_tests(lib.id_valid)
        invalid_skip_msgs = check_tests(lib.skip_msg_valid)
        if print_invalid:
            for test in invalid_ids:
                print(test.name)
            for test in invalid_skip_msgs:
                print(f"{test.name} [wrong ID in Skip If message]")

        if not invalid_ids and not invalid_skip_msgs:
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

    def id_mapped(self, print_invalid=False, fix=False):
        """Checks if the test_cases.json test ID mappings are correct and IDs are unique

        print_invalid: Print the invalid mappings and duplicate IDs
        fix: Add robot tests missing from test_cases.json automatically.
             JSON entries with no robot counterpart are only reported (not removed).
             Duplicate IDs are always reported and never auto-fixed.
        """
        duplicates = lib.check_id_unique()
        if print_invalid and duplicates:
            for tid, paths in sorted(duplicates.items()):
                for p in paths:
                    print(f"Duplicate ID {tid}: {p}")

        if fix:
            result = lib.fix_id_mappings()
            for test_id, name, module in result["added"]:
                print(f"Added: {test_id} {name!r} ({module})")
            for old_id, new_id, name in result["renamed"]:
                print(f"Renamed: {old_id} -> {new_id} {name!r}")
            diff = lib.compare_mappings()
            json_only = [d for d in diff if d.startswith("-")]
            for d in json_only:
                print(f"Warning: in test_cases.json but not in robot: {d[1:].strip()}")
            sys.exit(0 if not duplicates else 1)
        else:
            diff = lib.compare_mappings()
            if print_invalid:
                for d in diff:
                    print(d)
            if not diff and not duplicates:
                sys.exit(0)
            else:
                sys.exit(1)

    def env_skip_ids(self, print_invalid=False):
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

    def names_match(self, print_invalid=False, fix=False):
        """Checks that test names and modules in robot code match test_cases.json

        print_invalid: Print name and module mismatches
        fix: Update test_cases.json names and modules to match robot code
        """
        if fix:
            updated_names = lib.fix_names_in_json()
            updated_modules = lib.fix_modules_in_json()
            for test_id, old, new in updated_names:
                print(f"Name updated {test_id}: {old!r} -> {new!r}")
            for test_id, old, new in updated_modules:
                print(f"Module updated {test_id}: {old!r} -> {new!r}")
            remaining_names = lib.compare_names_robot_json()
            remaining_modules = lib.compare_modules_robot_json()
            sys.exit(0 if not remaining_names and not remaining_modules else 1)
        else:
            name_mismatches = lib.compare_names_robot_json()
            module_mismatches = lib.compare_modules_robot_json()
            if print_invalid:
                for test_id, robot_name, json_name in name_mismatches:
                    print(
                        f"{test_id}: robot name={robot_name!r} json name={json_name!r}"
                    )
                for test_id, robot_mod, json_mod in module_mismatches:
                    print(
                        f"{test_id}: robot module={robot_mod!r} json module={json_mod!r}"
                    )
            if not name_mismatches and not module_mismatches:
                sys.exit(0)
            else:
                sys.exit(1)

    def json_sync(self):
        """Sync test_cases.json with robot code: add missing tests, fix names and modules.

        Combines the fixes of id_mapped --fix and names_match --fix in one pass.
        JSON entries not in robot are warned about but not removed.
        Duplicate IDs are reported; they must be resolved manually.
        """
        duplicates = lib.check_id_unique()
        for tid, paths in sorted(duplicates.items()):
            for p in paths:
                print(f"Duplicate ID {tid}: {p}")

        result = lib.fix_id_mappings()
        for test_id, name, module in result["added"]:
            print(f"Added: {test_id} {name!r} ({module})")
        for old_id, new_id, name in result["renamed"]:
            print(f"Renamed: {old_id} -> {new_id} {name!r}")

        updated_names = lib.fix_names_in_json()
        for test_id, old, new in updated_names:
            print(f"Name updated {test_id}: {old!r} -> {new!r}")

        updated_modules = lib.fix_modules_in_json()
        for test_id, old, new in updated_modules:
            print(f"Module updated {test_id}: {old!r} -> {new!r}")

        diff = lib.compare_mappings()
        json_only = [d for d in diff if d.startswith("-")]
        for d in json_only:
            print(f"Warning: in test_cases.json but not in robot: {d[1:].strip()}")

        sys.exit(0 if not duplicates else 1)

    def semiauto(self, print_invalid=False, fix=False):
        """Checks that tests calling manual keywords have the semiauto tag.

        Tests that call Execute Manual Step (or similar manual-only keywords)
        must have the semiauto tag, either via [Tags] or suite Default Tags.

        A test tagged 'not_semiauto' is explicitly asserted to be fully automated
        (the manual keyword call is unreachable in automated runs) and is exempt.

        print_invalid: Print violating test names, filepaths, and call paths
        fix: Automatically add semiauto tag where unambiguous (direct top-level call)
        """
        violations = lib.find_semiauto_violations()

        if fix:
            for filepath, test_name, is_direct, call_paths in violations:
                if is_direct:
                    if lib.fix_semiauto_tag_in_file(filepath, test_name):
                        print(f"Fixed: {filepath}: {test_name}")
                    else:
                        print(f"Could not fix: {filepath}: {test_name}")
                else:
                    print(f"Ambiguous (manual fix needed): {filepath}: {test_name}")
                    for p in call_paths:
                        print(f"  via: {p}")
                    print(
                        f"  -> If the manual keyword is unreachable in automated runs, "
                        f"add [Tags]    not_semiauto to suppress this warning."
                    )
            remaining = lib.find_semiauto_violations()
            sys.exit(0 if not remaining else 1)
        else:
            if print_invalid:
                for filepath, test_name, is_direct, call_paths in violations:
                    if is_direct:
                        print(f"{filepath}: {test_name}")
                    else:
                        print(f"{filepath}: {test_name} [ambiguous]")
                        for p in call_paths:
                            print(f"  via: {p}")
                        print(
                            f"  -> If the manual keyword is unreachable in automated runs, "
                            f"add [Tags]    not_semiauto to suppress this warning."
                        )
            sys.exit(0 if not violations else 1)

    def env_skip_keywords(self, print_invalid=False, fix=False, strict=False):
        """Checks that tests have required Skip If guards for firmware and OS-boot keywords.

        Firmware guard: tests calling firmware UI entry keywords (e.g. Enter Setup
        Menu Tianocore, Enter Boot Menu Tianocore, Detect Heads Main Menu) must guard
        execution with:
            Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ...
        Tag a test 'not_firmware' to assert the firmware keyword is unreachable in
        automated runs and exempt it from this check.

        OS-boot guard: tests calling Boot System Or From Connected Disk, Boot And
        Login To OS, or Boot And Login To Windows must skip via the relevant OS
        support variable (e.g. TESTS_IN_UBUNTU_SUPPORT, TESTED_LINUX_DISTROS).
        This applies regardless of the test's ENV ID.

        Calls where the OS arg is a runtime variable (e.g. ${os_id}) cannot be
        checked statically.  By default they are silently ignored; pass --strict
        to report them and treat them as failures.

        print_invalid: Print violating test names, filepaths, and details
        fix: Automatically add missing Skip If lines where unambiguous
        strict: Also report and fail on OS-boot calls with runtime (ambiguous) OS args
        """
        violations = lib.find_env_skip_violations()

        def _is_failure(fw, ob_miss, ob_ambig):
            return fw is not None or bool(ob_miss) or (strict and bool(ob_ambig))

        if fix:
            for filepath, test_name, fw, ob_miss, ob_ambig in violations:
                fixed = lib.fix_env_skip_in_file(filepath, test_name, fw, ob_miss)
                if fixed:
                    print(f"Fixed: {filepath}: {test_name}")
                else:
                    if fw is not None:
                        _is_direct, call_paths = fw
                        if not _is_direct:
                            print(
                                f"Ambiguous firmware (manual fix needed): {filepath}: {test_name}"
                            )
                            for p in call_paths:
                                print(f"  via: {p}")
                        else:
                            print(f"Could not fix: {filepath}: {test_name}")
                if strict:
                    for kw_name, raw_arg in ob_ambig:
                        print(
                            f"Ambiguous OS-boot (manual fix needed): {filepath}: {test_name}"
                        )
                        print(f"  {kw_name} called with runtime arg: {raw_arg}")
            remaining = lib.find_env_skip_violations()
            has_failures = any(
                _is_failure(fw, om, oa) for _, _, fw, om, oa in remaining
            )
            sys.exit(0 if not has_failures else 1)
        else:
            if print_invalid:
                for filepath, test_name, fw, ob_miss, ob_ambig in violations:
                    if fw is not None:
                        is_direct, call_paths = fw
                        if is_direct:
                            print(
                                f"{filepath}: {test_name} [missing TESTS_IN_FIRMWARE_SUPPORT skip]"
                            )
                        else:
                            print(
                                f"{filepath}: {test_name} [missing TESTS_IN_FIRMWARE_SUPPORT skip, ambiguous]"
                            )
                            for p in call_paths:
                                print(f"  via: {p}")
                    for os_arg, specs in ob_miss:
                        need = [sv for sv, _ in specs]
                        print(
                            f"{filepath}: {test_name} [missing skip for {os_arg}: need one of {need}]"
                        )
                    if strict:
                        for kw_name, raw_arg in ob_ambig:
                            print(
                                f"{filepath}: {test_name} [ambiguous: {kw_name} with {raw_arg!r}]"
                            )
            has_failures = any(
                _is_failure(fw, om, oa) for _, _, fw, om, oa in violations
            )
            sys.exit(0 if not has_failures else 1)

    def suite_sorted(self, print_invalid=False):
        """Checks that tests within each suite are sorted: first by OS ENV ID, then by test ID

        The expected order groups tests by ENV ID (e.g. all .201 first, then all .301),
        and within each group sorts by prefix+number (e.g. ETC001 before ETC002).
        Example: ETC001.201, ETC002.201, ETC001.301, ETC002.301

        print_invalid: Print out-of-order test names
        """
        violations = lib.check_suite_sorted()
        if print_invalid:
            for filepath, file_violations in violations:
                for out_of_order, preceding in file_violations:
                    print(
                        f"{filepath}: '{out_of_order}' is out of order (after '{preceding}')"
                    )
            if len(violations) > 0:
                print(
                    f"\n#####################################################\n"
                    f"If the order is intentional, add a metadata to the affected test suites:\n"
                    f"*** Settings ***:\n"
                    f"       Metadata    ORDER_SENSITIVE    <reason>"
                )

        if len(violations) == 0:
            sys.exit(0)
        else:
            sys.exit(1)


if __name__ == "__main__":
    fire.Fire(CLI())
