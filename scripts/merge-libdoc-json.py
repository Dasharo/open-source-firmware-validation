#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import copy
import json
import os
import sys


def _keyword_prefix(libdoc):
    source = libdoc.get("source", "")
    return os.path.splitext(os.path.basename(source))[0] + "."


def _read_json(path):
    with open(path, "r", encoding="utf8") as json_file:
        return json.load(json_file)


def main():
    if len(sys.argv) < 4:
        print(
            "Usage: merge-libdoc-json.py <base-json> <output-json> <library-json>...",
            file=sys.stderr,
        )
        return 1

    base_json = sys.argv[1]
    output_json = sys.argv[2]
    library_jsons = sys.argv[3:]

    combined_doc = _read_json(base_json)

    for library_json in library_jsons:
        library_doc = _read_json(library_json)
        prefix = _keyword_prefix(library_doc)
        for keyword in library_doc.get("keywords", []):
            prefixed_keyword = copy.deepcopy(keyword)
            prefixed_keyword["name"] = prefix + prefixed_keyword["name"]
            combined_doc.setdefault("keywords", []).append(prefixed_keyword)

    combined_doc["keywords"].sort(key=lambda keyword: keyword["name"].lower())

    with open(output_json, "w", encoding="utf8") as json_file:
        json.dump(combined_doc, json_file, ensure_ascii=False, indent=2)
        json_file.write("\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
