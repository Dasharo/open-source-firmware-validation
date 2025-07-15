#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

# Default value for autofix flag

import os
import sys

from robot.api import get_model
from robot.api.parsing import Variable, VariableSection

# Define paths
BASE_DIR = "platform-configs"  # Adjust this if needed
INCLUDE_DIR = os.path.join(BASE_DIR, "include")
DEFAULT_ROBOT = os.path.join(INCLUDE_DIR, "default.robot")


def get_defined_variables(file_path):
    """Extract variable names from a Robot Framework file using RF parser."""
    with open(file_path, encoding="utf-8") as f:
        model = get_model(f.read())

    variables = set()
    for section in model.sections:
        if isinstance(section, VariableSection):
            for var in section.body:
                if isinstance(var, Variable):
                    variables.add(var.name)
    return variables


# Step 1: Load default.robot variables
default_variables = get_defined_variables(DEFAULT_ROBOT)

# Step 2: Walk all .robot files and extract additional variable definitions
undefined_variables = {}
all_undefined_vars = set()

for root, _, files in os.walk(BASE_DIR):
    for file in files:
        if not file.endswith(".robot"):
            continue
        path = os.path.join(root, file)
        if path == DEFAULT_ROBOT:
            continue

        file_vars = get_defined_variables(path)
        new_vars = file_vars - default_variables
        if new_vars:
            undefined_variables[path] = new_vars
            all_undefined_vars.update(new_vars)

# Step 3: Print per-file report
if undefined_variables:
    print("⚠️ Variables defined in files but missing in include/default.robot:\n")
    for path, vars in sorted(undefined_variables.items()):
        print(f"{path}:")
        for var in sorted(vars):
            print(f"  {var}")

    if all_undefined_vars:
        print("\n📌 Unique variables to consider adding to include/default.robot:\n")
        print("*** Variables ***\n")
        for var in sorted(all_undefined_vars):
            print(f"{var}=                           ${{TBD}}")
    sys.exit(1)
else:
    print("✅ All variables are defined in include/default.robot.")
