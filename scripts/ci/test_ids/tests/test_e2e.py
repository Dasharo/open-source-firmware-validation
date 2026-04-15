# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""End-to-end tests for the test_ids CI checking library.

Each test writes real .robot files and/or test_cases.json to a temporary
directory, then calls library functions directly and asserts results.

python -m pytest scripts/ci/test_ids/tests/test_e2e.py
"""

import json
import sys
from pathlib import Path

# Make the parent directory importable so we can import the library directly.
sys.path.insert(0, str(Path(__file__).parent.parent))

import test_id_checking_lib as lib
import test_ids_config as cfg

# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------

ROBOT_HEADER = """\
*** Settings ***


*** Test Cases ***
"""


def write_robot(path: Path, body: str) -> Path:
    """Write a minimal .robot file with Settings + Test Cases sections."""
    path.write_text(ROBOT_HEADER + body, encoding="utf-8")
    return path


def write_json(path: Path, entries: list) -> Path:
    """Write test_cases.json at *path* with the given list of doc dicts."""
    data = [{"doc": e} for e in entries]
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    return path


def get_single_test(robot_path: Path):
    """Return the first test case parsed from a robot file."""
    tests = lib.get_test_cases_from_file(str(robot_path))
    assert tests, f"No tests found in {robot_path}"
    return tests[0]


# ---------------------------------------------------------------------------
# 1. id_valid
# ---------------------------------------------------------------------------


class TestIdValid:
    def test_valid_id(self, tmp_path):
        f = write_robot(
            tmp_path / "suite.robot", "TST001.201 Valid test\n    Log    ok\n"
        )
        t = get_single_test(f)
        assert lib.id_valid(t)

    def test_invalid_id_prefix_too_short(self, tmp_path):
        # Two-letter prefix fails the strict pattern (requires 3-9 letters)
        f = write_robot(
            tmp_path / "suite.robot", "TS001.201 Short prefix\n    Log    ok\n"
        )
        t = get_single_test(f)
        assert not lib.id_valid(t)

    def test_invalid_id_case_number_too_long(self, tmp_path):
        # 4-digit case number fails (must be exactly 3)
        f = write_robot(
            tmp_path / "suite.robot", "TST0001.201 Long case\n    Log    ok\n"
        )
        t = get_single_test(f)
        assert not lib.id_valid(t)

    def test_pseudo_helper_exempt(self):
        # Tests whose names start with _ are exempt from ID validation.
        # Such tests are filtered out by get_test_cases_from_file() (they don't
        # match the discovery pattern), so we test id_valid() directly with a
        # fake test object representing what a pseudo-helper would look like.
        class _FakeTest:
            name = "_helper keyword"
            tags = []

        assert lib.id_valid(_FakeTest())


# ---------------------------------------------------------------------------
# 2. os_valid
# ---------------------------------------------------------------------------


class TestOsValid:
    def test_os_id_and_name_both_present(self, tmp_path):
        # .201 maps to Ubuntu - both must appear together
        f = write_robot(
            tmp_path / "suite.robot",
            "TST001.201 My test (Ubuntu)\n    Log    ok\n",
        )
        t = get_single_test(f)
        assert lib.os_valid(t)

    def test_os_id_present_name_absent_fails(self, tmp_path):
        # .201 is Ubuntu but the friendly name is missing
        f = write_robot(
            tmp_path / "suite.robot",
            "TST001.201 My test\n    Log    ok\n",
        )
        t = get_single_test(f)
        assert not lib.os_valid(t)

    def test_generic_env_no_os_name_ok(self, tmp_path):
        # .001 is unspecified - no OS name required
        f = write_robot(
            tmp_path / "suite.robot",
            "TST001.001 Generic test\n    Log    ok\n",
        )
        t = get_single_test(f)
        assert lib.os_valid(t)


# ---------------------------------------------------------------------------
# 3. os_skip_valid
# ---------------------------------------------------------------------------


class TestOsSkipValid:
    def test_os_env_with_skip_passes(self, tmp_path):
        f = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.201 Ubuntu test\n"
                "    [Documentation]    Test\n"
                "    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    not supported\n"
                "    Log    ok\n"
            ),
        )
        t = get_single_test(f)
        assert lib.os_skip_valid(t)

    def test_os_env_without_skip_fails(self, tmp_path):
        f = write_robot(
            tmp_path / "suite.robot",
            "TST001.201 Ubuntu test\n    Log    ok\n",
        )
        t = get_single_test(f)
        assert not lib.os_skip_valid(t)

    def test_generic_env_without_skip_passes(self, tmp_path):
        f = write_robot(
            tmp_path / "suite.robot",
            "TST001.001 Generic test\n    Log    ok\n",
        )
        t = get_single_test(f)
        assert lib.os_skip_valid(t)

    def test_generic_env_with_skip_is_not_flagged(self, tmp_path):
        # os_skip_valid() is one-directional: it only requires that non-0xx tests
        # *must* have an OS skip.  It does not flag 0xx tests that *have* a skip
        # as invalid - those are silently permitted by the implementation.
        f = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.001 Generic test\n"
                "    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    not supported\n"
                "    Log    ok\n"
            ),
        )
        t = get_single_test(f)
        assert lib.os_skip_valid(t)


# ---------------------------------------------------------------------------
# 4. semiauto_valid + fix_semiauto_tag_in_file
# ---------------------------------------------------------------------------


class TestSemiauto:
    def test_manual_keyword_without_tag_fails(self, tmp_path):
        f = write_robot(
            tmp_path / "suite.robot",
            "TST001.001 Manual test\n    Execute Manual Step    do it\n",
        )
        t = get_single_test(f)
        assert not lib.semiauto_valid(t)

    def test_manual_keyword_with_semiauto_tag_passes(self, tmp_path):
        f = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.001 Manual test\n"
                "    [Tags]    semiauto\n"
                "    Execute Manual Step    do it\n"
            ),
        )
        t = get_single_test(f)
        assert lib.semiauto_valid(t)

    def test_not_semiauto_tag_exempt(self, tmp_path):
        f = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.001 Manual test\n"
                "    [Tags]    not_semiauto\n"
                "    Execute Manual Step    do it\n"
            ),
        )
        t = get_single_test(f)
        assert lib.semiauto_valid(t)

    def test_fix_inserts_tags_line_when_absent(self, tmp_path, monkeypatch):
        robot_file = write_robot(
            tmp_path / "suite.robot",
            "TST001.001 Manual test\n    Execute Manual Step    do it\n",
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        violations = lib.find_semiauto_violations()
        assert len(violations) == 1
        filepath, test_name, is_direct, _ = violations[0]
        assert is_direct
        lib.fix_semiauto_tag_in_file(filepath, test_name)
        content = robot_file.read_text()
        assert "[Tags]    semiauto" in content

    def test_fix_inserts_tags_after_documentation(self, tmp_path, monkeypatch):
        # [Tags] must appear after [Documentation] per robocop ORD01 rule
        robot_file = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.001 Manual test\n"
                "    [Documentation]    This test does something.\n"
                "    ...    More details here.\n"
                "    Execute Manual Step    do it\n"
            ),
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        violations = lib.find_semiauto_violations()
        assert len(violations) == 1
        filepath, test_name, is_direct, _ = violations[0]
        lib.fix_semiauto_tag_in_file(filepath, test_name)
        lines = robot_file.read_text().splitlines()
        doc_last = max(i for i, ln in enumerate(lines) if "More details" in ln)
        tags_idx = next(i for i, ln in enumerate(lines) if "[Tags]" in ln)
        assert tags_idx == doc_last + 1, (
            f"[Tags] should be immediately after last doc line "
            f"(expected line {doc_last + 1}, got {tags_idx})"
        )

    def test_fix_replaces_automated_with_semiauto(self, tmp_path, monkeypatch):
        # For direct (unambiguous) cases the test is definitively semiauto —
        # 'automated' must be removed and replaced by 'semiauto', not kept alongside it.
        robot_file = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.001 Manual test\n"
                "    [Tags]    automated\n"
                "    Execute Manual Step    do it\n"
            ),
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        violations = lib.find_semiauto_violations()
        assert len(violations) == 1
        filepath, test_name, is_direct, _ = violations[0]
        lib.fix_semiauto_tag_in_file(filepath, test_name)
        content = robot_file.read_text()
        assert "semiauto" in content
        assert "automated" not in content

    def test_fix_preserves_other_tags_when_replacing_automated(
        self, tmp_path, monkeypatch
    ):
        robot_file = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.001 Manual test\n"
                "    [Tags]    automated    minimal-regression\n"
                "    Execute Manual Step    do it\n"
            ),
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        violations = lib.find_semiauto_violations()
        assert len(violations) == 1
        filepath, test_name, is_direct, _ = violations[0]
        lib.fix_semiauto_tag_in_file(filepath, test_name)
        content = robot_file.read_text()
        assert "semiauto" in content
        assert "automated" not in content
        assert "minimal-regression" in content


# ---------------------------------------------------------------------------
# 5. firmware_skip_valid + fix_env_skip_in_file
# ---------------------------------------------------------------------------


class TestFirmwareSkip:
    def test_firmware_keyword_with_skip_passes(self, tmp_path):
        f = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.001 FW test\n"
                "    [Documentation]    Test\n"
                "    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    not supported\n"
                "    Enter Setup Menu Tianocore\n"
            ),
        )
        t = get_single_test(f)
        assert lib.firmware_skip_valid(t)

    def test_firmware_keyword_without_skip_fails(self, tmp_path):
        f = write_robot(
            tmp_path / "suite.robot",
            "TST001.001 FW test\n    Enter Setup Menu Tianocore\n",
        )
        t = get_single_test(f)
        assert not lib.firmware_skip_valid(t)

    def test_not_firmware_tag_exempt(self, tmp_path):
        f = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.001 FW test\n"
                "    [Tags]    not_firmware\n"
                "    Enter Setup Menu Tianocore\n"
            ),
        )
        t = get_single_test(f)
        assert lib.firmware_skip_valid(t)

    def test_fix_inserts_firmware_skip(self, tmp_path, monkeypatch):
        robot_file = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.001 FW test\n"
                "    [Documentation]    Test\n"
                "    Enter Setup Menu Tianocore\n"
            ),
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        violations = lib.find_env_skip_violations()
        assert violations
        filepath, test_name, fw_violation, ob_missing, _ = violations[0]
        assert fw_violation is not None
        lib.fix_env_skip_in_file(filepath, test_name, fw_violation, ob_missing)
        content = robot_file.read_text()
        assert "not ${TESTS_IN_FIRMWARE_SUPPORT}" in content


# ---------------------------------------------------------------------------
# 6. osboot_skip_valid + fix_env_skip_in_file
# ---------------------------------------------------------------------------


class TestOsBootSkip:
    def test_boot_keyword_with_skip_passes(self, tmp_path):
        f = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.201 Ubuntu boot test\n"
                "    [Documentation]    Test\n"
                "    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    not supported\n"
                "    Boot And Login To OS    ${ENV_ID_UBUNTU}\n"
            ),
        )
        t = get_single_test(f)
        assert lib.osboot_skip_valid(t)

    def test_boot_keyword_without_skip_fails(self, tmp_path):
        f = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.201 Ubuntu boot test\n"
                "    Boot And Login To OS    ${ENV_ID_UBUNTU}\n"
            ),
        )
        t = get_single_test(f)
        assert not lib.osboot_skip_valid(t)

    def test_fix_inserts_ubuntu_skip(self, tmp_path, monkeypatch):
        robot_file = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.201 Ubuntu boot test\n"
                "    [Documentation]    Test\n"
                "    Boot And Login To OS    ${ENV_ID_UBUNTU}\n"
            ),
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        violations = lib.find_env_skip_violations()
        assert violations
        filepath, test_name, fw_violation, ob_missing, _ = violations[0]
        lib.fix_env_skip_in_file(filepath, test_name, fw_violation, ob_missing)
        content = robot_file.read_text()
        assert (
            "${TESTS_IN_UBUNTU_SUPPORT}" in content
            or "${TESTED_LINUX_DISTROS}" in content
        )


# ---------------------------------------------------------------------------
# 7. check_suite_sorted
# ---------------------------------------------------------------------------


class TestSuiteSorted:
    def test_sorted_by_env_then_prefix_passes(self, tmp_path, monkeypatch):
        write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.201 Test A Ubuntu\n"
                "    [Documentation]    Test\n"
                "    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    not supported\n"
                "    Log    ok\n"
                "TST001.301 Test A Windows\n"
                "    [Documentation]    Test\n"
                "    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    not supported\n"
                "    Log    ok\n"
            ),
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        assert lib.check_suite_sorted() == []

    def test_out_of_order_env_fails(self, tmp_path, monkeypatch):
        write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.301 Test A Windows\n"
                "    [Documentation]    Test\n"
                "    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    not supported\n"
                "    Log    ok\n"
                "TST001.201 Test A Ubuntu\n"
                "    [Documentation]    Test\n"
                "    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    not supported\n"
                "    Log    ok\n"
            ),
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        violations = lib.check_suite_sorted()
        assert violations

    def test_out_of_order_case_number_fails(self, tmp_path, monkeypatch):
        write_robot(
            tmp_path / "suite.robot",
            (
                "TST002.201 Test B Ubuntu\n"
                "    [Documentation]    Test\n"
                "    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    not supported\n"
                "    Log    ok\n"
                "TST001.201 Test A Ubuntu\n"
                "    [Documentation]    Test\n"
                "    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    not supported\n"
                "    Log    ok\n"
            ),
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        violations = lib.check_suite_sorted()
        assert violations

    def test_order_sensitive_metadata_exempts_suite(self, tmp_path, monkeypatch):
        # A suite with ORDER_SENSITIVE metadata must not be checked even if
        # the tests are out of order.
        path = tmp_path / "suite.robot"
        path.write_text(
            "*** Settings ***\n"
            "Metadata    ORDER_SENSITIVE    install must precede boot\n"
            "\n"
            "*** Test Cases ***\n"
            "TST001.301 Test A Windows\n"
            "    [Documentation]    Test\n"
            "    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    not supported\n"
            "    Log    ok\n"
            "TST001.201 Test A Ubuntu\n"
            "    [Documentation]    Test\n"
            "    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    not supported\n"
            "    Log    ok\n",
            encoding="utf-8",
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        # Despite being out of order, no violations reported
        assert lib.check_suite_sorted() == []


# ---------------------------------------------------------------------------
# 8. compare_names_robot_json + fix_names_in_json
# ---------------------------------------------------------------------------


class TestNamesMatch:
    def test_matching_names_returns_empty(self, tmp_path, monkeypatch):
        write_robot(
            tmp_path / "suite.robot",
            "TST001.201 My test\n    Log    ok\n",
        )
        json_path = tmp_path / "test_cases.json"
        write_json(
            json_path,
            [
                {
                    "_id": "TST001.201",
                    "name": "My test",
                    "module": "Dasharo Compatibility",
                }
            ],
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        mismatches = lib.compare_names_robot_json(str(json_path))
        assert mismatches == []

    def test_name_mismatch_reported(self, tmp_path, monkeypatch):
        write_robot(
            tmp_path / "suite.robot",
            "TST001.201 My test v2\n    Log    ok\n",
        )
        json_path = tmp_path / "test_cases.json"
        write_json(
            json_path,
            [
                {
                    "_id": "TST001.201",
                    "name": "My test",
                    "module": "Dasharo Compatibility",
                }
            ],
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        mismatches = lib.compare_names_robot_json(str(json_path))
        assert len(mismatches) == 1
        test_id, robot_name, json_name = mismatches[0]
        assert test_id == "TST001.201"
        assert robot_name == "My test v2"
        assert json_name == "My test"

    def test_fix_updates_json_name_from_robot(self, tmp_path, monkeypatch):
        write_robot(
            tmp_path / "suite.robot",
            "TST001.201 My test v2\n    Log    ok\n",
        )
        json_path = tmp_path / "test_cases.json"
        write_json(
            json_path,
            [
                {
                    "_id": "TST001.201",
                    "name": "My test",
                    "module": "Dasharo Compatibility",
                }
            ],
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        updated = lib.fix_names_in_json(str(json_path))
        assert len(updated) == 1
        assert updated[0] == ("TST001.201", "My test", "My test v2")
        data = json.loads(json_path.read_text())
        assert data[0]["doc"]["name"] == "My test v2"


# ---------------------------------------------------------------------------
# 9. fix_id_mappings - new tests (plain addition)
# ---------------------------------------------------------------------------


class TestFixIdMappingsAdd:
    def test_missing_robot_test_added_to_json(self, tmp_path, monkeypatch):
        write_robot(
            tmp_path / "suite.robot",
            "TST001.201 New test\n    Log    ok\n",
        )
        json_path = tmp_path / "test_cases.json"
        write_json(json_path, [])
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        result = lib.fix_id_mappings(str(json_path))
        assert result["renamed"] == []
        assert len(result["added"]) == 1
        assert result["added"][0][0] == "TST001.201"
        data = json.loads(json_path.read_text())
        assert data[0]["doc"]["_id"] == "TST001.201"
        assert data[0]["doc"]["name"] == "New test"
        assert (
            data[0]["doc"]["module"] == "Unknown"
        )  # tmp_path dir name is not a Dasharo dir

    def test_already_in_json_not_duplicated(self, tmp_path, monkeypatch):
        write_robot(
            tmp_path / "suite.robot",
            "TST001.201 Existing test\n    Log    ok\n",
        )
        json_path = tmp_path / "test_cases.json"
        write_json(
            json_path,
            [
                {
                    "_id": "TST001.201",
                    "name": "Existing test",
                    "module": "Dasharo Compatibility",
                }
            ],
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        result = lib.fix_id_mappings(str(json_path))
        assert result["added"] == []
        assert result["renamed"] == []
        data = json.loads(json_path.read_text())
        assert len(data) == 1

    def test_deprecated_entry_not_re_added(self, tmp_path, monkeypatch):
        # TST001.201 is in robot; JSON has TST001.201 deprecated (changed_to TST001.202)
        # and TST001.202 active. fix_id_mappings must not add TST001.201 again.
        write_robot(
            tmp_path / "suite.robot",
            "TST001.202 My test\n    Log    ok\n",
        )
        json_path = tmp_path / "test_cases.json"
        write_json(
            json_path,
            [
                {
                    "_id": "TST001.201",
                    "name": "My test",
                    "module": "Dasharo Compatibility",
                    "changed_to": "TST001.202",
                },
                {
                    "_id": "TST001.202",
                    "name": "My test",
                    "module": "Dasharo Compatibility",
                },
            ],
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        result = lib.fix_id_mappings(str(json_path))
        assert result["added"] == []
        assert result["renamed"] == []
        data = json.loads(json_path.read_text())
        assert len(data) == 2

    def test_json_sorted_after_add(self, tmp_path, monkeypatch):
        write_robot(
            tmp_path / "suite.robot",
            (
                "AAA999.001 AAA test\n    Log    ok\n"
                "ZZZ001.001 ZZZ test\n    Log    ok\n"
            ),
        )
        json_path = tmp_path / "test_cases.json"
        write_json(
            json_path,
            [
                {
                    "_id": "MMM001.001",
                    "name": "Middle test",
                    "module": "Dasharo Compatibility",
                }
            ],
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        lib.fix_id_mappings(str(json_path))
        data = json.loads(json_path.read_text())
        ids = [item["doc"]["_id"] for item in data]
        assert ids == sorted(ids)


# ---------------------------------------------------------------------------
# 10. fix_id_mappings - rename detection
# ---------------------------------------------------------------------------


class TestFixIdMappingsRename:
    def test_rename_detected_by_name_match(self, tmp_path, monkeypatch):
        """Robot has TST001.202, JSON has TST001.201 with same name - rename."""
        robot_file = write_robot(
            tmp_path / "suite.robot",
            "TST001.202 My test\n    [Documentation]    A test\n    Log    ok\n",
        )
        json_path = tmp_path / "test_cases.json"
        write_json(
            json_path,
            [
                {
                    "_id": "TST001.201",
                    "name": "My test",
                    "module": "Dasharo Compatibility",
                }
            ],
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        result = lib.fix_id_mappings(str(json_path))

        # Renamed, not added
        assert result["added"] == []
        assert len(result["renamed"]) == 1
        old_id, new_id, name = result["renamed"][0]
        assert old_id == "TST001.201"
        assert new_id == "TST001.202"
        assert name == "My test"

        # JSON: old entry gets changed_to, new entry appears
        data = json.loads(json_path.read_text())
        by_id = {item["doc"]["_id"]: item["doc"] for item in data}
        assert "changed_to" in by_id["TST001.201"]
        assert by_id["TST001.201"]["changed_to"] == "TST001.202"
        assert "TST001.202" in by_id
        assert "changed_to" not in by_id["TST001.202"]

        # Robot file: Previous IDs line inserted
        content = robot_file.read_text()
        assert "Previous IDs: TST001.201" in content

    def test_new_test_when_no_name_match(self, tmp_path, monkeypatch):
        """Robot has TST001.202 'New name', JSON has TST001.201 'Old name' - genuinely new."""
        write_robot(
            tmp_path / "suite.robot",
            "TST001.202 New name\n    [Documentation]    A test\n    Log    ok\n",
        )
        json_path = tmp_path / "test_cases.json"
        write_json(
            json_path,
            [
                {
                    "_id": "TST001.201",
                    "name": "Old name",
                    "module": "Dasharo Compatibility",
                }
            ],
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        result = lib.fix_id_mappings(str(json_path))

        assert result["renamed"] == []
        assert len(result["added"]) == 1
        assert result["added"][0][0] == "TST001.202"

        # Old entry must NOT get changed_to
        data = json.loads(json_path.read_text())
        by_id = {item["doc"]["_id"]: item["doc"] for item in data}
        assert "changed_to" not in by_id["TST001.201"]

    def test_chained_rename_uses_active_entry(self, tmp_path, monkeypatch):
        """
        TST001.201 (deprecated, changed_to TST001.202) is already in JSON.
        TST001.202 is active in JSON but no robot test for it.
        Robot has TST001.203 with same name as TST001.202 -> rename of TST001.202.
        """
        write_robot(
            tmp_path / "suite.robot",
            "TST001.203 My test\n    [Documentation]    A test\n    Log    ok\n",
        )
        json_path = tmp_path / "test_cases.json"
        write_json(
            json_path,
            [
                {
                    "_id": "TST001.201",
                    "name": "My test",
                    "module": "Dasharo Compatibility",
                    "changed_to": "TST001.202",
                },
                {
                    "_id": "TST001.202",
                    "name": "My test",
                    "module": "Dasharo Compatibility",
                },
            ],
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        result = lib.fix_id_mappings(str(json_path))

        assert result["added"] == []
        assert len(result["renamed"]) == 1
        old_id, new_id, _ = result["renamed"][0]
        assert old_id == "TST001.202"
        assert new_id == "TST001.203"

        data = json.loads(json_path.read_text())
        by_id = {item["doc"]["_id"]: item["doc"] for item in data}
        # TST001.201 still deprecated pointing to TST001.202 (unchanged)
        assert by_id["TST001.201"]["changed_to"] == "TST001.202"
        # TST001.202 now deprecated pointing to TST001.203
        assert by_id["TST001.202"]["changed_to"] == "TST001.203"
        assert "TST001.203" in by_id


# ---------------------------------------------------------------------------
# 11. _insert_previous_id_in_robot_doc
# ---------------------------------------------------------------------------


class TestInsertPreviousId:
    def test_inserts_new_previous_ids_line_after_doc(self, tmp_path, monkeypatch):
        robot_file = write_robot(
            tmp_path / "suite.robot",
            "TST001.202 My test\n    [Documentation]    A test\n    Log    ok\n",
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        result = lib._insert_previous_id_in_robot_doc("TST001.202", "TST001.201")
        assert result is True
        content = robot_file.read_text()
        assert "...    Previous IDs: TST001.201" in content

    def test_appends_to_existing_previous_ids_line(self, tmp_path, monkeypatch):
        robot_file = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.203 My test\n"
                "    [Documentation]    A test\n"
                "    ...    Previous IDs: TST001.201\n"
                "    Log    ok\n"
            ),
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        result = lib._insert_previous_id_in_robot_doc("TST001.203", "TST001.202")
        assert result is True
        content = robot_file.read_text()
        assert "Previous IDs: TST001.201 TST001.202" in content

    def test_returns_false_when_no_documentation_block(self, tmp_path, monkeypatch):
        # No [Documentation] line at all
        robot_file = write_robot(
            tmp_path / "suite.robot",
            "TST001.202 My test\n    Log    ok\n",
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        result = lib._insert_previous_id_in_robot_doc("TST001.202", "TST001.201")
        assert result is False
        # File must be unchanged
        assert "Previous IDs" not in robot_file.read_text()

    def test_returns_false_when_test_id_not_found(self, tmp_path, monkeypatch):
        write_robot(
            tmp_path / "suite.robot",
            "TST001.202 My test\n    [Documentation]    A test\n    Log    ok\n",
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        # Looking for a test that doesn't exist
        result = lib._insert_previous_id_in_robot_doc("TST999.999", "TST001.201")
        assert result is False


# ---------------------------------------------------------------------------
# 12. skip_msg_valid
# ---------------------------------------------------------------------------


class TestSkipMsgValid:
    def test_correct_id_in_message_passes(self, tmp_path):
        f = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.201 Ubuntu test\n"
                "    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TST001.201 not supported\n"
                "    Log    ok\n"
            ),
        )
        t = get_single_test(f)
        assert lib.skip_msg_valid(t)

    def test_wrong_env_in_message_fails(self, tmp_path):
        # Copy-paste error: message says .001 (firmware) but test is .201 (Ubuntu)
        f = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.201 Ubuntu test\n"
                "    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TST001.001 not supported\n"
                "    Log    ok\n"
            ),
        )
        t = get_single_test(f)
        assert not lib.skip_msg_valid(t)

    def test_wrong_case_number_in_message_fails(self, tmp_path):
        # Copy-paste error: message says TST002 but test is TST001
        f = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.201 Ubuntu test\n"
                "    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TST002.201 not supported\n"
                "    Log    ok\n"
            ),
        )
        t = get_single_test(f)
        assert not lib.skip_msg_valid(t)

    def test_free_form_message_ignored(self, tmp_path):
        # Messages not matching '<ID> not supported' are not checked
        f = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.201 Ubuntu test\n"
                "    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    feature not enabled\n"
                "    Log    ok\n"
            ),
        )
        t = get_single_test(f)
        assert lib.skip_msg_valid(t)

    def test_no_skip_if_passes(self, tmp_path):
        f = write_robot(
            tmp_path / "suite.robot",
            "TST001.201 Ubuntu test\n    Log    ok\n",
        )
        t = get_single_test(f)
        assert lib.skip_msg_valid(t)

    def test_fix_corrects_wrong_id_in_message(self, tmp_path, monkeypatch):
        robot_file = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.201 Ubuntu test\n"
                "    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TST001.001 not supported\n"
                "    Log    ok\n"
            ),
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        violations = lib.find_skip_msg_violations()
        assert len(violations) == 1
        filepath, test_name, own_id = violations[0]
        assert lib.fix_skip_msgs_in_file(filepath, test_name, own_id)
        content = robot_file.read_text()
        assert "TST001.201 not supported" in content
        assert "TST001.001 not supported" not in content

    def test_fix_leaves_correct_id_unchanged(self, tmp_path, monkeypatch):
        robot_file = write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.201 Ubuntu test\n"
                "    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TST001.201 not supported\n"
                "    Log    ok\n"
            ),
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        assert lib.find_skip_msg_violations() == []
        original = robot_file.read_text()
        # Nothing to fix — file should be untouched
        assert (
            lib.fix_skip_msgs_in_file(
                str(robot_file), "TST001.201 Ubuntu test", "TST001.201"
            )
            is False
        )
        assert robot_file.read_text() == original


# ---------------------------------------------------------------------------
# 13. check_id_unique
# ---------------------------------------------------------------------------


class TestCheckIdUnique:
    def test_no_duplicates_returns_empty(self, tmp_path, monkeypatch):
        write_robot(
            tmp_path / "suite.robot",
            ("TST001.201 Test A\n    Log    ok\n" "TST002.201 Test B\n    Log    ok\n"),
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        assert lib.check_id_unique() == {}

    def test_duplicate_within_same_file_detected(self, tmp_path, monkeypatch):
        write_robot(
            tmp_path / "suite.robot",
            (
                "TST001.201 Test A\n    Log    ok\n"
                "TST001.201 Test A duplicate\n    Log    ok\n"
            ),
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        duplicates = lib.check_id_unique()
        assert "TST001.201" in duplicates
        assert len(duplicates["TST001.201"]) == 2

    def test_duplicate_across_files_detected(self, tmp_path, monkeypatch):
        write_robot(
            tmp_path / "suite_a.robot",
            "TST001.201 Test A\n    Log    ok\n",
        )
        write_robot(
            tmp_path / "suite_b.robot",
            "TST001.201 Test A copy\n    Log    ok\n",
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(tmp_path)])
        duplicates = lib.check_id_unique()
        assert "TST001.201" in duplicates
        assert len(duplicates["TST001.201"]) == 2


# ---------------------------------------------------------------------------
# 14. compare_modules_robot_json + fix_modules_in_json
# ---------------------------------------------------------------------------


class TestModulesMatch:
    def test_matching_modules_returns_empty(self, tmp_path, monkeypatch):
        compat_dir = tmp_path / "dasharo-compatibility"
        compat_dir.mkdir()
        write_robot(
            compat_dir / "suite.robot",
            "TST001.201 My test\n    Log    ok\n",
        )
        json_path = tmp_path / "test_cases.json"
        write_json(
            json_path,
            [
                {
                    "_id": "TST001.201",
                    "name": "My test",
                    "module": "Dasharo Compatibility",
                }
            ],
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(compat_dir)])
        mismatches = lib.compare_modules_robot_json(str(json_path))
        assert mismatches == []

    def test_module_mismatch_reported(self, tmp_path, monkeypatch):
        compat_dir = tmp_path / "dasharo-compatibility"
        compat_dir.mkdir()
        write_robot(
            compat_dir / "suite.robot",
            "TST001.201 My test\n    Log    ok\n",
        )
        json_path = tmp_path / "test_cases.json"
        write_json(
            json_path,
            # JSON says Security but robot is in dasharo-compatibility
            [{"_id": "TST001.201", "name": "My test", "module": "Dasharo Security"}],
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(compat_dir)])
        mismatches = lib.compare_modules_robot_json(str(json_path))
        assert len(mismatches) == 1
        tid, robot_mod, json_mod = mismatches[0]
        assert tid == "TST001.201"
        assert robot_mod == "Dasharo Compatibility"
        assert json_mod == "Dasharo Security"

    def test_fix_updates_module_in_json(self, tmp_path, monkeypatch):
        compat_dir = tmp_path / "dasharo-compatibility"
        compat_dir.mkdir()
        write_robot(
            compat_dir / "suite.robot",
            "TST001.201 My test\n    Log    ok\n",
        )
        json_path = tmp_path / "test_cases.json"
        write_json(
            json_path,
            [{"_id": "TST001.201", "name": "My test", "module": "Dasharo Security"}],
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(compat_dir)])
        updated = lib.fix_modules_in_json(str(json_path))
        assert len(updated) == 1
        assert updated[0] == ("TST001.201", "Dasharo Security", "Dasharo Compatibility")
        data = json.loads(json_path.read_text())
        assert data[0]["doc"]["module"] == "Dasharo Compatibility"

    def test_deprecated_entry_not_checked(self, tmp_path, monkeypatch):
        compat_dir = tmp_path / "dasharo-compatibility"
        compat_dir.mkdir()
        write_robot(
            compat_dir / "suite.robot",
            "TST001.202 My test\n    Log    ok\n",
        )
        json_path = tmp_path / "test_cases.json"
        write_json(
            json_path,
            [
                # deprecated entry with wrong module — should not be flagged
                {
                    "_id": "TST001.201",
                    "name": "My test",
                    "module": "Dasharo Security",
                    "changed_to": "TST001.202",
                },
                {
                    "_id": "TST001.202",
                    "name": "My test",
                    "module": "Dasharo Compatibility",
                },
            ],
        )
        monkeypatch.setattr(cfg, "ROBOT_TEST_PATHS", [str(compat_dir)])
        mismatches = lib.compare_modules_robot_json(str(json_path))
        assert mismatches == []
