#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json
import sys

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} input.json", file=sys.stderr)
    sys.exit(1)

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)


def doc(e):
    return e.get("doc", e)


best, order = {}, []
for e in data:
    _id = doc(e).get("_id")
    if not _id:
        continue
    if _id not in best:
        best[_id] = e
        order.append(_id)
    else:
        if ("changed_to" in doc(e)) and ("changed_to" not in doc(best[_id])):
            best[_id] = e

json.dump([best[i] for i in order], sys.stdout, indent=2, ensure_ascii=False)
