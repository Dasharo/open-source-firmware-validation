#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import argparse
import json


def load_mappings(mapping_file):
    try:
        with open(mapping_file, "r") as file:
            return json.load(file)
    except json.JSONDecodeError as e:
        print(f"Error loading JSON file: {e}")
        return {}


def map_value(key, value, mappings):
    # Default mappings for 'Y' and 'N'
    default_value_mappings = {"Y": "${TRUE}", "N": "${FALSE}"}
    # Check if there is a specific mapping for the key
    if key in mappings["values"]:
        mapped_value = mappings["values"][key].get(value, None)
        if mapped_value is not None:
            # Special handling for TRUE and FALSE
            if mapped_value == "TRUE":
                return "${TRUE}"
            elif mapped_value == "FALSE":
                return "${FALSE}"
            return mapped_value
        else:
            return default_value_mappings.get(value, value.strip('"'))
    else:
        # Apply default mapping or return original value if not 'Y' or 'N'
        return default_value_mappings.get(value, value.strip('"'))


def list_unmapped_options(input_file, mappings):
    unmapped_options = []
    with open(input_file, "r") as infile:
        for line in infile:
            if "=" in line:
                key, _ = line.strip().split("=", 1)
                if key not in mappings["options"]:
                    unmapped_options.append(key)
    if unmapped_options:
        print("The following options are not included in the lib/mappings.json file:")
        for option in unmapped_options:
            print(f"  - {option}")
        print("\nYou could extend the lib/mappings.json file to include these options.")


def convert_config(input_file, output_file, mappings):
    lines = []
    with open(input_file, "r") as infile:
        for line in infile:
            if "=" in line:
                key, value = line.strip().split("=", 1)
                # Check if there is a mapping for the option name
                if key in mappings["options"]:
                    new_key = mappings["options"][key]
                    # Map the option value with consideration for default mappings and original values
                    new_value = map_value(new_key, value, mappings)
                    lines.append((new_key, new_value))

    # Determine the length of the longest key for alignment
    max_key_length = max(len(f"${{{key}}}") for key, _ in lines)

    with open(output_file, "w") as outfile:
        for key, value in lines:
            formatted_key = f"${{{key}}}"
            padding = " " * (max_key_length - len(formatted_key))
            outfile.write(f"{formatted_key}={padding}                {value}\n")


def main():
    parser = argparse.ArgumentParser(description="Convert config file to new format")
    parser.add_argument("input_file", help="Path to the input configuration file")
    parser.add_argument("output_file", help="Path to the output configuration file")
    parser.add_argument(
        "-m",
        "--mapping-file",
        default="lib/mappings.json",
        help="Path to the mappings JSON file (default: mappings.json)",
    )
    parser.add_argument(
        "--check-unmapped",
        action="store_true",
        help="List options not included in the mappings.json file",
    )

    args = parser.parse_args()

    mappings = load_mappings(args.mapping_file)
    if mappings:
        if args.check_unmapped:
            list_unmapped_options(args.input_file, mappings)
        convert_config(args.input_file, args.output_file, mappings)
    else:
        print("Failed to load mappings. Please check the JSON file.")


if __name__ == "__main__":
    main()
