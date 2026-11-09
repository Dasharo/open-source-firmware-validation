# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Load and check the expected results of a Source.

docs/drtm-report.md describes the files. One file per platform, firmware and
kernel, <platform>-<firmware>-<kernel>.yaml, in the Source's expectations
directory, and a references.yaml next to them with the known deviations.
"""

import re
from pathlib import Path

import yaml
from robot.api import TestSuiteBuilder

RESULTS = ("pass", "fail", "skip", "unknown")
META_KEYS = {"platform", "firmware", "description", "kernel", "evidence"}
ENTRY_KEYS = {"result", "refs", "basis", "note"}
TEST_ID = re.compile(r"^[A-Z]{3,8}[0-9]{3}\.[0-9]{3}$")


class ExpectationError(Exception):
    """An expectation file that does not follow docs/drtm-report.md."""


def load_tests(suite_dirs):
    """Returns {test ID: set of tags} of the suites in ``suite_dirs``."""
    tests = {}
    for suite_dir in suite_dirs:
        suite = TestSuiteBuilder().build(str(suite_dir))
        for test in suite.all_tests:
            tests[test.name.split()[0]] = set(test.tags)
    return tests


def other_paths(tags, evidence):
    """Returns the path:NAME tags in ``tags`` of an evidence path other than
    ``evidence``. path:log is on every path."""
    return {
        tag
        for tag in tags
        if tag.startswith("path:") and tag not in ("path:log", f"path:{evidence}")
    }


def load_references(path):
    """Returns the references of ``path``, {ID: {title, requirement, link}}."""
    data = yaml.safe_load(Path(path).read_text())
    if not isinstance(data, dict):
        raise ExpectationError(f"{path}: not a mapping of reference IDs")
    for ref, value in data.items():
        if not isinstance(value, dict) or not value.get("title"):
            raise ExpectationError(f"{path}: {ref} has no title")
    return data


def load_expectations(path, references, tests, evidences, suites="the suites"):
    """Returns the metadata and the entries of the expectation file ``path``,
    each entry as {result, refs, basis, note}. ``evidences`` are the evidence
    paths a file can have, and ``suites`` says where ``tests`` come from, for
    the messages. Raises ExpectationError on anything docs/drtm-report.md
    does not allow."""
    path = Path(path)
    data = yaml.safe_load(path.read_text())
    errors = []
    if not isinstance(data, dict):
        raise ExpectationError(f"{path}: not a mapping")
    meta = {key: data.get(key) for key in META_KEYS}
    for key in sorted(META_KEYS - {"description"}):
        if not isinstance(meta[key], str) or not meta[key]:
            errors.append(f"{key} is missing")
    unknown = set(data) - META_KEYS - {"basis", "default", "expectations"}
    if unknown:
        errors.append(f"unknown keys {sorted(unknown)}")
    evidence = meta["evidence"]
    if evidence not in evidences:
        errors.append(
            f"evidence is {evidence!r}, expected one of {', '.join(evidences)}"
        )
    expected_name = f"{meta['platform']}-{meta['firmware']}-{meta['kernel']}.yaml"
    if path.name != expected_name:
        errors.append(f"the file of these settings is {expected_name}")
    meta["default"] = data.get("default", "pass")
    if meta["default"] not in ("pass", "unknown"):
        errors.append(f"default is {meta['default']!r}, expected pass or unknown")

    entries = {}
    for test_id, value in (data.get("expectations") or {}).items():
        where = f"{test_id}:"
        if not TEST_ID.match(str(test_id)):
            errors.append(f"{where} not a test ID")
            continue
        if test_id not in tests:
            errors.append(f"{where} no such test in {suites}")
        else:
            left_out = other_paths(tests[test_id], evidence)
            if left_out:
                errors.append(
                    f"{where} tagged {', '.join(sorted(left_out))}, so a {evidence} run leaves it out"
                )
        entry = {"result": value} if isinstance(value, str) else value
        if not isinstance(entry, dict):
            errors.append(f"{where} neither a result nor a mapping")
            continue
        if set(entry) - ENTRY_KEYS:
            errors.append(f"{where} unknown keys {sorted(set(entry) - ENTRY_KEYS)}")
        result = entry.get("result")
        if result not in RESULTS:
            errors.append(
                f"{where} result is {result!r}, expected one of {', '.join(RESULTS)}"
            )
        refs = entry.get("refs") or []
        if not isinstance(refs, list):
            errors.append(f"{where} refs is not a list")
            refs = []
        for ref in refs:
            if ref not in references:
                errors.append(f"{where} no reference {ref!r} in references.yaml")
        if result == "fail" and not refs:
            errors.append(f"{where} an expected failure needs refs")
        entries[test_id] = {
            "result": result,
            "refs": refs,
            "basis": entry.get("basis", data.get("basis")),
            "note": entry.get("note"),
        }
    if errors:
        raise ExpectationError("\n".join(f"{path}: {error}" for error in errors))
    return meta, entries


def expectation(meta, entries, test_id):
    """Returns the entry of ``test_id``, or for a test the file does not list
    None when its default is pass and an unknown entry otherwise."""
    if test_id in entries:
        return entries[test_id]
    if meta["default"] == "unknown":
        return {"result": "unknown", "refs": [], "basis": None, "note": None}
    return None


def compare(entry, status):
    """Compares a result, robot's ``status`` PASS, FAIL or SKIP, with the
    expectation ``entry`` or None, as expectation() returns them. Returns one
    of:

    - "expected": the result is the expected one;
    - "regression": it differs, and is worse than expected;
    - "improved": an expected failure or skip passed;
    - "unknown": the expectation is unknown.
    """
    result = status.lower()
    if entry is None:
        return "expected" if result == "pass" else "regression"
    if entry["result"] == "unknown":
        return "unknown"
    if result == entry["result"]:
        return "expected"
    if result == "pass":
        return "improved"
    return "regression"


def check(source, paths=()):
    """Checks the expectation files ``paths`` of ``source``, every one in its
    expectations directory without any. Returns the error messages."""
    try:
        references = load_references(source.references)
    except (OSError, yaml.YAMLError, ExpectationError) as err:
        return [str(err)]
    tests = source.tests()
    if not paths:
        paths = source.expectation_files()
    errors = []
    for path in paths:
        if Path(path).resolve() == Path(source.references).resolve():
            continue
        try:
            load_expectations(
                path, references, tests, source.evidences, source.suites_text()
            )
        except (OSError, yaml.YAMLError, ExpectationError) as err:
            errors.append(str(err))
    return errors
