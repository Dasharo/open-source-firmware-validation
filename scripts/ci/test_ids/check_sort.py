#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


import argparse
import json
import sys


def load_json(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        return json.load(f)


def is_sorted_by_id(data):
    ids = [item["doc"]["_id"] for item in data]
    return ids == sorted(ids)


def sort_by_id(data):
    return sorted(data, key=lambda x: x["doc"]["_id"])


def main():
    parser = argparse.ArgumentParser(
        description="Check or fix sorting by _id in JSON file."
    )
    parser.add_argument("file", help="Path to the JSON file")
    parser.add_argument("--fix", action="store_true", help="Fix sorting if not sorted")

    args = parser.parse_args()

    try:
        data = load_json(args.file)
    except Exception as e:
        print(f"Error loading JSON: {e}")
        sys.exit(1)

    if not isinstance(data, list):
        print("Invalid JSON format: expected a list of objects.")
        sys.exit(1)

    if is_sorted_by_id(data):
        print("✅ JSON is sorted by _id.")
    else:
        print("❌ JSON is not sorted by _id.")
        if args.fix:
            sorted_data = sort_by_id(data)
            try:
                with open(args.file, "w", encoding="utf-8") as f:
                    json.dump(sorted_data, f, indent=2)
                    f.write("\n")
                print("✔ JSON has been sorted and saved.")
            except Exception as e:
                print(f"Error writing sorted JSON: {e}")
                sys.exit(1)
        else:
            print("Use --fix to sort and update the file.")


if __name__ == "__main__":
    main()
