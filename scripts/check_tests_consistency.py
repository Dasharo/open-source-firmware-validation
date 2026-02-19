#!/usr/bin/env python
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json
import os
import re
from pathlib import Path

# Foldery z test suitami
TEST_DIRS = [
    "dasharo-compatibility",
    "dasharo-security",
    "dasharo-performance",
    "dasharo-stability",
]

JSON_FILE = "test_cases.json"

TEST_CASE_REGEX = re.compile(r"^([A-Z]{3}\d{3}\.\d{3})\s+(.+)$")


def collect_robot_tests():
    tests = {}

    for base_dir in TEST_DIRS:
        for path in Path(base_dir).rglob("*.robot"):
            with open(path, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.rstrip()

                    # pomijamy wcięcia (kroki testowe)
                    if line.startswith(" ") or line.startswith("\t"):
                        continue

                    match = TEST_CASE_REGEX.match(line)
                    if match:
                        test_id = match.group(1)
                        title = match.group(2).strip()
                        tests[test_id] = {"title": title, "file": str(path)}

    return tests


def collect_json_tests():
    with open(JSON_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    tests = {}

    for entry in data:
        doc = entry.get("doc", {})
        test_id = doc.get("_id")
        name = doc.get("name")

        if test_id and name:
            tests[test_id] = name.strip()

    return tests


def main():
    robot_tests = collect_robot_tests()
    json_tests = collect_json_tests()

    errors = False

    print("\n=== Sprawdzanie zgodności ===\n")

    # 1️⃣ Testy w .robot ale brak w JSON
    for test_id, info in robot_tests.items():
        if test_id not in json_tests:
            print(f"[BRAK W JSON] {test_id} ({info['file']})")
            errors = True
        else:
            if info["title"] != json_tests[test_id]:
                print(f"[RÓŻNA NAZWA] {test_id}")
                print(f"  .robot : {info['title']}")
                print(f"  .json  : {json_tests[test_id]}")
                errors = True

    # 2️⃣ Testy w JSON ale brak w .robot
    for test_id in json_tests:
        if test_id not in robot_tests:
            print(f"[BRAK W ROBOT] {test_id}")
            errors = True

    if not errors:
        print("✔ Wszystkie testy są zgodne!")

    print("\n=== Koniec ===")


if __name__ == "__main__":
    main()
