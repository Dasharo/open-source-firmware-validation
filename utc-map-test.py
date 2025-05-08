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


old_file = (
    open("old-utc.robot").readlines() + open("old-utc-semiauto.robot").readlines()
)
new_file = open("dasharo-compatibility/usb-type-c.robot").readlines()

old_tests = [line for line in old_file if line.startswith("UTC")]
new_tests = [line for line in new_file if line.startswith("UTC")]
old_test_names = [" ".join(line.split(" ")[1:]) for line in old_tests]
old_test_ids = [line.split(" ")[0] for line in old_tests]
new_test_names = [" ".join(line.split(" ")[1:]) for line in new_tests]
new_test_ids = [line.split(" ")[0] for line in new_tests]

new_mappings = json.load(open("utc-new-ids.json", "r"))
i = 0
for old_id in old_test_ids:
    if old_id in new_mappings.keys():
        print(i, end=",")
        # print(old_id)
        i += 1
    else:
        print(old_id)

for new_id in new_test_ids:
    mapped = sum(new_mappings.values(), [])
    if new_id in mapped:
        print(i, end=",")
        # print(new_id)
        i += 1
    elif ".202" not in new_id:
        print(new_id)
