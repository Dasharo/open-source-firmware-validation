# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json
import re
from difflib import SequenceMatcher


def drop_brace_contents(s):
    return re.sub(r"\([^()]*\)", "", s)


def similar(a, b):
    a = drop_brace_contents(a.lower().strip())
    b = drop_brace_contents(b.lower().strip())
    if (a in b) or (b in a):
        return 1.0
    return SequenceMatcher(None, a, b).ratio()


old_file = open("old-utc-semiauto.robot")
new_file = open("dasharo-compatibility/usb-type-c.robot")
mappings_file = open("utc-new-ids.json", "w")

old_tests = [line for line in old_file.readlines() if line.startswith("UTC")]
new_tests = [line for line in new_file.readlines() if line.startswith("UTC")]
old_test_names = [" ".join(line.split(" ")[1:]) for line in old_tests]
old_test_ids = [line.split(" ")[0] for line in old_tests]
new_test_names = [" ".join(line.split(" ")[1:]) for line in new_tests]
new_test_ids = [line.split(" ")[0] for line in new_tests]

mappings = {}
for old_idx, old_test_name in enumerate(old_test_names):
    new_idx = [
        idx
        for idx, line in enumerate(new_test_names)
        if similar(line, old_test_name) > 0.8
    ]
    new_names = [new_test_names[idx] for idx in new_idx]
    new_ids = [
        new_test_ids[idx] for idx in new_idx if ".202" not in new_test_ids[idx]
    ]  # Fedora tests are all new
    mappings[old_test_ids[old_idx]] = new_ids

mappings_file.write(json.dumps(mappings, indent=4))
mappings_file.close()
old_file.close()
new_file.close()
