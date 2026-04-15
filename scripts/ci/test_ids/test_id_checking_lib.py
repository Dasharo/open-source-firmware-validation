#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import ast
import difflib
import json
import os
import re
import subprocess
from pathlib import Path

import test_ids_config as cfg
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
        self._parse_os_config(cfg.OS_CONFIG_PATH)

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
            if name == "ENV_ID_FRIENDLY_NAMES":
                self.friendly_names = value
            elif not isinstance(value, dict):
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
    pattern = cfg.TEST_CASE_ID_PATTERN
    list_of_tests = [t for t in finder.tests if pattern.search(t.name)]

    return list_of_tests


def get_test_cases_from_file(filepath):
    """Return test cases from a single robot file, preserving their order."""
    builder = TestSuiteBuilder()
    try:
        testsuite = builder.build(filepath)
    except Exception as e:
        if filepath.split("/")[-1] != "__init__.robot":
            print(f" building test suite from {filepath}: {e}. Assuming no test cases.")
        return []
    finder = TestCasesFinder()
    testsuite.visit(finder)
    pattern = cfg.TEST_CASE_ID_PATTERN
    return [t for t in finder.tests if pattern.search(t.name)]


def get_id(test):
    res = cfg.TEST_ID_STRICT_PATTERN.search(test.name)
    if res:
        return res.group(1)
    return None


def id_valid(test):
    # pseudo test cases used as helpers start with _
    # they are technically valid to use
    return get_id(test) is not None or test.name.startswith("_")


def _iter_skip_if_messages(body):
    """Yield the message argument of every 'Skip If' keyword call in body (recursively)."""
    for item in body:
        if getattr(item, "name", None) == "Skip If":
            args = getattr(item, "args", ())
            if len(args) >= 2:
                yield str(args[1])
        if hasattr(item, "body") and item.body:
            yield from _iter_skip_if_messages(item.body)
        if hasattr(item, "branches"):
            for branch in item.branches:
                if hasattr(branch, "body") and branch.body:
                    yield from _iter_skip_if_messages(branch.body)


_SKIP_MSG_ID_PATTERN = re.compile(r"^([A-Z]{3,9}[0-9]{3}\.[0-9]{3})\s+not supported")


def skip_msg_valid(test):
    """Return True if all 'Skip If' messages in the test reference the test's own ID.

    Catches copy-paste errors where the skip message says 'TST001.001 not supported'
    inside a test named 'TST001.201 ...'.  Only messages matching the pattern
    '<ID> not supported' are checked; free-form messages are ignored.
    """
    own_id = get_id(test)
    if own_id is None:
        return True
    for msg in _iter_skip_if_messages(test.body):
        m = _SKIP_MSG_ID_PATTERN.match(msg.strip())
        if m and m.group(1) != own_id:
            return False
    return True


def find_skip_msg_violations():
    """Find tests whose Skip If messages reference a different test ID.

    Returns list of (filepath, test_name, own_id) tuples.
    """
    violations = []
    for filepath, test in _iter_all_tests():
        if not skip_msg_valid(test):
            violations.append((filepath, test.name, get_id(test)))
    return violations


_WRONG_ID_IN_MSG_RE = re.compile(r"([A-Z]{3,9}[0-9]{3}\.[0-9]{3})( +not supported)")


def fix_skip_msgs_in_file(filepath, test_name, own_id):
    """Replace wrong test IDs in Skip If messages for test_name in filepath.

    On every Skip If line inside the named test, replaces
    '<WRONG_ID> not supported' with '<own_id> not supported'.
    Returns True if the file was modified.
    """
    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.readlines()

    # Locate the test header
    header_idx = None
    for i, line in enumerate(lines):
        if not line.startswith((" ", "\t")) and line.rstrip() == test_name:
            header_idx = i
            break
    if header_idx is None:
        return False

    modified = False
    for j in range(header_idx + 1, len(lines)):
        line = lines[j]
        # Blank lines are allowed inside test bodies — skip them, don't stop.
        if not line.strip():
            continue
        if not line.startswith((" ", "\t")):
            break
        if "Skip If" not in line or "not supported" not in line:
            continue
        new_line = _WRONG_ID_IN_MSG_RE.sub(
            lambda m: own_id + m.group(2) if m.group(1) != own_id else m.group(0),
            line,
        )
        if new_line != line:
            lines[j] = new_line
            modified = True

    if modified:
        with open(filepath, "w", encoding="utf-8") as f:
            f.writelines(lines)
    return modified


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


def _body_and_suite_strings(test):
    """Collect all keyword name/arg strings from a test body and its suite setup."""
    strings = _collect_body_strings(test.body)
    if test.parent and test.parent.setup:
        suite_setup = test.parent.setup
        if hasattr(suite_setup, "name") and suite_setup.name:
            strings.append(suite_setup.name)
        if hasattr(suite_setup, "args"):
            strings.extend(suite_setup.args)
    return strings


def has_os_skip(test):
    """Return True if the test (or its suite setup) skips based on OS support vars."""
    full = " ".join(_body_and_suite_strings(test))
    return any(var in full for var in cfg.OS_SKIP_VARS)


def get_env_id(test):
    """Return the 3-digit ENV ID from the test name, or None."""
    m = cfg.ENV_ID_CAPTURE_PATTERN.search(test.name)
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
    return (not has_os_env) or has_os_skip(test)


# ---------------------------------------------------------------------------
# Generic helpers shared by semiauto and env_skips checks
# ---------------------------------------------------------------------------


def _has_keyword(test, keyword_set):
    """Return True if the test body (recursively) calls any keyword in keyword_set."""
    return bool(keyword_set & set(_collect_body_strings(test.body)))


def _has_direct_keyword(test, keyword_set):
    """Return True if the test directly (top-level) calls any keyword in keyword_set."""
    return any(getattr(item, "name", None) in keyword_set for item in test.body)


def _has_skip_var(test, var_name):
    """Return True if var_name appears in the test body or suite setup strings."""
    return var_name in " ".join(_body_and_suite_strings(test))


def _control_label(item):
    """Return a short human-readable label for a control-structure item or branch."""
    item_type = getattr(item, "type", None) or ""
    condition = getattr(item, "condition", None)
    if condition:
        return f"{item_type} {condition}"
    if item_type == "FOR":
        variables = " ".join(getattr(item, "variables", []))
        flavor = getattr(item, "flavor", "IN")
        values = "  ".join(getattr(item, "values", []))
        return f"FOR {variables} {flavor} {values}".strip()
    if item_type:
        return item_type
    name = getattr(item, "name", None)
    return name if name else "?"


def _find_keyword_paths(body, keyword_set, path=None):
    """Find paths through control structures to keyword calls in keyword_set.

    Returns a list of " > ".join(segment_list) strings, one per reachable call site.
    """
    if path is None:
        path = []
    results = []
    for item in body:
        name = getattr(item, "name", None)
        if name and name in keyword_set:
            results.append(" > ".join(path + [name]))
            continue
        if hasattr(item, "branches"):
            for branch in item.branches:
                if hasattr(branch, "body") and branch.body:
                    results.extend(
                        _find_keyword_paths(
                            branch.body, keyword_set, path + [_control_label(branch)]
                        )
                    )
        elif hasattr(item, "body") and item.body:
            results.extend(
                _find_keyword_paths(
                    item.body, keyword_set, path + [_control_label(item)]
                )
            )
    return results


def _iter_all_tests():
    """Yield (filepath, test) for every test case in all robot test directories."""
    for path in cfg.ROBOT_TEST_PATHS:
        for root, dirs, files in os.walk(path):
            dirs.sort()
            for filename in sorted(files):
                if not filename.endswith(".robot"):
                    continue
                filepath = os.path.join(root, filename)
                for test in get_test_cases_from_file(filepath):
                    yield filepath, test


def _insert_skip_if_lines(filepath, test_name, conditions):
    """Insert Skip If lines into a robot file after [Documentation]/[Tags] of test_name.

    conditions: list of condition strings (e.g. ["not ${TESTS_IN_FIRMWARE_SUPPORT}"]).
    Returns True if the file was modified.
    """
    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.readlines()

    test_header_idx = None
    for i, line in enumerate(lines):
        if (
            not line.startswith(" ")
            and not line.startswith("\t")
            and line.rstrip() == test_name
        ):
            test_header_idx = i
            break

    if test_header_idx is None:
        return False

    indent = "    "
    for j in range(test_header_idx + 1, len(lines)):
        m = re.match(r"^(\s+)\S", lines[j])
        if m:
            indent = m.group(1)
            break

    insert_pos = test_header_idx + 1
    for j in range(test_header_idx + 1, len(lines)):
        stripped = lines[j].rstrip()
        if (
            re.match(r"^\s+\[Documentation\]", stripped)
            or re.match(r"^\s+\.\.\.", stripped)
            or re.match(r"^\s+\[Tags\]", stripped)
        ):
            insert_pos = j + 1
        else:
            break

    test_id = test_name.split()[0] if test_name else "?"
    new_lines = [
        f"{indent}Skip If    {cond}    {test_id} not supported\n" for cond in conditions
    ]
    for offset, new_line in enumerate(new_lines):
        lines.insert(insert_pos + offset, new_line)

    with open(filepath, "w", encoding="utf-8") as f:
        f.writelines(lines)

    return True


# ---------------------------------------------------------------------------
# Semiauto check
# ---------------------------------------------------------------------------


def semiauto_valid(test):
    """Return True if the test's semiauto tagging is consistent.

    A test that calls a manual keyword must carry the 'semiauto' tag.
    A test tagged 'not_semiauto' is explicitly asserted to be fully automated
    (the manual keyword is unreachable in automated runs) and is always valid.
    """
    if "not_semiauto" in test.tags:
        return True
    return not _has_keyword(test, cfg.MANUAL_KEYWORDS) or "semiauto" in test.tags


def find_semiauto_violations():
    """Find tests missing the semiauto tag that call manual keywords.

    Returns list of (filepath, test_name, is_unambiguous, call_paths) tuples.
    is_unambiguous=True means the call is directly in the test body (not nested
    inside IF/FOR/WHILE), so the tag can be added automatically.
    call_paths is populated only for ambiguous (nested) cases.
    """
    violations = []
    for filepath, test in _iter_all_tests():
        if not semiauto_valid(test):
            is_direct = _has_direct_keyword(test, cfg.MANUAL_KEYWORDS)
            call_paths = (
                [] if is_direct else _find_keyword_paths(test.body, cfg.MANUAL_KEYWORDS)
            )
            violations.append((filepath, test.name, is_direct, call_paths))
    return violations


def fix_semiauto_tag_in_file(filepath, test_name):
    """Add semiauto tag to a named test in a robot file (text-based edit).

    Appends to an existing [Tags] line, or inserts a new one if absent.
    Returns True if the file was modified.
    """
    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.readlines()

    in_test = False
    test_header_idx = None
    tags_line_idx = None

    for i, line in enumerate(lines):
        stripped = line.rstrip()
        if (
            not line.startswith(" ")
            and not line.startswith("\t")
            and stripped == test_name
        ):
            in_test = True
            test_header_idx = i
            tags_line_idx = None
            continue
        if in_test:
            # Blank lines are allowed inside test bodies — skip, don't stop.
            if not stripped:
                continue
            if not line.startswith(" ") and not line.startswith("\t"):
                break
            m = re.match(r"^(\s+)\[Tags\](.*)", line)
            if m:
                tags_line_idx = i
                break

    if test_header_idx is None:
        return False

    if tags_line_idx is not None:
        # Parse existing tags, remove 'automated' (test is unambiguously semiauto),
        # and insert 'semiauto' in its place — or append if 'automated' was absent.
        tag_line = lines[tags_line_idx].rstrip()
        header_m = re.match(r"^(\s+\[Tags\]\s+)(.*)", tag_line)
        if header_m:
            kw_prefix = header_m.group(1)
            existing_tags = [
                t for t in re.split(r"\s{2,}", header_m.group(2)) if t.strip()
            ]
            new_tags = []
            semiauto_placed = False
            for tag in existing_tags:
                if tag == "automated":
                    new_tags.append("semiauto")
                    semiauto_placed = True
                else:
                    new_tags.append(tag)
            if not semiauto_placed:
                new_tags.append("semiauto")
            lines[tags_line_idx] = kw_prefix + "    ".join(new_tags) + "\n"
        else:
            lines[tags_line_idx] = tag_line + "    semiauto\n"
    else:
        # Determine indent from first body line
        indent = "    "
        for j in range(test_header_idx + 1, len(lines)):
            m = re.match(r"^(\s+)\S", lines[j])
            if m:
                indent = m.group(1)
                break

        # Insert after [Documentation] block (including continuation lines) so that
        # [Tags] appears after [Documentation] per robocop ORD01 rule.
        # If there is no [Documentation], insert immediately after the test header.
        insert_pos = test_header_idx + 1
        in_doc = False
        for j in range(test_header_idx + 1, len(lines)):
            stripped = lines[j].rstrip()
            if not stripped or (not lines[j][0].isspace()):
                break
            if re.match(r"^\s+\[Documentation\]", stripped):
                in_doc = True
                insert_pos = j + 1
            elif in_doc and re.match(r"^\s+\.\.\.", stripped):
                insert_pos = j + 1
            elif in_doc:
                break

        lines.insert(insert_pos, f"{indent}[Tags]    semiauto\n")

    with open(filepath, "w", encoding="utf-8") as f:
        f.writelines(lines)

    return True


# ---------------------------------------------------------------------------
# env_skips check: firmware-entry + OS-boot keywords
# ---------------------------------------------------------------------------


def firmware_skip_valid(test):
    """Return True if the test has TESTS_IN_FIRMWARE_SUPPORT skip when using firmware-entry keywords.

    A test tagged 'not_firmware' is exempt (firmware keyword is on an unreachable branch).
    """
    if "not_firmware" in test.tags:
        return True
    return not _has_keyword(test, cfg.FIRMWARE_ENTRY_KEYWORDS) or _has_skip_var(
        test, "TESTS_IN_FIRMWARE_SUPPORT"
    )


def osboot_skip_valid(test):
    """Return True if the test has an appropriate Skip If for every OS-booting keyword call.

    Only evaluates calls with known (constant) OS args; runtime variable args are
    ignored here and reported separately by find_env_skip_violations().
    """
    boot_calls = _find_os_boot_calls(test.body)
    if not boot_calls:
        return True
    full = " ".join(_body_and_suite_strings(test))
    for _kw_name, os_arg in boot_calls:
        specs = cfg.BOOT_ARG_SKIP_SPECS.get(os_arg)
        if specs is None:
            continue
        if not any(sv in full for sv, _ in specs):
            return False
    return True


def _find_os_boot_calls(body):
    """Recursively find OS-booting keyword calls in a body.

    Returns a list of (keyword_name, os_arg) tuples where os_arg is the first
    argument string as it appears in robot source (e.g. "${ENV_ID_UBUNTU}"), or
    None if no arg is present.  Boot And Login To Windows is normalized to
    os_arg="${ENV_ID_WINDOWS}" (implicit).
    """
    results = []
    for item in body:
        name = getattr(item, "name", None)
        if name in cfg.OS_BOOT_KEYWORDS:
            if name == "Boot And Login To Windows":
                results.append((name, "${ENV_ID_WINDOWS}"))
            else:
                args = getattr(item, "args", ())
                results.append((name, args[0] if args else None))
        if hasattr(item, "body") and item.body:
            results.extend(_find_os_boot_calls(item.body))
        if hasattr(item, "branches"):
            for branch in item.branches:
                if hasattr(branch, "body") and branch.body:
                    results.extend(_find_os_boot_calls(branch.body))
    return results


def _firmware_violation(test):
    """Return (is_direct, call_paths) if test fails the firmware skip check, else None."""
    if "not_firmware" in test.tags:
        return None
    if not _has_keyword(test, cfg.FIRMWARE_ENTRY_KEYWORDS):
        return None
    if _has_skip_var(test, "TESTS_IN_FIRMWARE_SUPPORT"):
        return None
    is_direct = _has_direct_keyword(test, cfg.FIRMWARE_ENTRY_KEYWORDS)
    paths = (
        [] if is_direct else _find_keyword_paths(test.body, cfg.FIRMWARE_ENTRY_KEYWORDS)
    )
    return (is_direct, paths)


def _osboot_violation(test):
    """Return (missing_specs, ambiguous_calls) for OS-boot skip violations.

    missing_specs   — [(os_arg, specs)] for calls with known args that lack a skip
    ambiguous_calls — [(keyword_name, raw_arg)] for calls with runtime variable args
    """
    boot_calls = _find_os_boot_calls(test.body)
    if not boot_calls:
        return [], []
    full = " ".join(_body_and_suite_strings(test))
    missing_specs, ambiguous_calls, seen = [], [], set()
    for kw_name, os_arg in boot_calls:
        specs = cfg.BOOT_ARG_SKIP_SPECS.get(os_arg)
        if specs is None:
            pair = (kw_name, os_arg)
            if pair not in ambiguous_calls:
                ambiguous_calls.append(pair)
            continue
        if os_arg in seen:
            continue
        seen.add(os_arg)
        if not any(sv in full for sv, _ in specs):
            missing_specs.append((os_arg, specs))
    return missing_specs, ambiguous_calls


def find_env_skip_violations():
    """Find all environment-skip violations (firmware and OS-boot) in one pass.

    Returns list of (filepath, test_name, fw_violation, ob_missing, ob_ambiguous) tuples:
      fw_violation  — None | (is_direct, call_paths)
      ob_missing    — [(os_arg, specs)] for OS-boot calls missing a skip
      ob_ambiguous  — [(keyword_name, raw_arg)] for OS-boot calls with runtime args
    """
    violations = []
    for filepath, test in _iter_all_tests():
        fw = _firmware_violation(test)
        ob_miss, ob_ambig = _osboot_violation(test)
        if fw is not None or ob_miss or ob_ambig:
            violations.append((filepath, test.name, fw, ob_miss, ob_ambig))
    return violations


def fix_env_skip_in_file(filepath, test_name, fw_violation, ob_missing):
    """Insert all missing Skip If lines for a test in one file write.

    fw_violation: (is_direct, call_paths) from find_env_skip_violations, or None.
                  Only direct (top-level) firmware violations are auto-fixed.
    ob_missing:   [(os_arg, specs)] from find_env_skip_violations — all are fixed.
    Returns True if the file was modified.
    """
    conditions = []
    if fw_violation is not None:
        is_direct, _paths = fw_violation
        if is_direct:
            conditions.append("not ${TESTS_IN_FIRMWARE_SUPPORT}")
    for _os_arg, specs in ob_missing:
        conditions.extend(cond for _sv, cond in specs)
    if not conditions:
        return False
    return _insert_skip_if_lines(filepath, test_name, conditions)


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
    return [d for d in diff if not d.startswith((" ", "@@")) and "DEPRECATED" not in d]


def check_id_unique():
    """Return {id: [filepath, ...]} for test IDs that appear in more than one test.

    A duplicate means two tests claim the same ID.  The dict-based robot extraction
    silently keeps only the last one, so the other is invisible to mapping checks.
    """
    from collections import defaultdict

    seen = defaultdict(list)
    for filepath, test in _iter_all_tests():
        tid = get_id(test)
        if tid:
            seen[tid].append(filepath)
    return {tid: paths for tid, paths in seen.items() if len(paths) > 1}


def get_tests_from_docs():
    """Extract {id: name} from unified-test-documentation markdown files.

    Lines containing '<!-- OSFV_DOCS_SKIP -->' are excluded from comparison.
    """
    tests = {}
    for dirpath, _, filenames in os.walk(cfg.DOCS_PATH):
        for filename in sorted(filenames):
            if not filename.endswith(".md"):
                continue
            filepath = os.path.join(dirpath, filename)
            with open(filepath, "r", encoding="utf-8") as f:
                for line in f:
                    m = cfg.DOCS_TEST_ID_PATTERN.match(line.rstrip())
                    if not m:
                        continue
                    test_id, test_name = m.group(1), m.group(2)
                    if cfg.OSFV_DOCS_SKIP_PATTERN.search(test_name):
                        continue
                    tests[test_id] = test_name
    return tests


_DIR_TO_MODULE = {
    "dasharo-compatibility": "Dasharo Compatibility",
    "dasharo-performance": "Dasharo Performance",
    "dasharo-security": "Dasharo Security",
    "dasharo-stability": "Dasharo Stability",
}


def _get_tests_from_robot_with_module():
    """Extract {id: (name, module)} from all robot test files."""
    tests = {}
    for path in cfg.ROBOT_TEST_PATHS:
        module = _DIR_TO_MODULE.get(os.path.basename(path), "Unknown")
        for t in get_test_cases_from_dir(path):
            m = cfg.ROBOT_TEST_ID_PATTERN.match(t.name)
            if m:
                tests[m.group(1)] = (m.group(2), module)
    return tests


def get_tests_from_robot():
    """Extract {id: name} from all robot test files."""
    return {tid: name for tid, (name, _) in _get_tests_from_robot_with_module().items()}


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


def compare_names_robot_json(json_path="test_cases.json"):
    """Return list of (id, robot_name, json_name) for tests with mismatched names."""
    robot = get_tests_from_robot()
    json_tests = get_tests_from_json(json_path)
    return sorted(
        [
            (test_id, robot[test_id], json_tests[test_id])
            for test_id in robot
            if test_id in json_tests and robot[test_id] != json_tests[test_id]
        ]
    )


_SUITE_SORT_ID_PATTERN = re.compile(r"^([A-Z]{2,9}[0-9]{1,10})\.([0-9]+)")


def _suite_sort_key(test):
    """Return (env_id_int, prefix_number_str) sort key, or None if ID cannot be parsed."""
    m = _SUITE_SORT_ID_PATTERN.match(test.name)
    if not m:
        return None
    return (int(m.group(2)), m.group(1))


def check_suite_sorted():
    """Check that tests in each robot file are sorted: first by ENV ID, then by prefix+number.

    Suites that carry 'Metadata    ORDER_SENSITIVE    <reason>' in their
    *** Settings *** section are exempt from this check.  Use this when test
    execution order is meaningful (e.g. an install test must precede a boot
    test).  Automatic reordering is intentionally not supported — it is too
    dangerous when order carries semantic meaning.

    Returns a list of (filepath, violations) where each violation is a tuple
    (out_of_order_test_name, preceding_test_name).
    """
    results = []
    builder = TestSuiteBuilder()
    for path in cfg.ROBOT_TEST_PATHS:
        for root, dirs, files in os.walk(path):
            dirs.sort()
            for filename in sorted(files):
                if not filename.endswith(".robot"):
                    continue
                filepath = os.path.join(root, filename)

                try:
                    suite = builder.build(filepath)
                except Exception as e:
                    print(f"Error building test suite from {filepath}: {e}. Skipping.")
                    continue

                if "ORDER_SENSITIVE" in suite.metadata:
                    continue

                finder = TestCasesFinder()
                suite.visit(finder)
                tests = [
                    t for t in finder.tests if cfg.TEST_CASE_ID_PATTERN.search(t.name)
                ]

                keyed = [(t, _suite_sort_key(t)) for t in tests]
                keyed = [(t, key) for t, key in keyed if key is not None]

                if len(keyed) < 2:
                    continue

                file_violations = []
                for i in range(1, len(keyed)):
                    prev_t, prev_key = keyed[i - 1]
                    curr_t, curr_key = keyed[i]
                    if curr_key < prev_key:
                        file_violations.append((curr_t.name, prev_t.name))

                if file_violations:
                    results.append((filepath, file_violations))

    return results


def _insert_previous_id_in_robot_doc(new_id, old_id):
    """Add 'Previous IDs: old_id' to the [Documentation] of the test with new_id.

    Searches all robot test directories.  If a 'Previous IDs:' continuation line
    already exists, appends old_id to it.  Otherwise inserts a new continuation
    line after the last [Documentation] / '...' line.
    The line format matches list-tests-from-robot.sh expectation:
        '    ...    Previous IDs: OLD1 OLD2'
    Returns True if the file was modified.
    """
    for filepath, test in _iter_all_tests():
        if get_id(test) != new_id:
            continue
        with open(filepath, "r", encoding="utf-8") as f:
            lines = f.readlines()

        # Locate the test header line
        header_idx = None
        for i, line in enumerate(lines):
            if not line.startswith((" ", "\t")) and line.rstrip() == test.name:
                header_idx = i
                break
        if header_idx is None:
            return False

        # Walk through the test body to find [Documentation] span
        doc_end = None
        indent = "    "
        in_doc = False
        for j in range(header_idx + 1, len(lines)):
            stripped = lines[j].rstrip()
            if not stripped:
                break
            if not lines[j][0].isspace():
                break
            if re.match(r"^\s+\[Documentation\]", stripped):
                in_doc = True
                doc_end = j
                m = re.match(r"^(\s+)", lines[j])
                if m:
                    indent = m.group(1)
            elif in_doc and re.match(r"^\s+\.\.\.", stripped):
                doc_end = j
            elif in_doc:
                break

        if doc_end is None:
            return False

        # Append to an existing Previous IDs line if present
        for j in range(header_idx + 1, doc_end + 1):
            if "Previous IDs:" in lines[j]:
                lines[j] = lines[j].rstrip() + f" {old_id}\n"
                with open(filepath, "w", encoding="utf-8") as f:
                    f.writelines(lines)
                return True

        # Insert a new continuation line after doc_end
        new_line = f"{indent}...    Previous IDs: {old_id}\n"
        lines.insert(doc_end + 1, new_line)
        with open(filepath, "w", encoding="utf-8") as f:
            f.writelines(lines)
        return True
    return False


def fix_id_mappings(json_path="test_cases.json"):
    """Sync test_cases.json with robot tests.

    For each robot test whose ID is absent from JSON (active entries only):
    - If a non-deprecated JSON entry with the same name exists and has no
      robot counterpart, treat it as an ID rename:
        * Set changed_to=new_id on the old entry.
        * Add a new entry for new_id.
        * Insert 'Previous IDs: old_id' in the robot [Documentation].
    - Otherwise treat it as a genuinely new test and add a plain entry.

    JSON entries not in robot are warned about but never removed.

    Returns {'added': [(id, name, module)], 'renamed': [(old_id, new_id, name)]}.
    """
    robot = _get_tests_from_robot_with_module()
    json_tests = get_tests_from_json(json_path)

    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    only_in_robot = {tid: v for tid, v in robot.items() if tid not in json_tests}
    only_in_json = {tid for tid in json_tests if tid not in robot}

    # name → old_id for JSON-only active entries (candidate rename sources)
    json_only_by_name = {json_tests[tid]: tid for tid in only_in_json}

    added, renamed = [], []

    for new_id, (name, module) in sorted(only_in_robot.items()):
        if name in json_only_by_name:
            old_id = json_only_by_name.pop(name)
            for item in data:
                if item["doc"]["_id"] == old_id:
                    item["doc"]["changed_to"] = new_id
                    break
            data.append({"doc": {"_id": new_id, "name": name, "module": module}})
            renamed.append((old_id, new_id, name))
            _insert_previous_id_in_robot_doc(new_id, old_id)
        else:
            data.append({"doc": {"_id": new_id, "name": name, "module": module}})
            added.append((new_id, name, module))

    if added or renamed:
        data.sort(key=lambda item: item["doc"]["_id"])
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
            f.write("\n")

    return {"added": added, "renamed": renamed}


def fix_names_in_json(json_path="test_cases.json"):
    """Update test_cases.json names to match robot names.

    Robot is treated as the source of truth for test names (it is the
    implementation).  Returns list of (id, old_name, new_name) tuples updated.
    """
    mismatches = compare_names_robot_json(json_path)
    if not mismatches:
        return []

    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    id_to_robot_name = {tid: rname for tid, rname, _ in mismatches}
    updated = []
    for item in data:
        tid = item["doc"]["_id"]
        if tid in id_to_robot_name:
            old = item["doc"]["name"]
            item["doc"]["name"] = id_to_robot_name[tid]
            updated.append((tid, old, id_to_robot_name[tid]))

    if updated:
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
            f.write("\n")

    return updated


def compare_modules_robot_json(json_path="test_cases.json"):
    """Return list of (id, robot_module, json_module) for tests with mismatched modules.

    The robot module is derived from the test directory via _DIR_TO_MODULE.
    Only non-deprecated JSON entries are compared.
    """
    robot = _get_tests_from_robot_with_module()  # {id: (name, module)}
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    json_modules = {
        item["doc"]["_id"]: item["doc"].get("module", "")
        for item in data
        if "changed_to" not in item.get("doc", {})
    }
    return sorted(
        [
            (tid, robot[tid][1], json_modules[tid])
            for tid in robot
            if tid in json_modules and robot[tid][1] != json_modules[tid]
        ]
    )


def fix_modules_in_json(json_path="test_cases.json"):
    """Update test_cases.json module fields to match the robot file's directory.

    Robot directory is the source of truth for module assignment.
    Returns list of (id, old_module, new_module) tuples updated.
    """
    mismatches = compare_modules_robot_json(json_path)
    if not mismatches:
        return []

    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    id_to_robot_module = {tid: rmod for tid, rmod, _ in mismatches}
    updated = []
    for item in data:
        tid = item["doc"]["_id"]
        if tid in id_to_robot_module:
            old = item["doc"].get("module", "")
            item["doc"]["module"] = id_to_robot_module[tid]
            updated.append((tid, old, id_to_robot_module[tid]))

    if updated:
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
            f.write("\n")

    return updated


if __name__ == "__main__":
    from pprint import pprint

    pprint(OsConfig().get_id_to_friendly_mapping())
