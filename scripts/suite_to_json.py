#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import fileinput
import json
import re
import sys

PATTERN = re.compile(r"^\s*([A-Z]{3,7}\d{3}\.\d{3})\s+(.*\S)\s*$")


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <filename>")
        exit(1)

    path = sys.argv[1]
    path = path.split("/")
    module, file = path[0], path[1]
    module = module.replace("-", " ").title()
    entries = []
    for line in fileinput.input():
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        m = PATTERN.match(s)
        if not m:
            continue
        _id, name = m.groups()
        entry = {"doc": {"_id": _id, "name": name, "module": module}}
        entries.append(entry)

    print(json.dumps(entries, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
